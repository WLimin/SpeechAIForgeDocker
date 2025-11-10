#!/bin/bash
# 只定义了函数，需要外部定义变量：
# VOLUMES
# CONTAINER_NAME
# DOCKER_NET
# LINK_MODELS
# CMD_ARG
# EXTEND_ENV
# GRADIO_ROOT_PATH_ENV

# 重复利用其它项目已经下载的模型，可以全部移动到${VOLUMES}/models目录下。若不需要，设置为空
LINK_MODELS=$"
    -v ${VOLUMES}/models/tagger_cache:/app/Speech-AI-Forge/modules/repos_static/index_tts/indextts/utils/tagger_cache \
"
#额外的容器变量
EXTEND_ENV=''
GRADIO_ROOT_PATH_ENV=/speechforge
GIT_TAG='v0.7.0-404-gadb747d'
GIT_COMMIT='adb747dad7e3d10330931c01eda6b3694427ea70'
GIT_BRANCH='main'

# 宿主机是否有 nvidia GPU
which nvidia-smi
if [ $? -eq 0 ]; then #有gpu支持
    NV_GPU=1
else
    NV_GPU=0
fi

cli_common() {
    # 检查专属网络是否创建，用于OpenWebui+ollama的语音交互
    DOCKER_NET=openwebui-net
    source $HOME/Public/AI/openwebui-check-net.sh

    #是否存在容器，存在则启动，否则创建
    NS=$(docker ps -a --format '{{json .Names}},{{json .State}}' | grep "${CONTAINER_NAME}")
    if [ $? -eq 0 ]; then
        # 已存在
        docker start ${CONTAINER_NAME}
    else
        # 不存在
        # 宿主机是否有 nvidia GPU
        if [ $NV_GPU -eq 1 ]; then #有gpu支持
            RUN_USE_GPU="--name ${CONTAINER_NAME} --gpus all"
        else
            RUN_USE_GPU="--name ${CONTAINER_NAME} "
        fi
        # Debug: force use CPU
        #RUN_USE_GPU="--name ${CONTAINER_NAME} "
        # 提供的服务。由于暂时不打算提供模型共享，可以选择api用于对话服务。webui界面主要完成语音复刻和测试。
#         -p 7860:7860 -p 7870:7870 \
        #CAPABILITIES=api|web|all
        CAPABILITIES=api
        docker run -itd $RUN_USE_GPU \
            --network=${DOCKER_NET} \
            --ip=${SPEECH_AI_FORGE_IP} \
            -v ${VOLUMES}/models:/app/Speech-AI-Forge/models \
            --user $(id -u):$(id -g) \
            -e CAPABILITIES=${CAPABILITIES} \
            -e NLTK_DATA="/app/Speech-AI-Forge/models/nltk_data" \
            -e V_GIT_TAG="$GIT_TAG" -e V_GIT_COMMIT="$GIT_COMMIT" -e V_GIT_BRANCH="$GIT_BRANCH" \
            -e GRADIO_ROOT_PATH=${GRADIO_ROOT_PATH_ENV} \
            $EXTEND_ENV \
            $LINK_MODELS \
         chat-tts-forge $CMD_ARG
    fi
}


