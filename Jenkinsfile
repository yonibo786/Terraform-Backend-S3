   
def tfCmd(String command, String options = '') {
	ACCESS = "export AWS_PROFILE=default && export TF_ENV_profile=default"
	sh ("cd $WORKSPACE/main && ${ACCESS} && terraform init -migrate-state") // main
	sh ("cd $WORKSPACE/base && ${ACCESS} && terraform init -migrate-state") // base
	sh ("cd $WORKSPACE/main && terraform workspace select ${ENV_NAME} || terraform workspace new ${ENV_NAME}")
	sh ("echo ${command} ${options}") 
        sh ("cd $WORKSPACE/main && ${ACCESS} && terraform init && terraform ${command} ${options} && terraform show -no-color > show-${ENV_NAME}.txt")
}

pipeline {
  agent any

	environment {
		AWS_DEFAULT_REGION = "${params.AWS_REGION}"
		ACTION = "${params.ACTION}"
		PROJECT_DIR = "terraform/main"
  }
	options {
        buildDiscarder(logRotator(numToKeepStr: '30'))
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
  }
	parameters {

		choice (name: 'AWS_REGION',
				choices: ['eu-central-1','us-west-1', 'us-west-2'],
				description: 'Pick A regions defaults to eu-central-1')
		string (name: 'ENV_NAME',
			   defaultValue: 'tf-customer1',
			   description: 'Env or Customer name')
		choice (name: 'ACTION',
				choices: [ 'plan', 'apply', 'destroy'],
				description: 'Run terraform plan / apply / destroy')
    }
	stages {
		stage('Checkout & Environment Prep'){
			steps {
				script {
					wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
						withCredentials([
								[ $class: 'AmazonWebServicesCredentialsBinding',
									accessKeyVariable: 'AWS_ACCESS_KEY_ID',
									secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
									credentialsId: 'tantor',
									]])
							{
							try {
								echo "Setting up Terraform"
								def tfHome = tool name: 'terraform-11',
									type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
									env.PATH = "${tfHome}:${env.PATH}"
									currentBuild.displayName += "[$AWS_REGION]::[$ACTION]"
									tfCmd('version')
							} catch (ex) {
                                                                echo 'Err: Incremental Build failed with Error: ' + ex.toString()
								currentBuild.result = "UNSTABLE"
							}
						}
					}
				}
			}
		}		
		stage('terraform plan') {
			when { anyOf
					{
						environment name: 'ACTION', value: 'plan';
						environment name: 'ACTION', value: 'apply'
					}
				}
			steps {
				dir("${PROJECT_DIR}") {
					script {
						wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
							withCredentials([
								[ $class: 'AmazonWebServicesCredentialsBinding',
									accessKeyVariable: 'AWS_ACCESS_KEY_ID',
									secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
									credentialsId: 'tantor',
									]])
								{
								try {
									tfCmd('plan', '-detailed-exitcode -out=tfplan')
								} catch (ex) {
									if (ex == 2 && "${ACTION}" == 'apply') {
										currentBuild.result = "UNSTABLE"
									} else if (ex == 2 && "${ACTION}" == 'plan') {
										echo "Update found in plan tfplan"
									} else {
										echo "Try running terraform again in debug mode"
									}
								}
							}
						}
					}
				}
			}
		}
		stage('terraform apply') {
			when { anyOf
					{
						environment name: 'ACTION', value: 'apply'
					}
				}
			steps {
				dir("${PROJECT_DIR}") {
					script {
						wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
							withCredentials([
								[ $class: 'AmazonWebServicesCredentialsBinding',
									accessKeyVariable: 'AWS_ACCESS_KEY_ID',
									secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
									credentialsId: 'tantor',
									]])
								{
								try {
									tfCmd('apply', 'tfplan')
								} catch (ex) {
                  currentBuild.result = "UNSTABLE"
								}
							}
						}
					}
				}
			}
			post {
				always {
					archiveArtifacts artifacts: "keys/key-${ENV_NAME}.*", fingerprint: true
					archiveArtifacts artifacts: "main/show-${ENV_NAME}.txt", fingerprint: true
				}
			}
		}
		stage('terraform destroy') {    
			when { anyOf
					{
						environment name: 'ACTION', value: 'destroy';
					}
				}
			steps {
				script {
					def IS_APPROVED = input(
						message: "Destroy ${ENV_NAME} !?!",
						ok: "Yes",
						parameters: [
							string(name: 'IS_APPROVED', defaultValue: 'No', description: 'Think again!!!')
						]
					)
					if (IS_APPROVED != 'Yes') {
						currentBuild.result = "ABORTED"
						error "User cancelled"
					}
				}
				dir("${PROJECT_DIR}") {
					script {
						wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
							withCredentials([
								[ $class: 'AmazonWebServicesCredentialsBinding',
									accessKeyVariable: 'AWS_ACCESS_KEY_ID',
									secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
									credentialsId: 'tantor',
									]])
								{
								try {
									tfCmd('destroy', '-auto-approve')
								} catch (ex) {
									currentBuild.result = "UNSTABLE"
								}
							}
						}
					}
				}
			}
		}	
  	}
}
