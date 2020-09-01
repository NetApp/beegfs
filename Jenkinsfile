pipeline {
    agent { label 'solutions_automation' }

    environment {
        BITBUCKET_API_USER = credentials('solutions_automation_ci_username')
        BITBUCKET_API_TOKEN = credentials('solutions_automation_ci_token')
    }

    stages {
        stage('Build/Publish Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://docker.repo.eng.netapp.com', 'mswbuild-shared-account-cyclict') {
                        def image = docker.build("cicd/esola/ansible_control:${BRANCH_NAME}.${BUILD_ID}", "--build-arg internal_santricity_collection_url=https://$BITBUCKET_API_USER:$BITBUCKET_API_TOKEN@ict-bitbucket.eng.netapp.com/scm/esola/santricity.git --build-arg internal_host_collection_url=https://$BITBUCKET_API_USER:$BITBUCKET_API_TOKEN@ict-bitbucket.eng.netapp.com/scm/esola/host.git -f docker/Dockerfile ./")
                        image.push()
                    }
                }
            }
        }
    }

    post {
        always {
            sh "echo 'Removing Docker image and cleaning up build directory.'"
            sh "docker rmi cicd/esola/ansible_control:${BRANCH_NAME}.${BUILD_ID}"
            deleteDir()
        }
    }
}
