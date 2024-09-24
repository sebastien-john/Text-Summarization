# AWS SETUP

aws configure
aws s3 mb s3://nlp-summarization-project-YOUR-NAME

# TERRAFORM SETUP

terraform init
terraform plan
terraform apply
terraform destroy

# HOW TO USE

curl -X POST "https://sxg6nnw7r64nz3kjk74bqpbyza0gyosj.lambda-url.us-east-2.on.aws" -H "Content-Type: application/json" -d "{\"text\": \"Your long text to summarize goes here...\"}"

# TO-DO

configure sagemaker policy