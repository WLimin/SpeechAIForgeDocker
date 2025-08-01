#!/bin/bash
# 目标：容易删除容器且不再次下载
echo "Apply some source file patch..."
# AttributeError: module 'torch.serialization' has no attribute 'FILE_LIKE'
sed -i -e 's/FILE_LIKE/FileLike/g' /app/Speech-AI-Forge/modules/repos_static/ChatTTS/ChatTTS/core.py /app/Speech-AI-Forge/modules/repos_static/ChatTTS/ChatTTS/model/tokenizer.py
# CosyVoiceModel change to cosyvoice2.yaml
sed -i -e 's/cosyvoice.yaml/cosyvoice2.yaml/g' /app/Speech-AI-Forge/modules/core/models/tts/CosyVoiceModel.py
# robust_downloader.downloader - INFO - Downloading https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin to lid.176.bin (125.2M)
sed -i -e 's#cache_dir=.*fast_langdetect"#cache_dir="models/gpt_sovits_v4/fast_langdetect"#g' /app/Speech-AI-Forge/modules/repos_static/GPT_SoVITS/GPT_SoVITS/text/LangSegmenter/langsegmenter.py
# I don't like this error: fatal: not a git repository (or any of the parent directories): .git
#sed -i -e '/\"git_/s/^/#/' /app/Speech-AI-Forge/modules/config.py

sed -i -e '1i\import os'  /app/Speech-AI-Forge/modules/config.py
sed -i -e 's/"git_tag": /"git_tag": os.environ.get("V_GIT_TAG") or /g'  /app/Speech-AI-Forge/modules/config.py
sed -i -e 's/"git_branch": /"git_branch": os.environ.get("V_GIT_BRANCH") or /g'  /app/Speech-AI-Forge/modules/config.py
sed -i -e 's/"git_commit": /"git_commit": os.environ.get("V_GIT_COMMIT") or /g'  /app/Speech-AI-Forge/modules/config.py

# funasr version: 1.2.6, ...
# In offline it won't work that use downloading models from modelscope hub.
# download models from model hub: ms

:<<'REM_B1'
 #python3 webui.py --api
...
Traceback (most recent call last):
  File "/app/Speech-AI-Forge/webui.py", line 178, in <module>
    process_webui_args(args)
  File "/app/Speech-AI-Forge/webui.py", line 156, in process_webui_args
    process_api_args(args, app)
  File "/app/Speech-AI-Forge/modules/api/api_setup.py", line 87, in process_api_args
    api.set_cors(allow_origins=[cors_origin])
  File "/app/Speech-AI-Forge/modules/api/Api.py", line 101, in set_cors
    @self.app.middleware("http")
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/conda/lib/python3.11/site-packages/fastapi/applications.py", line 4535, in decorator
    self.add_middleware(BaseHTTPMiddleware, dispatch=func)
  File "/opt/conda/lib/python3.11/site-packages/starlette/applications.py", line 141, in add_middleware
    raise RuntimeError("Cannot add middleware after an application has started")
RuntimeError: Cannot add middleware after an application has started
不可思议的错误。我也不会调整fastapi执行顺序，将middlewar编排在app运行之前。注释。
问题原因及对策：
gradio.block.lunch()会调用route.App(FASTAPI)生成实例，设置add_middleware开始运行app。
必须采用运行时更改CORS的策略，在app.user_middleware里插入，并设置参数。借用starlette.CORSMiddleware更快速。

另外，webui.py --api启动的服务仍然在gui的7860端口。
REM_B1

patch -Np1 /app/Speech-AI-Forge/modules/api/api_setup.py </app/docker/patch_api_setup.patch

:<<'REM_B2'

  File "/app/Speech-AI-Forge/modules/core/pipeline/factory.py", line 134, in create
    raise Exception(f"Unknown model id: {model_id}")
Exception: Unknown model id: fireredtts
REM_B2

sed -i -e  's/elif model_id == "firered"/elif model_id == "fireredtts"/g' /app/Speech-AI-Forge/modules/core/pipeline/factory.py

:<<'REM_B3'
  File "/app/Speech-AI-Forge/modules/devices/devices.py", line 204, in get_gpu_memory
    total_memory = torch.cuda.get_device_properties(0).total_memory
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/conda/lib/python3.11/site-packages/torch/cuda/__init__.py", line 576, in get_device_properties
    _lazy_init()  # will define _get_device_properties
    ^^^^^^^^^^^^
  File "/opt/conda/lib/python3.11/site-packages/torch/cuda/__init__.py", line 372, in _lazy_init
    torch._C._cuda_init()
RuntimeError: Found no NVIDIA driver on your system. Please check that you have an NVIDIA GPU and installed a driver from http://www.nvidia.com/Download/index.aspx

REM_B3

sed -i -e '/torch.cuda.get_device_properties(0).total_memory/s/$/ if torch.cuda.is_available() else 0/' /app/Speech-AI-Forge/modules/devices/devices.py
sed -i -e '/torch.cuda.memory_reserved(0)/s/$/ if torch.cuda.is_available() else 0/' /app/Speech-AI-Forge/modules/devices/devices.py
sed -i -e '/torch.cuda.memory_allocated(0/s/$/ if torch.cuda.is_available() else 0/' /app/Speech-AI-Forge/modules/devices/devices.py

:<<'REM_B4'
 modules.core.models.tts.FireRed.FireRedTTSModel - INFO - loadding FireRedTTS...
Traceback (most recent call last):
 File "/app/Speech-AI-Forge/modules/repos_static/FireRedTTS/fireredtts/modules/codec/speaker.py", line 1040, in __init__
    model.load_state_dict(torch.load(ckpt_path), strict=True)
                          ^^^^^^^^^^^^^^^^^^^^^
  File "/opt/conda/lib/python3.11/site-packages/torch/serialization.py", line 605, in _validate_device
    raise RuntimeError(
RuntimeError: Attempting to deserialize object on a CUDA device but torch.cuda.is_available() is False. If you are running on a CPU-only machine, please use torch.load with map_location=torch.device('cpu') to map your storages to the CPU.

REM_B4

sed -i -e 's/\(model.load_state_dict(torch.load(ckpt_path\)\(), strict=True)\)/\1, map_location=torch.device(device)\2/g' /app/Speech-AI-Forge/modules/repos_static/FireRedTTS/fireredtts/modules/codec/speaker.py

echo "done."
