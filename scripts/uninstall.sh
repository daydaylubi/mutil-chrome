#!/bin/bash
set -euo pipefail

APP_DST="/Applications/MultiChrome.app"

if [[ -d "${APP_DST}" ]]; then
    echo "移除 ${APP_DST} 需要管理员权限"
    sudo rm -rf "${APP_DST}"
    echo "已卸载 MultiChrome"
else
    echo "未在 /Applications 发现 MultiChrome.app"
fi

read -r -p "是否清理日志目录 ~/Library/Logs/MultiChrome ? [y/N]: " ans
if [[ "${ans:-}" =~ ^[Yy]$ ]]; then
    rm -rf "${HOME}/Library/Logs/MultiChrome"
    echo "已清理日志"
fi

