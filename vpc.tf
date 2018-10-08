module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 1.45.0"

  name = "${var.resource_prefix}"
  cidr = "${var.cidr}"

  azs            = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}c"]
  public_subnets = ["${var.public_subnet_cidr_1}", "${var.public_subnet_cidr_2}"]

  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_vpn_gateway               = false
  enable_nat_gateway               = false
  enable_dhcp_options              = true
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS", "8.8.8.8", "8.8.4.4"]

  tags = {
    Name = "${var.resource_prefix}"
  }
}
