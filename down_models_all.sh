#!/bin/bash
#创建 Speech-AI-Forge 需要的所有模型目录及下载模型
# 2025-07-30 14:18:42
# 外部工具 wget unzip bash

#要下载的模型保存位置，默认当前目录下/models
MOOD_ZOOM=$PWD/models

mkdir_all(){
    mkdir -p ${MOOD_ZOOM}/{OpenVoiceV2,resemble-enhance,F5-TTS/F5TTS_v1_Base,FireRedTTS,faster-whisper-large-v3-turbo-ct2,\
Index-TTS-1.5,tagger_cache,CosyVoice2-0.5B/{CosyVoice-BlankEN,asset},fish-speech-1_4,faster-whisper-large-v3,Lora,\
Spark-TTS-0.5B/{wav2vec2-large-xlsr-53,LLM,src/figures,src/logo,BiCodec},Denoise,\
nltk_data/{taggers/{averaged_perceptron_tagger_eng,averaged_perceptron_tagger},corpora/cmudict},\
ChatTTS/{asset/{tokenizer,gpt},config},vocos-mel-24khz,SenseVoiceSmall/{example,fig},fsmn-vad/{example,fig},\
gpt_sovits_v4/{chinese-hubert-base,gsv-v2final-pretrained,fast_langdetect,gsv-v4-pretrained,\
models--nvidia--bigvgan_v2_24khz_100band_256x,chinese-roberta-wwm-ext-large,v2Pro,sv},\
Index-TTS-2/qwen0.6bemo4-merge,amphion/MaskGCT/semantic_codec,nvidia/bigvgan_v2_22khz_80band_256x,funasr/campplus,facebook/w2v-bert-2.0}
}
#下载指定列表
wget_required_list(){
    if [ "A$1" == "A" ]; then
        MAIN="main"
    else
        MAIN="$1"
    fi
    REQUIRED_URL="${MODEL_REPO_URL}/${MODEL_REPO_ID}/resolve/${MAIN}"
    for Required_File in ${REQUIRED_FILES[@]}; do
        wget -c ${REQUIRED_URL}/${Required_File} -O ${MOOD_ZOOM}/${LOCAL_BASE_DIR}/${Required_File}
    done
}

mkdir_all

#开始下载模型数据
echo "Download ChatTTS..."
MODEL_REPO_URL="https://modelscope.cn/models"
MODEL_REPO_ID="AI-ModelScope/ChatTTS"
LOCAL_BASE_DIR="ChatTTS"
REQUIRED_FILES=( "asset/DVAE.pt" "asset/DVAE_full.pt" "asset/Decoder.pt" "asset/GPT.pt" \
 "asset/Vocos.pt" "asset/spk_stat.pt" "asset/tokenizer.pt" "asset/tokenizer/special_tokens_map.json" \
 "asset/tokenizer/tokenizer.json" "asset/tokenizer/tokenizer_config.json" \
 "config/decoder.yaml" "config/dvae.yaml" "config/gpt.yaml" "config/path.yaml" "config/vocos.yaml" \
 "configuration.json" "asset/Vocos.safetensors" "asset/Embed.safetensors" "asset/Decoder.safetensors" \
 "asset/DVAE.safetensors" "asset/gpt/model.safetensors" "asset/gpt/config.json" "README.md")
wget_required_list "master"

echo "Download CosyVoice2-0.5B..."
#https://hf-mirror.com/FunAudioLLM/CosyVoice2-0.5B 24小时前被清空，https://modelscope.cn/models/iic/CosyVoice2-0.5B 正常
MODEL_REPO_URL="https://modelscope.cn/models"
MODEL_REPO_ID="iic/CosyVoice2-0.5B"
LOCAL_BASE_DIR="CosyVoice2-0.5B"
REQUIRED_FILES=("campplus.onnx" "configuration.json" "cosyvoice2.yaml" "flow.pt" "hift.pt" "llm.pt" "speech_tokenizer_v2.onnx" \
 "CosyVoice-BlankEN/model.safetensors" "CosyVoice-BlankEN/config.json" "CosyVoice-BlankEN/generation_config.json" \
 "CosyVoice-BlankEN/merges.txt" "CosyVoice-BlankEN/tokenizer_config.json" "CosyVoice-BlankEN/vocab.json" "README.md" )
wget_required_list "master"

echo "Download F5-TTS V1.25..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="SWivid/F5-TTS"
LOCAL_BASE_DIR="F5-TTS"
REQUIRED_FILES=("F5TTS_v1_Base/model_1250000.safetensors" )
wget_required_list

