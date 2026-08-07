#!/bin/sh
# 生成发布压缩包(页面文件 + 预编译翻译,纯文件,无脚本)
set -e
cd "$(dirname "$0")/.."
VERSION=1.0.0
./tools/build-lmo.sh >/dev/null
rm -rf /tmp/ts-release && mkdir -p /tmp/ts-release/luci-app-tailscale-lua
cp -r root /tmp/ts-release/luci-app-tailscale-lua/
cp tailscale.zh-cn.lmo /tmp/ts-release/luci-app-tailscale-lua/
mkdir -p dist
tar -C /tmp/ts-release -czf "dist/luci-app-tailscale-lua-${VERSION}.tar.gz" luci-app-tailscale-lua
rm -rf /tmp/ts-release
echo "生成: dist/luci-app-tailscale-lua-${VERSION}.tar.gz"
