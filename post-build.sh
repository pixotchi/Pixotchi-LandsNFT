#!/bin/bash

# Set the script to exit immediately if any command fails
set -e

# Define paths
ABI_JSON="src/generated/abi.json"
ABI_HUMAN_JS="src/generated/abi-human.js"
ABI_TS="src/generated/abi.ts"
CONVERTER_SCRIPT="abi-json-to-ts.js"

# Check if the abi.json file exists
if [ ! -f "$ABI_JSON" ]; then
    echo "Error: $ABI_JSON does not exist."
    exit 1
fi

# Check if the converter script exists
if [ ! -f "$CONVERTER_SCRIPT" ]; then
    echo "Error: $CONVERTER_SCRIPT does not exist."
    exit 1
fi

# Run hrabi to parse the ABI
echo "Parsing ABI with hrabi..."
npx hrabi parse "$ABI_JSON" "$ABI_HUMAN_JS"

# Run the Node.js script to convert JSON to TypeScript
echo "Converting ABI JSON to TypeScript..."
node "$CONVERTER_SCRIPT" "$ABI_JSON" "$ABI_TS"

echo "ABI processing completed successfully."