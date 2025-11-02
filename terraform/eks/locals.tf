data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_a = data.aws_availability_zones.available.names[0]
  az_b = data.aws_availability_zones.available.names[1]

  private-us-east-1a-id = var.private_subnet_ids[0]
  private-us-east-1b-id = var.private_subnet_ids[1]
  public-us-east-1a-id  = var.public_subnet_ids[0]
  public-us-east-1b-id  = var.public_subnet_ids[1]
}