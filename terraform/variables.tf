variable "region" {
  description = "AWS Region"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "model_artifacts_bucket" {
  description = "S3 bucket for storing model artifacts"
  type        = string
}

variable "sagemaker_endpoint" {
  description = "SageMaker endpoint for the summarization model"
  type        = string
}

variable "sagemaker_endpoint_config_name" {
  description = "SageMaker endpoint configuration name"
  type        = string
}

variable "sagemaker_model_name" {
  description = "SageMaker model name"
  type        = string
}

variable "sagemaker_endpoint_name" {
  description = "SageMaker endpoint name"
  type        = string
}
