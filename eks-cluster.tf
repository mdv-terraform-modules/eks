# EKS Cluster Resources

#================== Cluster IAM Role ================

resource "aws_iam_role" "kube_cluster" {
  name = "k8s-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "kube_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.kube_cluster.name
}

resource "aws_iam_role_policy_attachment" "kube_cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.kube_cluster.name
}

#=================== Cluster Security Group ===============

resource "aws_security_group" "cluster_sg" {
  name        = "k8s-cluster-SG"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = var.common.any_port
    to_port     = var.common.any_port
    protocol    = var.common.any_protocol
    cidr_blocks = [var.common.any_cidr]
  }

  tags = merge(var.common_tags, { Name = "k8s-cluster-SG" })
}

resource "aws_security_group_rule" "cluster_sg_ingress" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = var.common.ssl_port
  protocol          = var.common.protocol
  security_group_id = aws_security_group.cluster_sg.id
  to_port           = var.common.ssl_port
  type              = "ingress"
}

#=================== EKS Cluster ======================

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.kube_cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.cluster_sg.id]
    subnet_ids         = aws_subnet.public[*].id
  }
  tags = var.common_tags
  depends_on = [
    aws_iam_role_policy_attachment.kube_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.kube_cluster_AmazonEKSVPCResourceController,
  ]
}
