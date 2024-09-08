# AWS SETUP

aws configure
aws s3 mb s3://nlp-summarization-project-YOUR-NAME

# TERRAFORM SETUP

terraform init
terraform plan
terraform apply
terraform destroy

# HOW TO USE

curl -X POST http://127.0.0.1:5000/summarize -H "Content-Type: application/json" -d "{\"text\": \"Your long text here that you want summarized.\"}"  