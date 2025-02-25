#!/usr/bin/env bash
# Change working directory to ComfyUI
cd /runpod-volume/ComfyUI

# Install ComfyUI dependencies
pip3 install insightface
pip3 install onnxruntime
pip3 install onnxruntime-gpu
pip3 install --upgrade pip
pip3 install pyOpenSSL
pip3 install -r requirements.txt
pip3 install facexlib
pip3 install --upgrade huggingface-hub
pip3 install colorama

#install requirements insightface
cd /runpod-volume/ComfyUI/custom_nodes/ComfyUI_InstantID
pip3 install insightface==0.7.3 --force-reinstall
pip3 install albucore==0.0.17 --force-reinstall

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