# Create AWS VPC
resource "aws_vpc" "customvpc" {
  cidr_block = "172.25.0.0/16"
  enable_dns_support = "true" # provides internal domain name
  enable_dns_hostnames = "true" # provides internal host name
  enable_classiclink = "false"
  instance_tenancy = "default" #  VPC will be created on shared resources
  tags = {
    "Name" = "customvpc"
  }
}

# Create subnets in the custom VPC
resource "aws_subnet" "customvpc-public-1" {
  vpc_id = aws_vpc.customvpc.id
  cidr_block = "172.25.2.0/24"
  map_public_ip_on_launch = "true"  # it makes this a external/public subnet
  availability_zone = "us-east-2a"

  tags = {
      "Name" = "customvpc-public-1"
  }
}

resource "aws_subnet" "customvpc-public-2" {
  vpc_id = aws_vpc.customvpc.id
  cidr_block = "172.25.3.0/24"
  map_public_ip_on_launch = "true"  # it makes this a external/public subnet
  availability_zone = "us-east-2b"

  tags = {
      "Name" = "customvpc-public-2"
  }
}

resource "aws_subnet" "customvpc-private-1" {
  vpc_id = aws_vpc.customvpc.id
  cidr_block = "172.25.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-2a"

  tags = {
      "Name" = "customvpc-private-1"
  }
}

resource "aws_subnet" "customvpc-private-2" {
  vpc_id = aws_vpc.customvpc.id
  cidr_block = "172.25.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-2b"

  tags = {
      "Name" = "customvpc-private-2"
  }
}