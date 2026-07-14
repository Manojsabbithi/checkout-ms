pipeline {
    agent {
        label 'k8s-slave'
    }
    environment {
        REGISTRY_URL = "docker.io"
        IMAGE_REPOSITORY = "manojdock97/I27-helpdesk-ui"
    }
    stages {
        stage ('Prepare Tag') {
            steps {
                env.IMAGE_TAG = env.REGISTRY_URL + "/" + env.IMAGE_REPOSITORY + ":" + GIT_COMMIT
                echo "Using Registry: ${env.REGISTRY_URL}"
                echo "Using Image Repository: ${env.IMAGE_REPOSITORY}"
                echo "Using Image Tag: ${GIT_COMMIT}"
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${env.IMAGE_TAG} --build-arg NEXT_PUBLIC_API_BASE_URL=http://34.174.193.251:8080 .'
                }
            }
        }
    }

}
