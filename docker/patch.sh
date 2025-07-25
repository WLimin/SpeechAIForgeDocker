#!/bin/bash

# AttributeError: module 'torch.serialization' has no attribute 'FILE_LIKE'
sed -i -e 's/FILE_LIKE/FileLike/g' /app/Speech-AI-Forge/modules/repos_static/ChatTTS/ChatTTS/core.py /app/Speech-AI-Forge/modules/repos_static/ChatTTS/ChatTTS/model/tokenizer.py
# CosyVoiceModel change to cosyvoice2.yaml
sed -i -e 's/cosyvoice.yaml/cosyvoice2.yaml/g' /app/Speech-AI-Forge/modules/core/models/tts/CosyVoiceModel.py

