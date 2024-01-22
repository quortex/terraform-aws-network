
[![Quortex][logo]](https://quortex.io)

# terraform-aws-network

A terraform module for Quortex infrastructure EKS network layer.

It provides a set of resources necessary to provision the Kubernetes cluster of the Quortex infrastructure on Amazon AWS, via EKS.

![infra_diagram]

This module is available on [Terraform Registry][registry_tf_aws-network].

Get all our terraform modules on [Terraform Registry][registry_tf_modules] or on [Github][github_tf_modules] !

## Created resources

This module creates the following resources in AWS:

- a dedicated VPC
- 2 or more public subnets in different AZ
- 2 or more private subnets in different AZ
- an internet gateway
- route tables
- a NAT gateway in each public subnet

In addition, if NAT gateways are not provided an EIP allocation id:

- an Elastic IP for each such NAT gateway

## Usage example

```
module "network" {
  source = "quortex/network/aws"

  name               = "quortexcluster"
  vpc_cidr_block     = "10.0.0.0/16"
  subnets = {
    pub-eu-west-1b = {
      availability_zone = "eu-west-1b"
      cidr              = "10.100.64.0/22"
      public            = true
    }
    pub-eu-west-1c = {
      availability_zone = "eu-west-1c"
      cidr              = "10.100.68.0/22"
      public            = true
    }
    priv-eu-west-1b = {
      availability_zone = "eu-west-1b"
      cidr              = "10.100.96.0/19"
      public            = false
    }
    priv-eu-west-1c = {
      availability_zone = "eu-west-1c"
      cidr              = "10.100.128.0/19"
      public            = false
    }
  }
  nat_gateway = {
    quortex = {
      subnet_key = "pub-eu-west-1b"
      eip_allocation_id = "" # set an existing EIP's id, or an empty string to create a new EIP
    }
  }
}

```

---

## Related Projects

This project is part of our terraform modules to provision a Quortex infrastructure for AWS.

Check out these related projects.

- [terraform-aws-eks-cluster][registry_tf_aws-eks_cluster] - A terraform module for Quortex infrastructure AWS cluster layer.

- [terraform-aws-eks-load-balancer][registry_tf_aws-eks_load_balancer] - A terraform module for Quortex infrastructure AWS load balancing layer.

- [terraform-aws-storage][registry_tf_aws-eks_storage] - A terraform module for Quortex infrastructure AWS persistent storage layer.

## Help

**Got a question?**

File a GitHub [issue](https://github.com/quortex/terraform-aws-network/issues) or send us an [email][email].


  [logo]: https://storage.googleapis.com/quortex-assets/logo.webp
  [infra_diagram]: https://storage.googleapis.com/quortex-assets/infra_aws_002.jpg

  [email]: mailto:info@quortex.io

  [registry_tf_modules]: https://registry.terraform.io/modules/quortex
  [registry_tf_aws-eks_network]: https://registry.terraform.io/modules/quortex/network/aws
  [registry_tf_aws-eks_cluster]: https://registry.terraform.io/modules/quortex/eks-cluster/aws
  [registry_tf_aws-eks_load_balancer]: https://registry.terraform.io/modules/quortex/load-balancer/aws
  [registry_tf_aws-eks_storage]: https://registry.terraform.io/modules/quortex/storage/aws
  [github_tf_modules]: https://github.com/quortex?q=terraform-
