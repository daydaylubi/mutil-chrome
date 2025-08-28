#!/bin/bash

# Chrome 可执行文件路径
CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# 基础用户数据目录
BASE_USER_DATA_DIR="$HOME/Library/Application Support/Google"

# 显示使用方法
show_usage() {
    echo "Chrome 多实例管理工具"
    echo ""
    echo "数据目录: $BASE_USER_DATA_DIR/Chrome_Instance_*"
    echo ""
    echo "使用方法:"
    echo "  $0 <实例数量>            # 启动指定数量的 Chrome 实例"
    echo "  $0 -n <实例编号>         # 启动指定编号的 Chrome 实例"
    echo "  $0 -h, --help           # 显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 3                    # 启动3个 Chrome 实例 (1-3)"
    echo "  $0 -n 2                 # 启动第2个 Chrome 实例"
    echo ""
    echo "当前实例目录:"
    ls -d "$BASE_USER_DATA_DIR/Chrome_Instance_"* 2>/dev/null | sort -V || echo "  暂无实例"
    exit 0
}

# 创建新的用户数据目录
create_chrome_instance() {
    local instance_num=$1
    local user_data_dir="$BASE_USER_DATA_DIR/Chrome_Instance_$instance_num"
    
    # 如果目录不存在，创建它
    if [ ! -d "$user_data_dir" ]; then
        mkdir -p "$user_data_dir"
    fi
    
    # 启动 Chrome 实例
    "$CHROME_PATH" --user-data-dir="$user_data_dir" > /dev/null 2>&1 &
    
    # 等待 Chrome 启动
    sleep 3
    
    # 等待 Chrome 完全启动
    sleep 1
}

# 检查 Chrome 是否存在
if [ ! -f "$CHROME_PATH" ]; then
    echo "错误：找不到 Chrome 可执行文件"
    exit 1
fi

# 默认值
NUM_INSTANCES=0
SINGLE_INSTANCE=0
INSTANCE_NUM=0

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            ;;
        -n|--instance)
            SINGLE_INSTANCE=1
            INSTANCE_NUM=$2
            shift
            ;;
        *)
            if [[ $1 =~ ^[0-9]+$ ]]; then
                NUM_INSTANCES=$1
            else
                echo "错误：无效的参数 $1"
                show_usage
                exit 1
            fi
            ;;
    esac
    shift
done

# 验证参数
if [ $SINGLE_INSTANCE -eq 1 ]; then
    if [ $INSTANCE_NUM -lt 1 ] || [ $INSTANCE_NUM -gt 10 ]; then
        echo "错误：实例编号必须在 1-10 之间"
        exit 1
    fi
    
    echo "正在启动 Chrome 实例 $INSTANCE_NUM..."
    create_chrome_instance $INSTANCE_NUM
    echo "已启动 Chrome 实例 $INSTANCE_NUM"
    echo "数据目录: $BASE_USER_DATA_DIR/Chrome_Instance_$INSTANCE_NUM"
else
    if [ $NUM_INSTANCES -lt 1 ]; then
        show_usage
        exit 0
    fi
    
    # 确保实例数量在合理范围内
    if [ $NUM_INSTANCES -gt 10 ]; then
        echo "错误：最多支持 10 个实例"
        exit 1
    fi

    echo "正在启动 $NUM_INSTANCES 个 Chrome 实例..."
    
    # 先关闭所有现有的 Chrome 实例
    pkill -9 -f "Google Chrome.*Chrome_Instance_" 2>/dev/null
    sleep 2

    for i in $(seq 1 $NUM_INSTANCES); do
        echo "启动 Chrome 实例 $i..."
        create_chrome_instance $i
    done
    
    echo "已启动 $NUM_INSTANCES 个 Chrome 实例"
fi