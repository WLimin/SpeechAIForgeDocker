#!/bin/bash

# 创建容器或运行存在的容器

# 容器卷目录，保存下载的模型
VOLUMES=$PWD/

#容器名，存在则启动，否则创建
CONTAINER_NAME=chat-tts-forge-webui

# 检查专属网络是否创建，用于OpenWebui+ollama的语音交互。可以直接用容器名和端口作为主机名及端口进行内部通信，无需NAT路由
DOCKER_NET=openwebui-net

# 重复利用其它项目已经下载的模型，可以全部移动到${VOLUMES}/models目录下。若不需要，设置为空
LINK_MODELS=$"
    -v ${VOLUMES}/../FunAudioLLM/pretrained_models/CosyVoice2-0.5B:/app/Speech-AI-Forge/models/CosyVoice2-0.5B \
    -v ${VOLUMES}/../FunAudioLLM/pretrained_models/modelscope/hub/iic/SenseVoiceSmall:/app/Speech-AI-Forge/models/SenseVoiceSmall \
"
source ${VOLUMES}/common.sh

CMD_ARG="python3 webui.py"
#CMD_ARG="python3 webui.py --api"

cli_common
docker logs -f $CONTAINER_NAME

:<<'EOF'

 #python3 webui.py --api

EOF
