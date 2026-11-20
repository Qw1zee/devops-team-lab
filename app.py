"""Small demonstration web service for a team-based DevOps lab."""

import os

from flask import Flask, jsonify


def create_app() -> Flask:
    app = Flask(__name__)

    @app.get("/")
    def index():
        return jsonify(message="DevOps team lab v2", version=os.getenv("APP_VERSION", "dev"))

    @app.get("/health")
    def health():
        return jsonify(status="ok")

    return app


app = create_app()

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5055)
