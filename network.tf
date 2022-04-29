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
    {
      "Name"                                      = var.vpc_name,
      "kubernetes.io/cluster/${var.cluster_name}" = "shared", # tagged so that Kubernetes can discover it
    },
    var.tags
  )
  # NOTE: The usage of the specific kubernetes.io/cluster/* resource tags below are required for EKS and Kubernetes to discover and manage networking resources.
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  for_each   = var.vpc_secondary_cidrs
  vpc_id     = aws_vpc.quortex.id
  cidr_block = each.value
}

resource "aws_subnet" "quortex" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.quortex.id
  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = each.value.public

  tags = merge(
    {
      "Name"                                      = "${var.subnet_name_prefix}${each.key}",
      "Public"                                    = "true",
      "kubernetes.io/cluster/${var.cluster_name}" = "shared",
    },
    each.value.public ? {
      "kubernetes.io/role/elb" = "1" # tagged so that Kubernetes knows to use only those subnets for external load balancers
      } : {
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.tags
  )

  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]
}

# Internet Gateway
resource "aws_internet_gateway" "quortex" {
  vpc_id = aws_vpc.quortex.id

  tags = merge({
    Name = var.internet_gateway_name,
    },
    var.tags
  )
}

# Route table for public subnets
resource "aws_route_table" "quortex_public" {
  for_each = local.public_subnets

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

  # Additional route(s) to a VPC internet gateway or a virtual private gateway.
  dynamic "route" {
    for_each = var.gateway_routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = route.value.gateway_id
    }
  }

  tags = merge({ "Name" = "${var.route_table_prefix}${each.key}" }, var.tags)
}

# Route table for private subnets
resource "aws_route_table" "quortex_private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.quortex.id

  # Route to the NAT, if NAT is enabled...
  dynamic "route" {
    for_each = local.enable_nat_gateway ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.quortex.0.id
    }
  }

  # ...otherwise, route to the Internet Gateway
  dynamic "route" {
    for_each = local.enable_nat_gateway ? [] : [1]

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

  # Additional route(s) to a VPC internet gateway or a virtual private gateway.
  dynamic "route" {
    for_each = var.gateway_routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = route.value.gateway_id
    }
  }

  tags = merge({ "Name" = "${var.route_table_prefix}${each.key}" }, var.tags)
}


# Route table association

resource "aws_route_table_association" "quortex_public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.quortex[each.key].id
  route_table_id = aws_route_table.quortex_public[each.key].id
}


resource "aws_route_table_association" "quortex_private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.quortex[each.key].id
  route_table_id = aws_route_table.quortex_private[each.key].id
}


