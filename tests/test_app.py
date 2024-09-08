import pytest
from app.main import app
from app.model import summarize_text

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_summarize_endpoint(client):
    response = client.post('/summarize', json={'text': 'This is a long text that needs to be summarized.'})
    assert response.status_code == 200
    assert 'summary' in response.json

def test_summarize_text():
    text = "This is a long text that needs to be summarized. This is a long text that needs to be summarized. This is a long text that needs to be summarized."
    summary = summarize_text(text)
    assert len(summary) < len(text)