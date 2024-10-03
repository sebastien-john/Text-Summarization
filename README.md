# Text Summarization Project

A serverless NLP text summarization system deployed on AWS that uses a SageMaker endpoint for inference and Lambda for request handling. The system accepts text input and returns AI-generated summaries using transformer models. The goal of this project is to design a comprehensive template that covers containerization, CI/CD, IaaS, and other misc. environment stuff, which should allow someone to bootstrap themselves for a more complex ML project and automate some of the less important technical details.

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform installed
- Docker installed
- Python 3.8+

## Local Development

1. **Set Up Environment**
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Run Tests**
   ```bash
   python -m pytest
   ```

3. **Build Docker Image**
   ```bash
   docker build -t text-summarization -f image/Dockerfile .
   ```

## Deployment

### Manual Deployment

1. **Build and Push Docker Image**
   ```bash
   # Log in to ECR
   aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin [YOUR_ACCOUNT_ID].dkr.ecr.us-east-2.amazonaws.com

   # Build and tag
   docker build -t text-summarization -f image/Dockerfile .
   docker tag text-summarization:latest [YOUR_ACCOUNT_ID].dkr.ecr.us-east-2.amazonaws.com/[YOUR_REPO]:latest

   # Push to ECR
   docker push [YOUR_ACCOUNT_ID].dkr.ecr.us-east-2.amazonaws.com/[YOUR_REPO]:latest
   ```

2. **Deploy Infrastructure**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

### CI/CD Pipeline

The project includes a GitHub Actions workflow that automatically:
- Runs tests
- Builds and pushes the Docker image to ECR
- Updates the Lambda function
- Applies Terraform changes

To set up CI/CD:

1. Fork this repository
2. Add the following secrets to your GitHub repository:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `AWS_ACCOUNT_ID`
   - `ECR_REPOSITORY`
   - `LAMBDA_FUNCTION_NAME`
   - `MODEL_ARTIFACTS_BUCKET`
   - `SAGEMAKER_ENDPOINT`
   - `SAGEMAKER_ENDPOINT_CONFIG_NAME`
   - `SAGEMAKER_ENDPOINT_NAME`
   - `SAGEMAKER_MODEL_NAME`

## Usage

**Example using curl:**
```bash
curl -X POST "https://your-lambda-function-url/prod/summarize" -H "Content-Type: application/json" -d "{\"text\": \"Your long text to summarize goes here...\"}"
```

## Infrastructure

The Terraform configuration creates:
- SageMaker endpoint for model hosting
- Lambda function for request handling
- S3 bucket for model artifacts
- Required IAM roles and policies
- ECR repository cleanup (retains only the latest image)

## Testing

The test suite includes:
- Unit test for the Lambda handler
- Input validation test
- Error handling test

Run tests with:
```bash
python -m pytest
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.