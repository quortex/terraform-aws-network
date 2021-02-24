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


# VPC
resource "aws_vpc" "quortex" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true # required for using the cluster's private endpoint

  tags = merge(
    map(
      "Name", var.vpc_name,
      "kubernetes.io/cluster/${var.cluster_name}", "shared", # tagged so that Kubernetes can discover it
    ),
    var.tags
  )
  # NOTE: The usage of the specific kubernetes.io/cluster/* resource tags below are required for EKS and Kubernetes to discover and manage networking resources.
}

# Subnets - public
resource "aws_subnet" "quortex_public" {
  count = length(var.subnets_public)

  availability_zone = var.subnets_public[count.index].availability_zone
  cidr_block        = var.subnets_public[count.index].cidr != "" ? var.subnets_public[count.index].cidr : cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, count.index)
  vpc_id            = aws_vpc.quortex.id

  map_public_ip_on_launch = true

  tags = merge(
    map(
      "Name", "${var.subnet_name_prefix}pub-az${count.index}",
      "Public", "true",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
      "kubernetes.io/role/elb", "1" # tagged so that Kubernetes knows to use only those subnets for external load balancers
    ),
    var.tags
  )
}

# Subnets - private
resource "aws_subnet" "quortex_private" {
  count = length(var.subnets_private)

  availability_zone = var.subnets_private[count.index].availability_zone
  cidr_block        = var.subnets_private[count.index].cidr != "" ? var.subnets_private[count.index].cidr : cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, length(var.subnets_public) + count.index)
  vpc_id            = aws_vpc.quortex.id

  tags = merge(
    map(
      "Name", "${var.subnet_name_prefix}priv-az${count.index}",
      "Public", "true",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
      "kubernetes.io/role/internal-elb", "1"
    ),
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "quortex" {
  vpc_id = aws_vpc.quortex.id

  tags = merge({
    Name = var.gateway_name,
    },
    var.tags
  )
}

# Route table for public subnets
resource "aws_route_table" "quortex_public" {
  count = length(aws_subnet.quortex_public)

  vpc_id = aws_vpc.quortex.id

  # Public subnet: add route to Internet GW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.quortex.id
  }

  # Additional route(s) to peered VPC
  dynamic "route" {
    for_each = var.vpc_peering_routes
    content {
      cidr_block                = route.value.cidr_block
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }

  tags = merge({
    Name = var.route_table_name,
    },
    var.tags
  )
}

# Route table for private subnets
resource "aws_route_table" "quortex_private" {
  count = length(aws_subnet.quortex_private)

  vpc_id = aws_vpc.quortex.id

  # Route to the NAT, if NAT is enabled...
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.quortex[var.single_nat_gateway ? 0 : count.index].id
    }
  }

  # ...otherwise, route to the Internet Gateway
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [] : [1]

    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.quortex.id
    }
  }

  # Additional route(s) to peered VPC
  dynamic "route" {
    for_each = var.vpc_peering_routes
    content {
      cidr_block                = route.value.cidr_block
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }

  tags = merge({
    Name = var.route_table_name,
    },
    var.tags
  )
}


# Route table association

resource "aws_route_table_association" "quortex_public" {
  count = length(aws_subnet.quortex_public)

  subnet_id      = aws_subnet.quortex_public.*.id[count.index]
  route_table_id = aws_route_table.quortex_public[count.index].id
}


resource "aws_route_table_association" "quortex_private" {
  count = length(aws_subnet.quortex_private)

  subnet_id      = aws_subnet.quortex_private.*.id[count.index]
  route_table_id = aws_route_table.quortex_private[count.index].id
}


