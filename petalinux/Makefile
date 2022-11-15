SHELL	:=/bin/bash

#
# Copyright 2022 IKERLAN S.COOP.
#
# Based on the Versal Custom Thin Platform Extensible System developed by Xilinx, Inc.
# Original repository available at:
# https://github.com/Xilinx/Vitis-Tutorials/tree/2021.1/Developer_Contributed/01-Versal_Custom_Thin_Platform_Extensible_System
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# =========================================================
# MAKEFILE ARGUMENTS
# =========================================================

TIME            ?=$(shell date "+%Y%m%d-%H%M%S")
PROJ_NAME       ?=platform
USE_BSP         ?=TRUE
XEN_HYPERVISOR  ?=FALSE
QEMU            ?=TRUE
XILINX_VER      ?=2021.2
LINUX_BUILD_SRC ?=network

# =========================================================
# PETALINUX CONFIGURATION
# =========================================================

CPU_ARCH  :=a72

# =========================================================
# SHELL COMMANDS
# =========================================================

RM		:=@rm -f
CP		:=@cp
CD		:=@cd
ECHO	:=@echo -e
WAIT	:=$(ECHO) "\n[..]"
OK		:=$(ECHO) "[OK]"
INFO	:=$(ECHO) "[INFO]"
ERROR	:=$(ECHO) "[ERROR]"
MAKE	:=$(MAKE)
PWD		:=$(shell pwd)

# =========================================================
# DIRECTORIES
# =========================================================

SYSROOT	:=../sysroot
BSP		:=../src/xilinx-vck190-v${XILINX_VER}-final.bsp

PROJ_PATH	:=${PWD}/${PROJ_NAME}
LINUX_DIR	:=${PROJ_PATH}/images/linux
XSA			:=$(shell dirname "${PWD}")/vivado/${PROJ_NAME}/${PROJ_NAME}.xsa
XSA_PATH	:=${PWD}/src/import_from_vivado

LINUX_TMP_DIR              ?= /tmp/petalinux
LINUX_LOCAL_DOWNLOADS_DIR  ?= ${LINUX_TEMP_DIR}/workspace/downloads
LINUX_LOCAL_SSTATE_DIR     ?= ${LINUX_TEMP_DIR}/workspace/sstate_aarch64_2021.2/aarch64

USR_ROOTFS_APPEND	:=${PWD}/src/components/user-rootfsconfig.append
SRC_PATH_EXT_SRC	:=${PWD}/src/components/ext_src
DEST_PATH_EXT_SRC	:=${PROJ_PATH}/project-spec

FILE_MAIN_CFG	:=${PROJ_PATH}/project-spec/configs/config
FILE_ROOTFS_CFG	:=${PROJ_PATH}/project-spec/configs/rootfs_config
USR_ROOTFS_CFG	:=${PROJ_PATH}/project-spec/meta-user/conf/user-rootfsconfig
FILE_SYSTEM_USR	:=${PROJ_PATH}/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi
DT_BBAPPEND		:=${PROJ_PATH}/project-spec/meta-user/recipes-bsp/device-tree/device-tree.bbappend

ROOTFS		:=${LINUX_DIR}/rootfs.ext4
IMAGE		:=${LINUX_DIR}/Image
BL31		:=${LINUX_DIR}/bl31.elf
BOOT_SCR	:=${LINUX_DIR}/boot.scr

BOOT		:=${LINUX_DIR}/BOOT.BIN
BOOT_BH		:=${LINUX_DIR}/BOOT_bh.bin
QEMU_BOOT	:=${LINUX_DIR}/qemu_boot.img
PLM			:=${LINUX_DIR}/plm.elf
PSMFW		:=${LINUX_DIR}/psmfw.elf
UBOOT		:=${LINUX_DIR}/u-boot.elf
DTB			:=${LINUX_DIR}/system.dtb

SDK		:=${LINUX_DIR}/sdk.sh
SYSROOT	:=${PWD}/sysroot

BIF		:=${PWD}/src/boot_custom.bif

# =========================================================
# ALIASES
# =========================================================

PETALINUX_CREATE	:=@petalinux-create -t project -n ${PROJ_NAME}
PETALINUX_CONFIG	:=$(RM) update_build update_bootimage update_sdk update_sysroot && cd ${PROJ_PATH} && petalinux-config --silentconfig
PETALINUX_BUILD		:=$(CD) ${PROJ_PATH} && petalinux-build
PETALINUX_PACKAGE	:=$(CD) ${PROJ_PATH} && petalinux-package
PETALINUX_BOOT		:=cd ${PROJ_PATH} && petalinux-boot

CFG					:=@./src/config
MAIN_CONFIG			:=$(CFG) --file ${FILE_MAIN_CFG}
ROOTFS_CONFIG		:=$(CFG) --file ${FILE_ROOTFS_CFG}
ENABLE				:=--keep-case --enable
DISABLE				:=--keep-case --disable
SET_STR				:=--set-str

PASS_CONFIG_LOG		:=echo -e "[OK] petalinux-config exited successfully"; cp ${PROJ_PATH}/build/config.log ${PWD}/${TIME}_PASS_
ERROR_CONFIG_LOG	:=echo -e "[ERROR] petalinux-config ended with errors (log file available)"; cp ${PROJ_PATH}/build/config.log ${PWD}/${TIME}_ERROR_
PASS_BUILD_LOG		:=echo -e "[OK] petalinux-build exited successfully"; cp ${PROJ_PATH}/build/build.log ${PWD}/${TIME}_PASS_
ERROR_BUILD_LOG		:=echo -e "[ERROR] petalinux-build ended with errors (log file available)"; cp ${PROJ_PATH}/build/build.log ${PWD}/${TIME}_ERROR_
PASS_PACKAGE_LOG	:=echo -e "[OK] petalinux-package exited successfully"; cp ${PROJ_PATH}/build/package.log ${PWD}/${TIME}_PASS_
ERROR_PACKAGE_LOG	:=echo -e "[ERROR] petalinux-package ended with errors (log file available)"; cp ${PROJ_PATH}/build/package.log ${PWD}/${TIME}_ERROR_

# =========================================================
# RECIPES
# =========================================================

.PHONY: all clean help targets

all: ${PROJ_PATH}
	$(MAKE) update_all_configs
	$(MAKE) update_build
	$(MAKE) update_bootimage
