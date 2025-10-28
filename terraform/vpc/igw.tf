resource "aws_internet_gateway" "liorm_igw" {
  vpc_id = aws_vpc.liorm_vpc.id
  tags = {
    Name = "liorm-igw"
  }
}