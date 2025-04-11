pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-1'
        S3_BUCKET = 'bg-kar-terraform-state'
        LAMBDA_FUNCTIONS = "lambda1,lambda2,lambda3"
        LAYERS = "layer1,layer2,layer3"
    }

    parameters {
        choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy Terraform resources')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/karthikmp1111/lambda-with-layer.git'
            }
        }

        stage('Setup AWS Credentials') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_KEY')
                ]) {
                    sh '''
                        mkdir -p ~/.aws
                        cat > ~/.aws/credentials <<-EOL
                        [default]
                        aws_access_key_id=$AWS_ACCESS_KEY
                        aws_secret_access_key=$AWS_SECRET_KEY
                        region=$AWS_REGION
                        EOL
                    '''
                }
            }
        }

        stage('Build and Upload Lambda Layers') {
            when {
                expression { params.APPLY_OR_DESTROY == 'apply' }
            }
            steps {
                script {
                    def layers = LAYERS.split(',')
                    layers.each { layer ->
                        def layerPath = "lambda-layers/${layer}"
                        if (sh(script: "git diff --quiet HEAD~1 ${layerPath}", returnStatus: true) != 0) {
                            echo "Changes detected in ${layer}, building and uploading..."
                            sh "bash ${layerPath}/build.sh"
                            sh "aws s3 cp ${layerPath}/layer.zip s3://${S3_BUCKET}/lambda-layers/${layer}/layer.zip"
                        } else {
                            echo "No changes detected in ${layer}, skipping build and upload."
                        }
                    }
                }
            }
        }

        stage('Build and Upload Lambda Packages') {
            when {
                expression { params.APPLY_OR_DESTROY == 'apply' }
            }
            steps {
                script {
                    def lambdas = LAMBDA_FUNCTIONS.split(',')
                    lambdas.each { lambdaName ->
                        def lambdaPath = "lambda-functions/${lambdaName}"
                        if (sh(script: "git diff --quiet HEAD~1 ${lambdaPath}", returnStatus: true) != 0) {
                            echo "Changes detected for ${lambdaName}, building and uploading..."
                            sh "bash ${lambdaPath}/build.sh"
                            sh "aws s3 cp ${lambdaPath}/package.zip s3://${S3_BUCKET}/lambda-packages/${lambdaName}/package.zip"
                        } else {
                            echo "No changes detected in ${lambdaName}, skipping build and upload."
                        }
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.APPLY_OR_DESTROY == 'apply' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.APPLY_OR_DESTROY == 'destroy' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
    }
}
