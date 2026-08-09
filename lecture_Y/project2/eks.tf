module "eks" {

    # This two line use for import the module template
    source = "terraform-aws-modules/eks/aws"
    version = "~> 21.0"

    # cluster info (control plane)
    cluster_name = local.name
    cluster_version = "1.31"  # version nahi bhi denge tu chalega wo apne aap latest version le lega.
    cluster_endpoint_public_access = true

    vpc_id = module.vpc
    subnet_ids = module.vpc.private_subnets

    # control plane network 
    control_plane_subnet_ids = module.vpc.intra_subnets

    # ye use hota hai managing nodes in the cluster
    eks_managed_node_group_defaults = {

        cluster_addons = {
            vpc-cni = {
                most-recent = true
            }
            kube-proxy = {
                most-recent = true
            }
            core-dns = {
                most-recent = true
            }
        }
        instance_types = ["t2.medium"]
        attach_cluster_primary_security_group = true
    }

    eks_managed_node_groups = {
        kaif-cluster-ng = {
         instance_types = ["t2.medium"]

         min_size = 2
         max_size = 3
         desired_size = 2

         capacity_type = "SPOT"
        }
    }

    tags = {
        Environment = local.env
        Terraform = "true"
    }
}