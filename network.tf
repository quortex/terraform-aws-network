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
  # Note: name is not settable via Terraform

  cidr_block = var.cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true # required for using the cluster's private endpoint

  tags = merge(
    map(
      "Name", "${var.vpc_name}",
      "kubernetes.io/cluster/${var.cluster_name}", "shared", # tagged so that Kubernetes can discover it
    ),
    var.tags
  )
  # NOTE: The usage of the specific kubernetes.io/cluster/* resource tags below are required for EKS and Kubernetes to discover and manage networking resources.
}

# Subnets (master) - public
resource "aws_subnet" "quortex_master" {
  # Note: name is not settable via Terraform
  count = length(var.availability_zones)

  availability_zone = var.availability_zones[count.index]
  cidr_block        = cidrsubnet(var.cidr_block, var.subnet_newbits, count.index)
  vpc_id            = aws_vpc.quortex.id

  map_public_ip_on_launch = true

  tags = merge(
    map(
      "Name", "${var.subnet_name_prefix}ms-az${count.index}",
      "Public", "true",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
      "kubernetes.io/role/elb", "1" # tagged so that Kubernetes knows to use only those subnets for external load balancers
    ),
    var.tags
  )
}

# Subnet (worker) - public
resource "aws_subnet" "quortex_worker" {
  # Note: name is not settable via Terraform
  count = length(var.availability_zones)

  availability_zone = var.availability_zones[count.index]
  cidr_block        = cidrsubnet(var.cidr_block, var.subnet_newbits, length(var.availability_zones) + count.index)
  vpc_id            = aws_vpc.quortex.id

  map_public_ip_on_launch = true

  tags = merge(
    map(
      "Name", "${var.subnet_name_prefix}wk-az${count.index}",
      "Public", "true",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
      "kubernetes.io/role/elb", "1" # tagged so that Kubernetes knows to use only those subnets for external load balancers
    ),
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "quortex" {
  # Note: name is not settable via Terraform
  vpc_id = aws_vpc.quortex.id

  tags = merge({
    Name = "${var.gateway_name}",
    },
    var.tags
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
    Name = "${var.route_table_name}",
    },
    var.tags
  )
}


# Route table association

resource "aws_route_table_association" "quortex_master" {
  count = length(aws_subnet.quortex_master)

  subnet_id      = aws_subnet.quortex_master.*.id[count.index]
  route_table_id = aws_route_table.quortex.id
}

resource "aws_route_table_association" "quortex_worker" {
  count = length(aws_subnet.quortex_worker)

  subnet_id      = aws_subnet.quortex_worker.*.id[count.index]
  route_table_id = aws_route_table.quortex.id
}


