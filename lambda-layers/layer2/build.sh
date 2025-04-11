# #!/bin/bash

# echo "Building lambda-layer..."

# cd "$(dirname "$0")"  # ensure we’re in the correct directory

# # Clean up previous builds
# rm -f layer.zip
# rm -rf python

# # Re-create python/ and install dependencies (if any)
# mkdir -p python

# if [ -f "requirements.txt" ]; then
#     pip install -r requirements.txt -t python/
# else
#     echo "No requirements.txt found, skipping pip install"
# fi

# # Create the zip
# zip -r layer.zip python/
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
