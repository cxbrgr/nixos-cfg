FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

# Prevent interactive queries during build
ENV DEBIAN_FRONTEND=noninteractive

# Install System Dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    wget \
    curl \
    vim \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    build-essential \
    python3-dev \
    python3-pip \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    && rm -rf /var/lib/apt/lists/*

# Fix Python Alias (Ensure python3 and python define python3.12)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Install Core Python Packages for ComfyUI
# Matching 'megapak' philosophy but for Ubuntu
RUN pip install --no-cache-dir \
    torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu124 \
    xformers \
    opencv-python \
    scipy \
    matplotlib \
    numpy \
    Pillow \
    pyyaml \
    tqdm \
    psutil \
    requests \
    gitpython

# Setup ComfyUI Directory
WORKDIR /root/ComfyUI

# Clone ComfyUI (Main & Manager)
RUN git clone https://github.com/comfyanonymous/ComfyUI.git . \
    && git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager

# Install Requirements
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt

# Entrypoint script
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Environment Variables
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

EXPOSE 8188

ENTRYPOINT ["/root/entrypoint.sh"]
