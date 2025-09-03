#!/bin/bash

# Chrome 可执行文件路径
CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# 基础用户数据目录
BASE_USER_DATA_DIR="$HOME/Library/Application Support/Google"

# 脚本名称（用于显示）
SCRIPT_NAME=$(basename "$0")

# 显示使用方法
show_usage() {
    echo "Chrome 多实例管理工具"
    echo ""
    echo "数据目录: $BASE_USER_DATA_DIR/Chrome_Instance_*"
    echo ""
    echo "使用方法:"
    echo "  $SCRIPT_NAME <实例数量>            # 启动指定数量的 Chrome 实例"
    echo "  $SCRIPT_NAME -n <实例编号>         # 启动指定编号的 Chrome 实例"
    echo "  $SCRIPT_NAME -r <起始编号>-<结束编号>  # 启动指定编号区间的 Chrome 实例"
    echo "  $SCRIPT_NAME -s                   # 显示当前运行的实例状态"
    echo "  $SCRIPT_NAME -k [实例编号]         # 关闭所有实例或指定实例"
    echo "  $SCRIPT_NAME -K <起始编号>-<结束编号>  # 关闭指定编号区间的 Chrome 实例"
    echo "  $SCRIPT_NAME -h, --help           # 显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $SCRIPT_NAME 3                    # 启动3个 Chrome 实例 (1-3)"
    echo "  $SCRIPT_NAME -n 2                 # 启动第2个 Chrome 实例"
    echo "  $SCRIPT_NAME -r 3-6               # 启动第3到第6个 Chrome 实例"
    echo "  $SCRIPT_NAME -k                   # 关闭所有实例"
    echo "  $SCRIPT_NAME -k 2                 # 关闭第2个实例"
    echo "  $SCRIPT_NAME -K 3-6               # 关闭第3到第6个 Chrome 实例"
    echo "  $SCRIPT_NAME -s                   # 查看实例状态"
    echo ""
    show_instances_status
}

# 显示实例状态
show_instances_status() {
    echo "当前实例目录:"
    local found=0
    
    # Use find to handle paths with spaces correctly
    while IFS= read -r -d '' dir; do
        local instance_num=$(basename "$dir" | sed 's/Chrome_Instance_//')
        local status="已停止"
        if pgrep -f "Google Chrome.*Chrome_Instance_$instance_num" >/dev/null 2>&1; then
            status="运行中"
        fi
        printf "  实例 %-3s: %s (%s)\n" "$instance_num" "$status" "$dir"
        found=1
    done < <(find "$BASE_USER_DATA_DIR" -maxdepth 1 -type d -name "Chrome_Instance_*" -print0 2>/dev/null | sort -Vz)
    
    if [ $found -eq 0 ]; then
        echo "  暂无实例"
    fi
}

# 检查实例是否正在运行
is_instance_running() {
    local instance_num=$1
    pgrep -f "Google Chrome.*Chrome_Instance_$instance_num" >/dev/null 2>&1
}

# 等待Chrome启动完成
wait_for_chrome_startup() {
    local instance_num=$1
    local max_wait=10
    local count=0
    
    while [ $count -lt $max_wait ]; do
        if is_instance_running $instance_num; then
            return 0
        fi
        sleep 1
        ((count++))
    done
    return 1
}

# 创建新的用户数据目录并启动实例
create_chrome_instance() {
    local instance_num=$1
    local user_data_dir="$BASE_USER_DATA_DIR/Chrome_Instance_$instance_num"
    
    # 检查实例是否已经在运行
    if is_instance_running $instance_num; then
        echo "跳过：实例 $instance_num 已经在运行中"
        return 0
    fi
    
    # 如果目录不存在，创建它
    if [ ! -d "$user_data_dir" ]; then
        if ! mkdir -p "$user_data_dir"; then
            echo "错误：无法创建目录 $user_data_dir"
            return 1
        fi
    fi
    
    # 启动 Chrome 实例
    if ! "$CHROME_PATH" --user-data-dir="$user_data_dir" --no-default-browser-check --disable-default-apps > /dev/null 2>&1 & then
        echo "错误：无法启动 Chrome 实例 $instance_num"
        return 1
    fi
    
    # 等待 Chrome 启动完成
    if wait_for_chrome_startup $instance_num; then
        echo "✓ Chrome 实例 $instance_num 启动成功"
        return 0
    else
        echo "✗ Chrome 实例 $instance_num 启动超时"
        return 1
    fi
}

