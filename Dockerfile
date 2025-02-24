# Sử dụng Nvidia CUDA base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Thiết lập biến môi trường để tối ưu hóa quá trình cài đặt
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1 

# Cài đặt Python, git và các công cụ cần thiết
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libgl1 \
        libglib2.0-0 \
        python3.10 \
        python3-pip \
        git \
        wget && \
    apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Cài đặt RunPod và các thư viện Python cần thiết
RUN pip3 install --no-cache-dir runpod requests

# Thiết lập thư mục làm việc chính
WORKDIR /runpod-volume/ComfyUI

# Copy các file cần thiết vào container
COPY src/extra_model_paths.yaml /runpod-volume/ComfyUI/
COPY src/start.sh src/rp_handler.py test_input.json / 

# Gán quyền thực thi cho start.sh
RUN chmod +x /start.sh

# Chạy container bằng start.sh
CMD ["/start.sh"]
