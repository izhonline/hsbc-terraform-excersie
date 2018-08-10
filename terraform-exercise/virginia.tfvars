region = "us-east-1"

vpc-cidr = "10.0.0.0/24"

subnets = [
  {
    zone       = "${var.region}a"
    cidr-block = "10.1.0.0/27"
  },
  {
    zone       = "${var.region}b"
    cidr-block = "10.2.0.0/27"
  },
  {
    zone       = "${var.region}c"
    cidr-block = "10.3.0.0/27"
  },
  {
    zone       = "${var.region}d"
    cidr-block = "10.4.0.0/27"
  },
  {
    zone       = "${var.region}e"
    cidr-block = "10.5.0.0/27"
  },
  {
    zone       = "${var.region}f"
    cidr-block = "10.6.0.0/27"
  },
]
