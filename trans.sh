#!/bin/bash

# 将录音文件转写为文本
#set -x
# 设置默认值
FORMAT="txt"
PRESET_LANG="zh"
MODEL="sensevoice"
HOST="http://localhost:7860"

HELP(){
    echo  "将录音文件转写为文本的脚本。"
    echo  "用法：$(basename \"${BASH_SOURCE[0]}\") [-f format] [-l language] [-m model] [-h host:port] audio_file"
    echo  " format: 输出文件格式及扩展名。默认：$FORMAT，可用：txt srt vtt tsv lrc json。"
    echo  " language: 转写指定的默认语言，会自动判断，一般无需设置。默认：$PRESET_LANG，可用：af, am, ar, as, az, ba, be, bg, bn, bo, br, bs, ca, cs, cy, da, de, el, en, es, et, eu, fa, fi, fo, fr, gl, gu, ha, haw, he, hi, hr, ht, hu, hy, id, is, it, ja, jw, ka, kk, km, kn, ko, la, lb, ln, lo, lt, lv, mg, mi, mk, ml, mn, mr, ms, mt, my, ne, nl, nn, no, oc, pa, pl, ps, pt, ro, ru, sa, sd, si, sk, sl, sn, so, sq, sr, su, sv, sw, ta, te, tg, th, tk, tl, tr, tt, uk, ur, uz, vi, yi, yo, zh, yue"
    echo  " model: 转写用的模型。默认：$MODEL，可用：whisper.turbo、whisper.large、sensevoice。"
    echo  " host:port: 要访问转写的URL地址，默认：$HOST。"
    echo  " audio_file: 待转写的音频文件。支持 mp3, wav, ogg, acc, flac, raw。"
    echo  ""
    echo  "默认输出为指定格式扩展名的同名文件。"
}
# 使用 URL_CHECK 检查HOST是否正常
CheckURL(){
    URL_CHECK="${HOST}/v1/ping"
    RESPONSE=$(curl --silent -H 'accept: application/json' -X 'GET' $URL_CHECK | jq '.data')
    if [ "Ok$RESPONSE" !=  'Ok"pong"' ]; then
        echo "Invalid response. 请检查 $URL_CHECK 是否正确。"
        exit 1
    fi
}

# 读取命令行参数个数，至少需要文件名
if [ "$#" -lt 1 ]; then
    HELP
fi
# 读取命令行参数
while [ "$#" -gt 0 ]; do
    case $1 in
        -f) FORMAT=$2; shift ;;
        -l) PRESET_LANG=$2; shift ;;
        -m) MODEL=$2; shift ;;
        -h) HOST=$2; shift ;;
        *) AUDIO_FILE="$1";;
    esac
    shift
done

# 检查音频文件是否提供
if [ -z "$AUDIO_FILE" ]; then
    echo "Audio file is required."
    exit 1
elif [ ! -f "$AUDIO_FILE" ]; then
    echo "Audio file is not exist."
    exit 1
fi

# 根据音频文件扩展名设置Content-Type
EXT="${AUDIO_FILE##*.}"
case  ${EXT,,} in   # Bash 4.0属以上内置${string,,} 转小写和 ${string^^}转大写
    mp3|m4a|mp4) TYPE="audio/mpeg";;
    wav) TYPE="audio/x-wav";;
    ogg) TYPE="audio/ogg";;
    acc) TYPE="audio/aac";;
    flac) TYPE="audio/flac";;
    raw) TYPE="audio/x-raw";;
    *)
        echo "Invalid audio file type extension name. Supported types: mp3, wav, ogg, acc, flac, raw"
        exit 1
        ;;
esac
# 检查格式参数是否有效
case $FORMAT in
    txt|srt|vtt|tsv|lrc|json)
        ;;
    *)
        echo "Invalid format: $FORMAT. Use one of the following: txt, srt, vtt, tsv, lrc, json"
        exit 1
        ;;
esac

