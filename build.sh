#!/bin/bash
# 创建容器镜像
SHELL_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"

docker build --progress=plain -t chat-tts-forge -f docker/Dockerfile .
source ${SHELL_FOLDER}/common.sh
GIT_TAG=$(git -C Speech-AI-Forge describe --tags)
GIT_COMMIT=$(git -C Speech-AI-Forge rev-parse HEAD)
GIT_BRANCH=$(git -C Speech-AI-Forge rev-parse --abbrev-ref HEAD)
sed -i -e "s/^GIT_TAG=.*$/GIT_TAG=${GIT_TAG}/g" ${SHELL_FOLDER}/common.sh
sed -i -e "s/^GIT_COMMIT=.*$/GIT_COMMIT=${GIT_COMMIT}/g" ${SHELL_FOLDER}/common.sh
sed -i -e "s/^GIT_BRANCH=.*$/GIT_BRANCH=${GIT_BRANCH}/g" ${SHELL_FOLDER}/common.sh
