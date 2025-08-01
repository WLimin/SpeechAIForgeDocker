# SpeechAIForgeDocker
A Dockerfile for building the [Speech-AI-Forge](https://github.com/lenML/Speech-AI-Forge) docker image with Nvidia GeForce RTX 5070 Ti.
如上所述，本仓库将采用 Torch 2.7.1+cu128，基础镜像为 pytorch/pytorch:2.7.1-cuda12.8-cudnn9-runtime。如果你的硬件不符合，需要自己调整基础镜像。已经尽量放松python pip包版本约束了。

## 测试的运行系统
Debian 13 Linux，docker-ce (Docker version 28.3.2, build 578ccf6).
INTEL CPU(AMD64)

## 特点
* 容器不采用root，而是以uid=1000, user=webui运行映射到当前用户和当前路径。
* 镜像中的[Speech-AI-Forge](https://github.com/lenML/Speech-AI-Forge)代码不保留.git仓库，因此运行时会出现三行git错误提示。可以删除.dockerignore中的*/.git来避免。已经patch。
* 已经测试成功：
    webui.py支持下的Web界面，以及该界面下的ChatTTS，CosyVoice2-0.5B。

## 代码组织
* [Speech-AI-Forge/](https://github.com/lenML/Speech-AI-Forge) 以子模块方式存放原始代码，不作改动。源代码补丁在打包镜像时完成。
* docker/	存放构建镜像所需要的脚本、补丁等
* models/ 存放容器运行时下载的模型文件
* build.sh 构建镜像
* run.sh  创建容器并开启WebUI/API服务
* cli.sh  创建容器并打开交互命令行
* common.sh 创建容器公共支持。会被build.sh 构建镜像时修改 GIT_TAG、GIT_COMMIT 和 GIT_BRANCH 等3个变量。它们是指子模块中原始代码仓库的内容。

## 如何使用
用 build.sh 构建镜像。
**首次使用**或需要增加模型时，用cli.sh 创建容器并打开交互命令行，按照 [Speech-AI-Forge/README.md](https://github.com/lenML/Speech-AI-Forge/README.md) 的说明和自己需求，**下载需要的模型文件**。
其它使用，可以用run.sh创建容器并开启WebUI/API服务。
###已更新
可以在镜像构建前，在当前路径下执行 down_models_all.sh 来下载用到的模型文件。若windows系统，可以考虑用WSL，或者用bash docker执行下载。

docker用法不详细叙述，自己AI。

## 版权问题
各人版权归各人，本人没有任何版权。此仓库仅用于本人学习之目的，其它用户使用后果自负，与本人无关。
