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

output "region" {
  value       = var.region
  description = "The region in wich regional resources resides (subnet, router, nat...)."
}

output "public_subnet_ids" {
  value       = aws_subnet.quortex_public[*].id
  description = "The IDs of the public subnets"
}

output "public_subnet_cidr_blocks" {
  value       = aws_subnet.quortex_public[*].cidr_block
  description = "The CIDR blocks of the public subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.quortex_private[*].id
  description = "The IDs of the private subnets"
}

output "private_subnet_cidr_blocks" {
  value       = aws_subnet.quortex_private[*].cidr_block
  description = "The CIDR blocks of the private subnets"
}

output "vpc_id" {
  value       = aws_vpc.quortex.id
  description = "The ID of the VPC"
}

output "vpc_cidr_block" {
  value       = var.vpc_cidr_block
  description = "The CIDR block of the VPC"
}

output "route_table_ids_public" {
  value       = aws_route_table.quortex_public.*.id
  description = "The IDs of the route tables for public subnets"
}

output "route_table_ids_private" {
  value       = aws_route_table.quortex_private.*.id
  description = "The IDs of the route tables for private subnets"
}

output "nat_eip" {
  value       = aws_eip.quortex.id
  description = "The static Elastic IP created for Quortex cluster External NAT Gateway IP."
}
