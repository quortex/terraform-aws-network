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

variable "internet_gateway_name" {
  type        = string
  description = "Name for the internet gateway resource."
  default     = "quortex"
}

variable "route_table_prefix" {
  type        = string
  description = "A prefix for the name of route tables."
  default     = "quortex-"
}

variable "nat_gateway" {
  type        = object({ name = string, subnet_key = string })
  description = <<EOT
The NAT gateway configuration, a name and a subnet_key that must match a key
of the given subnets variable.
EOT
  default     = null
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

variable "subnets" {
  type        = map(object({ availability_zone = string, cidr = string, public = bool }))
  description = <<EOT
A map representing the subnets that need to be created. Each item should
specify the subnet's Availability Zone, cidr block, and whether the subnet
should be public or not.
EOT
}

variable "vpc_peering_routes" {
  type        = list(object({ cidr_block = string, vpc_peering_connection_id = string }))
  description = "Additional routes to add, for directing traffic to a VPC internet gateway or a virtual private gateway."
  default     = []
}

variable "gateway_routes" {
  type        = list(object({ cidr_block = string, gateway_id = string }))
  description = "Additional routes to add, for directing traffic to peered VPC."
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "The tags (a map of key/value pairs) to be applied to created resources."
  default     = {}
}

variable "nat_eip_allocation_id" {
  type        = string
  description = "Allocation ID of an existing EIP that should be associated to the NAT gateway. Specify this ID if you want to associate an existing EIP to the NAT gateway. If not specified, a new EIP will be created and associated to the NAT gateway."
  default     = ""
}
