provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "instance_key" {
  key_name   = "instance-key"
  public_key = "${file("${var.INSTANCE_PUBLIC_KEY}")}"
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
  depends_on                  = ["aws_instance.bastion"]
  count                       = "${length(var.subnets)}"
  ami                         = "${lookup(var.AMIS, var.region)}"
  instance_type               = "t2.small"
  key_name                    = "${aws_key_pair.instance_key.key_name}"
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
      from_port = "80"
      to_port   = "80"
      protocol  = "tcp"
      self      = true
    },
    {
      from_port = "443"
      to_port   = "443"
      protocol  = "tcp"
      self      = true
    },
    {
      from_port = "22"
      to_port   = "22"
      protocol  = "tcp"
      self      = true
    },
  ]
}

output "nginx_domain" {
  value = "${aws_instance.instance.*.public_dns}"
}
