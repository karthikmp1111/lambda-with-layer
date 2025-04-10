#!/bin/bash
set -e

LAYER_NAME=$(basename "$PWD")

echo "Building $LAYER_NAME..."

cd "$(dirname "$0")"

# Verify requirements.txt exists
if [[ ! -f "requirements.txt" ]]; then
    echo "❌ ERROR: requirements.txt not found in $(pwd)"
    exit 1
fi

# Install dependencies
pip install -r requirements.txt -t .

# Create zip package
zip -r package.zip . -x "build-layer1.sh" "*.pyc" "__pycache__/*"

echo "✅ Build completed for $LAYER_NAME"
