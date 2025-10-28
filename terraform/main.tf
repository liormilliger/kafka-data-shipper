module "vpc" {
    source = "./vpc"
    cluster_name = var.cluster_name
    vpc_name = var.vpc_name
    cluster_version = var.cluster_version
    private_subnet_cidrs = var.private_subnet_cidrs
    public_subnet_cidrs = var.public_subnet_cidrs
    vpc_cidr_block = var.vpc_cidr_block
}

module "eks" {
    source = "./eks"
    cluster_name = var.cluster_name
    max_size = var.max_size
    node_name = var.node_name    
    capacity_type = var.capacity_type
    EbsCredSecret = var.EbsCredSecret
    REGION = var.REGION
    ACCOUNT = var.ACCOUNT
    instance_types = var.instance_types
    node_group_name = var.node_group_name
    cluster_version = var.cluster_version
    CredSecret = var.CredSecret
    desired_size = var.desired_size
    private_subnet_ids = module.vpc.private_subnet_ids
    public_subnet_ids = module.vpc.public_subnet_ids

}

module "argocd" {
  source                 = "./argocd"
  config_repo_url         = "git@github.com:liormilliger/mywebsite-k8s.git"
  config-repo-secret-name = "config-repo-private-sshkey"

  
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
  
  depends_on = [module.eks]
}



