resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = "${file("${var.BASTION_PUBLIC_KEY}")}"
}

resource "aws_instance" "bastion" {
  ami                         = "${lookup(var.AMIS, var.region)}"
  instance_type               = "t2.small"
  key_name                    = "${aws_key_pair.bastion_key.key_name}"
  security_groups             = ["${aws_security_group.bastion-sg.name}"]
  associate_public_ip_address = true

  tags {
    Name = "${var.region}-bastion"
  }
}

resource "aws_security_group" "bastion-sg" {
  name        = "bastion-security-group"
  description = "Allow access from network to instances"
  vpc_id      = "${aws_vpc.vpc.id}"

  # SSH

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.vpc-cidr}"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_allow" {
  name        = "allow_bastion_ssh"
  description = "allow access from bastion host"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion-sg.id}"]
    self            = false
  }
}

output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
