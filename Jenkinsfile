pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-1'
        S3_BUCKET = 'bg-kar-terraform-state'
        LAMBDA_FUNCTIONS = "lambda1,lambda2,lambda3"
    }

    parameters {
        choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy Terraform resources')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/karthikmp1111/multi-lambda.git'
            }
        }

        stage('Setup AWS Credentials') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_KEY')
                ]) {
                    sh '''
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY
                    aws configure set aws_secret_access_key $AWS_SECRET_KEY
                    aws configure set region $AWS_REGION
                    '''
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
                        if (sh(script: "git diff --quiet HEAD~1 lambda-functions/${lambdaName}", returnStatus: true) != 0) {
                            echo "Changes detected for ${lambdaName}, building and uploading..."
                            sh "bash lambda-functions/${lambdaName}/build.sh"
                            sh "aws s3 cp lambda-functions/${lambdaName}/package.zip s3://$S3_BUCKET/lambda-packages/${lambdaName}/package.zip"
                        } else {
                            echo "No changes detected in ${lambdaName}, skipping build and upload."
                        }
                    }
                }
            }
        }

        stage('Build and Upload Layer Packages') {
            when {
                expression { params.APPLY_OR_DESTROY == 'apply' }
            }
            steps {
                script {
                    def layers = ["layer1", "layer2", "layer3"]
                    layers.each { layerName ->
                        if (sh(script: "git diff --quiet HEAD~1 lambda-layers/${layerName}", returnStatus: true) != 0) {
                            echo "Changes detected for ${layerName}, building and uploading..."
                            sh "bash lambda-layers/${layerName}/build-${layerName}.sh"
                            sh "aws s3 cp lambda-layers/${layerName}/package.zip s3://$S3_BUCKET/lambda-layers/${layerName}/package.zip"
                        } else {
                            echo "No changes detected in ${layerName}, skipping build and upload."
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
                    sh 'terraform apply -auto-approve'
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
