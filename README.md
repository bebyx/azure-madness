# Artem's Azure Test Project

This is a test project implementing Jenkins, Kubernetes, and sample application in Azure.

## Pre-requisites

- Unix-based OS
- Azure CLI
- Terraform
- Ansible

## Structure

`/iaac` directory holds Terraform code for deploying fundamental infrastructure:
- `/cicd` — Jenkins server in a dedicated virtual machine
- `/k8s` — Azure Kubernetes Service 

`/app` directory source code of a sample Java web application and supplemental files like `Dockerfile` and `Jenkinsfile`.

To deploy the app, Jenkins job will need to pass tests.

## Deploy

### Deploy Jenkins and Kubernetes

Login into Azure:

```bash
az login
```

Go to `/cicd` folder and run Terraform:

```bash
terraform init && terraform apply
```

Once Jenkins is deployed, use VM public IP from the TF output in the web browser. The port is 8080.
Login with username `brew` and auto-generated password uploaded to Azure Key Vault as a secret with name `jenkins-admin-password`.

