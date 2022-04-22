locals {
  public_subnets     = { for k, v in aws_subnet.quortex : k => v if v.map_public_ip_on_launch == true }
  private_subnets    = { for k, v in aws_subnet.quortex : k => v if v.map_public_ip_on_launch == false }
  enable_nat_gateway = var.nat_gateway != null
}
