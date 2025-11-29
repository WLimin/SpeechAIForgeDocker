#!/bin/bash

# 创建容器或运行存在的容器
SHELL_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"
# 容器卷目录，保存下载的模型
VOLUMES=$PWD

#容器名，存在则启动，否则创建
CONTAINER_NAME=chat-tts-forge-webui

# 检查专属网络是否创建，用于OpenWebui+ollama的语音交互。可以直接用容器名和端口作为主机名及端口进行内部通信，无需NAT路由
DOCKER_NET=openwebui-net
source ${SHELL_FOLDER}/common.sh

# 传递给容器的默认命令行
CMD_ARG="python3 webui.py --api --webui_experimental"
if [ $NV_GPU -eq 0 ]; then #没有gpu支持
    CMD_ARG="${CMD_ARG} --use_cpu all --no_half"
fi

#额外的容器变量
EXTEND_ENV='-e LOG_LEVEL=ERROR'
#EXTEND_ENV='-e LOG_LEVEL=DEBUG'

cli_common
docker logs -f $CONTAINER_NAME

:<<'EOF'
# python3 webui.py --api
# 返回模型列表
curl -X 'GET' 'http://adeb.local:7860/v1/models/list' -H 'accept: application/json'
curl -X 'GET' 'https://adeb.local/speechforge/v1/models/list' -H 'accept: application/json' -k

{"message":"ok","data":["chat-tts","fish-speech","cosy-voice","fire-red-tts","f5-tts","index-tts","spark-tts","gpt-sovits-v1","gpt-sovits-v2","gpt-sovits-v3","gpt-sovits-v4","resemble-enhance","whisper.large","whisper.turbo","sensevoice","open-voice"]}

# 返回说话人列表
curl -X 'GET' 'https://adeb.local/speechforge/v1/speakers/list?detailed=false&offset=0&limit=-1' -H 'accept: application/json' -k |jq -r '.data.items[].data.meta.data|.gender+":"+.name'|sort

...

# OpenAI 兼容合成语音

curl -X 'POST' 'http://adeb.local:7860/v1/audio/speech' \
  -H 'accept: application/json' -H 'Content-Type: application/json' \
  -d '{  "input": "Speech-AI-Forge 是一个围绕 TTS 生成模型 ChatTTS 开发的项目，实现了 API Server 和 基于 Gradio 的 WebUI。",
  "voice": "音色有韵味带磁性",  "speed": 1 }'

# 生成字幕文件
**上传文件“台湾女.mp3”，指定格式为'srt'，指定模型，语言可为zh、jp或空白，用 jq -r .text 输出text的原始文本内容。**
curl -X 'POST' \
  'http://adeb.local:7860/v1/audio/transcriptions' \
  -H 'accept: application/json' \
  -H 'Content-Type: multipart/form-data' -F 'file=@台湾女.mp3;type=audio/mpeg' \
  -F 'model=whisper.large' -F 'language=' \
  -F 'prompt=' -F 'response_format=srt' \
  -F 'temperature=0' -F 'timestamp_granularities=segment' | jq -r '.text' >台湾女.srt

# Open WebUI
引擎：http://chat-tts-forge-webui:7860/v1
音色（根据需要）：音色有韵味带磁性
文本转语音模型：chat-tts
额外参数：
{
  "response_format": "mp3",
  "speed": 1,
  "seed": 42,
  "temperature": 0.3,
  "top_k": 20,
  "top_p": 0.7,
  "style": "",
  "batch_size": 1,
  "spliter_threshold": 100,
  "eos": "[uv_break]",
  "enhance": false,
  "denoise": false,
  "stream": false,
  "bitrate": "64k"
}
EOF
