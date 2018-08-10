region = "eu-west-1"

vpc-cidr = "10.10.10.0/24"

subnets = [
  {
    zone       = "${var.region}a"
    cidr-block = "10.10.10.0/27"
  },
  {
    zone       = "${var.region}b"
    cidr-block = "10.10.10.32/27"
  },
  {
    zone       = "${var.region}c"
    cidr-block = "10.10.10.64/27"
  },
]
