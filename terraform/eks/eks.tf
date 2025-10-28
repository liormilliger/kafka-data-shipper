# -----------------------------------------------------------------------------
# EKS Cluster IAM Role (For EKS Control Plane Only)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "eks-cluster-iam-role" {
  name = "${var.cluster_name}-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = {
    provisioned_by = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-iam-role.name
}

# -----------------------------------------------------------------------------
# EKS Cluster Definition
# -----------------------------------------------------------------------------
resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster-iam-role.arn

  tags = {
    provisioned_by = "Terraform"
  }

  lifecycle {
    ignore_changes = [tags]
  }

  vpc_config {
    subnet_ids = [
      local.private-us-east-1a-id,
      local.private-us-east-1b-id,
      local.public-us-east-1a-id,
      local.public-us-east-1b-id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks-cluster-policy]
}

# -----------------------------------------------------------------------------
# OIDC Provider for IAM Roles for Service Accounts (IRSA)
# -----------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer

  tags = {
    Name = "oidc-provider-${replace(aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")}"
  }
}

data "tls_certificate" "eks_cluster_cert" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

# -----------------------------------------------------------------------------
# IAM Role for AWS Load Balancer Controller
# -----------------------------------------------------------------------------
resource "aws_iam_role" "liorm-alb-controller-role" {
  name = "${var.cluster_name}-alb-role"

  # This trust policy is CRITICAL. It allows the K8s service account to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    provisioned_by = "Terraform"
  }
}

# CORRECT: Attach the liormALB policy to the ALB controller's role
resource "aws_iam_role_policy_attachment" "liorm-alb-controller-policy-attachment" {
  policy_arn = "arn:aws:iam::704505749045:policy/liormALB"
  role       = aws_iam_role.liorm-alb-controller-role.name
}