echo "Download faster-whisper-large-v3..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="Systran/faster-whisper-large-v3"
LOCAL_BASE_DIR="faster-whisper-large-v3"
REQUIRED_FILES=("config.json" "model.bin" "preprocessor_config.json" "README.md" "tokenizer.json" "vocabulary.json" )
wget_required_list

echo "Download faster-whisper-large-v3-turbo-ct2..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="deepdml/faster-whisper-large-v3-turbo-ct2"
LOCAL_BASE_DIR="faster-whisper-large-v3-turbo-ct2"
REQUIRED_FILES=("config.json" "model.bin" "preprocessor_config.json" "README.md" "tokenizer.json" "vocabulary.json" )
wget_required_list

echo "Download FireRedTTS..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="fireredteam/FireRedTTS"
LOCAL_BASE_DIR="FireRedTTS"
REQUIRED_FILES=("fireredtts_gpt.pt" "fireredtts_speaker.bin" "fireredtts_token2wav.pt" )
wget_required_list

echo "Download fishaudio/fish-speech-1.4..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="fishaudio/fish-speech-1.4"
LOCAL_BASE_DIR="fish-speech-1_4"
REQUIRED_FILES=("config.json" "firefly-gan-vq-fsq-8x1024-21hz-generator.pth" "model.pth" "special_tokens_map.json" \
 "tokenizer.json" "tokenizer_config.json" "README.md" )
wget_required_list

echo "Download GPT-SoVITS V4..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="lj1995/GPT-SoVITS"
LOCAL_BASE_DIR="gpt_sovits_v4"
REQUIRED_FILES=("chinese-hubert-base/config.json" "chinese-hubert-base/preprocessor_config.json" "chinese-hubert-base/pytorch_model.bin" \
 "chinese-roberta-wwm-ext-large/config.json" "chinese-roberta-wwm-ext-large/pytorch_model.bin" "chinese-roberta-wwm-ext-large/tokenizer.json" \
 "gsv-v2final-pretrained/s1bert25hz-5kh-longer-epoch=12-step=369668.ckpt" "gsv-v2final-pretrained/s2D2333k.pth" "gsv-v2final-pretrained/s2G2333k.pth" \
 "gsv-v4-pretrained/s2Gv4.pth" "gsv-v4-pretrained/vocoder.pth" "models--nvidia--bigvgan_v2_24khz_100band_256x/bigvgan_generator.pt" \
 "models--nvidia--bigvgan_v2_24khz_100band_256x/config.json" "s1bert25hz-2kh-longer-epoch=68e-step=50232.ckpt" "s1v3.ckpt" "s2D488k.pth" \
 "s2G488k.pth" "s2Gv3.pth" "v2Pro/s2Dv2Pro.pth" "v2Pro/s2Dv2ProPlus.pth" "v2Pro/s2Gv2Pro.pth" "v2Pro/s2Gv2ProPlus.pth" \
 "sv/pretrained_eres2netv2w24s4ep4.ckpt" )
wget_required_list

echo "Download Index-TTS-1.5..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="IndexTeam/IndexTTS-1.5"
LOCAL_BASE_DIR="Index-TTS-1.5"
REQUIRED_FILES=("bigvgan_discriminator.pth" "bigvgan_generator.pth" "bpe.model" "config.yaml" "dvae.pth" "gpt.pth" "unigram_12000.vocab" "README" "README.md" )
wget_required_list

echo "Download Index-TTS-2..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="IndexTeam/IndexTTS-2"
LOCAL_BASE_DIR="Index-TTS-2"
REQUIRED_FILES=("gpt.pth" "s2mel.pth" "qwen0.6bemo4-merge/model.safetensors" ".gitattributes" "README.md" "bpe.model" "config.yaml" "feat1.pt" "feat2.pt" "wav2vec2bert_stats.pt" \
"qwen0.6bemo4-merge/Modelfile" "qwen0.6bemo4-merge/added_tokens.json" "qwen0.6bemo4-merge/chat_template.jinja" "qwen0.6bemo4-merge/config.json" "qwen0.6bemo4-merge/generation_config.json" \
"qwen0.6bemo4-merge/merges.txt" "qwen0.6bemo4-merge/special_tokens_map.json" "qwen0.6bemo4-merge/tokenizer.json" "qwen0.6bemo4-merge/tokenizer_config.json" "qwen0.6bemo4-merge/vocab.json" )
wget_required_list

echo "Download OpenVoiceV2..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="myshell-ai/OpenVoiceV2"
LOCAL_BASE_DIR="OpenVoiceV2"
REQUIRED_FILES=("converter/checkpoint.pth" "converter/config.json" "README.md" )
wget_required_list

