import boto3
import json

# Initialize the SageMaker runtime client
sagemaker_runtime = boto3.client('sagemaker-runtime')

def summarize_text(text):
    """Call the SageMaker endpoint to summarize the text."""

    # Replace 'your-endpoint-name' with your actual endpoint name
    endpoint_name = 'hf-summarization-distilbart-cnn-6-6-2024-09-20-01-54-46-040'

    # Encode the input text to utf-8
    encoded_text = text.encode("utf-8")

    # Make the request to the SageMaker endpoint
    response = sagemaker_runtime.invoke_endpoint(
        EndpointName=endpoint_name,
        ContentType="application/x-text",
        Body=encoded_text
    )

    # Parse the response and return the summary
    response_body = response['Body'].read().decode('utf-8')
    model_predictions = json.loads(response_body)
    summary_text = model_predictions["summary_text"]

    return summary_text
