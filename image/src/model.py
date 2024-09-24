import boto3
import json


sagemaker_runtime = boto3.client('sagemaker-runtime')

def summarize_text(text):
    """Call the SageMaker endpoint to summarize the text."""
    
    endpoint_name = 'text-summarization-012509-Endpoint-20240924-023101'

    encoded_text = text.encode("utf-8")

    response = sagemaker_runtime.invoke_endpoint(
        EndpointName=endpoint_name,
        ContentType="application/x-text",
        Body=encoded_text
    )

    response_body = response['Body'].read().decode('utf-8')
    model_predictions = json.loads(response_body)
    summary_text = model_predictions["summary_text"]

    return summary_text
