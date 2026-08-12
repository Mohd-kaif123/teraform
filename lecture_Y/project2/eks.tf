module "eks" {

  # EKS module
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # --------------------------------------------------
  # EKS Cluster / Control Plane
  # --------------------------------------------------

  name                   = local.name
  kubernetes_version     = "1.31"
  endpoint_public_access = true

  # --------------------------------------------------
  # VPC Configuration
  # --------------------------------------------------

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Control plane network
  control_plane_subnet_ids = module.vpc.intra_subnets

  # --------------------------------------------------
  # EKS Add-ons
  # --------------------------------------------------

  addons = {
  vpc-cni = {
    most_recent   = true
    before_compute = true
  }

  kube-proxy = {
    most_recent   = true
    before_compute = true
  }

  coredns = {
    most_recent = true
  }

  eks-pod-identity-agent = {
    most_recent   = true
    before_compute = true
  }
}

  # --------------------------------------------------
  # Managed Node Groups
  # --------------------------------------------------

  eks_managed_node_groups = {

    kaif-cluster-ng = {

      instance_types = ["t2.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      capacity_type = "ON_DEMAND"

      attach_cluster_primary_security_group = true
    }
  }

  # --------------------------------------------------
  # Tags
  # --------------------------------------------------

  tags = {
    Environment = local.env
    Terraform   = "true"
  }
}

