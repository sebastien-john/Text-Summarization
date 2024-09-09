from flask import Flask, render_template, request, jsonify
from .model import summarize_text

app = Flask(__name__)

@app.route('/summarize', methods=['POST'])

def summarize():
    data = request.json
    text = data.get('text')
    if not text:
        return jsonify({'error': 'No text provided'}), 400
    
    summary = summarize_text(text)
    return jsonify({'summary': summary})

@app.route('/')

def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)