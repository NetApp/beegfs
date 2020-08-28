pipeline {
    agent { label 'solutions_automation' }

    environment {
        BITBUCKET_API_USER = credentials('solutions_automation_ci_username')
        BITBUCKET_API_TOKEN = credentials('solutions_automation_ci_token')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh "docker build -f docker/Dockerfile . -t nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} --build-arg internal_santricity_collection_url=http://repomirror-rtp.eng.netapp.com/ngage/~swartzn/santricity.git --build-arg internal_host_collection_url=https://$BITBUCKET_API_USER:$BITBUCKET_API_TOKEN@ict-bitbucket.eng.netapp.com/scm/em/solutions_automation_host.git"
	            echo "Built/tagged Docker image."
            }
        }

        stage('Execute/Verify Initial Setup Tasks') {
            when { not { branch "MASTER" } }
            steps {
                // To reduce pipeline runtime and as we're not technically testing the SANtricity roles, we'll verify storage is setup and connections established a single time.
                sh "docker run --rm -v '/root/.ssh:/root/.ssh' -v ${WORKSPACE}:/ansible/playbooks nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} -i tests/inventory_ci_testbed.yml tests/playbook_ci_testbed.yml"
            }
        }

        stage('Deploy/Test/Remove CI Config 1') {
            when { not { branch "MASTER" } }
            steps {
                sh "docker run --rm -v '/root/.ssh:/root/.ssh' -v ${WORKSPACE}:/ansible/playbooks nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} -i tests/inventory_config_1.yml tests/playbook_beegfs.yml"
                sh "echo 'Finished deploying config 1.'"
            }

            post {
                always {
                    sh "docker run --rm -v '/root/.ssh:/root/.ssh' -v ${WORKSPACE}:/ansible/playbooks nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} -i tests/inventory_config_1.yml tests/playbook_beegfs.yml --tags=beegfs_uninstall --extra-vars='@tests/remove_var.json'"
                    sh "echo 'Finished removing config 1.'"
                }
            }
        }

        stage('Deploy/Test/Remove CI Config 2') {
            when { not { branch "MASTER" } }
            steps {
                sh "docker run --rm -v '/root/.ssh:/root/.ssh' -v ${WORKSPACE}:/ansible/playbooks nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} -i tests/inventory_config_2.yml tests/playbook_beegfs.yml"
                sh "echo 'Finished deploying config 2.'"
            }

            post {
                always {
                    sh "docker run --rm -v '/root/.ssh:/root/.ssh' -v ${WORKSPACE}:/ansible/playbooks nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} -i tests/inventory_config_2.yml tests/playbook_beegfs.yml --tags=beegfs_uninstall --extra-vars='@tests/remove_var.json'"
                    sh "echo 'Finished removing config 2.'"
                }
            }
        }

        stage('Deploy/Test/Remove CI Config 3') {
            when { not { branch "MASTER" } }
            steps {
                sh "docker run --rm -v '/root/.ssh:/root/.ssh' -v ${WORKSPACE}:/ansible/playbooks nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} -i tests/inventory_config_3.yml tests/playbook_beegfs.yml"
                // sh "docker run --rm -v '/root/.ssh:/root/.ssh' -v ${WORKSPACE}:/ansible/playbooks nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} -i tests/inventory_config_3.yml tests/playbook_test_config_3.yml"
                sh "echo 'Finished deploying config 3.'"
            }

            post {
                always {
                    sh "docker run --rm -v '/root/.ssh:/root/.ssh' -v ${WORKSPACE}:/ansible/playbooks nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} -i tests/inventory_config_3.yml tests/playbook_beegfs.yml --tags=beegfs_uninstall --extra-vars='@tests/remove_var.json'"
                    sh "echo 'Finished removing config 3.'"
                }
            }
        }

        stage('Deploy/Test/Remove CI Config 4') {
            when { not { branch "MASTER" } }
            steps {
                sh "docker run --rm -v '/root/.ssh:/root/.ssh' -v ${WORKSPACE}:/ansible/playbooks nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} -i tests/inventory_config_4.yml tests/playbook_beegfs.yml"
                sh "echo 'Finished deploying config 4.'"
            }

            post {
                always {
                    sh "docker run --rm -v '/root/.ssh:/root/.ssh' -v ${WORKSPACE}:/ansible/playbooks nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID} -i tests/inventory_config_4.yml tests/playbook_beegfs.yml --tags=beegfs_uninstall --extra-vars='@tests/remove_var.json'"
                    sh "echo 'Finished removing config 4.'"
                }
            }
        }
    }

    post {
        always {
            sh "echo 'Removing Docker image and cleaning up build directory.'"
            sh "docker rmi nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID}"
            deleteDir()
        }
    }
}