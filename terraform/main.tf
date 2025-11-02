module "vpc" {
  source               = "./vpc"
  cluster_name         = var.cluster_name
  vpc_name             = var.vpc_name
  cluster_version      = var.cluster_version
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  vpc_cidr_block       = var.vpc_cidr_block
}

module "eks" {
  source              = "./eks"
  cluster_name        = var.cluster_name
  max_size            = var.max_size
  node_name           = var.node_name
  capacity_type       = var.capacity_type
  EbsCredSecret       = var.EbsCredSecret
  REGION              = var.REGION
  ACCOUNT             = var.ACCOUNT
  instance_types      = var.instance_types
  node_group_name     = var.node_group_name
  cluster_version     = var.cluster_version
  CredSecret          = var.CredSecret
  desired_size        = var.desired_size
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids

  # --- ADDED VARIABLES for applications ---
  strimzi_chart_version           = var.strimzi_chart_version
  strimzi_namespace               = var.strimzi_namespace
  kafka_data_shipper_chart_path   = var.kafka_data_shipper_chart_path
  kafka_data_shipper_release_name = var.kafka_data_shipper_release_name
  kafka_data_shipper_namespace    = var.kafka_data_shipper_namespace

  depends_on = [module.vpc]
  
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
    kubectl    = kubectl # Assumes 'kubectl' is the unaliased provider in your root
  }
}

