locals {
  public_subnets     = { for k, v in aws_subnet.quortex : k => v if v.map_public_ip_on_launch == true }
  private_subnets    = { for k, v in aws_subnet.quortex : k => v if v.map_public_ip_on_launch == false }
  availability_zones = { for k, v in var.nat_gateways : k => local.public_subnets[v.subnet_key].availability_zone if local.public_subnets[v.subnet_key] != null }
}