# 检查语言参数是否有效（可选）
if [ ! -z "$PRESET_LANG" ]; then
    case $PRESET_LANG in
        af|am|ar|as|az|ba|be|bg|bn|bo|br|bs|ca|cs|cy|da|de|el|en|es|et|eu|fa|fi|fo|fr|gl|gu|ha|haw|he|hi|hr|ht|hu|hy|id|is|it|ja|jw|ka|kk|km|kn|ko|la|lb|ln|lo|lt|lv|mg|mi|mk|ml|mn|mr|ms|mt|my|ne|nl|nn|no|oc|pa|pl|ps|pt|ro|ru|sa|sd|si|sk|sl|sn|so|sq|sr|su|sv|sw|ta|te|tg|th|tk|tl|tr|tt|uk|ur|uz|vi|yi|yo|zh|yue)
            ;;
        *)
            echo "Invalid language: $PRESET_LANG. Use one of the following: af, am, ar, as, az, ba, be, bg, bn, bo, br, bs, ca, cs, cy, da, de, el, en, es, et, eu, fa, fi, fo, fr, gl, gu, ha, haw, he, hi, hr, ht, hu, hy, id, is, it, ja, jw, ka, kk, km, kn, ko, la, lb, ln, lo, lt, lv, mg, mi, mk, ml, mn, mr, ms, mt, my, ne, nl, nn, no, oc, pa, pl, ps, pt, ro, ru, sa, sd, si, sk, sl, sn, so, sq, sr, su, sv, sw, ta, te, tg, th, tk, tl, tr, tt, uk, ur, uz, vi, yi, yo, zh, yue"
            exit 1
            ;;
    esac
fi

# 检查模型参数是否有效
case $MODEL in
    whisper.turbo|whisper.large|sensevoice)
        ;;
    *)
        echo "Invalid model: $MODEL. Use one of the following: whisper.turbo, whisper.large, sensevoice"
        exit 1
        ;;
esac
# 使用 URL_CHECK 检查HOST是否正常
CheckURL

# 使用curl上传音频文件并获取转写结果
URL="${HOST}/v1/audio/transcriptions"
echo "文件 '${AUDIO_FILE}' 将被提交到 '${URL}' 转写为 '${FORMAT}' 格式。"
echo -n "请等待……"
# 设置整个 curl 命令的参数为数组，每个参数独立存放
declare -a headers=(
    '-H' 'accept: application/json'     # 包含特殊字符*，用单引号包裹
    '-H' 'Content-Type: multipart/form-data'
    '-F' "file=@$AUDIO_FILE;type=$TYPE"  # 需变量替换，用双引号
    '-F' "model=$MODEL"
    '-F' "language=$PRESET_LANG"
    '-F' "prompt="
    '-F' "response_format=$FORMAT"
    '-F' 'temperature=0'
    '-F' 'timestamp_granularities=segment'
)

# 上传音频文件并获取转写结果
RESPONSE=$(curl --silent -X 'POST' "$URL" "${headers[@]}" )
# 输出或处理转写结果
if [ $? -eq 0 ]; then
    RESPONSE=$(echo "$RESPONSE" | jq -r '.text')
else
    echo "Response from server:"
    echo "$RESPONSE"
    exit 2
fi
# 将转写结果保存为指定格式的文件
if [ ! -z "$FORMAT" ]; then
    # 去掉扩展名并添加新的格式
    NEW_FILE="${AUDIO_FILE%.*}.$FORMAT"
    echo "Saving transcription to '$NEW_FILE'."
    echo "$RESPONSE" > "$NEW_FILE"
fi

:<<'REM'
# 返回模型列表
curl -X 'GET' 'http://adeb.local:7860/v1/models/list' -H 'accept: application/json'

{"message":"ok","data":["chat-tts","fish-speech","cosy-voice","fire-red-tts","f5-tts","index-tts","spark-tts","gpt-sovits-v1","gpt-sovits-v2","gpt-sovits-v3","gpt-sovits-v4","resemble-enhance","whisper.large","whisper.turbo","sensevoice","open-voice"]}

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

# 将目录下的播客语音文件转写文本
for a in 纵横四海/*.m4a ; do echo $a; time ./SpeechAIForgeDocker/trans.sh -f txt -m sensevoice -l zh "$a"; echo 'done.'; done
REM
exit 0
