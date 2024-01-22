/**
 * Copyright 2020 Quortex
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

output "vpc_id" {
  value       = aws_vpc.quortex.id
  description = "The ID of the VPC"
}

output "vpc_cidr_block" {
  value       = var.vpc_cidr_block
  description = "The CIDR block of the VPC"
}

output "subnets" {
  value = { for k, v in aws_subnet.quortex : k =>
    {
      id                = v.id,
      availability_zone = v.availability_zone,
      public            = v.map_public_ip_on_launch,
      cidr              = v.cidr_block,
    }
  }
  description = <<EOT
A map representing the subnets that has been created. The keys match those
passed in the subnets variable, each item contains the subnet's ID,
Availability Zone, cidr block, and whether the subnet is public or not.
EOT
}

output "route_table_ids_public" {
  value       = values(aws_route_table.quortex_public)[*].id
  description = "The IDs of the route tables for public subnets"
}

output "route_table_ids_private" {
  value       = values(aws_route_table.quortex_private)[*].id
  description = "The IDs of the route tables for private subnets"
}

output "nat_eip_ids" {
  value       = concat(values(aws_eip.quortex)[*].allocation_id, [for k, v in var.nat_gateways : v.eip_allocation_id if v.eip_allocation_id != null])
  description = "The IDs of the Elastic IPs associated to the Quortex cluster External NAT Gateways."
}

output "nat_eip_addresses" {
  value       = concat(values(aws_eip.quortex)[*].public_ip, values(data.aws_eip.existing_eip)[*].public_ip)
  description = "The public addresses of the Elastic IP associated to the Quortex cluster External NAT Gateways."
}
