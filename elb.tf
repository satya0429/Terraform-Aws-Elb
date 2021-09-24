# AWS ELB Config
resource "aws_elb" "custom-elb" {
    name = "custom-elb"
    subnets = [aws_subnet.customvpc-public-1.id,aws_subnet.customvpc-public-2.id]
#    subnets = [aws_subnet.customvpc-public-1.id]
    security_groups = [aws_security_group.custom-elb-sg.id]

    listener {
      instance_port = 80
      instance_protocol = "http"
      lb_port = 80
      lb_protocol = "http"
    }

    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      target = "HTTP:80/"
      interval = 30
    }

    cross_zone_load_balancing = true
    connection_draining = true
    connection_draining_timeout = 400

    tags = {
        Name = "custom-elb"
    }
}

# Security Group for ELB
resource "aws_security_group" "custom-elb-sg" {
    vpc_id = aws_vpc.customvpc.id
    name = "custom-elb-sg"
    description = "security group for ELB"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "custom-elb-sg"
    }
}

# Security Group for instances
#resource "aws_security_group" "custom-instance-sg" {
#    vpc_id = aws_vpc.customvpc.id
#    name = "custom-instance-sg"
#    description = "security group for instance"

#    egress {
#        from_port = 0
#        to_port = 0
#        protocol = "-1"
#        cidr_blocks = ["0.0.0.0/0"]
#    }

#    ingress {
#        from_port = 22
#        to_port = 80
#        protocol = "tcp"
#        security_groups = [aws_security_group.custom-elb-sg.id]
#    }

#    tags = {
#        Name = "custom-instance-sg"
#    }
#}

# create security group
resource "aws_security_group" "custom-instance-sg" {
    vpc_id = aws_vpc.customvpc.id
    name = "custom-instance-sg"
    description = "security group for instance"

  egress = [ {          # outbound rules
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = -1
    to_port = 0
    "ipv6_cidr_blocks" = null,
    "prefix_list_ids" = null,
    "security_groups" = [aws_security_group.custom-elb-sg.id]
    "self" = null,
    "description" = "outbound rules"
  } ]
  ingress = [ {         # inbound rule [ HTTP TCP 80 ]
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = "80"
    protocol = "tcp"
    to_port = "80"
    "ipv6_cidr_blocks" = null,
    "prefix_list_ids" = null,
    "security_groups" = [aws_security_group.custom-elb-sg.id]
    "self" = null,
    "description" = "inbound rules"
  },
  {         # inbound rule [ HTTPS TCP 443 ]
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = "443"
    protocol = "tcp"
    to_port = "443"
    "ipv6_cidr_blocks" = null,
    "prefix_list_ids" = null,
    "security_groups" = [aws_security_group.custom-elb-sg.id]
    "self" = null,
    "description" = "inbound rules"
  },
  {         # inbound rule [ SSH TCP 22 ]
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = "22"
    protocol = "tcp"
    to_port = "22"
    "ipv6_cidr_blocks" = null,
    "prefix_list_ids" = null,
    "security_groups" = [aws_security_group.custom-elb-sg.id]
    "self" = null,
    "description" = "inbound rules"
  },
    {         # inbound rule [ ALl ICMP ]
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = "-1"
    protocol = "icmp"
    to_port = "-1"
    "ipv6_cidr_blocks" = null,
    "prefix_list_ids" = null,
    "security_groups" = [aws_security_group.custom-elb-sg.id]
    "self" = null,
    "description" = "inbound rules"
  }
]
  tags = {
    "Name" = "custom-instance-sg"
  }
}