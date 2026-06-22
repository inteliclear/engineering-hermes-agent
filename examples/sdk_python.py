"""
Minimal example: call the ICLR LiteLLM proxy via HTTP.

Usage:
    source .env
    pip install requests
    python examples/sdk_python.py
"""

import os
import sys
import requests


def main():
    base = os.environ.get("HERMES_API_BASE")
    key = os.environ.get("HERMES_API_KEY")
    model = os.environ.get("HERMES_MODEL_ALIAS", "reasoning")

    if not base or not key:
        print("Error: HERMES_API_BASE and HERMES_API_KEY must be set (source .env).")
        sys.exit(1)

    url = f"{base}/chat/completions"
    headers = {
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": model,
        "max_tokens": 256,
        "messages": [{"role": "user", "content": "Say 'hello'"}],
    }

    try:
        resp = requests.post(url, json=payload, headers=headers, timeout=30)
        resp.raise_for_status()
        print(resp.json()["choices"][0]["message"]["content"])
    except requests.RequestException as e:
        print(f"Request failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
