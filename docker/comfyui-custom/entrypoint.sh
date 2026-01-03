#!/bin/bash
set -e

# Pass arguments to ComfyUI
CLI_ARGS=${CLI_ARGS:-""}

echo "Starting ComfyUI with args: $CLI_ARGS"

# Ensure we are in the correct directory
cd /root/ComfyUI

# Run ComfyUI
exec python3 main.py --listen 0.0.0.0 --port 8188 $CLI_ARGS
