#!/usr/bin/env bash
# Change working directory to ComfyUI
cd /runpod-volume/ComfyUI

# Install ComfyUI dependencies
pip3 install -r requirements.txt
pip3 install --upgrade pip3
pip3 install onnxruntime-gpu
pip3 install insightface
pip3 install pyOpenSSL
pip3 install facexlib
pip3 install timm
pip3 install ftfy

# copy extra
cd /
cp extra_model_paths.yaml /runpod-volume/ComfyUI/

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

# Serve the API and don't shutdown the container
if [ "$SERVE_API_LOCALLY" == "true" ]; then
    echo "runpod-worker-comfy: Starting ComfyUI"
    python3 /runpod-volume/ComfyUI/main.py --disable-auto-launch --disable-metadata --listen &

    echo "runpod-worker-comfy: Starting RunPod Handler"
    python3 -u /rp_handler.py --rp_serve_api --rp_api_host=0.0.0.0
else
    echo "runpod-worker-comfy: Starting ComfyUI"
    python3 /runpod-volume/ComfyUI/main.py --disable-auto-launch --disable-metadata &

    echo "runpod-worker-comfy: Starting RunPod Handler"
    python3 -u /rp_handler.py
fi
