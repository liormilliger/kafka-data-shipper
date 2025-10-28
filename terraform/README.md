# My Personal Website & Portfolio - Infrastructure

This repository contains the source code for the Infrastructure as Code (Terraform) of my personal portfolio website. It includes modules for provisioning the necessary AWS resources, including the VPC, EKS cluster, and the deployment of ArgoCD.

## 🏛️ Project Architecture

This website is part of a larger cloud-native project, deployed on AWS EKS. The entire infrastructure and deployment pipeline are managed across three dedicated repositories:

* **🌐 [mywebsite-app](https://github.com/liormilliger/mywebsite-app.git):** Contains the Python/Flask application code, HTML/CSS for the frontend, and Docker configuration for containerization.

* **🔧 [mywebsite-k8s](https://github.com/liormilliger/mywebsite-k8s.git):** Holds the Kubernetes deployment files and ArgoCD App-of-Apps manifests for GitOps-based deployment.

* **🏗️ [mywebsite-iac](https://github.com/liormilliger/mywebsite-iac.git) (This Repo):** Includes the Terraform Infrastructure as Code (IaC) to provision the AWS VPC, EKS cluster, and deploy ArgoCD via its Helm chart.

## Terraform Modules

This repository is organized into three main Terraform modules:

### VPC Module

This module is responsible for setting up the networking foundation on AWS. It creates:

* A VPC with a `/16` CIDR block.

* Four subnets, each with a `/24` mask, distributed across two different Availability Zones for high availability (2 public and 2 private).

* An Internet Gateway to allow communication between the VPC and the internet.

* All necessary route tables to control the flow of traffic.
  Each of these components is defined in separate files for better organization and maintainability.

### EKS Module

This module provisions the Amazon EKS (Elastic Kubernetes Service) cluster. It handles the creation of:

* The EKS cluster control plane.

* The required IAM roles and policies that grant the necessary permissions for the cluster to operate and integrate with other AWS services.

* Other essential add-ons and resources required for a fully functional cluster.

### ArgoCD Module

This module automates the installation and configuration of ArgoCD on the EKS cluster. It:

* Deploys the official ArgoCD Helm chart.

* Configures ArgoCD using the "app-of-apps" pattern to manage all subsequent application deployments.

* Sets up the connection to the `mywebsite-k8s` repository by using an SSH key securely stored as a secret in AWS Secrets Manager.

## Required Variables (`terraform.tfvars`)

Please note that a `terraform.tfvars` file is excluded from this repository for security reasons, but it is essential for the deployment of the infrastructure. You will need to create this file in the root of the repository.

Below is the structure of the variables that should be included in your `terraform.tfvars` file. Replace the placeholder values with your specific configuration.

```hcl
### GENERAL ###
REGION = "<your-aws-region>"
ACCOUNT = "<your-aws-account-id>"

### VPC ###
vpc_name = "<your-vpc-name>"
# availability_zone = ""
# az_name = ""
vpc_cidr_block = "<your-vpc-cidr>"
private_subnet_cidrs = ["<private-subnet-1-cidr>", "<private-subnet-2-cidr>"]
public_subnet_cidrs = ["<public-subnet-1-cidr>", "<public-subnet-2-cidr>"]

### CLUSTER ###
EbsCredSecret = "<your-ebs-secret-name>"
CredSecret = "<your-credentials-secret-name>"
cluster_name = "<your-eks-cluster-name>"
cluster_version = "<eks-cluster-version>"

### NODE GROUP ###
node_group_name = "<your-node-group-name>"
capacity_type = "ON_DEMAND"
# instance_types = ["t3.medium", "t3a.medium"]
instance_types = ["<instance-type-1>", "<instance-type-2>"]
max_size = <max-node-count>
desired_size = <desired-node-count>
node_name = "<your-node-name>"