from flask import Flask, render_template, request, jsonify
from .model import summarize_text
import logging

# Set up logging to stdout for visibility in Docker logs
logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)

# Debugging print to ensure the app is starting
print("Flask app is starting...")

@app.route('/summarize', methods=['POST'])
def summarize():
    logging.debug("Received request to /summarize")
    data = request.json
    text = data.get('text')
    if not text:
        logging.error("No text provided in the request.")
        return jsonify({'error': 'No text provided'}), 400

    # Debugging print to confirm data was received
    logging.debug(f"Text received: {text}")
    
    summary = summarize_text(text)
    logging.debug(f"Summary generated: {summary}")
    
    return jsonify({'summary': summary})

@app.route('/')
def index():
    logging.debug("Rendering index page.")
    return render_template('index.html')

if __name__ == "__main__":
    print("Starting Flask app on port 8080...")
    app.run(host="0.0.0.0", debug=True, port=8080)
