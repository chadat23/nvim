#!/bin/bash

# Find the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Activate the virtual environment using a relative path
source "$SCRIPT_DIR/venv/bin/activate"

# Run the Python script
python "$SCRIPT_DIR/fetch_script.py" "$1"

