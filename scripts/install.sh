#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_SRC="${PROJECT_ROOT}/dist/MultiChrome.app"
APP_DST="/Applications/MultiChrome.app"

if [[ ! -d "${APP_SRC}" ]]; then
    echo "未找到 ${APP_SRC}，请先运行 scripts/build_app.sh 生成应用。"
    exit 1
fi

echo "安装到 /Applications 需要管理员权限（如失败将自动提示使用 sudo）"

set +e
cp -R "${APP_SRC}" "${APP_DST}" 2>/dev/null
STATUS=$?
set -e

if [[ ${STATUS} -ne 0 ]]; then
    echo "赋权并安装..."
    sudo rm -rf "${APP_DST}"
    sudo cp -R "${APP_SRC}" "${APP_DST}"
fi

echo "已安装: ${APP_DST}"
echo "首次运行如遇到安全提示：右键应用图标 -> 打开 -> 再次打开"

