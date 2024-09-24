provider "aws" {
  region = "us-east-2"
}

# delete all images except for the last one
resource "null_resource" "delete_old_ecr_images" {
  provisioner "local-exec" {
    command = <<EOT
      images_to_delete=$(aws ecr list-images --repository-name "cdk-hnb659fds-container-assets-767397964219-us-east-2" \
        --query 'imageIds | sort_by(@, &imagePushedAt)[0:-1]' \
        --output json)

      if [ "$images_to_delete" != "[]" ]; then
        aws ecr batch-delete-image --repository-name "cdk-hnb659fds-container-assets-767397964219-us-east-2" \
          --image-ids "$images_to_delete"
      else
        echo "No old images to delete."
      fi
    EOT
  }
}

terraform {
  backend "s3" {
    bucket = "nlp-summarization-project-sebastien"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

resource "aws_s3_bucket" "model_artifacts" {
  bucket = "nlp-summarization-artifacts-sebastien"
}

data "aws_ecr_repository" "nlp_summarization" {
  name = "cdk-hnb659fds-container-assets-767397964219-us-east-2"
}

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

resource "aws_iam_role" "lambda_role" {
  name = "lambda-sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sagemaker_invoke" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "nlp_summarization" {
  filename      = "lambda_function.zip"  
  function_name = "nlp-summarization-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.8"

  environment {
    variables = {
      SAGEMAKER_ENDPOINT = "text-summarization-012509-Endpoint-20240924-023101"
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "nlp_endpoint_config" {
  name = "text-summarization-012509-config"

  production_variants {
    variant_name           = "variant-1"
    model_name             = "text-summarization-012509"  
    instance_type          = "ml.c6i.xlarge"
    initial_instance_count = 1
    initial_variant_weight = 1
  }
}

resource "aws_sagemaker_endpoint" "nlp_endpoint" {
  name                 = "text-summarization-012509-Endpoint-20240924-023101"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.nlp_endpoint_config.name
}