#	$(MAKE) update_sysroot

clean:
	$(WAIT) "Cleaning project"
	$(RM) -r ${PROJ_PATH}
	$(RM) -r sysroot
	$(RM) update_build
	$(RM) update_bootimage
	$(RM) update_sdk
	$(RM) update_sysroot
	$(OK) "Successfully cleaned project"

help: targets
targets:
	$(ECHO) "Make targets: all create update_hw update_config update_ext_src update_device_tree update_ext_src_config update_build update_bootimage update_sysroot"

# =========================================================
# CREATE PROJECT
# =========================================================

.PHONY: create

create: clean ${PROJ_PATH}
${PROJ_PATH}:
	$(WAIT) "Create project ${PROJ_NAME}"
ifeq ("$(wildcard ${BSP});${USE_BSP}","${BSP};TRUE")
#	BSP exists
	$(INFO) "Using BSP ${BSP}"
#	Use this to create a project for the VCK190 development board
	$(PETALINUX_CREATE) -s ${BSP}
else
#	BSP does not exist
	$(INFO) "Using VERSAL template"
#	Use this to create a project for a custom board
	$(PETALINUX_CREATE) --template versal
endif
	$(OK) "Successfully created project ${PROJ_NAME}"

# =========================================================
# CONFIG PROJECT
# =========================================================

.PHONY: update_all_configs clean_config

# Create backup config files for project restoration:
${FILE_MAIN_CFG}.original:
	$(WAIT) "Creating a backup of config"
	$(CP) ${FILE_MAIN_CFG} ${FILE_MAIN_CFG}.original
	$(OK) "Successfully created backup of config"

${FILE_ROOTFS_CFG}.original:
	$(WAIT) "Creating a backup of rootfs_config"
	$(CP) ${FILE_ROOTFS_CFG} ${FILE_ROOTFS_CFG}.original
	$(OK) "Successfully created backup of rootfs_config"

${USR_ROOTFS_CFG}.original:
	$(WAIT) "Creating a backup of usr-rootfsconfig"
	$(CP) ${USR_ROOTFS_CFG} ${USR_ROOTFS_CFG}.original
	$(OK) "Successfully created backup of usr-rootfsconfig"

${FILE_SYSTEM_USR}.original:
	$(WAIT) "Creating a backup of system-user.dtsi"
	$(CP) ${FILE_SYSTEM_USR} ${FILE_SYSTEM_USR}.original
	$(OK) "Successfully created backup of system-user.dtsi"

${DT_BBAPPEND}.original:
	$(WAIT) "Creating a backup of device-tree.bbappend"
	$(CP) ${DT_BBAPPEND} ${DT_BBAPPEND}.original
	$(OK) "Successfully created backup of device-tree.bbappend"

update_all_configs:
	$(MAKE) update_hw
	$(MAKE) update_main_config
	$(MAKE) update_kernel_config
	$(MAKE) update_rootfs_config
#	$(MAKE) update_ext_src
#	$(MAKE) update_ext_src_config
# ifeq ("${XEN_HYPERVISOR}","TRUE")
# 	$(MAKE) enable_xen_hypervisor
# else
# 	$(MAKE) disable_xen_hypervisor
# endif

clean_config: | ${FILE_MAIN_CFG}.original ${FILE_ROOTFS_CFG}.original
	$(WAIT) "Cleaning configuration"
	$(CP) ${FILE_MAIN_CFG}.original ${FILE_MAIN_CFG}
	$(WAIT) "Configuring ${FILE_MAIN_CFG}"
	$(PETALINUX_CONFIG)
	$(OK) "Successfully configured ${FILE_MAIN_CFG}"
	$(CP) ${FILE_ROOTFS_CFG}.original ${FILE_ROOTFS_CFG}
	$(WAIT) "Configuring ${FILE_ROOTFS_CFG}"
	$(PETALINUX_CONFIG) -c rootfs
	$(OK) "Successfully configured ${FILE_ROOTFS_CFG}"
	$(MAKE) clean_extra_layers
	$(MAKE) disable_xen_hypervisor
	$(OK) "Successfully cleaned configuration"

# =========================================================
# HW CONFIG
# =========================================================

.PHONY: update_hw ${XSA_PATH}

${XSA}:
	$(MAKE) ${XSA} -C ../vivado

${XSA_PATH}: ${XSA}
	$(WAIT) "Importing XSA from Vivado"
	$(CP) ${XSA} ${XSA_PATH}/.
	$(OK) "Successfully imported XSA from Vivado"

update_hw: ${FILE_MAIN_CFG}.original ${XSA_PATH}
	$(WAIT) "Updating hardware with ${XSA_PATH}"
	$(INFO) "Restoring original main config file"
	$(CP) ${FILE_MAIN_CFG}.original ${FILE_MAIN_CFG}
	$(PETALINUX_CONFIG) --get-hw-description=${XSA_PATH} && { \
		$(PASS_CONFIG_LOG)hw_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)hw_config.log; \
	}
	$(OK) "Successfully updated hardware"
	$(INFO) "Recreating a backup of config"
	$(CP) ${FILE_MAIN_CFG} ${FILE_MAIN_CFG}.original
	$(WAIT) "Configuring ${FILE_MAIN_CFG}"
	$(PETALINUX_CONFIG)
	$(OK) "Successfully configured ${FILE_MAIN_CFG}"

# =========================================================
# MAIN CONFIG
# =========================================================

.PHONY: update_main_config

update_main_config: ${FILE_MAIN_CFG}.original
	$(WAIT) "Updating ${FILE_MAIN_CFG}"
	$(INFO) "Restoring original main config file"
	$(CP) ${FILE_MAIN_CFG}.original ${FILE_MAIN_CFG}
## Subsystem AUTO HW Settings - Flash Settings
# Why was it enabled?
#	$(MAIN_CONFIG) $(ENABLE) SUBSYSTEM_FLASH__ADVANCED_AUTOCONFIG
## DTG Settings
ifeq ("${USE_BSP}","TRUE")
	$(MAIN_CONFIG) $(SET_STR) CONFIG_SUBSYSTEM_MACHINE_NAME "versal-vck190-reva-x-ebm-01-reva"
else
	$(MAIN_CONFIG) $(SET_STR) CONFIG_SUBSYSTEM_MACHINE_NAME "template"
