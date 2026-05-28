#!/usr/bin/env bash
set -euo pipefail

# Create isolated venv using standard python3
python3 -m venv /home/hiryu/.hermes/venv

# Install dependencies using standard pip
/home/hiryu/.hermes/venv/bin/pip install --upgrade pip
/home/hiryu/.hermes/venv/bin/pip install -r /home/hiryu/.hermes/requirements.txt
