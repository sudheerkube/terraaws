# Network Main

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_vpc" "auto_vpc" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "auto_vpc-${random_integer.random.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "auto_public_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.auto_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "auto_public_${count.index + 1}"
  }
}

resource "aws_route_table_association" "auto_public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.auto_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.auto_public_rt.id
}


resource "aws_subnet" "auto_private_subnet" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.auto_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "auto_private_${count.index + 1}"
  }
}

resource "aws_internet_gateway" "auto_igw" {
  vpc_id = aws_vpc.auto_vpc.id

  tags = {
    Name = "Auto_IGW"
  }
}

resource "aws_route_table" "auto_public_rt" {
  vpc_id = aws_vpc.auto_vpc.id

  tags = {
    Name = "Auto_public_RT"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.auto_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.auto_igw.id
}

resource "aws_default_route_table" "auto_private_rt" {
  default_route_table_id = aws_vpc.auto_vpc.default_route_table_id

  tags = {
    Name = "auto_private_rt"
  }
}

resource "aws_security_group" "auto_sg" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.auto_vpc.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {

      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = each.value.name
  }
}

resource "aws_db_subnet_group" "auto_rds_sng" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "auto_rds_sng"
  subnet_ids = aws_subnet.auto_private_subnet.*.id

  tags = {
    Name = "auto_rds_sng"
  }
}