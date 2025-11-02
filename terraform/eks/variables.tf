variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "REGION" {
  description = "AWS region where the resources will be deployed."
  type        = string
}

variable "ACCOUNT" {
  description = "AWS account ID."
  type        = string
}

variable "CredSecret" {
  description = "Name of the AWS credentials secret."
  type        = string
}

variable "EbsCredSecret" {
  description = "Name of the EBS CSI driver secret."
  type        = string
}

variable "strimzi_chart_version" {
  description = "Version of the Strimzi Kafka Operator Helm chart."
  type        = string
}

variable "strimzi_namespace" {
  description = "Namespace to install the Strimzi Kafka Operator into."
  type        = string
}

variable "kafka_data_shipper_chart_path" {
  description = "Path to the kafka-data-shipper Helm chart."
  type        = string
}

variable "kafka_data_shipper_release_name" {
  description = "Helm release name for the kafka-data-shipper app."
  type        = string
}

variable "kafka_data_shipper_namespace" {
  description = "Namespace to install the kafka-data-shipper app into."
  type        = string
}

####< NETWORK VARS >####
locals {
  private-us-east-1a-id = var.private_subnet_ids[0]
  private-us-east-1b-id = var.private_subnet_ids[1]
  public-us-east-1a-id  = var.public_subnet_ids[0]
  public-us-east-1b-id  = var.public_subnet_ids[1]
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs from the VPC module."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs from the VPC module."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs from the VPC module."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs from the VPC module."
  type        = list(string)
}

####< NODE VARS >####

variable "node_group_name" {
  description = "Name of the EKS node group."
  type        = string
}

variable "capacity_type" {
  description = "Capacity type for the node group (e.g., ON_DEMAND, SPOT)."
  type        = string
}

variable "instance_types" {
  description = "List of instance types for the node group."
  type        = list(string)
}

variable "max_size" {
  description = "Maximum number of nodes in the node group."
  type        = number
}

variable "desired_size" {
  description = "Desired number of nodes in the node group."
  type        = number
}

variable "node_name" {
  description = "Base name for the EKS nodes."
  type        = string
}

