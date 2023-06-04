resource "random_id" "id" {
  byte_length = 4
}

//Non default virtual private cloud
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${random_id.id.hex}-vpc"
    Profile = "${random_id.id.hex}"
  }
}

// Internet gateway for the public subnet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${random_id.id.hex}-igw"
    Profile = "${random_id.id.hex}"
  }
}

// Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = element(var.availability_zones, count.index % length(var.availability_zones))
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${random_id.id.hex}"
    Profile = "${random_id.id.hex}"

  }
}


// Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = var.private_subnets_cidr[count.index]
  availability_zone       = element(var.availability_zones, count.index % length(var.availability_zones))
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${random_id.id.hex}"
    Profile = "${random_id.id.hex}"
  }
}

// Routing table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${random_id.id.hex}-private-route-table"
    Profile = "${random_id.id.hex}"
  }
}

// Routing table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${random_id.id.hex}-public-route-table"
    Profile = "${random_id.id.hex}"
  }
}

//Public internet gateway for public route table
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.public_route_table_id
  gateway_id             = aws_internet_gateway.ig.id
}

// Route table association for public subnets to public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

// Route table association for private subnets to public route table
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
  
output "public_subnet_id" {
  value = aws_subnet.public_subnet[*].id
  
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet[*].id
}
