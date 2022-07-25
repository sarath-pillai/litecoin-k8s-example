pipeline {
  environment {
    registry = "sarathp88/litecoin"
    registryCredential = 'dockerhub'
    dockerImage = ''
  }
  agent any
  stages {
    stage('Building our image') { 
            steps { 
                script { 
                    dockerImage = docker.build registry + ":$GIT_COMMIT" 
                }
            } 
        }
        stage('Deploy our image') { 
            steps { 
                script { 
                    docker.withRegistry( '', registryCredential ) { 
                        dockerImage.push()
                    }
                } 
            }
        } 
        stage('Cleaning up') { 
            steps { 
                sh "docker rmi $registry:$GIT_COMMIT" 
            }
        }
        stage('Deploy to k8s') {
            steps {
                sh "sed -i -e s/IMAGE_TAG_TO_BE_REPLACED_BY_JENKINS/$GIT_COMMIT/g k8s/statefulset.yaml && kubectl apply -f k8s/statefulset.yaml"
            }
        }
   }
}

