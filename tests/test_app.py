import json
import pytest
from unittest import mock
from image.src.lambda_function import handler, summarize_text

def test_handler_with_valid_text():
    """Test the Lambda handler function with valid input."""
    event = {
        'body': json.dumps({
            'text': "Eiffel Tower is a famous structure in Paris."
        })
    }

    # Mock summarize_text
    with mock.patch('image.src.lambda_function.summarize_text', return_value="A short summary"):
        response = handler(event, {})
        assert response['statusCode'] == 200
        body = json.loads(response['body'])
        assert 'summary' in body
        assert body['summary'] == "A short summary"


def test_handler_with_no_text():
    """Test the Lambda handler function with missing text."""
    event = {
        'body': json.dumps({
            'text': ""
        })
    }

    response = handler(event, {})
    assert response['statusCode'] == 400
    body = json.loads(response['body'])
    assert body['error'] == 'No text provided'


def test_handler_with_invalid_json():
    """Test the Lambda handler function with invalid JSON input."""

    event = {
        'body': "Invalid JSON"
    }

    response = handler(event, {})
    assert response['statusCode'] == 500
    body = json.loads(response['body'])
    assert 'error' in body
