# EKS Worker Nodes Resources

#=============== Nodes IAM Role ================

resource "aws_iam_role" "worker_node" {
  name = "k8s-worker-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_node.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_node.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_node.name
}

#==================== Node Group =====================

resource "aws_eks_node_group" "primary_ng" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "test"
  node_role_arn   = aws_iam_role.worker_node.arn
  subnet_ids      = aws_subnet.public[*].id
  instance_types  = [var.instance_types]

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.worker_node_AmazonEC2ContainerRegistryReadOnly,
  ]
}
