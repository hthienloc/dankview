BINARY_NAME=dview
SHELL_NAME=dankview
ICON_NAME=com.danklinux.dankview
CORE_DIR=core
BUILD_DIR=$(CORE_DIR)/bin
PREFIX ?= /usr/local
DESTDIR ?=
INSTALL_DIR=$(PREFIX)/bin
DATA_DIR=$(PREFIX)/share
ICON_DIR=$(DATA_DIR)/icons/hicolor/scalable/apps
APPLICATIONS_DIR=$(DATA_DIR)/applications
SHELL_DIR=quickshell

.PHONY: all build dev run clean test fmt vet update-common install uninstall help

all: build

build:
	@$(MAKE) -C $(CORE_DIR) build

dev:
	@$(MAKE) -C $(CORE_DIR) dev

run: dev
	@$(BUILD_DIR)/$(BINARY_NAME) -c $(CURDIR)/$(SHELL_DIR) $(filter-out $@,$(MAKECMDGOALS))

clean:
	@$(MAKE) -C $(CORE_DIR) clean

test:
	@$(MAKE) -C $(CORE_DIR) test

fmt:
	@$(MAKE) -C $(CORE_DIR) fmt

vet:
	@$(MAKE) -C $(CORE_DIR) vet

update-common:
	git submodule update --remote --merge dank-qml-common

install: build
	@install -D -m 755 $(BUILD_DIR)/$(BINARY_NAME) $(DESTDIR)$(INSTALL_DIR)/$(BINARY_NAME)
	@install -D -m 644 distro/$(ICON_NAME).desktop $(DESTDIR)$(APPLICATIONS_DIR)/$(ICON_NAME).desktop

uninstall:
	@rm -f $(DESTDIR)$(INSTALL_DIR)/$(BINARY_NAME)
	@rm -f $(DESTDIR)$(APPLICATIONS_DIR)/$(ICON_NAME).desktop

help:
	@echo "DankView Makefile targets:"
	@echo "  build       - Build the dview binary"
	@echo "  dev         - Fast development build"
	@echo "  run [image] - Build and run dview with optional image path"
	@echo "  test / fmt / vet"
	@echo "  install / uninstall"
