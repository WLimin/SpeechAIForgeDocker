#!/bin/bash

# 创建容器或运行存在的容器，并进入交互命令行

# 容器卷目录，保存下载的模型
VOLUMES=$PWD/

#容器名，存在则启动，否则创建
CONTAINER_NAME=chat-tts-forge-webui

# 检查专属网络是否创建，用于OpenWebui+ollama的语音交互。可以直接用容器名和端口作为主机名及端口进行内部通信，无需NAT路由
DOCKER_NET=openwebui-net

# 传递给容器的默认命令行
CMD_ARG=

source ${VOLUMES}/common.sh

cli_common
docker exec -it ${CONTAINER_NAME} /bin/bash

:<<'EOF'

 #python3 webui.py --api

EOF
