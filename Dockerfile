# Use Nvidia CUDA base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1 

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-dev python3-venv git wget \
    build-essential libgl1 libglib2.0-0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /

# Install Python dependencies in a single layer to improve caching
RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir --upgrade setuptools wheel
RUN pip3 install --no-cache-dir insightface==0.7.3 --force-reinstall
RUN pip3 install --no-cache-dir onnxruntime
RUN pip3 install --no-cache-dir onnxruntime-gpu
RUN pip3 install --no-cache-dir runpod
RUN pip3 install --no-cache-dir requests
RUN pip3 install --no-cache-dir pyOpenSSL
RUN pip3 install --no-cache-dir facexlib
RUN pip3 install --no-cache-dir colorama
RUN pip3 install --no-cache-dir huggingface-hub

# Create output folder
RUN mkdir /output

# Copy necessary files
COPY src/extra_model_paths.yaml /runpod-volume/ComfyUI/
COPY src/start.sh src/rp_handler.py src/extra_model_paths.yaml test_input.json ./

# Ensure start script is executable
RUN chmod +x /start.sh

# Start the container
CMD ["/start.sh"]
