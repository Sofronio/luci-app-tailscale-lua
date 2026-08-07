#!/bin/sh
# 用官方 po2lmo(编译自 openwrt/luci openwrt-24.10 分支)编译翻译文件
# 用法: ./tools/build-lmo.sh   (在仓库根目录运行)
set -e
cd "$(dirname "$0")/.."
./tools/bin/po2lmo po/templates.po tailscale.en.lmo   # 默认英文(仅含msgid≠msgstr的条目)
./tools/bin/po2lmo po/zh-cn.po tailscale.zh-cn.lmo
ls -la tailscale.*.lmo 2>/dev/null || true
echo "生成完成: 安装到 /usr/lib/lua/luci/i18n/"
