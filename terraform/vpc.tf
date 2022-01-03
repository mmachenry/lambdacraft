resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.main.id
  availability_zone = "us-east-1a"
  cidr_block = "172.31.0.0/20"
}

resource "aws_subnet" "subnet_b" {
  vpc_id     = aws_vpc.main.id
  availability_zone = "us-east-1b"
  cidr_block = "172.31.16.0/20"
}

resource "aws_subnet" "subnet_c" {
  vpc_id     = aws_vpc.main.id
  availability_zone = "us-east-1c"
  cidr_block = "172.31.32.0/20"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

locals {
  subnets = [
    aws_subnet.subnet_a.id, 
    aws_subnet.subnet_b.id,
    aws_subnet.subnet_c.id
  ]
}

resource "aws_route_table_association" "subnet_public_b" {
  count          = length(local.subnets)
  subnet_id      = local.subnets[count.index]
  route_table_id = aws_route_table.public.id
}
