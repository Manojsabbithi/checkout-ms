pipeline {
    agent {
        label 'k8s-slave'
    }
    parameters {
        booleanParam(name: 'BUILD', defaultValue: true, description: 'Push the built image to the registry')
        choice(name: 'TARGET_ENV', choices: ['dev', 'test','stage','prod'], description: 'Select the environment to build')
    }
    environment {
        REGISTRY_URL = "docker.io"
        IMAGE_REPOSITORY = "manojdock97/I27-helpdesk-ui"
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
                            env.NEXT_PUBLIC_API_BASE_URL = "http://34.174.72.218:8081"
                            break
                        case 'stage':
                            env.NEXT_PUBLIC_API_BASE_URL = "http://34.174.72.218:8082"
                            break
                        case 'prod':
                            env.NEXT_PUBLIC_API_BASE_URL = "http://34.174.72.218:8083"
                            break
                    }
                    echo "Using Registry: ${env.REGISTRY_URL}"
                    echo "Using Image Repository: ${env.IMAGE_REPOSITORY}"
                    echo "Using Image Tag: ${GIT_COMMIT}"
                    echo " Full Image Tag: ${env.IMAGE_TAG}"
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
    }

}