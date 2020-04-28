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

variable "name" {
  type        = string
  description = "This value will be in the Name tag of all network resources. Matches the EKS cluster name"
}

variable "region" {
  type        = string
  description = "The AWS region in wich to create network regional resources (subnet, router, nat...)."
}

variable "availability_zones" {
  type        = list(string)
  description = "The list of availability zones (AZ) for the subnets. Amazon EKS requires subnets in at least two Availability Zones"
}

variable "resource_labels" {
  type        = map
  description = "The labels (a map of key/value pairs) to be applied to created resources."
  default     = {}
}
