#-------------------IAM ROLE----------------------------
resource "aws_iam_role" "nodes" {
  name = "nagy-eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

#-------Node Group---------------------------------

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.my-eks.name
  node_group_name = "nagy-private-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  


  subnet_ids = [
    aws_subnet.private-sub1.id,
    aws_subnet.private-sub2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 0
  }

  remote_access {
    ec2_ssh_key = "nagy-kh"
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}

#------------------------------Bastion-Host---------------------



resource "aws_instance" "bastion" {
 ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
 
  associate_public_ip_address = true
  subnet_id = aws_subnet.pub-sub-1.id
  vpc_security_group_ids = [aws_security_group.pub-secgroup.id]
  key_name = "nagy-kh"
  tags = {
    Name = "nagy-bastion-host"
    
  }
  
}


