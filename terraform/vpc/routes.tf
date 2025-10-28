resource "aws_route_table" "liorm_route_table" {
  vpc_id = aws_vpc.liorm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.liorm_igw.id
  }

  tags = {
    Name = "liorm-route-table"
  }
}

resource "aws_route_table_association" "liorm_public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.liorm_route_table.id
}

resource "aws_route_table_association" "liorm_private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.liorm_route_table.id
}