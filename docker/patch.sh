#!/bin/bash
# 目标：容易删除容器且不再次下载
# AttributeError: module 'torch.serialization' has no attribute 'FILE_LIKE'
sed -i -e 's/FILE_LIKE/FileLike/g' /app/Speech-AI-Forge/modules/repos_static/ChatTTS/ChatTTS/core.py /app/Speech-AI-Forge/modules/repos_static/ChatTTS/ChatTTS/model/tokenizer.py
# CosyVoiceModel change to cosyvoice2.yaml
sed -i -e 's/cosyvoice.yaml/cosyvoice2.yaml/g' /app/Speech-AI-Forge/modules/core/models/tts/CosyVoiceModel.py
# robust_downloader.downloader - INFO - Downloading https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin to lid.176.bin (125.2M)
sed -i -e 's#cache_dir=.*$#cache_dir="models/gpt_sovits_v4/fast_langdetect"#g' /app/Speech-AI-Forge/modules/repos_static/GPT_SoVITS/GPT_SoVITS/text/LangSegmenter/langsegmenter.py
# I don't like this error: fatal: not a git repository (or any of the parent directories): .git
sed -i -e '/\"git_/s/^/#/' /app/Speech-AI-Forge/modules/config.py
# funasr version: 1.2.6, ...
# In offline it won't work that use downloading models from modelscope hub.
# download models from model hub: ms

