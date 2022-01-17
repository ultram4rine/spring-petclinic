pipeline {
    agent any

    stages {
        stage('Clone repository') {
            steps {
                git url: 'https://github.com/ultram4rine/spring-petclinic.git'
            }
        }

        stage('Build image') {
            steps {
            sh 'docker build -t ultram4rine/spring-petclinic .'
            }
        }

        stage('Push image') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_TOKEN')
                ]) {
                    sh 'echo ${DOCKERHUB_TOKEN} | docker login -u ${DOCKERHUB_USER} --password-stdin'
                }

                sh 'docker push ultram4rine/spring-petclinic:latest'
            }
        }

        stage('Create petclinic network') {
            steps {
                sh "docker network create petclinic"
            }
        }

        stage('Deploy image locally') {
            steps {
                sh 'docker pull ultram4rine/spring-petclinic'
            }
        }

        stage('Run image') {
            steps {
                sh 'docker run -d --network petclinic --name spring-petclinic -p 8082:8080 -t ultram4rine/spring-petclinic'
            }
        }

        stage('Wait for app actually starts') {
            steps {
                script {
                    def code = sh(script: 'docker container logs spring-petclinic | grep "Tomcat started on port"', returnStatus: true)
                    while (code != 0) {
                        println("waiting...")
                        sleep(3)
                        code = sh(script: 'docker container logs spring-petclinic | grep "Tomcat started on port"', returnStatus: true)
                    }
                }
            }
        }

        stage('cURL container') {
            steps {
                script {
                    def petclinic_ip = sh(script: 'docker inspect -f "{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}" spring-petclinic', returnStdout: true).trim()
                    sh "docker run --network host --rm curlimages/curl -o /dev/null -s -w '%{http_code}\n' http://${petclinic_ip}:8082"
                }
            }
        }
    }

    post { 
        always {
            sh 'docker stop spring-petclinic'
            sh 'docker container rm spring-petclinic'
            sh "docker network rm petclinic"
        }
    }
}