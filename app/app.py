from flask import Flask, jsonify
import os

app = Flask(__name__)


APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
BUILD_NUMBER = os.getenv("BUILD_NUMBER", "unknown")
GIT_COMMIT = os.getenv("GIT_COMMIT", "unknown")


@app.route("/")
def home():
    return jsonify({
        "message": "OrderHub API"
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "UP"
    })


@app.route("/orders")
def orders():
    return jsonify([
        {
            "id": 1,
            "product": "Laptop",
            "quantity": 1
        },
        {
            "id": 2,
            "product": "Mobile",
            "quantity": 2
        }
    ])


@app.route("/version")
def version():
    return jsonify({
        "version": APP_VERSION,
        "build": BUILD_NUMBER,
        "commit": GIT_COMMIT
    })


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=8080
    )