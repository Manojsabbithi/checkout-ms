def deploytoEnv(String namespace) {
    sh """
    echo "*************************** Deploying to ${namespace} Environment *************************** "
    echo "Deploying to namespace: ${namespace}"
    kubectl get pods -n ${namespace}
    sed -i "s|{NAMESPACE}|${namespace}|g" k8s/*.yaml
    sed -i "s|{IMAGE_NAME}|${env.IMAGE_REPOSITORY}|g" k8s/*.yaml
    sed -i "s|{IMAGE_TAG}|${GIT_COMMIT}|g" k8s/*.yaml
    echo "Applying Kubernetes manifests..."
    kubectl apply -f k8s/
    echo "Deployment completed."
    """
}
def GKEAuth(String clusterName, String clusterZone, String projectId) {
    sh """
    echo "*************************** GKE Auth *************************** "
    gcloud container clusters get-credentials ${clusterName} --zone ${clusterZone} --project ${projectId}
    echo "*************************** GKE Auth Completed *************************** "
    kubectl get nodes
    """
}
pipeline {
    agent {
        label 'k8s-slave'
    }
    parameters {
        booleanParam(name: 'BUILD', defaultValue: true, description: 'Push the build image to the registry')
        choice(name: 'TARGET_ENV', choices: ['dev', 'test','stage','prod'], description: 'Select the environment to build')
        booleanParam(name: 'SKIP_SONAR', defaultValue: true, description: 'Skip the tests during build')
    }
    environment {
        REGISTRY_URL = "docker.io"
        IMAGE_REPOSITORY = "manojdock97/jenkins-test"

        REGISTRY_CREDENTIALS_ID = credentials('docker-crendetials')

        DEV_CLUSTER_NAME = "np-cluster"
        DEV_CLUSTER_ZONE = "us-east4-a"
        DEV_PROJECT_ID = "project-cdc0b247-e969-48dc-823"

        TEST_CLUSTER_NAME = "np-cluster"
        TEST_CLUSTER_ZONE = "us-east4-a"
        TEST_PROJECT_ID = "project-cdc0b247-e969-48dc-823"

        STAGE_CLUSTER_NAME = "np-cluster"
        STAGE_CLUSTER_ZONE = "us-east4-a"
        STAGE_PROJECT_ID = "project-cdc0b247-e969-48dc-823"

        PROD_CLUSTER_NAME = "np-cluster"
        PROD_CLUSTER_ZONE = "us-east4-a"
        PROD_PROJECT_ID = "project-cdc0b247-e969-48dc-823"
    }
    stages {
        stage ('Prepare Tag') {
            when {
                expression {
                    return params.BUILD
                }
            }
            steps {
                script {
                    env.IMAGE_TAG = env.REGISTRY_URL + "/" + env.IMAGE_REPOSITORY + ":" + GIT_COMMIT

                    switch (params.TARGET_ENV) {
                        case 'dev':
                            env.NEXT_PUBLIC_API_BASE_URL = "http://34.174.72.218:8080"
                            break
                        case 'test':
                            env.NEXT_PUBLIC_API_BASE_URL = "http://test-gateway.i27helpdesk.in"
                            break
                        case 'stage':
                            env.NEXT_PUBLIC_API_BASE_URL = "http://stage-gateway.i27helpdesk.in"
                            break
                        case 'prod':
                            env.NEXT_PUBLIC_API_BASE_URL = "http://prod-gateway.i27helpdesk.in"
                            break
                    }
                    echo "Using Registry: ${env.REGISTRY_URL}"
                    echo "Using Image Repository: ${env.IMAGE_REPOSITORY}"
                    echo "Using Image Tag: ${GIT_COMMIT}"
                    echo " Full Image Tag: ${env.IMAGE_TAG}"
                }
            }
        }
        stage('SonarQube Analysis') {
            when {
                expression {
                    return params.BUILD && !params.SKIP_SONAR
                }
            }
            steps {
                script {
                    def scannerHome = tool 'SonarQubeScanner'
                    withSonarQubeEnv('sonarqube') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
        stage('Quality Gate') {
            when {
                expression {
                    return params.BUILD && !params.SKIP_SONAR
                }
            }
            steps {
                script {
                    timeout(time: 1, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                        }
                    }
                }
        }
        stage('Build Docker Image') {
            when {
                expression {
                    return params.BUILD
                }
            }
            steps {
                script {
                    sh "docker build -t ${env.IMAGE_TAG} --build-arg NEXT_PUBLIC_API_BASE_URL=${env.NEXT_PUBLIC_API_BASE_URL} ."
                }
            }
        }
        stage('Push Docker Image') {
            when {
                expression {
                    return params.BUILD
                }
            }
            steps {
                script {
                    // should create dockerhub-credentials in jenkins with username - manojsabbithi9@gmail.com and password Manoj1997! of dockerhub
                    echo "*************************** Docker Login *************************** "
                    sh "docker login -u ${env.REGISTRY_CREDENTIALS_ID_USR} -p ${env.REGISTRY_CREDENTIALS_ID_PSW} ${env.REGISTRY_URL}"
                    echo "*************************** Docker Push *************************** "
                    sh "docker push ${env.IMAGE_TAG}"
                    }
                }
        }
        // stage('GKE Auth') {
        //     when {
        //         expression {
        //             return params.TARGET_ENV == 'dev'
        //         }
        //     }
        //     steps {
        //         script {
        //             sh """
        //             echo "*************************** GKE Auth *************************** "
        //             gcloud container clusters get-credentials ${DEV_CLUSTER_NAME} --zone ${DEV_CLUSTER_ZONE} --project ${DEV_PROJECT_ID}
        //             echo "*************************** GKE Auth Completed *************************** "
        //             kubectl get nodes
        //             """
        //         }
        //     }
        // }
        stage('DeployToDevEnvironment') {
            when {
                expression {
                    return params.BUILD && params.TARGET_ENV == 'dev'
                }
            }
            steps {
                script {
                    GKEAuth("${DEV_CLUSTER_NAME}", "${DEV_CLUSTER_ZONE}", "${DEV_PROJECT_ID}")
                    deploytoEnv("i27-helpdesk-dev")
                }
            }
        }
        stage('DeployToTestEnvironment') {
            when {
                expression {
                    return params.BUILD && params.TARGET_ENV == 'test'
                }
            }
            steps {
                script {
                    GKEAuth("${TEST_CLUSTER_NAME}", "${TEST_CLUSTER_ZONE}", "${TEST_PROJECT_ID}")
                    deploytoEnv("i27-helpdesk-test")
                }
            }
        }
        stage('DeployToStageEnvironment') {
            when {
                allOf {
                    expression {
                        return params.BUILD && params.TARGET_ENV == 'stage'
                    }
                    anyOf {
                        branch ('release/*')
                        tag pattern: 'v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}', comparator: 'REGEXP'
                    }
                }
                
            }
            steps {
                script {
                    GKEAuth("${STAGE_CLUSTER_NAME}", "${STAGE_CLUSTER_ZONE}", "${STAGE_PROJECT_ID}")
                    deploytoEnv("i27-helpdesk-stage")
                }
    
            }
        }
        stage('DeployToProdEnvironment') {
            when {
                allOf {
                    expression {
                        return params.BUILD && params.TARGET_ENV == 'prod'
                    }
                    anyOf {
                        tag pattern: 'v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}', comparator: 'REGEXP'
                    }
                }
            }
            steps {
                script {
                    GKEAuth("${PROD_CLUSTER_NAME}", "${PROD_CLUSTER_ZONE}", "${PROD_PROJECT_ID}")
                    deploytoEnv("i27-helpdesk-prod")
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo "Build completed successfully."
        }
        failure {
            echo "Build failed."   
        }
    }
}