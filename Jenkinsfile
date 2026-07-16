<<<<<<< HEAD
pipeline {
    agent {
        label 'k8s-slave'
    }
    parameters {
        booleanParam(name: 'BUILD', defaultValue: true, description: 'Push the built image to the registry')

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
                    sh 'docker build -t ${env.IMAGE_TAG} --build-arg NEXT_PUBLIC_API_BASE_URL=http://34.174.72.218:8080 .'
                }
            }
        }
    }

}