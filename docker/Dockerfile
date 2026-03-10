# Defines build arguments for the versions of PyTorch, CUDA, and cuDNN to use ( 2026-02-23 20:23:33 )
ARG PYTORCH_VERSION=2.9.1
ARG CUDA_VERSION=13.0
ARG CUDNN_VERSION=9

# This image is based on the latest official PyTorch image, because it already contains CUDA, CuDNN, and PyTorch
# /opt/conda/bin/python3.11, uv, conda, pip3, venv
FROM pytorch/pytorch:${PYTORCH_VERSION}-cuda${CUDA_VERSION}-cudnn${CUDNN_VERSION}-runtime
# ubuntu 22.04 lts, jammy
#python 3.11

ARG UID=1000
ARG ARG_USER_NAME=ubuntu
ARG VENV_NAME="speech-forge"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    CUDA_HOME=/usr/local/cuda \
    LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Asia/Shanghai \
    PATH=/usr/local/cuda/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

ENV USER_NAME=$ARG_USER_NAME

ENV VENV=$VENV_NAME

SHELL ["/bin/bash", "--login", "-c"]


# 更新并安装需要的程序
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
  echo -e 'deb http://mirrors.ustc.edu.cn/ubuntu/ jammy-security main universe restricted multiverse\n' \
     'deb http://mirrors.ustc.edu.cn/ubuntu/ jammy-backports main universe restricted multiverse\n' \
     'deb http://mirrors.ustc.edu.cn/ubuntu/ jammy-updates main universe restricted multiverse\n' \
     'deb http://mirrors.ustc.edu.cn/ubuntu/ jammy main universe restricted multiverse'> /etc/apt/sources.list \
    && rm -rf /etc/apt/sources.list.d/ubuntu.sources  && apt-get update -y --fix-missing \
    && DEBIAN_FRONTEND=noninteractive apt install -y tzdata \
    && apt-get install -y --no-install-recommends \
    git build-essential curl wget ffmpeg unzip git git-lfs sox libsox-dev tar bash vim rubberband-cli \
    && apt-get clean && git lfs install && git config --global --add safe.directory '*' \
    && python -m pip config set global.index-url https://mirrors.aliyun.com/pypi/simple && useradd -l -u $UID -U -m -s /bin/bash ${USER_NAME}

ENV CONDA_DEFAULT_ENV=${VENV}
ENV PATH=/opt/conda/bin:/opt/conda/envs/${VENV}/bin:$PATH

# Set working directory
WORKDIR /app

# Copy the requirements file for Python dependencies
COPY ./docker/requirements.txt /app/requirements.txt

# Install Python dependencies using aliyun's PyPI mirror and clean up cache to reduce image size
RUN --mount=type=cache,target=/root/.cache/pip  \
  python -m pip install --no-cache-dir -r /app/requirements.txt -i https://mirrors.aliyun.com/pypi/simple  

COPY ./Speech-AI-Forge /app/Speech-AI-Forge

RUN rm -rf /root/.cache/pip && conda clean --all && chown -R ${USER_NAME}:${USER_NAME} /app
#  && sed -i -e 's#"https://huggingface.co#"https://hf-mirror.com#g' /opt/conda/lib/python3.1*/site-packages/huggingface_hub/constants.py

COPY ./docker /app/docker

USER ${USER_NAME}
ENV HOME=/home/${USER_NAME}
WORKDIR $HOME

RUN /opt/conda/bin/python3.11 -m venv  --system-site-packages ${VENV} \
 && echo "source $HOME/${VENV}/bin/activate" >> ${HOME}/.bashrc && source $HOME/${VENV}/bin/activate \
 && bash /app/docker/patch.sh

ENV LD_LIBRARY_PATH=/opt/conda/lib/python3.11/site-packages/torch/lib:/opt/conda/lib/python3.11/site-packages/nvidia/cudnn/lib:$LD_LIBRARY_PATH
ENV NLTK_DATA=/app/Speech-AI-Forge/models/nltk_data
ENV PYTHONPATH=/app/Speech-AI-Forge
WORKDIR /app/Speech-AI-Forge
# Set the default command (modify as needed based on your application)
CMD ["bash"]