echo "Download SparkAudio/Spark-TTS-0.5B..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="SparkAudio/Spark-TTS-0.5B"
LOCAL_BASE_DIR="Spark-TTS-0.5B"
REQUIRED_FILES=( "BiCodec/config.yaml" "BiCodec/model.safetensors" "config.yaml" "LLM/added_tokens.json" "LLM/config.json" "LLM/merges.txt" \
 "LLM/model.safetensors" "LLM/special_tokens_map.json" "LLM/tokenizer_config.json" "LLM/tokenizer.json" "LLM/vocab.json" "README.md" \
 "wav2vec2-large-xlsr-53/config.json" "wav2vec2-large-xlsr-53/preprocessor_config.json" "wav2vec2-large-xlsr-53/pytorch_model.bin" \
 "wav2vec2-large-xlsr-53/README.md" )
wget_required_list

echo "Download vocos-mel-24khz..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="charactr/vocos-mel-24khz"
LOCAL_BASE_DIR="vocos-mel-24khz"
REQUIRED_FILES=("config.yaml" "pytorch_model.bin" )
wget_required_list

echo "Download FunAudioLLM/SenseVoiceSmall..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="FunAudioLLM/SenseVoiceSmall"
LOCAL_BASE_DIR="SenseVoiceSmall"
REQUIRED_FILES=("am.mvn" "chn_jpn_yue_eng_ko_spectok.bpe.model" "configuration.json" "config.yaml" "model.pt" "README.md" "README_zh.md" "tokens.json" )
wget_required_list

echo "Download funasr/fsmn-vad..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="funasr/fsmn-vad"
LOCAL_BASE_DIR="fsmn-vad"
REQUIRED_FILES=("am.mvn" "configuration.json" "config.yaml" "example/vad_example.wav" "fig/struct.png" "model.pt" "README.md" )
wget_required_list

echo "Download ResembleAI/resemble-enhance..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="ResembleAI/resemble-enhance"
LOCAL_BASE_DIR="resemble-enhance"
REQUIRED_FILES=("hparams.yaml" )
wget_required_list
wget -c ${REQUIRED_URL}/enhancer_stage2/ds/G/default/mp_rank_00_model_states.pt -O ${MOOD_ZOOM}/${LOCAL_BASE_DIR}/mp_rank_00_model_states.pt

echo "Download fast_langdetect model..."
wget -c https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin -O ${MOOD_ZOOM}/gpt_sovits_v4/fast_langdetect/lid.176.bin

echo "Download nltk_data model..."
wget -c https://www.modelscope.cn/models/XXXXRT/GPT-SoVITS-Pretrained/resolve/master/nltk_data.zip -O /tmp/nltk_data.zip
unzip -q -o /tmp/nltk_data.zip -d ${MOOD_ZOOM}/
rm /tmp/nltk_data.zip

echo "Download amphion/MaskGCT..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="amphion/MaskGCT"
LOCAL_BASE_DIR="amphion/MaskGCT"
REQUIRED_FILES=("semantic_codec/model.safetensors" )
wget_required_list

echo "Download nvidia/bigvgan_v2_22khz_80band_256x..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="nvidia/bigvgan_v2_22khz_80band_256x"
LOCAL_BASE_DIR="nvidia/bigvgan_v2_22khz_80band_256x"
REQUIRED_FILES=("configuration.json" "config.json" "bigvgan_generator.pt" )
wget_required_list

echo "Download funasr/campplus..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="funasr/campplus"
LOCAL_BASE_DIR="funasr/campplus"
REQUIRED_FILES=("campplus_cn_common.bin" )
wget_required_list

echo "Download facebook/w2v-bert-2.0..."
MODEL_REPO_URL="https://hf-mirror.com"
MODEL_REPO_ID="facebook/w2v-bert-2.0"
LOCAL_BASE_DIR="facebook/w2v-bert-2.0"
REQUIRED_FILES=("preprocessor_config.json" "config.json" "model.safetensors" )
wget_required_list

:<<'REM'
下面的目录可以不预先下载，等待容器首次启动运行后自动完成。
${MOOD_ZOOM}/tagger_cache/zh_tn_tagger.fst
${MOOD_ZOOM}/tagger_cache/zh_tn_verbalizer.fst

用法：
运行本脚本，会在当前目录下创建models目录，并下载几乎用到的所有模型文件。
确保空间够用。

对于docker容器，挂载卷 models 到容器内 Speech-AI-Forge/models 目录: -v ${PWD}/models:/app/Speech-AI-Forge/models 。

已知问题
长时间使用 hf-mirror.com 会造成限速。本文件下载调用 wget 支持断点续传。
Speech-AI-Forge 自带的下载脚本采用python编写，需要系统安装python及支持模块才能运行。本文件配合docker使用，对宿主机python无特别要求。
REM
