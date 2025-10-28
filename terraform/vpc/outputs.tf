output "vpc_id" {
    description = "VPC id for liorm_portfolio"
    value = aws_vpc.liorm_vpc.id
}
output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}
output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}