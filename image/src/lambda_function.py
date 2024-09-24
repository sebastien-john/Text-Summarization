import json
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

def handler(event, context):
    try:
        body = json.loads(event['body'])
        text = body.get('text')
        
        if not text:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'No text provided'})
            }

        summary = summarize_text(text)

        return {
            'statusCode': 200,
            'body': json.dumps({'summary': summary})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

    
# Simulate Lambda Event
def main():
    event = {
        'body': json.dumps({
            'text': "The tower is 324 metres (1,063 ft) tall, about the same height as an 81-storey building, and the tallest structure in Paris. Its base is square, measuring 125 metres (410 ft) on each side. During its construction, the Eiffel Tower surpassed the Washington Monument to become the tallest man-made structure in the world, a title it held for 41 years until the Chrysler Building in New York City was finished in 1930. It was the first structure to reach a height of 300 metres. Due to the addition of a broadcasting aerial at the top of the tower in 1957, it is now taller than the Chrysler Building by 5.2 metres (17 ft). Excluding transmitters, the Eiffel Tower is the second tallest free-standing structure in France after the Millau Viaduct."

        })
    }

    response = handler(event, {})
    print(f"Status Code: {response['statusCode']}")
    print(f"Response Body: {json.loads(response['body'])}")

if __name__ == "__main__":
    main()