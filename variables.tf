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

variable "region" {
  type        = string
  description = "The AWS region in wich to create network regional resources (subnet, router, nat...)."
}

variable "availability_zones" {
  type        = list(string)
  description = "The list of availability zones (AZ) for the subnets. Amazon EKS requires subnets in at least two Availability Zones"
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_newbits" {
  type        = number
  description = "The number of bits to add to the VPC CIDR block for obtaining the subnet CIDR blocks"
  default     = 8
}

variable "vpc_peering_routes" {
  type        = list(object({ cidr_block=string, vpc_peering_connection_id=string }))
  description = "Additional routes to add, for directing traffic to peered VPC."
  default     = []
}

variable "tags" {
  type        = map
  description = "The tags (a map of key/value pairs) to be applied to created resources."
  default     = {}
}
