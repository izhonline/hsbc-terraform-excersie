variable "region" {}

variable "AMIS" {
  type = "map"

  default = {
    eu-west-1 = "ami-cdbfa4ab"
    us-east-1 = "ami-48cce137"
  }
}

variable "vpc-cidr" {}

variable "subnets" {
  type = "list"
}

variable "INSTANCE_PRIVATE_KEY" {
  default = "instance-key"
}

variable "INSTANCE_PUBLIC_KEY" {
  default = "instance-key.pub"
}

variable "BASTION_PRIVATE_KEY" {
  default = "bastion-key"
}

variable "BASTION_PUBLIC_KEY" {
  default = "bastion-key.pub"
}

variable "bastion_uid" {
  default = "admin"
}
