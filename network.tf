# create internet gateway
resource "aws_internet_gateway" "customvpc-gw" {
  vpc_id = aws_vpc.customvpc.id

  tags = {
    "Name" = "customvpc-ig"
  }
}

# create public route table
resource "aws_route_table" "customvpc-r" {
  vpc_id = aws_vpc.customvpc.id

  route {
    cidr_block = "0.0.0.0/0"  # associated subnet can reach everywhere
    gateway_id = aws_internet_gateway.customvpc-gw.id # public RT uses this IGW to reach internet
    egress_only_gateway_id = null
    instance_id = null
    ipv6_cidr_block = null
    local_gateway_id = null
    nat_gateway_id = null
    network_interface_id = null
    transit_gateway_id = null
    vpc_endpoint_id = null
    vpc_peering_connection_id = null
  }

  tags = {
    "Name" = "customvpc-public-r"
  } 
}

# associate public route table and public subnet
resource "aws_route_table_association" "customvpc-public-1-a" {
  subnet_id = aws_subnet.customvpc-public-1.id
  route_table_id = aws_route_table.customvpc-r.id
}

resource "aws_route_table_association" "customvpc-public-2-a" {
  subnet_id = aws_subnet.customvpc-public-2.id
  route_table_id = aws_route_table.customvpc-r.id
}

# create elastic IP
resource "aws_eip" "customvpc-nat" {
  vpc = true

  tags = {
    "Name" = "customvpc-nat"
  }
}

# create NAT gateways
resource "aws_nat_gateway" "customvpc-nat-gw" {
  allocation_id = aws_eip.customvpc-nat.id
  subnet_id = aws_subnet.customvpc-public-1.id
  depends_on = [ aws_internet_gateway.customvpc-gw  ]

  tags = {
    "Name" = "customvpc-nat-gw"
  }
}

# create private route table
resource "aws_route_table" "customvpc-private" {
  vpc_id = aws_vpc.customvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.customvpc-nat-gw.id
    egress_only_gateway_id = null
    instance_id = null
    ipv6_cidr_block = null
    local_gateway_id = null
    nat_gateway_id = null
    network_interface_id = null
    transit_gateway_id = null
    vpc_endpoint_id = null
    vpc_peering_connection_id = null
  }
  tags = {
    "Name" = "customvpc-private"
  }  
}

# associate private route table and private subnet
resource "aws_route_table_association" "customvpc-private-1-a" {
  subnet_id = aws_subnet.customvpc-private-1.id
  route_table_id = aws_route_table.customvpc-private.id
}

resource "aws_route_table_association" "customvpc-private-2-a" {
  subnet_id = aws_subnet.customvpc-private-2.id
  route_table_id = aws_route_table.customvpc-private.id
}