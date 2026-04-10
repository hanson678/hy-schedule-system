# 河源排期入单系统

华登玩具集团内部工具 — 将客户 PO（Excel 格式）自动匹配到河源各排期文件，修改单直接回写排期，新单打包成可复制粘贴的 Excel。

## 系统要求

- **Windows 10/11**（COM 写入依赖 WPS Office）
- **WPS Office**（金山，提供 `Ket.Application` COM 接口）
- **Python 3.12+**
- 排期文件目录（本地或 Z 盘共享）

## 安装

```bash
# 1. 安装依赖
pip install -r requirements.txt

# 2. 配置排期目录
# 编辑 data/config.json，修改 default_schedule_dir 为你的排期文件路径

# 3. 扫描货号映射（首次运行或排期新增货号后重跑）
python scan_hy_items.py "你的排期目录路径"

# 4. 启动
python app.py
# 或双击 启动系统.bat
```

## 访问

- 本机：http://localhost:5006
- 局域网：http://你的IP:5006

## 功能

| 功能 | 说明 |
|------|------|
| 修改单自动写入 | WPS COM 打开排期文件 → 蓝色标记改动单元格 → 保存关闭 |
| 新单 Excel 生成 | 按目标排期文件分 sheet，28 列严格对齐，含公式占位符 |
| 未识别货号 | 红色标签 sheet 独立输出，需手动确认目标排期 |
| 跨文件重复货号 | 前端弹窗让用户选择目标文件 |
| 货号直查表 | hy_item_map.json，161 个货号 → 文件/sheet 映射 |

## 配置

`data/config.json`：
```json
{
  "port": 5006,
  "default_schedule_dir": "你的排期文件目录路径"
}
```

## 文件结构

```
├── app.py              # Flask 主程序
├── hy_schedule.py      # 核心：全局索引 + COM 写入 + 新单 Excel
├── scan_hy_items.py    # 货号映射扫描脚本
├── excel_po_parser.py  # Excel PO 解析器
├── pdf_parser.py       # PDF PO 解析器
├── data/
│   ├── config.json     # 系统配置
│   └── hy_item_map.json # 货号直查表
├── templates/
│   └── hy_master.html  # 前端页面
├── uploads/            # PO 临时上传目录（自动创建）
├── exports/            # 新单 Excel 输出目录（自动创建）
├── 启动系统.bat        # 带控制台启动
└── 一键启动.vbs        # 静默启动
```
