#--------------IAM ROLE-------------------------
resource "aws_iam_role" "eks-role" {
    name = "nagy-eks-cluster-role"

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

resource "aws_iam_role_policy_attachment" "role-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.eks-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks-role.name
}

#---------------EKS CLUSTER-------------
resource "aws_eks_cluster" "my-eks" {
  name     = "nagy-eks"
  role_arn = aws_iam_role.eks-role.arn
  
  vpc_config {
    subnet_ids = [
      aws_subnet.private-sub1.id,
      aws_subnet.private-sub2.id,
      aws_subnet.pub-sub-1.id,
      aws_subnet.pub-sub-2.id
    ]
    security_group_ids = [aws_security_group.pub-secgroup.id]
    endpoint_private_access = true
  }
    depends_on = [aws_iam_role_policy_attachment.role-AmazonEKSClusterPolicy]
}