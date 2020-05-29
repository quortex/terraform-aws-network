
[![Quortex][logo]](https://quortex.io)

# terraform-aws-network

A terraform module for Quortex infrastructure EKS network layer.

It provides a set of resources necessary to provision the Kubernetes cluster of the Quortex infrastructure on Amazon AWS, via EKS.

![infra_diagram]

This module is available on [Terraform Registry][registry_tf_aws-eks_cluster].

Get all our terraform modules on [Terraform Registry][registry_tf_modules] or on [Github][github_tf_modules] !

## Created resources

This module creates the following resources in AWS:

- a dedicated VPC
- 2 or more subnets (public) in different AZ, for the master nodes
- 1 or more subnets in different AZ, for the worker nodes
- an internet gateway and a route table, for reaching the internet from inside the subnet


## Usage example

```
module "network" {
  source = "git::https://github.com/quortex/terraform-aws-network.git"

  region             = "eu-west-3"
  name               = "quortexcluster"
  cidr_block         = "10.0.0.0/16"
  subnet_newbits     = 8
  availability_zones = ["eu-west-3a", "eu-west-3c"]
}

```

---

## Related Projects

This project is part of our terraform modules to provision a Quortex infrastructure for AWS.

Check out these related projects.

- [terraform-aws-network][registry_tf_aws-eks_network] - A terraform module for Quortex infrastructure network layer.

- [terraform-aws-eks-cluster][registry_tf_aws-eks_cluster] - A terraform module for Quortex infrastructure AWS cluster layer.

- [terraform-aws-eks-load-balancer][registry_tf_aws-eks_load_balancer] - A terraform module for Quortex infrastructure AWS load balancing layer.

- [terraform-aws-storage][registry_tf_aws-eks_storage] - A terraform module for Quortex infrastructure AWS persistent storage layer.

## Help

**Got a question?**

File a GitHub [issue](https://github.com/quortex/terraform-aws-eks-storage/issues) or send us an [email][email].


  [logo]: https://storage.googleapis.com/quortex-assets/logo.webp
  [infra_diagram]: https://storage.googleapis.com/quortex-assets/infra_aws_001.jpg

  [email]: mailto:info@quortex.io

  [registry_tf_modules]: https://registry.terraform.io/modules/quortex
  [registry_tf_aws-eks_network]: https://registry.terraform.io/modules/quortex/network/aws-eks
  [registry_tf_aws-eks_cluster]: https://registry.terraform.io/modules/quortex/eks-cluster/aws-eks
  [registry_tf_aws-eks_load_balancer]: https://registry.terraform.io/modules/quortex/load-balancer/aws-eks
  [registry_tf_aws-eks_storage]: https://registry.terraform.io/modules/quortex/storage/aws-eks
  [github_tf_modules]: https://github.com/quortex?q=terraform-