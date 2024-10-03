terraform {
  backend "s3" {
    bucket = "terraform-state-nlp-summarization"  # You'll need to create this bucket
    key    = "nlp-summarization/terraform.tfstate"
    region = "us-east-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

# delete all images except for the last one
resource "null_resource" "delete_old_ecr_images" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = <<EOT
      Write-Host "Starting image deletion script..."
      
      # Get all images with their details
      Write-Host "Listing ECR images..."
      $imagesJson = aws ecr describe-images --repository-name "${var.ecr_repository_name}" --query 'sort_by(imageDetails, &imagePushedAt)[0:-1].imageDigest' --output json
      
      if ($LASTEXITCODE -eq 0 -and $imagesJson) {
        $images = $imagesJson | ConvertFrom-Json
        
        if ($images.Length -gt 0) {
          # Create the correct JSON structure that ECR expects
          $imageIds = @{
            "imageIds" = @($images | ForEach-Object {
              @{
                "imageDigest" = $_.ToString()  # Ensure it's a string
              }
            })
          } | ConvertTo-Json -Compress

          # Log the image IDs for debugging
          Write-Host "Image IDs to delete: $imageIds"

          # Delete old images (pass the JSON directly as a string)
          Write-Host "Deleting old images..."
          $deleteResult = aws ecr batch-delete-image --repository-name "${var.ecr_repository_name}" --cli-input-json $imageIds

          # Log the result of deletion
          Write-Host "Deletion result: $deleteResult"
        } else {
          Write-Host "No images to delete"
        }
      } else {
        Write-Host "No images found or error occurred while listing images"
      }
      
      Write-Host "Script completed"
    EOT
  }
}


resource "aws_s3_bucket" "model_artifacts" {
  bucket = var.model_artifacts_bucket
}

data "aws_ecr_repository" "nlp_summarization" {
  name = var.ecr_repository_name
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
      SAGEMAKER_ENDPOINT = var.sagemaker_endpoint
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "nlp_endpoint_config" {
  name = var.sagemaker_endpoint_config_name

  production_variants {
    variant_name           = "variant-1"
    model_name             = var.sagemaker_model_name
    instance_type          = "ml.c6i.xlarge"
    initial_instance_count = 1
    initial_variant_weight = 1
  }
}

resource "aws_sagemaker_endpoint" "nlp_endpoint" {
  name                 = var.sagemaker_endpoint_name
  endpoint_config_name = aws_sagemaker_endpoint_configuration.nlp_endpoint_config.name
}
