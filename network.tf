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
  cidr_block = "10.0.0.0/16"


  tags = map(
    "Name", "${var.name}",
    "kubernetes.io/cluster/${var.name}", "shared",
  )
  # NOTE: The usage of the specific kubernetes.io/cluster/* resource tags below are required for EKS and Kubernetes to discover and manage networking resources.
}


# Subnet
resource "aws_subnet" "quortex" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.quortex.id

  tags = map(
    "Name", "${var.name}",
    "kubernetes.io/cluster/${var.name}", "shared",
  )
}


# Internet Gateway
resource "aws_internet_gateway" "quortex" {
  vpc_id = aws_vpc.quortex.id

  tags = {
    Name = "${var.name}",
  }
}

# Route table
resource "aws_route_table" "quortex" {
  vpc_id = aws_vpc.quortex.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.quortex.id
  }

  tags = {
    Name = "${var.name}",
  }
}


# Route table association
resource "aws_route_table_association" "quortex" {
  count = 2

  subnet_id      = aws_subnet.quortex.*.id[count.index]
  route_table_id = aws_route_table.quortex.id
}


