#!/bin/bash
set -e

echo "Building lambda-layer..."

mkdir -p python

# Only install requirements if requirements.txt exists
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt -t python
else
    echo "No requirements.txt found, skipping pip install"
fi

zip -r layer.zip python
