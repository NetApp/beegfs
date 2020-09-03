pipeline {
    agent { label 'solutions_automation' }

    environment {
        BITBUCKET_API_USER = credentials('solutions_automation_ci_username')
        BITBUCKET_API_TOKEN = credentials('solutions_automation_ci_token')
    }

    stages {
        // Note this publishes to the cicd/esola namespace that has a retention policy of 90-days.
        stage('Build/Publish Docker Image (Non-Release Branch)') {
            when { not { branch "release-*" } }
            steps {
                script {
                    docker.withRegistry('https://docker.repo.eng.netapp.com', 'mswbuild-shared-account-cyclict') {
                        def image = docker.build("cicd/esola/ansible:${BRANCH_NAME}.${BUILD_ID}", "--build-arg internal_santricity_collection_url=https://$BITBUCKET_API_USER:$BITBUCKET_API_TOKEN@ict-bitbucket.eng.netapp.com/scm/esola/santricity.git --build-arg internal_host_collection_url=https://$BITBUCKET_API_USER:$BITBUCKET_API_TOKEN@ict-bitbucket.eng.netapp.com/scm/esola/host.git -f docker/Dockerfile ./")
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
                        def image = docker.build("team/esola/ansible:${SEM_VERSION}", "--build-arg internal_santricity_collection_url=https://$BITBUCKET_API_USER:$BITBUCKET_API_TOKEN@ict-bitbucket.eng.netapp.com/scm/esola/santricity.git --build-arg internal_host_collection_url=https://$BITBUCKET_API_USER:$BITBUCKET_API_TOKEN@ict-bitbucket.eng.netapp.com/scm/esola/host.git -f docker/Dockerfile ./")
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
