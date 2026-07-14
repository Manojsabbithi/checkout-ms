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
                echo "Using Registry: ${env.REGISTRY_URL}"
                echo "Using Image Repository: ${env.IMAGE_REPOSITORY}"
                echo "Using Image Tag: ${GIT_COMMIT}"
                echo "printing the env variables"
                echo "REGISTRY_URL: ${env.REGISTRY_URL}"
                echo "IMAGE_REPOSITORY: ${env.IMAGE_REPOSITORY}"
            }
        }
        // stage('Build Docker Image') {
        //     steps {
        //         script {
        //             sh 'docker build -t ${REGISTRY_URL}/${IMAGE_REPOSITORY}:dev --build-arg NEXT_PUBLIC_API_BASE_URL=http://34.174.193.251:8080 .'
        //         }
        //     }
        // }
    }

}
