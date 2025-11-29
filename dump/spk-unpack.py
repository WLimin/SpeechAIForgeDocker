import os
import sys
import argparse
import requests
import soundfile as sf
from PIL import Image

now_dir = os.getcwd()
sys.path.append(now_dir)
# /app/Speech-AI-Forge
sys.path.append("%s/" % (now_dir))

from TTSSpeaker import TTSSpeaker

def get_filename_without_extension(path):
    return os.path.splitext(os.path.basename(path))[0]

def get_output_dir(spk, outdir, base_dir):
    """
    根据 spk 和 outdir 计算输出目录。

    参数:
        spk: 输入的文件或目录路径
        outdir: 输出目录（可为空）
        base_dir: 基础目录（用于截取 spk 中的相对路径）

    返回:
        str: 输出目录路径
    
    若outdir为空
        如果spk是文件，
            输出目录为该文件所在目录
        如果spk是目录，
            输出目录为spk
        否则
            抛出错误
    否则
        输出目录为outdir + '/' + (spk 截取 base_dir 后剩下的目录)

    """
    if not os.path.isabs(spk):
        spk = os.path.join(base_dir, spk)

    if not outdir:
        if os.path.isfile(spk):
            return os.path.dirname(spk)
        elif os.path.isdir(spk):
            # 如果提供了outdir，则使用outdir；否则使用当前目录
            return spk
        else:
            raise ValueError("spk must be a valid file or directory.")
    else:
        # 如果 outdir 不为空，将 spk 截取 base_dir 后的部分拼接进去
        # 例如: base_dir = '/home/user/project', spk = '/home/user/project/data/speaker.json'
        # => spk_rel = 'data/speaker.json'
        spk_rel = os.path.relpath(spk, base_dir)
        return os.path.join(outdir, os.path.dirname(spk_rel))

def download_image(url, save_path):
    print(f"Download avatar url: {url} \n    to: {save_path}")
    response = requests.get(url)
    response.raise_for_status()
    with open(save_path, 'wb') as f:
        f.write(response.content)

    # Convert to PNG
    img = Image.open(save_path)
    # 构建PNG文件路径
    base_name = os.path.splitext(save_path)[0]  # 去掉扩展名
    png_path = base_name + '.png'  # 添加.png扩展名
    img.save(png_path, 'PNG')
    os.remove(save_path)  # Remove original format file
    return png_path

def process_json_file(json_file, outdir, base_dir):
    try:
        spk = TTSSpeaker.from_file(json_file)
    except Exception as e:
        print(f"Error loading {json_file}: {e}")
        return

    # 确保输出目录存在
    out_dir = get_output_dir(json_file, outdir, base_dir)

    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    name = spk.name
    gender = spk.gender
    avatar_url = spk.avatar
    sr, wav, text = spk.get_ref_wav()

    gender_flag = 'F' if '女' in gender or 'female' in gender.lower() else 'M'
    base_name = f"{name}_{gender_flag}"

    # Output paths
    wav_path = os.path.join(out_dir, f"{base_name}.wav")
    txt_path = os.path.join(out_dir, f"{base_name}.txt")
    png_path = os.path.join(out_dir, f"{base_name}.png")

    # Write .wav
    print(f"{wav.shape[0] / sr} seconds")
    print(f"{wav.shape[0]} samples")
    print(f"{sr} kz")
    sf.write(wav_path, wav, sr)
    print(f"Saved audio: {wav_path}")

    # Write .txt
    print(f"Text: {text}")
    with open(txt_path, 'w', encoding='utf-8') as f:
        f.write(text)
    print(f"Saved text: {txt_path}")

    # Download and convert avatar to PNG
    try:
        if avatar_url:
            # 生成临时文件路径（不包含扩展名）
            temp_img_path = os.path.join(out_dir, f"{base_name}_temp")
            # 下载并转换为PNG
            final_png_path = download_image(avatar_url, temp_img_path)
            # 确保重命名正确（temp_img_path应该已经是.png了）
            if final_png_path != png_path:
                os.rename(final_png_path, png_path)  # 因为 temp_img_path 已经是 .png 了
            print(f"Saved avatar: {png_path}")
        else:
            print(f"No avatar URL for {json_file}")
    except Exception as e:
        print(f"Failed to download avatar for {json_file}: {e}")

def parse_args():
    parser = argparse.ArgumentParser(description="Edit TTSSpeaker data")
    parser.add_argument(
        "--spk",
        required=True,
        help="Speaker file or path",
    )
    parser.add_argument(
        "--out",
        required=False,
        help="Output directory path",
    )
    args = parser.parse_args()
    return args

def main():
    """ 提取并下载json中的 wav, txt, avatar。
        如果指定输出文件夹，会输出到输出文件夹下，相同层级的目录下。
    """
    args = parse_args()

    spk = args.spk
    outdir = args.out
    base_dir = spk
    # 处理输出目录
    output_dir = get_output_dir(spk, outdir, base_dir)

    # 确保输出目录存在
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # 根据spk类型确定要处理的文件
    if os.path.isfile(spk):
        json_files = [spk]
    elif os.path.isdir(spk):
        json_files = [os.path.join(root, f) for root, _, files in os.walk(spk) for f in files if f.endswith('.json')]
    else:
        raise ValueError("spk must be a valid file or directory.")

    for json_file in json_files:
        print(f"\nProcessing: {json_file}")
        process_json_file(json_file, output_dir, base_dir)

if __name__ == "__main__":
    """ python ./spk-unpack.py --spk=/tmp/spks/ --out=/tmp/out
    """
    main()
