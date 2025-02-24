#!/usr/bin/env bash

# Chuyển vào thư mục ComfyUI trong volume
cd /runpod-volume/ComfyUI || exit

# Cài đặt dependencies nếu chưa có
if [ ! -f "/runpod-volume/ComfyUI/requirements_installed" ]; then
    echo "Installing ComfyUI dependencies..."
    pip3 install --upgrade pip
    pip3 install -r requirements.txt
    pip3 install insightface==0.7.3 --force-reinstall
    pip3 install onnxruntime onnxruntime-gpu pyOpenSSL facexlib timm ftfy

    # Cài đặt dependencies cho ComfyUI_InstantID nếu chưa có
    cd /runpod-volume/ComfyUI/custom_nodes/ComfyUI_InstantID || exit
    pip3 install insightface==0.7.3 simpleeval --force-reinstall

    # Đánh dấu đã cài đặt dependencies để không cài lại lần sau
    touch /runpod-volume/ComfyUI/requirements_installed
fi

# Quay lại thư mục gốc
cd / || exit

# Copy extra_model_paths.yaml nếu cần
if [ ! -f "/runpod-volume/ComfyUI/extra_model_paths.yaml" ]; then
    cp extra_model_paths.yaml /runpod-volume/ComfyUI/
fi

# Sử dụng libtcmalloc để tối ưu quản lý bộ nhớ
TCMALLOC="$(ldconfig -p | grep -Po 'libtcmalloc.so.\d' | head -n 1)"
if [ -n "$TCMALLOC" ]; then
    export LD_PRELOAD="${TCMALLOC}"
fi

# Khởi chạy ComfyUI và RunPod Handler
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
