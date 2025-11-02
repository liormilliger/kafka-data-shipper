data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Assuming you want to use the first two available AZs in the region
  az_a = data.aws_availability_zones.available.names[0]
  az_b = data.aws_availability_zones.available.names[1]

  # Recreating the local variables from your original eks.tf
  # It's safer to use the IDs passed in directly.
  private-us-east-1a-id = var.private_subnet_ids[0]
  private-us-east-1b-id = var.private_subnet_ids[1]
  public-us-east-1a-id  = var.public_subnet_ids[0]
  public-us-east-1b-id  = var.public_subnet_ids[1]
}