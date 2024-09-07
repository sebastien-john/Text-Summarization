provider "aws" {
  region = "us-east-2"  
}

terraform {
  backend "s3" {
    bucket = "nlp-summarization-project-sebastien"
    key    = "terraform.tfstate"
    region = "us-east-2"  
  }
}

# S3 Bucket
resource "aws_s3_bucket" "model_artifacts" {
  bucket = "nlp-summarization-artifacts-sebastien"
}

# IAM Role for SageMaker
resource "aws_iam_role" "sagemaker_role" {
  name = "sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
  role       = aws_iam_role.sagemaker_role.name
}

# SageMaker Notebook Instance
resource "aws_sagemaker_notebook_instance" "nlp_notebook" {
  name          = "nlp-summarization-notebook"
  role_arn      = aws_iam_role.sagemaker_role.arn
  instance_type = "ml.t2.medium"
}