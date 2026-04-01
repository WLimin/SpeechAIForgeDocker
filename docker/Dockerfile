# Defines build arguments for the versions of PyTorch, CUDA, and cuDNN to use ( 2026-02-23 20:23:33 )
#ARG PYTORCH_VERSION=2.9.1
#ARG CUDA_VERSION=13.0
#ARG CUDNN_VERSION=9
# 用pytorch的devel版本编译 flash-attn https://github.com/Dao-AILab/flash-attention
# FROM llm-flash-attn-builder:latest AS builder

# This image is based on the latest official PyTorch image, because it already contains CUDA, CuDNN, and PyTorch
# /opt/conda/bin/python3.11, uv, conda, pip3, venv
FROM aibase:torch291_cuda130
# ubuntu 22.04 lts, jammy, python 3.11

ARG UID=1000
ARG ARG_USER_NAME=ubuntu
ARG VENV_NAME="torch_cuda"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    CUDA_HOME=/usr/local/cuda \
    LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Asia/Shanghai \
    PATH=/opt/conda/bin:$PATH  \
    LD_LIBRARY_PATH=/opt/conda/lib/python3.11/site-packages/nvidia/cudnn/lib:$LD_LIBRARY_PATH \
    PYTORCH_VERSION=2.9.1

ENV USER_NAME=$ARG_USER_NAME
ENV VENV=$VENV_NAME

SHELL ["/bin/bash", "--login", "-c"]

# Installs Git, because ComfyUI and the ComfyUI Manager are installed by cloning their respective Git repositories
# Install system dependencies
RUN mkdir -p /models /app && chown -R ${USER_NAME}:${USER_NAME} /models /app # Create directory for models (will be mounted from host)

USER ${USER_NAME}
ENV HOME=/home/${USER_NAME}
# Let .pyc files be stored in one place
ENV PYTHONPYCACHEPREFIX="${HOME}/.pycache"

RUN mkdir -p ${HOME}/.local/bin ${HOME}/.pycache \
 && /opt/conda/bin/python3.11 -m venv  --system-site-packages ${HOME}/${VENV} \
 && echo "source $HOME/${VENV}/bin/activate" >> ${HOME}/.bashrc && source $HOME/${VENV}/bin/activate

# Set working directory
WORKDIR /app

# activate venv
ENV PATH=$HOME/${VENV}/bin:${HOME}/.local/bin:$PATH

# Copy the requirements file for Python dependencies
COPY  --chown=${USER_NAME}:${USER_NAME} ./docker /app/docker

# Install Python dependencies using aliyun's PyPI mirror and clean up cache to reduce image size
RUN pip install --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple --upgrade pip && \
 python -m pip install --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple  --extra-index-url https://download.pytorch.org/whl/cu130 -r docker/requirements.txt

COPY --chown=${USER_NAME}:${USER_NAME} ./Speech-AI-Forge /app/Speech-AI-Forge

RUN bash /app/docker/patch.sh \
  && sed -i -e 's#"https://huggingface.co#"https://hf-mirror.com#g' ${HOME}/${VENV}/lib/python3.1*/site-packages/huggingface_hub/constants.py 
   #&& chmod -R 777 ${HOME}/${VENV}/lib/python3.11/site-packages/tn/
  

ENV LD_LIBRARY_PATH=/opt/conda/lib/python3.11/site-packages/torch/lib:/opt/conda/lib/python3.11/site-packages/nvidia/cudnn/lib:/opt/conda/lib/python3.11/site-packages/nvidia/cu13/lib:$LD_LIBRARY_PATH
ENV NLTK_DATA=/app/Speech-AI-Forge/models/nltk_data
ENV PYTHONPATH=/app/Speech-AI-Forge
WORKDIR /app/Speech-AI-Forge
# Set the default command (modify as needed based on your application)
CMD ["bash"]
