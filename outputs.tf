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

output "region" {
  value       = var.region
  description = "The region in wich regional resources resides (subnet, router, nat...)."
}

output "subnet_ids" {
  value       = aws_subnet.quortex[*].id
  description = "The IDs of the subnets"
}

output "vpc_id" {
  value       = aws_vpc.quortex.id
  description = "The ID of the VPC"
}
