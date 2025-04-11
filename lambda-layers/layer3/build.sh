#!/bin/bash
set -e

LAYER_NAME=$(basename "$PWD")
echo "📦 Building layer: $LAYER_NAME"

cd "$(dirname "$0")"

# Clean previous builds
rm -rf python layer.zip

# Check for requirements.txt
if [[ ! -f "requirements.txt" ]]; then
    echo "❌ ERROR: requirements.txt not found!"
    exit 1
fi

# Install dependencies into python/
mkdir -p python
pip install -r requirements.txt -t python/

# Create the layer ZIP
zip -r layer.zip python

echo "✅ Lambda Layer $LAYER_NAME built successfully"