endif
## u-boot Configuration
	$(MAIN_CONFIG) $(SET_STR) CONFIG_SUBSYSTEM_UBOOT_CONFIG_TARGET "xilinx_versal_virt_defconfig"
## Image Packaging Configuration
#	Required for booting INITRD images with full rootfs (ramdisk.cpio.gz -> EXT4)
#	https://support.xilinx.com/s/article/76842?language=en_US (Method 1)
	$(MAIN_CONFIG) $(DISABLE) SUBSYSTEM_ROOTFS_INITRAMFS
	$(MAIN_CONFIG) $(ENABLE) SUBSYSTEM_ROOTFS_INITRD
	$(MAIN_CONFIG) $(SET_STR) CONFIG_SUBSYSTEM_INITRAMFS_IMAGE_NAME "petalinux-image-minimal"
	$(MAIN_CONFIG) $(SET_STR) CONFIG_SUBSYSTEM_RFS_FORMATS "cpio cpio.gz cpio.gz.u-boot tar.gz jffs2 ext4"
## Firmware Version Configuration
	$(MAIN_CONFIG) $(SET_STR) CONFIG_SUBSYSTEM_HOSTNAME "fractal_versal"
	$(MAIN_CONFIG) $(SET_STR) CONFIG_SUBSYSTEM_PRODUCT "fractal_versal"
## Yocto Settings - Yocto board settings
	$(MAIN_CONFIG) $(SET_STR) CONFIG_YOCTO_BOARD_NAME "vck190"
## Yocto Settings - Local/Network sstate feeds settings
	$(MAIN_CONFIG) $(ENABLE) YOCTO_BUILDTOOLS_EXTENDED
ifeq (${LINUX_BUILD_SRC},"local")
	$(MAIN_CONFIG) $(ENABLE) CONFIG_YOCTO_BB_NO_NETWORK
	$(MAIN_CONFIG) $(DISABLE) CONFIG_YOCTO_NETWORK_SSTATE_FEEDS
	$(MAIN_CONFIG) $(SET_STR) CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL ${LINUX_LOCAL_SSTATE_DIR}
	$(MAIN_CONFIG) $(SET_STR) CONFIG_PRE_MIRROR_URL "file\:\/\/"${LINUX_LOCAL_DOWNLOADS_DIR}
endif
	$(OK) "Successfully updated ${FILE_MAIN_CFG}"
	$(WAIT) "Configuring ${FILE_MAIN_CFG}"
	$(PETALINUX_CONFIG) && { \
		$(PASS_CONFIG_LOG)main_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)main_config.log; \
	}
	$(OK) "Successfully configured ${FILE_MAIN_CFG}"

# =========================================================
# KERNEL CONFIG
# =========================================================

.PHONY: update_kernel_config

update_kernel_config:
	$(WAIT) "Configuring kernel"
	$(PETALINUX_CONFIG) -c kernel && { \
		$(PASS_CONFIG_LOG)kernel_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)kernel_config.log; \
	}
	$(OK) "Successfully configured kernel"

# =========================================================
# ROOTFS CONFIG
# =========================================================

.PHONY: update_rootfs_config

update_rootfs_config: ${FILE_ROOTFS_CFG}.original
	$(WAIT) "Updating ${FILE_ROOTFS_CFG}"
	$(INFO) "Restoring original Root FS config file"
	$(CP) ${FILE_ROOTFS_CFG}.original ${FILE_ROOTFS_CFG}
## FS Packages - Base
	$(ROOTFS_CONFIG) $(ENABLE) dnf
#	$(ROOTFS_CONFIG) $(ENABLE) e2fsprogs-mke2fs
	$(ROOTFS_CONFIG) $(ENABLE) e2fsprogs-resize2fs
#	$(ROOTFS_CONFIG) $(ENABLE) fpga-manager-script
#	$(ROOTFS_CONFIG) $(ENABLE) haveged
#	$(ROOTFS_CONFIG) $(ENABLE) mtd-utils
## FS Packages - Console - Network
#	$(ROOTFS_CONFIG) $(ENABLE) can-utils
#	$(ROOTFS_CONFIG) $(ENABLE) openssh-sftp-server
## FS Packages - Console - Tools
	$(ROOTFS_CONFIG) $(ENABLE) parted
## FS Packages - Console - Utils
#	$(ROOTFS_CONFIG) $(ENABLE) alsa-tools
#	$(ROOTFS_CONFIG) $(ENABLE) alsa-utilss
#	$(ROOTFS_CONFIG) $(ENABLE) bash-completion
#	$(ROOTFS_CONFIG) $(ENABLE) bzip2
#	$(ROOTFS_CONFIG) $(ENABLE) file
#	$(ROOTFS_CONFIG) $(ENABLE) findutils
#	$(ROOTFS_CONFIG) $(ENABLE) gawk
#	$(ROOTFS_CONFIG) $(ENABLE) git
#	$(ROOTFS_CONFIG) $(ENABLE) grep
#	$(ROOTFS_CONFIG) $(ENABLE) groff
#	$(ROOTFS_CONFIG) $(ENABLE) gzip
#	$(ROOTFS_CONFIG) $(ENABLE) hdparm
#	$(ROOTFS_CONFIG) $(ENABLE) less
#	$(ROOTFS_CONFIG) $(ENABLE) lmbench
#	$(ROOTFS_CONFIG) $(ENABLE) ltp
#	$(ROOTFS_CONFIG) $(ENABLE) man
#	$(ROOTFS_CONFIG) $(ENABLE) man-pages
#	$(ROOTFS_CONFIG) $(ENABLE) mc
#	$(ROOTFS_CONFIG) $(ENABLE) pciutils
#	$(ROOTFS_CONFIG) $(ENABLE) pkgconfig
#	$(ROOTFS_CONFIG) $(ENABLE) screen
#	$(ROOTFS_CONFIG) $(ENABLE) sed
#	$(ROOTFS_CONFIG) $(ENABLE) setserial
#	$(ROOTFS_CONFIG) $(ENABLE) smartmontools
#	$(ROOTFS_CONFIG) $(ENABLE) strace
#	$(ROOTFS_CONFIG) $(ENABLE) sysstat
#	$(ROOTFS_CONFIG) $(ENABLE) texinfo
#	$(ROOTFS_CONFIG) $(ENABLE) unzip
#	$(ROOTFS_CONFIG) $(ENABLE) vim
#	$(ROOTFS_CONFIG) $(ENABLE) zip
## FS Packages - Development
	$(ROOTFS_CONFIG) $(ENABLE) binutils
