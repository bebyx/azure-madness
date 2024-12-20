# Artem's Azure Test Project

This is a test project implementing Jenkins, Kubernetes, and sample application in Azure.

## Pre-requisites

- Unix-based OS
- Azure CLI
- Terraform
- Ansible
- Docker (optional for running app locally)

## Structure

`/iaac` directory holds Terraform code for deploying fundamental infrastructure:
- `/cicd` — Jenkins server in a dedicated virtual machine
- `/k8s` — Azure Kubernetes Service 

`/app` directory source code of a sample Java web application and supplemental files like `Dockerfile` and `Jenkinsfile`.

## Infra

### Deploy Jenkins and Kubernetes

Login into Azure:

```bash
az login
```

Go to `/iaac` folder and run Terraform:

```bash
terraform init && terraform apply
```

Once Jenkins is deployed, it should be available under URL: http://jenkins.artem-bebik.com:8080.
Login with username `brew` and auto-generated password uploaded to common Azure Key Vault as a secret with name `jenkins-admin-password`.

## App

### Run locally

You can run the app locally in Docker. Just go to `/app` and build the image:

```bash
docker build -t spring-boot-app .
```

And then run it:

```bash
docker run -d -p 8080:8080 spring-boot-app
```

The website will be available under http://localhost:8080.

### Deploy to AKS with Jenkins

Jenkins should create the `app` deployment job upon provision.
In case needed to create the job manually, make sure to create Jenkins Pipeline with the proper Jenkinsfile path: `app/Jenkinsfile`.

Run the job and let it finish. Wait a minute or so for cert to be created. Check at https://app.artem-bebik.com.
