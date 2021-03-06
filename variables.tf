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

variable "vpc_name" {
  type        = string
  description = "Name for the VPC resource. Will be in the Name tag of the VPC instead of the actual resource name, since the resource name cannot be set via Terraform."
  default     = "quortex"
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster. Will be used to set the kubernetes.io/cluster/<cluster-name> tag on the VPC and subnets. It is required for Kubernetes to discover them."
}

variable "subnet_name_prefix" {
  type        = string
  description = "A prefix for the name of the subnets."
  default     = "quortex-"
}

variable "gateway_name" {
  type        = string
  description = "Name for the gateway resource"
  default     = "quortex"
}

variable "route_table_name" {
  type        = string
  description = "Name for the route table resource"
  default     = "quortex"
}

variable "nat_gw_name" {
  type        = string
  description = "Name for the NAT gateway resource"
  default     = "quortex"
}

variable "eip_name" {
  type        = string
  description = "Name for the Elastic IP resource"
  default     = "quortex"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_newbits" {
  type        = number
  description = "The number of bits to add to the VPC CIDR block for obtaining the subnet CIDR blocks. Used when subnets cidr are not specified."
  default     = 4
}

variable "subnets_private" {
  type        = list(object({ availability_zone = string, cidr = string }))
  description = "A list representing the subnets that must be created for the master. Each item must specify the subnet's availability zone and cidr block. The cidr block can empty, in this case the subnet will be computed based on the VPC range, the index in the array, using 4 bits (or as defined by subnet_newbits) for the subnet number, thus allowing 16 subnets. Amazon EKS requires at least 2 subnets in different Availability Zones"
}

variable "subnets_public" {
  type        = list(object({ availability_zone = string, cidr = string }))
  description = "A list representing the subnets that must be created. Each item must specify the subnet's availability zone and cidr block. The cidr block can empty, in this case the subnet will be computed based on the VPC range, the index in the array, using 4 bits (or as defined by subnet_newbits) for the subnet number, thus allowing 16 subnets."
}

variable "vpc_peering_routes" {
  type        = list(object({ cidr_block = string, vpc_peering_connection_id = string }))
  description = "Additional routes to add, for directing traffic to peered VPC."
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "The tags (a map of key/value pairs) to be applied to created resources."
  default     = {}
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Set to true if a NAT Gateway and Elastic IP should be created"
  default     = false
}

variable "single_nat_gateway" {
  type        = bool
  description = "Set to true if a common NAT Gateway should be used for all subnets"
  default     = true
}

variable "nat_eip_allocation_id" {
  type        = string
  description = "Allocation ID of an existing EIP that should be associated to the NAT gateway. Specify this ID if you want to associate an existing EIP to the NAT gateway. If not specified, a new EIP will be created and associated to the NAT gateway."
  default     = ""
}
