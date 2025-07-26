#!/bin/bash
# 只定义了函数，需要外部定义变量：
# VOLUMES
# CONTAINER_NAME
# DOCKER_NET
# LINK_MODELS
# CMD_ARG

# 重复利用其它项目已经下载的模型，可以全部移动到${VOLUMES}/models目录下。若不需要，设置为空
LINK_MODELS=$"
    -v ${VOLUMES}/../FunAudioLLM/pretrained_models/CosyVoice2-0.5B:/app/Speech-AI-Forge/models/CosyVoice2-0.5B \
    -v ${VOLUMES}/../FunAudioLLM/pretrained_models/modelscope/hub/iic/SenseVoiceSmall:/app/Speech-AI-Forge/models/SenseVoiceSmall \
    -v ${VOLUMES}/../SparkAudio/pretrained_models/Spark-TTS-0.5B:/app/Speech-AI-Forge/models/Spark-TTS-0.5B \
    -v ${VOLUMES}/../RVC-Boss/models/GPT_SoVITS/pretrained_models:/app/Speech-AI-Forge/models/gpt_sovits_v4 \
    -v ${VOLUMES}/../RVC-Boss/models/nltk_data:/app/Speech-AI-Forge/models/nltk_data \
    -v ${VOLUMES}/../RVC-Boss/models/tools/asr/models/faster-whisper-large-v3:/app/Speech-AI-Forge/models/faster-whisper-large-v3 \
    -v ${VOLUMES}/../RVC-Boss/models/tools/asr/models/speech_fsmn_vad_zh-cn-16k-common-pytorch:/app/Speech-AI-Forge/models/fsmn-vad \
"

GIT_TAG=$(git -C Speech-AI-Forge describe --tags)
GIT_COMMIT=$(git -C Speech-AI-Forge rev-parse HEAD)
GIT_BRANCH=$(git -C Speech-AI-Forge rev-parse --abbrev-ref HEAD)

cli_common() {
    # 检查专属网络是否创建，用于OpenWebui+ollama的语音交互
    docker network ls --format '{{.Name}}' | grep "${DOCKER_NET}"
    if [ $? -ne 0 ]; then
        docker network create ${DOCKER_NET}
    fi

    #是否存在容器，存在则启动，否则创建
    NS=$(docker ps -a --format '{{json .Names}},{{json .State}}' | grep "${CONTAINER_NAME}")
    if [ $? -eq 0 ]; then
        # 已存在
        docker start ${CONTAINER_NAME}
    else
        # 不存在
        # 宿主机是否有 nvidia GPU
        which nvidia-smi
        if [ $? -eq 0 ]; then #有gpu支持
            RUN_USE_GPU="--name ${CONTAINER_NAME} --gpus all"
        else
            RUN_USE_GPU="--name ${CONTAINER_NAME} "
        fi
        # Debug: force use CPU
        #RUN_USE_GPU="--name ${CONTAINER_NAME} "
        # 提供的服务。由于暂时不打算提供模型共享，可以选择api用于对话服务。webui界面主要完成语音复刻和测试。
        #CAPABILITIES=api|web|all
        CAPABILITIES=api
        docker run -itd $RUN_USE_GPU \
            --network=${DOCKER_NET} \
            -p 7860:7860 -p 7870:7870\
            -v ${VOLUMES}/models:/app/Speech-AI-Forge/models\
            --user $(id -u):$(id -g) \
            -e CAPABILITIES=${CAPABILITIES} \
            -e NLTK_DATA="/app/Speech-AI-Forge/models/nltk_data" \
            -e V_GIT_TAG="$GIT_TAG" -e V_GIT_COMMIT="$GIT_COMMIT" -e V_GIT_BRANCH="$GIT_BRANCH" \
            $LINK_MODELS \
         chat-tts-forge $CMD_ARG
    fi
}


