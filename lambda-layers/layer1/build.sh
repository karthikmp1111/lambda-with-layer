#!/bin/bash
set -e

LAYER_NAME=$(basename "$PWD")
echo "Building $LAYER_NAME..."

mkdir -p python
pip install -r requirements.txt -t python/
zip -r layer.zip python/ -x "*.pyc" "__pycache__/*"
echo "✅ Layer $LAYER_NAME built."
