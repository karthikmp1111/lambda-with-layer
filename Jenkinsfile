pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-1'
        S3_BUCKET = 'bg-kar-terraform-state'
        LAMBDA_FUNCTIONS = "lambda1,lambda2,lambda3"
        LAYERS = "layer1,layer2,layer3"
    }

    parameters {
        choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Apply or Destroy')
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

stage('Build & Upload Layers') {
  when {
    expression { params.APPLY_OR_DESTROY == 'apply' }
  }
  steps {
    script {
      def layers = LAYERS.split(',')
      layers.each { layerName ->
        def diffCmd = "git diff --quiet HEAD~1 lambda-layers/${layerName}"
        if (sh(script: diffCmd, returnStatus: true) != 0) {
          echo "Changes detected in ${layerName}, building..."
          sh "bash lambda-layers/${layerName}/build.sh"
          sh "aws s3 cp lambda-layers/${layerName}/layer.zip s3://$S3_BUCKET/lambda-layers/${layerName}/layer.zip"
        } else {
          echo "No changes in ${layerName}"
        }
      }
    }
  }
}

        stage('Build & Upload Lambda Packages') {
            when {
                expression { params.APPLY_OR_DESTROY == 'apply' }
            }
            steps {
                script {
                    def lambdas = LAMBDA_FUNCTIONS.split(',')
                    lambdas.each { lambdaName ->
                        def lambdaPath = "lambda-functions/${lambdaName}"
                        def diffCmd = "git diff --quiet origin/main ${lambdaPath}"
                        if (sh(script: diffCmd, returnStatus: true) != 0) {
                            echo "Changes detected in ${lambdaName}, building and uploading..."
                            try {
                                sh "bash ${lambdaPath}/build.sh"
                                sh "aws s3 cp ${lambdaPath}/package.zip s3://${S3_BUCKET}/lambda-packages/${lambdaName}/package.zip"
                            } catch (Exception err) {
                                error "Failed to build/upload ${lambdaName}: ${err}"
                            }
                        } else {
                            echo "No changes in ${lambdaName}"
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
