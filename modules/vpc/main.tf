# This will create a VPC with 2 public and 2 private subnets
# It will also have 2 route tables; Public and Private  with default routes pointing to IGW or NATGW
# default subnet CIDR for subnet is /24 
# when providing the VPC CIDR please provide a range big enough to get number of az * 2 /24 networks
# creates a Security group to allow web traffic from internet

locals {
  tags = {
    CreatedOn = formatdate("YYYY-MM-DD", timestamp())
  }
}
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.name
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
  Name = format("%s_%s", "IGW", var.your_name) })
}
resource "aws_eip" "natgw_ip" {
  tags = merge(local.tags, {
  Name = format("%s_%s", "NATGW_EIP", var.your_name) })
}

locals {
  subnet_cidrs = [for i in range(length(var.az) * 2) : cidrsubnet(var.cidr_block, local.newbits, i)]
}
resource "aws_subnet" "public_subnets" {
  count             = length(var.az)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_cidrs[count.index]
  availability_zone = var.az[count.index]
  tags              = merge(local.tags, { Name = format("%s_%s_%s", "Public_Subnet", var.your_name, count.index + 1) })
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.az)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_cidrs[count.index + length(var.az)]
  availability_zone = var.az[count.index]
  tags              = merge(local.tags, { Name = format("%s_%s_%s", "Private_Subnet", var.your_name, count.index + 1) })
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw_ip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = merge(local.tags, {
    Name = format("%s_%s", "NATGW", var.your_name)
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.tags, { Name = format("%s_%s", "Public_RT", var.your_name) })
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
  tags = merge(local.tags, { Name = format("%s_%s", "Private_RT", var.your_name) })
}

resource "aws_route_table_association" "public" {
  count          = length(var.az)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.az)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  vpc_id      = aws_vpc.main.id
  description = "Only allow Web traffic from Internet"
  dynamic "ingress" {
    for_each = var.allow_web
    iterator = rule
    content {
      description = rule.value["description"]
      from_port   = rule.value["port"]
      to_port     = rule.value["port"]
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = local.tags
}