#	$(ROOTFS_CONFIG) $(ENABLE) make
#	# $(ROOTFS_CONFIG) $(ENABLE) ruby
#	$(ROOTFS_CONFIG) $(ENABLE) run-postinsts
#	$(ROOTFS_CONFIG) $(ENABLE) tcl
## FS Packages - Development - Python
	$(ROOTFS_CONFIG) $(ENABLE) packagegroup-petalinux-python-modules
	$(ROOTFS_CONFIG) $(ENABLE) python
	$(ROOTFS_CONFIG) $(ENABLE) libpython2
	$(ROOTFS_CONFIG) $(ENABLE) python-2to3
	$(ROOTFS_CONFIG) $(ENABLE) python-argparse
	$(ROOTFS_CONFIG) $(ENABLE) python-audio
	$(ROOTFS_CONFIG) $(ENABLE) python-bsddb
	$(ROOTFS_CONFIG) $(ENABLE) python-codecs
	$(ROOTFS_CONFIG) $(ENABLE) python-compile
	$(ROOTFS_CONFIG) $(ENABLE) python-compiler
	$(ROOTFS_CONFIG) $(ENABLE) python-compression
	$(ROOTFS_CONFIG) $(ENABLE) python-contextlib
	$(ROOTFS_CONFIG) $(ENABLE) python-core
	$(ROOTFS_CONFIG) $(ENABLE) python-crypt
	$(ROOTFS_CONFIG) $(ENABLE) python-ctypes
	$(ROOTFS_CONFIG) $(ENABLE) python-curses
	$(ROOTFS_CONFIG) $(ENABLE) python-datetime
	$(ROOTFS_CONFIG) $(ENABLE) python-db
	$(ROOTFS_CONFIG) $(ENABLE) python-debugger
	$(ROOTFS_CONFIG) $(ENABLE) python-difflib
	$(ROOTFS_CONFIG) $(ENABLE) python-distutils
	$(ROOTFS_CONFIG) $(ENABLE) python-email
	$(ROOTFS_CONFIG) $(ENABLE) python-fcntl
	$(ROOTFS_CONFIG) $(ENABLE) python-gdbm
	$(ROOTFS_CONFIG) $(ENABLE) python-hotshot
	$(ROOTFS_CONFIG) $(ENABLE) python-html
	$(ROOTFS_CONFIG) $(ENABLE) python-idle
	$(ROOTFS_CONFIG) $(ENABLE) python-image
	$(ROOTFS_CONFIG) $(ENABLE) python-io
	$(ROOTFS_CONFIG) $(ENABLE) python-json
	$(ROOTFS_CONFIG) $(ENABLE) python-lang
	$(ROOTFS_CONFIG) $(ENABLE) python-logging
	$(ROOTFS_CONFIG) $(ENABLE) python-mailbox
	$(ROOTFS_CONFIG) $(ENABLE) python-math
	$(ROOTFS_CONFIG) $(ENABLE) python-mime
	$(ROOTFS_CONFIG) $(ENABLE) python-misc
	$(ROOTFS_CONFIG) $(ENABLE) python-mmap
	$(ROOTFS_CONFIG) $(ENABLE) python-modules
	$(ROOTFS_CONFIG) $(ENABLE) python-multiprocessing
	$(ROOTFS_CONFIG) $(ENABLE) python-netclient
	$(ROOTFS_CONFIG) $(ENABLE) python-netserver
	$(ROOTFS_CONFIG) $(ENABLE) python-numbers
	$(ROOTFS_CONFIG) $(ENABLE) python-pickle
	$(ROOTFS_CONFIG) $(ENABLE) python-pkgutil
	$(ROOTFS_CONFIG) $(ENABLE) python-plistlib
	$(ROOTFS_CONFIG) $(ENABLE) python-pprint
	$(ROOTFS_CONFIG) $(ENABLE) python-profile
	$(ROOTFS_CONFIG) $(ENABLE) python-pydoc
	$(ROOTFS_CONFIG) $(ENABLE) python-re
	$(ROOTFS_CONFIG) $(ENABLE) python-resource
	$(ROOTFS_CONFIG) $(ENABLE) python-robotparser
	$(ROOTFS_CONFIG) $(ENABLE) python-shell
	$(ROOTFS_CONFIG) $(ENABLE) python-smtpd
	$(ROOTFS_CONFIG) $(ENABLE) python-sqlite3
	$(ROOTFS_CONFIG) $(ENABLE) python-stringold
	$(ROOTFS_CONFIG) $(ENABLE) python-subprocess
	$(ROOTFS_CONFIG) $(ENABLE) python-syslog
	$(ROOTFS_CONFIG) $(ENABLE) python-terminal
	$(ROOTFS_CONFIG) $(ENABLE) python-tests
	$(ROOTFS_CONFIG) $(ENABLE) python-textutils
	$(ROOTFS_CONFIG) $(ENABLE) python-threading
	$(ROOTFS_CONFIG) $(ENABLE) python-tkinter
	$(ROOTFS_CONFIG) $(ENABLE) python-unittest
	$(ROOTFS_CONFIG) $(ENABLE) python-unixadmin
	$(ROOTFS_CONFIG) $(ENABLE) python-xml
	$(ROOTFS_CONFIG) $(ENABLE) python-xmlrpc
	$(ROOTFS_CONFIG) $(ENABLE) python-zlib
	$(ROOTFS_CONFIG) $(ENABLE) python3
	$(ROOTFS_CONFIG) $(ENABLE) libpython3
	$(ROOTFS_CONFIG) $(ENABLE) python3-2to3
	$(ROOTFS_CONFIG) $(ENABLE) python3-async
	$(ROOTFS_CONFIG) $(ENABLE) python3-asyncio
	$(ROOTFS_CONFIG) $(ENABLE) python3-audio
	$(ROOTFS_CONFIG) $(ENABLE) python3-codecs
	$(ROOTFS_CONFIG) $(ENABLE) python3-compile
	$(ROOTFS_CONFIG) $(ENABLE) python3-compression
	$(ROOTFS_CONFIG) $(ENABLE) python3-core
	$(ROOTFS_CONFIG) $(ENABLE) python3-crypt
	$(ROOTFS_CONFIG) $(ENABLE) python3-ctypes
	$(ROOTFS_CONFIG) $(ENABLE) python3-curses
	$(ROOTFS_CONFIG) $(ENABLE) python3-datetime
	$(ROOTFS_CONFIG) $(ENABLE) python3-db
	$(ROOTFS_CONFIG) $(ENABLE) python3-debugger
	$(ROOTFS_CONFIG) $(ENABLE) python3-difflib
	$(ROOTFS_CONFIG) $(ENABLE) python3-distutils
	$(ROOTFS_CONFIG) $(ENABLE) python3-email
	$(ROOTFS_CONFIG) $(ENABLE) python3-fcntl
	$(ROOTFS_CONFIG) $(ENABLE) python3-gdbm
	$(ROOTFS_CONFIG) $(ENABLE) python3-git
	$(ROOTFS_CONFIG) $(ENABLE) python3-gitdb
	$(ROOTFS_CONFIG) $(ENABLE) python3-html
	$(ROOTFS_CONFIG) $(ENABLE) python3-idle
	$(ROOTFS_CONFIG) $(ENABLE) python3-image
	$(ROOTFS_CONFIG) $(ENABLE) python3-io
	$(ROOTFS_CONFIG) $(ENABLE) python3-json
	$(ROOTFS_CONFIG) $(ENABLE) python3-logging
	$(ROOTFS_CONFIG) $(ENABLE) python3-mailbox
	$(ROOTFS_CONFIG) $(ENABLE) python3-math
	$(ROOTFS_CONFIG) $(ENABLE) python3-mime
	$(ROOTFS_CONFIG) $(ENABLE) python3-misc
	$(ROOTFS_CONFIG) $(ENABLE) python3-mmap
	$(ROOTFS_CONFIG) $(ENABLE) python3-modules
	$(ROOTFS_CONFIG) $(ENABLE) python3-multiprocessing
	$(ROOTFS_CONFIG) $(ENABLE) python3-netclient
	$(ROOTFS_CONFIG) $(ENABLE) python3-netserver
	$(ROOTFS_CONFIG) $(ENABLE) python3-numbers
	$(ROOTFS_CONFIG) $(ENABLE) python3-pickle
	$(ROOTFS_CONFIG) $(ENABLE) python3-pkgutil
	$(ROOTFS_CONFIG) $(ENABLE) python3-pprint
	$(ROOTFS_CONFIG) $(ENABLE) python3-profile
	$(ROOTFS_CONFIG) $(ENABLE) python3-pydoc
	$(ROOTFS_CONFIG) $(ENABLE) python3-pyvenv
	$(ROOTFS_CONFIG) $(ENABLE) python3-resource
	$(ROOTFS_CONFIG) $(ENABLE) python3-setuptools
	$(ROOTFS_CONFIG) $(ENABLE) python3-shell
	$(ROOTFS_CONFIG) $(ENABLE) python3-smmap
	$(ROOTFS_CONFIG) $(ENABLE) python3-smtpd
	$(ROOTFS_CONFIG) $(ENABLE) python3-sqlite3
	$(ROOTFS_CONFIG) $(ENABLE) python3-stringold
	$(ROOTFS_CONFIG) $(ENABLE) python3-syslog
	$(ROOTFS_CONFIG) $(ENABLE) python3-terminal
	$(ROOTFS_CONFIG) $(ENABLE) python3-tests
	$(ROOTFS_CONFIG) $(ENABLE) python3-threading
	$(ROOTFS_CONFIG) $(ENABLE) python3-tkinter
	$(ROOTFS_CONFIG) $(ENABLE) python3-unittest
	$(ROOTFS_CONFIG) $(ENABLE) python3-unixadmin
	$(ROOTFS_CONFIG) $(ENABLE) python3-xml
	$(ROOTFS_CONFIG) $(ENABLE) python3-xmlrpc
	$(ROOTFS_CONFIG) $(ENABLE) python3-dbus
	$(ROOTFS_CONFIG) $(ENABLE) python3-nose
	$(ROOTFS_CONFIG) $(ENABLE) python3-numpy
	$(ROOTFS_CONFIG) $(ENABLE) python3-pygobject
	$(ROOTFS_CONFIG) $(ENABLE) python3-scons
