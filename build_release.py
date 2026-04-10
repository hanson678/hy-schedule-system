# -*- coding: utf-8 -*-
"""打包河源排期系统为发布zip

使用：python build_release.py
输出：dist/河源排期入单系统_vX.Y.Z.zip
"""
import os
import sys
import io
import json
import shutil
import zipfile
from datetime import datetime

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# ========== 版本号 ==========
VERSION = '1.0.0'

APP_DIR = os.path.dirname(os.path.abspath(__file__))
DIST_DIR = os.path.join(APP_DIR, 'dist')

# 需要打包的文件/目录
INCLUDE = [
    'app.py',
    'hy_schedule.py',
    'scan_hy_items.py',
    'excel_po_parser.py',
    'pdf_parser.py',
    'requirements.txt',
    'README.md',
    '一键安装启动.bat',
    'templates/',
    'static/',
]

# data/ 目录特殊处理：只含 config 模板和空的 hy_item_map
DATA_FILES = {
    'data/config.json': json.dumps({
        'port': 5006,
        'default_schedule_dir': ''
    }, ensure_ascii=False, indent=2),
    'data/hy_item_map.json': '{}',
}

# 排除的模式
EXCLUDE_PATTERNS = (
    '__pycache__', '.pyc', '.git', '.venv', 'dist',
    'uploads', 'exports', 'ops.log', '.bak', '~$',
    'build_release.py', 'test_',
)


def should_exclude(path):
    for pat in EXCLUDE_PATTERNS:
        if pat in path:
            return True
    return False


def build():
    os.makedirs(DIST_DIR, exist_ok=True)

    zip_name = f'河源排期入单系统_v{VERSION}.zip'
    zip_path = os.path.join(DIST_DIR, zip_name)
    # 压缩包内顶层文件夹名
    top_dir = f'河源排期入单系统_v{VERSION}'

    if os.path.exists(zip_path):
        os.remove(zip_path)

    count = 0
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        # 1. 打包代码文件
        for item in INCLUDE:
            src = os.path.join(APP_DIR, item)
            if os.path.isfile(src):
                arcname = f'{top_dir}/{item}'
                if not should_exclude(arcname):
                    zf.write(src, arcname)
                    count += 1
                    print(f'  + {item}')
            elif os.path.isdir(src):
                for root, dirs, files in os.walk(src):
                    # 跳过排除目录
                    dirs[:] = [d for d in dirs if not should_exclude(d)]
                    for fn in files:
                        if should_exclude(fn):
                            continue
                        fpath = os.path.join(root, fn)
                        rel = os.path.relpath(fpath, APP_DIR)
                        arcname = f'{top_dir}/{rel}'.replace('\\', '/')
                        zf.write(fpath, arcname)
                        count += 1
                        print(f'  + {rel}')

        # 2. 写入 data/ 模板文件（空配置，不含本机路径）
        for rel_path, content in DATA_FILES.items():
            arcname = f'{top_dir}/{rel_path}'
            zf.writestr(arcname, content)
            count += 1
            print(f'  + {rel_path} (模板)')

        # 3. 写入版本信息文件
        version_info = json.dumps({
            'version': VERSION,
            'build_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'python_version': f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}',
        }, ensure_ascii=False, indent=2)
        zf.writestr(f'{top_dir}/VERSION.json', version_info)
        count += 1
        print(f'  + VERSION.json')

    size_mb = os.path.getsize(zip_path) / 1024 / 1024
    print(f'\n打包完成：{zip_path}')
    print(f'版本：v{VERSION}')
    print(f'文件数：{count}')
    print(f'大小：{size_mb:.1f} MB')


if __name__ == '__main__':
    print(f'河源排期入单系统 打包工具 v{VERSION}')
    print(f'源目录：{APP_DIR}\n')
    build()
