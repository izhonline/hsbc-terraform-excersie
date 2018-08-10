provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc-cidr}"
  enable_dns_hostnames = true
}

# Public Subnets
resource "aws_subnet" "subnets" {
  count             = "${length(var.subnets)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.subnets[count.index], "cidr-block")}"
  availability_zone = "${lookup(var.subnets[count.index], "zone")}"
}

resource "aws_route_table" "subnet-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "subnet-route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  route_table_id         = "${aws_route_table.subnet-route-table.id}"
}

resource "aws_route_table_association" "subnet-route-table-association" {
  count          = "${length(var.subnets)}"
  subnet_id      = "${aws_subnet.subnets.*.id}"
  route_table_id = "${aws_route_table.subnet-route-table.id}"
}

# Nginx
resource "aws_instance" "instance" {
  count                       = "${length(var.subnets)}"
  ami                         = "ami-cdbfa4ab"
  instance_type               = "t2.small"
  vpc_security_group_ids      = ["${aws_security_group.security-group.id}"]
  subnet_id                   = "${aws_subnet.subnets.*.id}"
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF

  tags {
    Name = "instance-${count.index}"
  }
}

resource "aws_security_group" "security-group" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress = [
    {
      from_port   = "80"
      to_port     = "80"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = "443"
      to_port     = "443"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = "22"
      to_port     = "22"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "nginx_domain" {
  value = "${aws_instance.instance.*.public_dns}"
}
