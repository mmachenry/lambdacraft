resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

# Not sure if we need multiple subnets, as we only ever run at most two VMs
# that should be colocated. However, having two might mean if one zone goes
# down things could migrate to the other AZ (if appropriately configured.)
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.aws_region}a"
  cidr_block              = "172.31.0.0/20"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.aws_region}b"
  cidr_block              = "172.31.16.0/20"
  map_public_ip_on_launch = true
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
  ]
}

resource "aws_route_table_association" "subnet_public_b" {
  count          = length(local.subnets)
  subnet_id      = local.subnets[count.index]
  route_table_id = aws_route_table.public.id
}
