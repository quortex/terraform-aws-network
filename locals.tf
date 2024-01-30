locals {
  public_subnets    = { for k, v in aws_subnet.quortex : k => v if v.map_public_ip_on_launch == true }
  private_subnets   = { for k, v in aws_subnet.quortex : k => v if v.map_public_ip_on_launch == false }
  zoned_gateway_ids = { for k, v in local.public_subnets : v.availability_zone => [for gw in values(aws_nat_gateway.quortex) : gw.id if gw.subnet_id == v.id][0] }
}
