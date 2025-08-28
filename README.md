# Chrome 多实例管理工具 / Chrome Multi-Instance Manager

## 中文说明 / Chinese Documentation

### 简介
这是一个用于在macOS上管理多个Chrome浏览器实例的bash脚本工具。每个实例使用独立的用户数据目录，可以同时运行多个完全隔离的Chrome浏览器会话。

### 主要特性
- 🚀 **批量启动**: 一次性启动多个Chrome实例
- 📊 **状态监控**: 查看所有实例的运行状态
- 🎯 **精确控制**: 启动或关闭指定编号的实例
- 🔒 **数据隔离**: 每个实例使用独立的用户数据目录
- ⚡ **智能跳过**: 自动跳过已运行的实例，避免重复启动
- 🛡️ **安全保护**: 参数验证和错误处理

### 系统要求
- macOS系统
- Google Chrome浏览器已安装
- Bash shell环境

### 安装和使用

#### 1. 下载和权限设置
```bash
# 下载脚本到本地
chmod +x multi_chrome.sh
```

#### 2. 使用方法

```bash
# 显示帮助信息
./multi_chrome.sh -h

# 启动3个Chrome实例 (编号1-3)
./multi_chrome.sh 3

# 启动指定编号的实例
./multi_chrome.sh -n 5

# 查看所有实例状态
./multi_chrome.sh -s

# 关闭所有实例
./multi_chrome.sh -k

# 关闭指定实例
./multi_chrome.sh -k 2
```

### 命令选项详解

| 选项 | 说明 | 示例 |
|------|------|------|
| `<数量>` | 启动指定数量的实例 | `./multi_chrome.sh 5` |
| `-n <编号>` | 启动指定编号的实例 | `./multi_chrome.sh -n 3` |
| `-s` | 显示实例运行状态 | `./multi_chrome.sh -s` |
| `-k` | 关闭所有实例 | `./multi_chrome.sh -k` |
| `-k <编号>` | 关闭指定编号的实例 | `./multi_chrome.sh -k 2` |
| `-h` | 显示帮助信息 | `./multi_chrome.sh -h` |

### 数据目录
实例数据存储在：`~/Library/Application Support/Google/Chrome_Instance_<编号>/`

### 常见使用场景
- **多账号管理**: 同时登录不同的Google账号或网站账号
- **开发测试**: 在不同环境下测试网站功能
- **隐私隔离**: 将工作和个人浏览会话完全分离
- **插件测试**: 在不同实例中测试不同的浏览器插件组合

---

## English Documentation

### Overview
A bash script tool for managing multiple Chrome browser instances on macOS. Each instance uses a separate user data directory, allowing you to run multiple completely isolated Chrome browser sessions simultaneously.

### Key Features
- 🚀 **Batch Launch**: Start multiple Chrome instances at once
- 📊 **Status Monitoring**: View the running status of all instances
- 🎯 **Precise Control**: Start or stop specific numbered instances
- 🔒 **Data Isolation**: Each instance uses a separate user data directory
- ⚡ **Smart Skip**: Automatically skip already running instances to avoid duplicates
- 🛡️ **Safety Protection**: Parameter validation and error handling

### System Requirements
- macOS system
- Google Chrome browser installed
- Bash shell environment

### Installation and Usage

#### 1. Download and Permission Setup
```bash
# Download script locally
chmod +x multi_chrome.sh
```

#### 2. Usage

```bash
# Show help information
./multi_chrome.sh -h

# Start 3 Chrome instances (numbered 1-3)
./multi_chrome.sh 3

# Start a specific numbered instance
./multi_chrome.sh -n 5

# View status of all instances
./multi_chrome.sh -s

# Close all instances
./multi_chrome.sh -k

# Close a specific instance
./multi_chrome.sh -k 2
```

### Command Options

| Option | Description | Example |
|--------|-------------|---------|
| `<number>` | Start specified number of instances | `./multi_chrome.sh 5` |
| `-n <number>` | Start a specific numbered instance | `./multi_chrome.sh -n 3` |
| `-s` | Show instance running status | `./multi_chrome.sh -s` |
| `-k` | Close all instances | `./multi_chrome.sh -k` |
| `-k <number>` | Close a specific numbered instance | `./multi_chrome.sh -k 2` |
| `-h` | Show help information | `./multi_chrome.sh -h` |

### Data Directory
Instance data is stored in: `~/Library/Application Support/Google/Chrome_Instance_<number>/`

### Common Use Cases
- **Multi-account Management**: Simultaneously log into different Google accounts or website accounts
- **Development Testing**: Test website functionality in different environments
- **Privacy Isolation**: Completely separate work and personal browsing sessions
- **Extension Testing**: Test different browser extension combinations in different instances

### Troubleshooting

#### Common Issues
1. **Permission Denied**: Ensure the script has execute permissions (`chmod +x`)
2. **Chrome Not Found**: Verify Chrome is installed in the default location
3. **Instance Won't Start**: Check system resources and close unnecessary applications
4. **Port Conflicts**: Each instance automatically uses different ports

#### Tips
- Use `./multi_chrome.sh -s` to monitor instance status
- Instances are automatically isolated - cookies, sessions, and extensions don't interfere
- Each instance can have different Chrome profiles and settings
- Safe to force quit instances if needed - data is preserved

### Advanced Usage
```bash
# Start instances for different projects
./multi_chrome.sh -n 1  # Personal browsing
./multi_chrome.sh -n 2  # Work project A
./multi_chrome.sh -n 3  # Work project B
./multi_chrome.sh -n 4  # Testing environment

# Check what's running
./multi_chrome.sh -s

# Clean shutdown at end of day
./multi_chrome.sh -k
```