## FS Packages - Libraries
	$(ROOTFS_CONFIG) $(ENABLE) ai-engine-driver
	$(ROOTFS_CONFIG) $(ENABLE) xrt
#	$(ROOTFS_CONFIG) $(ENABLE) zocl
## FS Packages - Miscellaneous
#	$(ROOTFS_CONFIG) $(ENABLE) udev-extraconf
#	$(ROOTFS_CONFIG) $(ENABLE) libstdcPLUSPLUS
#	$(ROOTFS_CONFIG) $(ENABLE) packagegroup-core-boot
#	$(ROOTFS_CONFIG) $(ENABLE) packagegroup-core-ssh-dropbear
#	# $(ROOTFS_CONFIG) $(ENABLE) qemu
	$(ROOTFS_CONFIG) $(ENABLE) libsysfs
#	$(ROOTFS_CONFIG) $(ENABLE) tcf-agent
## FS Packages - Network
#	$(ROOTFS_CONFIG) $(ENABLE) bridge-utils
## FS Packages - Utilities
#	$(ROOTFS_CONFIG) $(ENABLE) u-boot-tools
## PetaLinux Package Groups
	$(ROOTFS_CONFIG) $(ENABLE) packagegroup-petalinux
	$(ROOTFS_CONFIG) $(ENABLE) packagegroup-petalinux-mraa
	$(ROOTFS_CONFIG) $(ENABLE) packagegroup-petalinux-openamp
	$(ROOTFS_CONFIG) $(ENABLE) packagegroup-petalinux-opencv
	$(ROOTFS_CONFIG) $(ENABLE) packagegroup-petalinux-utils