# 关闭指定实例
kill_instance() {
    local instance_num=$1
    if [ -n "$instance_num" ]; then
        if is_instance_running $instance_num; then
            pkill -f "Google Chrome.*Chrome_Instance_$instance_num"
            echo "已关闭实例 $instance_num"
        else
            echo "实例 $instance_num 未在运行"
        fi
    else
        # 关闭所有实例
        if pgrep -f "Google Chrome.*Chrome_Instance_" >/dev/null 2>&1; then
            pkill -f "Google Chrome.*Chrome_Instance_"
            sleep 2
            echo "已关闭所有Chrome实例"
        else
            echo "没有运行中的Chrome实例"
        fi
    fi
}

# 关闭指定区间的实例
kill_instance_range() {
    local start=$1
    local end=$2
    
    # 验证参数
    if ! validate_range_numbers $start $end; then
        return 1
    fi
    
    echo "正在关闭 Chrome 实例 $start 到 $end..."
    
    local closed_count=0
    local not_running_count=0
    
    for i in $(seq $start $end); do
        if is_instance_running $i; then
            pkill -f "Google Chrome.*Chrome_Instance_$i"
            echo "已关闭实例 $i"
            ((closed_count++))
        else
            echo "实例 $i 未在运行"
            ((not_running_count++))
        fi
    done
    
    echo "关闭完成：成功关闭 $closed_count 个，$not_running_count 个未在运行，共 $(($end-$start+1)) 个实例"
}

# 清理未使用的实例目录
cleanup_instances() {
    echo "正在扫描未使用的实例目录..."
    local cleaned=0
    
    if ls -d "$BASE_USER_DATA_DIR/Chrome_Instance_"* >/dev/null 2>&1; then
        for dir in $(ls -d "$BASE_USER_DATA_DIR/Chrome_Instance_"* 2>/dev/null); do
            local instance_num=$(basename "$dir" | sed 's/Chrome_Instance_//')
            if ! is_instance_running $instance_num; then
                echo -n "是否删除实例目录 $dir? [y/N]: "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    rm -rf "$dir"
                    echo "已删除: $dir"
                    ((cleaned++))
                fi
            fi
        done
    fi
    
    echo "清理完成，共清理了 $cleaned 个目录"
}

# 验证参数
validate_instance_number() {
    local num=$1
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt 999 ]; then
        echo "错误：实例编号必须是1-999之间的数字"
        return 1
    fi
    return 0
}

# 验证区间参数
validate_range_numbers() {
    local start=$1
    local end=$2
    if ! validate_instance_number $start || ! validate_instance_number $end; then
        return 1
    fi
    if [ $start -gt $end ]; then
        echo "错误：起始编号必须小于或等于结束编号"
        return 1
    fi
    return 0
}

# 检查 Chrome 是否存在
if [ ! -f "$CHROME_PATH" ]; then
    echo "错误：找不到 Chrome 可执行文件: $CHROME_PATH"
    echo "请检查 Chrome 是否已安装"
    exit 1
fi

# 检查基础目录权限
if [ ! -w "$(dirname "$BASE_USER_DATA_DIR")" ]; then
    echo "错误：没有写入权限: $(dirname "$BASE_USER_DATA_DIR")"
    exit 1
fi

