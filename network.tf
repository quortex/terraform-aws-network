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

/**
 * - The created subnets are public, but the recommended way would be to create both public and private subnets
 * - AWS requires that at least 2 subnets in different AZ are created.
 */

# VPC
resource "aws_vpc" "quortex" {
  cidr_block = "10.0.0.0/16"


  tags = merge(
    map(
      "Name", "${var.name}",
      "kubernetes.io/cluster/${var.name}", "shared", # tagged so that Kubernetes can discover it
    ),
    var.resource_labels
  )
  # NOTE: The usage of the specific kubernetes.io/cluster/* resource tags below are required for EKS and Kubernetes to discover and manage networking resources.
}

# Subnet (public)
resource "aws_subnet" "quortex_public" {
  count = length(var.availability_zones)

  availability_zone = var.availability_zones[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.quortex.id

  map_public_ip_on_launch = true

  tags = merge(
    map(
      "Name", "${var.name}-public-az${count.index}",
      "Public", "true",
      "kubernetes.io/cluster/${var.name}", "shared",
      "kubernetes.io/role/elb", "1" # tagged so that Kubernetes knows to use only those subnets for external load balancers
    ),
    var.resource_labels
  )
}


# Internet Gateway
resource "aws_internet_gateway" "quortex" {
  vpc_id = aws_vpc.quortex.id

  tags = merge({
      Name = "${var.name}",
    },
    var.resource_labels
  )
}

# Route table
resource "aws_route_table" "quortex" {
  vpc_id = aws_vpc.quortex.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.quortex.id
  }

  tags = merge({
      Name = "${var.name}",
    },
    var.resource_labels
  )
}


# Route table association, for public subnets
resource "aws_route_table_association" "quortex_public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.quortex_public.*.id[count.index]
  route_table_id = aws_route_table.quortex.id
}


