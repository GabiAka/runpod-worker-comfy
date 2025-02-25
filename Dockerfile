# Use Nvidia CUDA base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1 

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 python3-pip git wget \
    build-essential libgl1 libglib2.0-0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /

# Install Python dependencies in a single layer to improve caching
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir runpod requests \
    insightface onnxruntime onnxruntime-gpu pyOpenSSL \
    facexlib colorama huggingface-hub

# Create output folder
RUN mkdir /output

# Copy necessary files
COPY src/extra_model_paths.yaml /runpod-volume/ComfyUI/
COPY src/start.sh src/rp_handler.py src/extra_model_paths.yaml test_input.json ./

# Ensure start script is executable
RUN chmod +x /start.sh

# Start the container
CMD ["/start.sh"]
