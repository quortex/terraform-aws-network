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
resource "aws_eip" "quortex" {
  vpc   = true

  tags = merge(map("Name", "${var.eip_name}",),var.tags)
}

# A single NAT gateway is used for all subnets (NAT gateway is placed in the 1st subnet),
# or, one NAT gateway in each subnet 
resource "aws_nat_gateway" "quortex" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(aws_subnet.quortex_worker)) : 0

  allocation_id = aws_eip.quortex.id # can a single EIP be associated to more than 1 NAT gateway ?
  subnet_id = aws_subnet.quortex_worker[count.index].id

  tags = merge(map("Name", "${var.nat_gw_name}-wk${count.index}",),var.tags)

  depends_on = [aws_internet_gateway.quortex]
}


#
# General info about NAT gateways on AWS:
#   https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
#
# Terraform resources doc:
#   EIP: https://www.terraform.io/docs/providers/aws/r/eip.html
#   NAT Gateway: https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
