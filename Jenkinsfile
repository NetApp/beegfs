pipeline {
    agent { label 'solutions_automation' }

    environment {
        BITBUCKET_API_USER = credentials('solutions_automation_ci_username')
        BITBUCKET_API_TOKEN = credentials('solutions_automation_ci_token')

        SANTRICITY_COLLECTION_URL = "https://${BITBUCKET_API_USER}:${BITBUCKET_API_TOKEN}@ict-bitbucket.eng.netapp.com/scm/esola/santricity.git"
        HOST_COLLECTION_URL = "https://${BITBUCKET_API_USER}:${BITBUCKET_API_TOKEN}@ict-bitbucket.eng.netapp.com/scm/esola/host.git"
        BEEGFS_COLLECTION_URL = "'https://${BITBUCKET_API_USER}:${BITBUCKET_API_TOKEN}@ict-bitbucket.eng.netapp.com/scm/esola/beegfs.git --branch ${BRANCH_NAME}'"
        DEPENDENT_COLLECTIONS_URL = "https://${BITBUCKET_API_USER}:${BITBUCKET_API_TOKEN}@ict-bitbucket.eng.netapp.com/scm/~swartzn/ansible-collections.git"

        BUILD_ARGS = "--build-arg use_local_collection=false " +
                     "--build-arg internal_santricity_collection_url=${SANTRICITY_COLLECTION_URL} " +
                     "--build-arg internal_host_collection_url=${HOST_COLLECTION_URL} " +
                     "--build-arg internal_beegfs_collection_url=${BEEGFS_COLLECTION_URL} " +
                     "--build-arg internal_collection_dependencies_url=${DEPENDENT_COLLECTIONS_URL} -f docker/Dockerfile ."
    }

    stages {
        // Note this publishes to the cicd/esola namespace that has a retention policy of 90-days.
        stage('Build/Publish Docker Image (Non-Release Branch)') {
            when { not { branch "release-*" } }
            steps {
                script {
                    docker.withRegistry('https://docker.repo.eng.netapp.com', 'mswbuild-shared-account-cyclict') {
                        def image = docker.build("cicd/esola/ansible:${BRANCH_NAME}.${BUILD_ID}", "${BUILD_ARGS}")
                        image.push()
                        if (env.BRANCH_NAME == 'master')  {
                                image.push('latest')
                        }
                    }
                }
            }
            post {
                always {
                sh "echo 'Removing Docker image.'"
                sh "docker rmi \$(docker images --filter=reference='*cicd/esola/ansible*' -q) -f"
                sh "docker system prune -f"
                }
            }
        }

        // Note this publishes to the team/esola namespace which allows indefinite storage of images.
        stage('Build/Publish Docker Image (Release Branch)') {
            when { branch "release-*" }
            steps {
                script {
                    docker.withRegistry('https://docker.repo.eng.netapp.com', 'mswbuild-shared-account-cyclict') {
                        def SEM_VERSION = env.BRANCH_NAME.split("-")[1]
                        def image = docker.build("cicd/esola/ansible:${BRANCH_NAME}.${BUILD_ID}", "${BUILD_ARGS}")
                        image.push()
                        image.push('latest')
                    }
                }
            }
            post {
                always {
                sh "echo 'Removing Docker image.'"
                sh "docker rmi \$(docker images --filter=reference='*team/esola/ansible*' -q) -f"
                sh "docker system prune -f"
                }
            }
        }
    }

    post {
        always {
            sh "echo 'Cleaning up build directory.'"
            deleteDir()
        }
    }
}
