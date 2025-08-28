APP_NAME := MultiChrome
DIST_DIR := dist
APP_PATH := $(DIST_DIR)/$(APP_NAME).app

# Configurable via environment: VERSION=1.0.0 IDENTIFIER=com.yourorg.multichrome make app
VERSION ?= 0.1.0
IDENTIFIER ?= io.multichrome.app

.PHONY: app build open install uninstall clean ensure_exec help

# Default target: build and open the app
app: open

build: ensure_exec
	./scripts/build_app.sh --version $(VERSION) --identifier $(IDENTIFIER)

open: build
	open "$(APP_PATH)"

install: build
	./scripts/install.sh

uninstall:
	./scripts/uninstall.sh

clean:
	rm -rf "$(APP_PATH)" "$(DIST_DIR)"

ensure_exec:
	chmod +x multi_chrome.sh || true
	chmod +x scripts/*.sh || true

help:
	@echo "Targets:"
	@echo "  make app         # Build and open $(APP_NAME).app"
	@echo "  make build       # Build the app bundle"
	@echo "  make open        # Open the built app"
	@echo "  make install     # Install to /Applications"
	@echo "  make uninstall   # Remove from /Applications"
	@echo "  make clean       # Remove dist output"
	@echo "Variables: VERSION=0.1.0 IDENTIFIER=io.multichrome.app"