## Image Features
#	$(ROOTFS_CONFIG) $(ENABLE) imagefeature-ssh-server-dropbear
#	$(ROOTFS_CONFIG) $(DISABLE) imagefeature-ssh-server-openssh
#	$(ROOTFS_CONFIG) $(ENABLE) imagefeature-hwcodecs
#	$(ROOTFS_CONFIG) $(DISABLE) imagefeature-package-management
#	$(ROOTFS_CONFIG) $(ENABLE) imagefeature-debug-tweaks
	$(ROOTFS_CONFIG) $(ENABLE) auto-login
## Apps
#	$(ROOTFS_CONFIG) $(ENABLE) aie-oob
	$(ROOTFS_CONFIG) $(ENABLE) gpio-demo
	$(ROOTFS_CONFIG) $(ENABLE) peekpoke
## User packages
#	$(ROOTFS_CONFIG) $(ENABLE) aie-notebooks
#	$(ROOTFS_CONFIG) $(ENABLE) openamp-demo-notebooks
#	$(ROOTFS_CONFIG) $(ENABLE) packagegroup-petalinux-jupyter
#	$(ROOTFS_CONFIG) $(ENABLE) pm-notebooks
#	$(ROOTFS_CONFIG) $(ENABLE) python3-ipywidgets
# Configure
	$(OK) "Successfully updated ${FILE_ROOTFS_CFG}"
	$(WAIT) "Configuring ${FILE_ROOTFS_CFG}"
	$(PETALINUX_CONFIG) -c rootfs && { \
		$(PASS_CONFIG_LOG)rootfs_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)rootfs_config.log; \
	}
	$(OK) "Successfully configured ${FILE_ROOTFS_CFG}"

# =========================================================
# EXTERNAL SOURCES/LAYERS
# =========================================================

.PHONY: update_ext_src update_ext_src_config clean_ext_src clean_extra_layers

PKG_GRP_VITISAI	:=${PROJ_PATH}/components/yocto/layers/meta-petalinux/recipes-core/packagegroups/packagegroup-petalinux-vitisai.bb

update_ext_src: clean_ext_src
	$(WAIT) "Updating external source code"
#	$(INFO) "Cloning meta-tensorflow from yoctoproject.org"
#	@git clone -b thud git://git.yoctoproject.org/meta-tensorflow ${SRC_PATH_EXT_SRC}/meta-tensorflow
	$(INFO) "Cloning meta-vitis-ai from github.com"
	@git clone -b rel-v2021.1 https://github.com/Xilinx/meta-vitis-ai.git ${SRC_PATH_EXT_SRC}/meta-vitis-ai
	$(ECHO) "packagegroup-petalinux-vitisai" >> \
		${USR_ROOTFS_APPEND}
	$(CP) ${PKG_GRP_VITISAI} ${PKG_GRP_VITISAI}.original
	@cat ${PKG_GRP_VITISAI} | \
		tr '\n' '\f' | \
		sed -e 's?\f    dnndk \\\f?\f?' | \
		tr '\f' '\n' | \
		tee ${PKG_GRP_VITISAI} > \
		/dev/null
	$(OK) "Successfully updated external source code"

update_ext_src_config: ${FILE_MAIN_CFG}.original ${FILE_ROOTFS_CFG}.original ${USR_ROOTFS_CFG}.original
	$(WAIT) "Updating external source code configuration"
	$(WAIT) "Proceding to add the following layers to the PetaLinux project:"
	$(INFO) "$(shell ls ${SRC_PATH_EXT_SRC})"
	@COUNTER=0; \
	for i in $(shell ls ${SRC_PATH_EXT_SRC}); do \
		echo "[INFO] Adding $${i} external layer"; \
		rm -rf ${DEST_PATH_EXT_SRC}/$${i}; \
		mkdir ${DEST_PATH_EXT_SRC}/$${i}; \
		cp -r ${SRC_PATH_EXT_SRC}/$${i} ${DEST_PATH_EXT_SRC}; \
		sed -i "s?CONFIG_USER_LAYER_$${COUNTER}=.*?CONFIG_USER_LAYER_$${COUNTER}=\"${DEST_PATH_EXT_SRC}/$${i}\"\nCONFIG_USER_LAYER_$$((COUNTER+1))=\"\"?" ${FILE_MAIN_CFG}; \
		COUNTER=$$((COUNTER+1)); \
	done;
	$(OK) "Successfully added the external layers"
	$(WAIT) "Configuring ${FILE_MAIN_CFG}"
	$(PETALINUX_CONFIG) && { \
		$(PASS_CONFIG_LOG)ext_src_main_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)ext_src_main_config.log; \
	}
	$(OK) "Successfully configured ${FILE_MAIN_CFG}"
	$(WAIT) "Adding user packages to ${USR_ROOTFS_CFG}"
	@for i in ${USR_ROOTFS_APPEND}; do \
		echo "CONFIG_$${i}" >> ${USR_ROOTFS_CFG}; \
		${PWD}/src/config --file ${FILE_ROOTFS_CFG} ${ENABLE} $${i}; \
	done;
	$(OK) "Successfully added the user packages"
	$(WAIT) "Configuring ${FILE_ROOTFS_CFG}"
	$(PETALINUX_CONFIG) -c rootfs && { \
		$(PASS_CONFIG_LOG)ext_src_rootfs_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)ext_src_rootfs_config.log; \
	}
	$(OK) "Successfully configured ${FILE_ROOTFS_CFG}"
	$(OK) "Successfully updated external source code configuration"

