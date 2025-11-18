#!/bin/bash
# 目标：容易删除容器且不再次下载
echo "Apply some source file patch..."
# AttributeError: module 'torch.serialization' has no attribute 'FILE_LIKE'
sed -i -e 's/FILE_LIKE/FileLike/g' /app/Speech-AI-Forge/modules/repos_static/ChatTTS/ChatTTS/core.py /app/Speech-AI-Forge/modules/repos_static/ChatTTS/ChatTTS/model/tokenizer.py

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
#line 15
sed -i -e '/gpu_mem = devices.get_gpu_memory()/s/$/ if devices.torch.cuda.is_available() else devices.MemUsage(devices.device, 0, 0, 0)/' /app/Speech-AI-Forge/modules/webui/system_tab.py

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
# force use the dark theme, why?
sed -i -e 's#js=js_func, ##g' /app/Speech-AI-Forge/modules/webui/app.py

:<<'REM_B5'
transformers==4.52.1
执行ChatTTS:
```
  File "/app/Speech-AI-Forge/modules/repos_static/ChatTTS/ChatTTS/model/gpt.py", line 288, in _prepare_generation_inputs
    max_cache_length = past_key_values.get_max_length()
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AttributeError: 'DynamicCache' object has no attribute 'get_max_length'
```
transformers==4.48.3 执行ChatTTS正常，不出错。但是，执行IndexTTS-V2，出现错误：
```
Loading config.json from local directory
Loading weights from local directory
Traceback (most recent call last):
  File "/opt/conda/lib/python3.11/site-packages/transformers/models/auto/configuration_auto.py", line 1034, in from_pretrained
    config_class = CONFIG_MAPPING[config_dict["model_type"]]
                   ~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/conda/lib/python3.11/site-packages/transformers/models/auto/configuration_auto.py", line 736, in __getitem__
    raise KeyError(key)
KeyError: 'qwen3'

During handling of the above exception, another exception occurred:
....
 File "/app/Speech-AI-Forge/modules/core/models/tts/IndexTTS/infer/infer_v2.py", line 782, in __init__
    self.model = AutoModelForCausalLM.from_pretrained(
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/conda/lib/python3.11/site-packages/modelscope/utils/hf_util.py", line 278, in from_pretrained
    module_obj = module_class.from_pretrained(model_dir, *model_args,
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/conda/lib/python3.11/site-packages/transformers/models/auto/auto_factory.py", line 526, in from_pretrained
    config, kwargs = AutoConfig.from_pretrained(
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/conda/lib/python3.11/site-packages/transformers/models/auto/configuration_auto.py", line 1036, in from_pretrained
    raise ValueError(
ValueError: The checkpoint you are trying to load has model type `qwen3` but Transformers does not recognize this architecture. This could be because of an issue with the checkpoint, or because your version of Transformers is out of date.
```
REM_B5
sed -i -e "s/\(max_cache_length = past_key_values.get_max_length()\)/\1 if hasattr(past_key_values, 'get_max_length') else past_key_values.get_seq_length() # 检查是否具有 'get_seq_length' 属性(transformers_version>4.80)/g" /app/Speech-AI-Forge/modules/repos_static/ChatTTS/ChatTTS/model/gpt.py

:<<'REM_B6'
反向代理问题
/docs, /redoc绝对路径造成反向代理问题。添加环境变量GRADIO_ROOT_PATH。涉及文件Speech-AI-Forge/:
./modules/webui/app.py:59:        footer_items.append(f"[api](/docs)")

GRADIO_ROOT_PATH='/abc' python3 -c "import os;print(f\"[api]({os.environ.get('GRADIO_ROOT_PATH', '')}/docs)\")"

下列文件因为属于gradio附属函数，会被正确处理环境变量。
./modules/api/worker.py:40:    docs_url=None if config.runtime_env_vars.no_docs else "/docs",
./webui.py:143:                else None if config.runtime_env_vars.no_docs else "/docs"

./modules/api/worker.py:39:    redoc_url=None if config.runtime_env_vars.no_docs else "/redoc",
./webui.py:138:                else None if config.runtime_env_vars.no_docs else "/redoc"

REM_B6
sed -i -e "s#\(footer_items.append(f\"\[api\](\)\(/docs)\")\)#\1{os.environ.get('GRADIO_ROOT_PATH', '')}\2#g" /app/Speech-AI-Forge/modules/webui/app.py
echo "done."
