pipeline {

    agent any

    options {
        disableConcurrentBuilds()
    }

    environment {
        IMAGE = "orderhub"
        TAG = "${BUILD_NUMBER}"
        CONTAINER = "orderhub-${BUILD_NUMBER}"
        TEST_PORT = "8081"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "========== CHECKOUT =========="

                checkout scm
            }
        }

        stage('Unit Test') {
            steps {
                echo "========== UNIT TEST =========="

                bat "python -m pytest"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "========== DOCKER BUILD =========="

                bat "docker build -t %IMAGE%:%TAG% ."
            }
        }

        stage('Test Docker Image') {
            steps {
                echo "========== DOCKER TEST =========="

                bat """
                    docker run -d ^
                    --name %CONTAINER% ^
                    -p %TEST_PORT%:8080 ^
                    -e BUILD_NUMBER=%BUILD_NUMBER% ^
                    -e GIT_COMMIT=%GIT_COMMIT% ^
                    %IMAGE%:%TAG%
                """

                timeout(time: 60, unit: 'SECONDS') {
                    script {
                        def healthy = false

                        for (int i = 0; i < 12; i++) {

                            def result = bat(
                                script: "curl -s http://localhost:%TEST_PORT%/health",
                                returnStatus: true
                            )

                            if (result == 0) {
                                healthy = true
                                break
                            }

                            sleep 5
                        }

                        if (!healthy) {
                            error("OrderHub health check failed")
                        }
                    }
                }

                bat "curl http://localhost:%TEST_PORT%/health"

                bat "curl http://localhost:%TEST_PORT%/version"
            }
        }

        stage('Push Image') {
            steps {
                echo "========== PUSH IMAGE =========="

                echo "Push step will be connected to Docker Registry credentials."
                echo "Image: %IMAGE%:%TAG%"
            }
        }

        stage('Approval') {
            when {
                branch 'main'
            }

            steps {
                echo "========== PRODUCTION APPROVAL =========="

                input message: 'Deploy this OrderHub image to production?',
                      ok: 'Deploy'
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }

            steps {
                echo "========== DEPLOY =========="

                bat """
                    docker stop orderhub || exit /b 0
                    docker rm orderhub || exit /b 0

                    docker run -d ^
                    --name orderhub ^
                    -p 8080:8080 ^
                    -e APP_VERSION=1.0.0 ^
                    -e BUILD_NUMBER=%BUILD_NUMBER% ^
                    -e GIT_COMMIT=%GIT_COMMIT% ^
                    %IMAGE%:%TAG%
                """
            }
        }

        stage('Smoke Test') {
            when {
                branch 'main'
            }

            steps {
                echo "========== SMOKE TEST =========="

                bat "curl http://localhost:8080/health"

                bat "curl http://localhost:8080/version"
            }
        }
    }

    post {

        always {
            echo "========== CLEANUP =========="

            bat "docker stop %CONTAINER% || exit /b 0"
            bat "docker rm %CONTAINER% || exit /b 0"

            junit allowEmptyResults: true,
                  testResults: '**/test-results/*.xml'

            echo "Build: ${BUILD_NUMBER}"
            echo "Git Commit: ${GIT_COMMIT}"
            echo "Branch: ${BRANCH_NAME}"
            echo "Build URL: ${BUILD_URL}"
        }

        success {
            echo "OrderHub pipeline completed successfully."
        }

        failure {
            echo "OrderHub pipeline FAILED."
        }

        aborted {
            echo "OrderHub pipeline was ABORTED."
        }
    }
}