"""Secrets helper: prefer environment variables, optional AWS Secrets Manager.

Usage: from app.utils.secrets import get_secret
       key = get_secret("GEMINI_API_KEY")

Behavior:
 - If `SECRET_PROVIDER` == "aws", attempts to read from AWS Secrets Manager
   using `boto3` and the provided `AWS_REGION` env var.
 - Otherwise returns `os.getenv(name)`.

This keeps the codebase free of hardcoded secrets and allows CI/infra to
provide secrets from a real secret store.
"""
import os
import logging

def get_secret(name: str) -> str:
    """Return a secret's value from the configured provider or environment.

    Returns empty string if not found.
    """
    provider = os.getenv("SECRET_PROVIDER", "env").lower()
    if provider == "aws":
        try:
            import boto3
            import base64
            client = boto3.client("secretsmanager", region_name=os.getenv("AWS_REGION"))
            resp = client.get_secret_value(SecretId=name)
            if "SecretString" in resp and resp["SecretString"]:
                return resp["SecretString"]
            if "SecretBinary" in resp and resp["SecretBinary"]:
                return base64.b64decode(resp["SecretBinary"]).decode()
        except Exception as e:
            logging.exception("Failed to read secret %s from AWS Secrets Manager: %s", name, e)
            return ""

    # Fallback to environment variable
    return os.getenv(name, "")
