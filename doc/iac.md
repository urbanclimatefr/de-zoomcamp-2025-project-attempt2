# Infrastructure Setup with Terraform
This project uses Terraform to provide cloud resources efficiently. 

This make sures infrastructure as code (IaC) best practices, enabling well-maintained deployments.

## Prerequisites

- Terraform
- Google Cloud SDK (gcloud)
- A GCP Service Account with the required permissions

## Authentication

Authenticate with GCP Service Account:
```
source Terraform/setup.sh
```

## Deploy  Infrastructure

```
cd Terraform
./deployment.sh
```

Remove resources after the project delivery
```
terraform destroy
```
