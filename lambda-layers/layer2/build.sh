#!/bin/bash

echo "Building lambda-layer..."

cd "$(dirname "$0")"  # ensure we’re in the correct directory

# Clean up previous builds
rm -f layer.zip
rm -rf python

# Re-create python/ and install dependencies (if any)
mkdir -p python

if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt -t python/
else
    echo "No requirements.txt found, skipping pip install"
fi

# Create the zip
zip -r layer.zip python/