clean_ext_src:
	$(WAIT) "Cleaning external source components"
	$(RM) -r ${SRC_PATH_EXT_SRC}/*
	$(RM) ${USR_ROOTFS_APPEND}
	@touch ${USR_ROOTFS_APPEND}
############# PENDING #############
# https://www.hackster.io/jack-bonnell2/xilinx-kv260-petalinux-2021-1-build-vitis-ai-libraries-dd3025
	@cat ${PKG_GRP_VITISAI} | \
		tr '\n' '\f' | \
		sed -e 's?\f    opencv \\\f?\f    opencv \\\f    dnndk \\\f?' | \
		tr '\f' '\n' | \
		tee ${PKG_GRP_VITISAI} > \
		/dev/null
############ PENDING #############
	$(OK) "Successfully cleaned external source components"

clean_extra_layers:
	$(WAIT) "Cleaning extra layers"
	$(INFO) "Removing extra layers from the ${PROJ_NAME}/project-spec directory"
	@COUNTER=0; \
	for i in $(shell ls ${DEST_PATH_EXT_SRC}); do \
		if [[ "attributes configs hw-description meta-user" != *"$${i}"* ]]; then \
			echo "[INFO]    Removing $${i} external layer"; \
			rm -rf ${DEST_PATH_EXT_SRC}/$${i}; \
		fi; \
	done;
	$(INFO) "Removing user layers from ${FILE_MAIN_CFG}"
	@sed -i "s?CONFIG_USER_LAYER_0=.*?CONFIG_USER_LAYER_0=\"\"?" ${FILE_MAIN_CFG}
	@cat ${FILE_MAIN_CFG} | \
		tr '\n' '\f' | \
		sed -e 's?\fCONFIG_USER_LAYER_1=.*\fCONFIG_?\fCONFIG_?' | \
		tr '\f' '\n' | \
		tee ${FILE_MAIN_CFG} > \
		/dev/null
		$(WAIT) "Configuring ${FILE_MAIN_CFG}"
	$(PETALINUX_CONFIG) && { \
		$(PASS_CONFIG_LOG)clean_ext_src_main_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)clean_ext_src_main_config.log; \
	}
	$(OK) "Successfully configured ${FILE_MAIN_CFG}"
	$(INFO) "Removing user packages from ${FILE_ROOTFS_CFG}"
	@for i in ${USR_ROOTFS_APPEND}; do \
		cat ${FILE_ROOTFS_CFG} | \
			tr '\n' '\f' | \
			sed -e 's?\fCONFIG_$${i}=y\f?\f?' | \
			tr '\f' '\n' | \
			tee ${FILE_ROOTFS_CFG} > \
			/dev/null; \
	done;
	$(WAIT) "Configuring ${FILE_ROOTFS_CFG}"
	$(PETALINUX_CONFIG) -c rootfs && { \
		$(PASS_CONFIG_LOG)clean_ext_src_rootfs_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)clean_ext_src_rootfs_config.log; \
	}
	$(OK) "Successfully configured ${FILE_ROOTFS_CFG}"
	$(INFO) "Restoring original ${USR_ROOTFS_CFG}"
	$(CP) ${USR_ROOTFS_CFG}.original ${USR_ROOTFS_CFG}
	$(OK) "Successfully cleaned extra layers"

# =========================================================
# DEVICE TREE (deprecated)
# =========================================================

.PHONY: update_device_tree

update_device_tree:
	$(WAIT) "Updating device tree"
	$(OK) "Successfully updated device tree"

# =========================================================
# XEN HYPERVISOR
# =========================================================

.PHONY: enable_xen_hypervisor disable_xen_hypervisor

enable_xen_hypervisor: ${FILE_SYSTEM_USR}.original ${DT_BBAPPEND}.original disable_xen_hypervisor
	$(WAIT) "Enabling Xen Hypervisor"
	$(WAIT) "Updating ${FILE_MAIN_CFG}"
	$(MAIN_CONFIG) $(DISABLE) SUBSYSTEM_ROOTFS_INITRAMFS
	$(MAIN_CONFIG) $(ENABLE) SUBSYSTEM_ROOTFS_INITRD
	$(MAIN_CONFIG) $(SET_STR) CONFIG_SUBSYSTEM_INITRAMFS_IMAGE_NAME "petalinux-image-minimal"
	$(OK) "Successfully updated ${FILE_MAIN_CFG}"
	$(WAIT) "Configuring ${FILE_MAIN_CFG}"
	$(PETALINUX_CONFIG) && { \
		$(PASS_CONFIG_LOG)enable_xen_main_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)enable_xen_main_config.log; \
	}
	$(OK) "Successfully configured ${FILE_MAIN_CFG}"
	$(WAIT) "Updating ${FILE_ROOTFS_CFG}"
	$(ROOTFS_CONFIG) $(ENABLE) packagegroup-petalinux-xen
	$(OK) "Successfully updated ${FILE_ROOTFS_CFG}"
	$(WAIT) "Configuring ${FILE_ROOTFS_CFG}"
	$(PETALINUX_CONFIG) -c rootfs && { \
		$(PASS_CONFIG_LOG)enable_xen_rootfs_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)enable_xen_rootfs_config.log; \
	}
	$(OK) "Successfully configured ${FILE_ROOTFS_CFG}"
	$(WAIT) "Modifying the device tree"
	$(INFO) "Including xen.dtsi to system-user.dtsi"
	$(CP) ${FILE_SYSTEM_USR} ${FILE_SYSTEM_USR}.${TIME}.old
	$(CP) ./src/xen.dtsi ${PROJ_PATH}/project-spec/meta-user/recipes-bsp/device-tree/files/xen.dtsi
	@sed -i 's?/include/ "system-conf.dtsi"?/include/ "system-conf.dtsi"\n/include/ "xen.dtsi"\n/include/ "xen-qemu.dtsi"?' ${FILE_SYSTEM_USR}
ifeq ("${QEMU}","TRUE")
	$(INFO) "Disabling virtual cores for QEMU"
	$(CP) ./src/xen-qemu.dtsi ${PROJ_PATH}/project-spec/meta-user/recipes-bsp/device-tree/files/xen-qemu.dtsi
else
	$(INFO) "Enabling virtual cores for HW"
	$(ECHO) "/ {\n};" | \
		tee ${PROJ_PATH}/project-spec/meta-user/recipes-bsp/device-tree/files/xen-qemu.dtsi > \
		/dev/null
endif
	$(INFO) "Including xen.dtsi to device-tree.bbappend"
	$(CP) ${DT_BBAPPEND} ${DT_BBAPPEND}.${TIME}.old
	$(ECHO) "SRC_URI_append = \" file://xen.dtsi file://xen-qemu.dtsi\"" >> \
		${DT_BBAPPEND}
	$(OK) "Successfully modified the device tree"
	$(OK) "Successfully enabled Xen Hypervisor"

disable_xen_hypervisor: ${FILE_SYSTEM_USR}.original ${DT_BBAPPEND}.original
	$(WAIT) "Disabling Xen Hypervisor"
	$(WAIT) "Updating ${FILE_MAIN_CFG}"
	$(MAIN_CONFIG) $(DISABLE) SUBSYSTEM_ROOTFS_INITRD
	$(MAIN_CONFIG) $(ENABLE) SUBSYSTEM_ROOTFS_INITRAMFS
	$(MAIN_CONFIG) $(SET_STR) CONFIG_SUBSYSTEM_INITRAMFS_IMAGE_NAME "petalinux-initramfs-image"
	$(OK) "Successfully updated ${FILE_MAIN_CFG}"
	$(WAIT) "Configuring ${FILE_MAIN_CFG}"
	$(PETALINUX_CONFIG) && { \
		$(PASS_CONFIG_LOG)disable_xen_main_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)disable_xen_main_config.log; \
	}
	$(OK) "Successfully configured ${FILE_MAIN_CFG}"
	$(WAIT) "Updating ${FILE_ROOTFS_CFG}"
	$(ROOTFS_CONFIG) $(DISABLE) packagegroup-petalinux-xen
	$(OK) "Successfully updated ${FILE_ROOTFS_CFG}"
	$(WAIT) "Configuring ${FILE_ROOTFS_CFG}"
	$(PETALINUX_CONFIG) -c rootfs && { \
		$(PASS_CONFIG_LOG)disable_xen_rootfs_config.log; \
	} || { \
		$(ERROR_CONFIG_LOG)disable_xen_rootfs_config.log; \
	}
	$(OK) "Successfully configured ${FILE_ROOTFS_CFG}"
	$(WAIT) "Modifying the device tree"
	$(INFO) "Excluding xen.dtsi & xen-qemu.dtsi from system-user.dtsi"
	$(CP) ${FILE_SYSTEM_USR} ${FILE_SYSTEM_USR}.${TIME}.old
	$(ECHO) "/ {\n};" | \
		tee ${PROJ_PATH}/project-spec/meta-user/recipes-bsp/device-tree/files/xen-qemu.dtsi > \
		/dev/null
	@cat ${FILE_SYSTEM_USR} | \
		tr '\n' '\f' | \
		sed -e 's?\f/include/ "xen.dtsi"\f/include/ "xen-qemu.dtsi"??' | \
		tr '\f' '\n' | tee ${FILE_SYSTEM_USR} > \
		/dev/null
	$(INFO) "Excluding xen.dtsi from device-tree.bbappend"
	$(CP) ${DT_BBAPPEND} ${DT_BBAPPEND}.${TIME}.old
	@cat ${DT_BBAPPEND} | \
		tr '\n' '\f' | \
		sed -e 's?\fSRC_URI_append = " file://xen.dtsi file://xen-qemu.dtsi"??' | \
		tr '\f' '\n' | \
		tee ${DT_BBAPPEND} > \
		/dev/null
	$(OK) "Successfully modified the device tree"
	$(OK) "Successfully disabled Xen Hypervisor"

# =========================================================
# BUILD & PACKAGE
# =========================================================

${LINUX_DIR}/ ${ROOTFS} ${IMAGE} ${BL31} ${BOOT_SCR}: update_build
update_build:
	$(WAIT) "Updating build"
	$(INFO) "Removing output dependencies"
	$(RM) update_build update_bootimage update_sdk update_sysroot
	$(PETALINUX_BUILD) && { \
		$(PASS_BUILD_LOG)build.log; \
		touch ../update_build; \
	} || { \
		$(ERROR_BUILD_LOG)build.log; \
	}
	$(OK) "Successfully updated build"

${BOOT} ${BOOT_BH} ${QEMU_BOOT} ${PLM} ${PSMFW} ${UBOOT} ${DTB}: update_bootimage
update_bootimage: ${ROOTFS} ${IMAGE} ${BL31} ${BOOT_SCR}
	$(WAIT) "Packaging BOOT image"
	$(INFO) "Removing output dependencies"
	$(RM) update_bootimage
	$(PETALINUX_PACKAGE) --boot --plm --psmfw --u-boot --dtb --force && { \
		$(PASS_PACKAGE_LOG)bootimage.log; \
		touch ../update_bootimage; \
	} || { \
		$(ERROR_PACKAGE_LOG)bootimage.log; \
	}
	$(OK) "Successfully packaged BOOT image"

${SDK}: update_sdk
update_sdk: ${ROOTFS} ${IMAGE} ${BL31} ${BOOT_SCR}
	$(WAIT) "Building SDK"
	$(INFO) "Removing output dependencies"
	$(RM) update_sdk update_sysroot
ifeq (${LINUX_BUILD_SRC},"local")
# Turn Network Access ON here, since it's not included in the MIRROR
	$(INFO) "Turning Network Access ON"
	$(MAIN_CONFIG) $(DISABLE) CONFIG_YOCTO_BB_NO_NETWORK
	$(PETALINUX_CONFIG)
endif
	$(PETALINUX_BUILD) --sdk && { \
		$(PASS_BUILD_LOG)sdk.log; touch ../update_sdk; \
	} || { \
		$(ERROR_BUILD_LOG)sdk.log; \
	}
ifeq (${LINUX_BUILD_SRC},"local")
# Turn Network Access ON here, since it's not included in the MIRROR
	$(INFO) "Turning Network Access OFF"
	$(MAIN_CONFIG) $(ENABLE) CONFIG_YOCTO_BB_NO_NETWORK
	$(PETALINUX_CONFIG)
endif
	$(OK) "Successfully built SDK"

${SYSROOT}/: update_sysroot
update_sysroot: ${SDK}
	$(WAIT) "Packaging sysroot"
	$(INFO) "Removing output dependencies"
	$(RM) update_sysroot
	@mkdir -p ${SYSROOT}
	$(PETALINUX_PACKAGE) --sysroot -d ${SYSROOT} && { \
		$(PASS_PACKAGE_LOG)sysroot.log; \
		touch ../update_sysroot; \
	} || { \
		$(ERROR_PACKAGE_LOG)sysroot.log; \
	}
	$(OK) "Successfully packaged sysroot"

# =========================================================
# QEMU SIMULATION
# =========================================================

.PHONY: qemu

qemu: update_bootimage
	$(WAIT) "Launching QEMU"
	$(ECHO) "$(PETALINUX_BOOT) --qemu --kernel" | \
		tee ${PWD}/qemu > \
		/dev/null
	@chmod +x ${PWD}/qemu
	@script -q ${PWD}/${TIME}_qemu.log -c ${PWD}/qemu
	$(RM) ${PWD}/qemu
	$(OK) "Exited from QEMU"
