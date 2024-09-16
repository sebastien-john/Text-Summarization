import json
from model import summarize_text

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
        
