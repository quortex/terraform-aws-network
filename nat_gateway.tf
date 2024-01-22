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


# A static Elastic IP used for Quortex cluster External NAT Gateway IP.
# This resource is created for each nat gateway where no existing EIP is specified.
resource "aws_eip" "quortex" {
  for_each = { for k, v in var.nat_gateways : k => v if v.eip_allocation_id == null }

  tags = merge({ "Name" = "${var.nat_gateway_name_prefix}${each.key}" }, var.tags)
}

# An existing Elastic IP that will be attached to NAT gateways when
# the id is defined. This datasource is used only to display the IP address
data "aws_eip" "existing_eip" {
  for_each = { for k, v in var.nat_gateways : k => v if v.eip_allocation_id != null }

  id = each.value.eip_allocation_id
}

# Nat gateways depending on the list passed in the nat_gateways variable
resource "aws_nat_gateway" "quortex" {
  for_each = { for k, v in var.nat_gateways : k => v if local.public_subnets[v.subnet_key] != null }

  allocation_id = each.value.eip_allocation_id == null ? aws_eip.quortex[each.key].id : data.aws_eip.existing_eip[each.key].id
  subnet_id     = local.public_subnets[each.value.subnet_key].id

  tags = merge({
    "Name" = "${var.nat_gateway_name_prefix}${each.key}"
  }, var.tags)

  depends_on = [aws_internet_gateway.quortex]
}
