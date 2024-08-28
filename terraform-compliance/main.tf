terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-2"
  access_key = "***"
  secret_key = "***"
}

resource "aws_vpc" "prod-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "prod-vpc"
  }
}

#S3 Bucket wuth Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket" {
  bucket = "my-tf-encrypted-bucket"
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#To ensure that no security group allows unrestricted SSH access
resource "aws_security_group" "prod-sg" {
  name = "Prod-SG"
  description = "Security group with restricted SSH access"
  vpc_id = aws_vpc.prod-vpc.id
}

resource "aws_security_group_rule" "allow-ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks= ["192.168.1.0/24"]  # Replace with your IP range
  security_group_id = aws_security_group.prod-sg.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.prod-sg.id
}