# 默认值
NUM_INSTANCES=0
SINGLE_INSTANCE=0
INSTANCE_NUM=0
SHOW_STATUS=0
KILL_INSTANCES=0
KILL_RANGE_MODE=0
RANGE_START=0
RANGE_END=0
RANGE_MODE=0

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -n|--instance)
            if [ -z "$2" ]; then
                echo "错误：-n 选项需要指定实例编号"
                exit 1
            fi
            SINGLE_INSTANCE=1
            INSTANCE_NUM=$2
            shift
            ;;
        -r|--range)
            if [ -z "$2" ]; then
                echo "错误：-r 选项需要指定起始和结束编号，格式为 起始编号-结束编号"
                exit 1
            fi
            # 解析起始和结束编号
            if [[ $2 =~ ^([0-9]+)-([0-9]+)$ ]]; then
                RANGE_START=${BASH_REMATCH[1]}
                RANGE_END=${BASH_REMATCH[2]}
                if [ $RANGE_START -gt $RANGE_END ]; then
                    echo "错误：起始编号必须小于或等于结束编号"
                    exit 1
                fi
                RANGE_MODE=1
            else
                echo "错误：-r 选项格式不正确，应为 起始编号-结束编号，例如 3-6"
                exit 1
            fi
            shift
            ;;
        -K|--kill-range)
            if [ -z "$2" ]; then
                echo "错误：-K 选项需要指定起始和结束编号，格式为 起始编号-结束编号"
                exit 1
            fi
            # 解析起始和结束编号
            if [[ $2 =~ ^([0-9]+)-([0-9]+)$ ]]; then
                RANGE_START=${BASH_REMATCH[1]}
                RANGE_END=${BASH_REMATCH[2]}
                if [ $RANGE_START -gt $RANGE_END ]; then
                    echo "错误：起始编号必须小于或等于结束编号"
                    exit 1
                fi
                KILL_RANGE_MODE=1
            else
                echo "错误：-K 选项格式不正确，应为 起始编号-结束编号，例如 3-6"
                exit 1
            fi
            shift
            ;;
        -s|--status)
            SHOW_STATUS=1
            ;;
        -k|--kill)
            KILL_INSTANCES=1
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                INSTANCE_NUM=$2
                shift
            fi
            ;;
        *)
            if [[ $1 =~ ^[0-9]+$ ]]; then
                NUM_INSTANCES=$1
            else
                echo "错误：无效的参数 $1"
                echo "使用 $SCRIPT_NAME -h 查看帮助信息"
                exit 1
            fi
            ;;
    esac
    shift
done

# 执行相应操作
if [ $SHOW_STATUS -eq 1 ]; then
    show_instances_status
elif [ $KILL_INSTANCES -eq 1 ]; then
    if [ $INSTANCE_NUM -eq 0 ]; then
        kill_instance ""
    else
        kill_instance $INSTANCE_NUM
    fi
elif [ $KILL_RANGE_MODE -eq 1 ]; then
    # 区间关闭模式
    kill_instance_range $RANGE_START $RANGE_END
elif [ $SINGLE_INSTANCE -eq 1 ]; then
    if ! validate_instance_number $INSTANCE_NUM; then
        exit 1
    fi
    
    echo "正在启动 Chrome 实例 $INSTANCE_NUM..."
    if create_chrome_instance $INSTANCE_NUM; then
        echo "数据目录: $BASE_USER_DATA_DIR/Chrome_Instance_$INSTANCE_NUM"
    else
        exit 1
    fi
elif [ $RANGE_MODE -eq 1 ]; then
    # 区间启动模式
    if ! validate_range_numbers $RANGE_START $RANGE_END; then
        exit 1
    fi
    
    echo "正在启动 Chrome 实例 $RANGE_START 到 $RANGE_END..."
    
    success_count=0
    skip_count=0
    
    for i in $(seq $RANGE_START $RANGE_END); do
        echo "启动 Chrome 实例 $i..."
        if is_instance_running $i; then
            echo "跳过：实例 $i 已经在运行中"
            ((skip_count++))
        elif create_chrome_instance $i; then
            ((success_count++))
        fi
    done
    
    echo "启动完成：成功 $success_count 个，跳过 $skip_count 个，共 $(($RANGE_END-$RANGE_START+1)) 个实例"
else
    if [ $NUM_INSTANCES -lt 1 ]; then
        show_usage
        exit 0
    fi

    if [ $NUM_INSTANCES -gt 20 ]; then
        echo "警告：启动大量实例可能会消耗过多系统资源"
        echo -n "确定要启动 $NUM_INSTANCES 个实例吗? [y/N]: "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "已取消操作"
            exit 0
        fi
    fi

    echo "正在启动 $NUM_INSTANCES 个 Chrome 实例..."
    
    success_count=0
    skip_count=0
    
    for i in $(seq 1 $NUM_INSTANCES); do
        echo "启动 Chrome 实例 $i..."
        if is_instance_running $i; then
            echo "跳过：实例 $i 已经在运行中"
            ((skip_count++))
        elif create_chrome_instance $i; then
            ((success_count++))
        fi
    done
    
    echo "启动完成：成功 $success_count 个，跳过 $skip_count 个，共 $NUM_INSTANCES 个实例"
fi