# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Chrome Multi-Instance Manager for macOS that allows users to run multiple isolated Chrome browser instances simultaneously. Each instance uses a separate user data directory for complete isolation.

## Code Architecture

1. **Main Script**: `multi_chrome.sh` - The core bash script that manages Chrome instances
2. **Build System**: Make-based build system that creates a macOS application bundle
3. **Application Components**:
   - `scripts/build_app.sh` - Creates the macOS app bundle
   - `scripts/launcher` - GUI launcher with AppleScript interface
   - `scripts/Info.plist` - Application metadata template
   - `scripts/install.sh` and `scripts/uninstall.sh` - Installation utilities

## Key Directories

- Root: Main script and Makefile
- `scripts/`: Build and installation scripts
- `assets/`: Application icons and resources
- `dist/`: Build output directory for the macOS app

## Common Development Tasks

### Building and Running

```bash
# Make the main script executable
chmod +x multi_chrome.sh

# Run the script directly
./multi_chrome.sh -h  # Show help

# Build the macOS app
make app

# Install to Applications folder
make install

# Clean build artifacts
make clean
```

### New Range-based Instance Startup Feature

The script now supports starting a range of Chrome instances with the `-r` option:

```bash
# Start instances in a range (e.g., instances 3-6)
./multi_chrome.sh -r 3-6

# The range must be specified as START-END where START <= END
# Each instance in the range will be started if not already running
```

### New Range-based Instance Shutdown Feature

The script also supports closing a range of Chrome instances with the `-K` option:

```bash
# Close instances in a range (e.g., instances 3-6)
./multi_chrome.sh -K 3-6

# The range must be specified as START-END where START <= END
# Each instance in the range will be closed if currently running
```

### GUI Application Features

The macOS application bundle also includes the new range-based features in its graphical interface:
- Start instances in a range through the "启动区间编号" option
- Close instances in a range through the "关闭区间编号" option

### Testing Changes

1. Test the main script directly: `./multi_chrome.sh -h`
2. Test the new range startup feature: `./multi_chrome.sh -r 3-6`
3. Test the new range shutdown feature: `./multi_chrome.sh -K 3-6`
4. Build the app: `make app`
5. Test the app bundle by opening it
6. Test the GUI features including the new range options
7. Check logs at: `~/Library/Logs/MultiChrome/run.log`

## Code Structure

The main script (`multi_chrome.sh`) contains functions for:
- Instance management (start, stop, status)
- Process monitoring with `pgrep`/`pkill`
- User data directory creation and management
- Command-line argument parsing
- Range-based instance startup (`-r START-END` option)
- Range-based instance shutdown (`-K START-END` option)

The launcher script provides a GUI interface using AppleScript for users who prefer not to use the command line.

## Data Storage

Instance data is stored in:
`~/Library/Application Support/Google/Chrome_Instance_<number>/`

Logs are stored in:
`~/Library/Logs/MultiChrome/run.log`