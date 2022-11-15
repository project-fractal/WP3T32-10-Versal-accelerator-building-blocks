SHELL	:=/bin/bash

#
# Copyright 2022 IKERLAN S.COOP.
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

TIME			?=$(shell date "+%Y%m%d-%H%M%S")
PLATFORM_NAME	?=fractal
JOBS			?=4
CONTAINER		?=FALSE
XEN_HYPERVISOR	?=FALSE
QEMU			?=FALSE
XILINX_PATH		?=/tools/Xilinx
XILINX_VER		?=2021.2

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
EXIT	:=$(ECHO) "\n" && exit 1
MAKE	:=$(MAKE)
CFG		:=@./src/config
PWD		:=$(shell pwd)
DISTRO	:=$(shell cat /etc/*elease* | grep -i "^ID=" | cut -d "=" -f 2)
INSTALL	:=$(ERROR) "Cannot auto-install on $(DISTRO) distribution.\nPlease install it manually and re-run de 'make' command." && $(EXIT)
ifneq (,$(findstring "ubuntu",${DISTRO}))
INSTALL	:=sudo apt-get install -y
endif
ifneq (,$(findstring "debian",${DISTRO}))
INSTALL	:=sudo apt-get install -y
endif
ifneq (,$(findstring "centos",${DISTRO}))
INSTALL	:=sudo yum install -y
endif
ifneq (,$(findstring "rhel",${DISTRO}))
INSTALL	:=sudo yum install -y
endif
ifneq (,$(findstring "fedora",${DISTRO}))
INSTALL	:=sudo dnf install -y
endif

# =========================================================
# DIRECTORIES
# =========================================================

PLATFORM_DIR	:= ${PWD}

PETALINUX_INSTALLER	:=${PLATFORM_DIR}/src/petalinux-v${XILINX_VER}-final-installer.run
BSP					:=${PLATFORM_DIR}/src/xilinx-vck190-v${XILINX_VER}-final.bsp
COMMON_IMAGE		:=${PLATFORM_DIR}/src/xilinx-versal-common-v${XILINX_VER}.tar.gz

BOARD_REPO	:=${PLATFORM_DIR}/vivado/src/board_repo
XPR_NAME	:=${PLATFORM_NAME}_platform.xpr
XSA_NAME	:=${PLATFORM_NAME}_platform.xsa
XPR			:=${PLATFORM_DIR}/vivado/${PLATFORM_NAME}_platform/${XPR_NAME}
XSA			:=${PLATFORM_DIR}/vivado/${PLATFORM_NAME}_platform/${XSA_NAME}

SYSROOT	:=${PLATFORM_DIR}/petalinux/sysroot
ROOTFS	:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_platform/images/linux/rootfs.ext4
IMAGE	:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_platform/images/linux/Image
BL31	:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_platform/images/linux/bl31.elf
DTB		:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_platform/images/linux/system.dtb
UBOOT	:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_platform/images/linux/u-boot.elf
BIF		:=${PLATFORM_DIR}/petalinux/src/boot_custom.bif
BOOTSCR	:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_platform/images/linux/boot.scr

# =========================================================
# SCRIPT ARGUMETS
# =========================================================

MAKE_VIVADO_ARGS	:=PLATFORM_CUSTOM=${PLATFORM_NAME}_platform PRE_SYNTH=true DEVICE_NAME=xcvc1902-vsva2197-2MP-e-S JOBS=${JOBS}
MAKE_PETALINUX_ARGS	:=PROJ_NAME=${PLATFORM_NAME}_platform XEN_HYPERVISOR=${XEN_HYPERVISOR} QEMU=${QEMU} XILINX_VER=${XILINX_VER} TIME=${TIME}
MAKE_VITIS_ARGS		:=PLATFORM_NAME=${PLATFORM_NAME}_platform XSA=${XSA} TIME=${TIME}

UBUNTU_VERSION	?=18.04
DOCKER_ENV_VAR	:=	-e DISPLAY=${DISPLAY} \
					-e PROJ_NAME=${PLATFORM_NAME}_platform \
					-e XEN_HYPERVISOR=${XEN_HYPERVISOR} \
					-e QEMU=${QEMU} \
					-e XILINX_VER=${XILINX_VER} \
					-e MAKE_ARGS="${MAKE_PETALINUX_ARGS}" \
					-e TIME=${TIME}
DOCKER_VOLUMES	:=	-v ${PLATFORM_DIR}/petalinux:/home/xilinx/petalinux \
					-v ${PLATFORM_DIR}/vivado:/home/xilinx/vivado \
					-v ${PLATFORM_DIR}/src:/home/xilinx/src \
					-v /tftpboot:/tftpboot

# =========================================================
# RECIPES
# =========================================================

.PHONY: all check_all clean_all

all:
#	$(MAKE) clean_all
	$(MAKE) check_all
	$(MAKE) ${XSA}
ifeq ("${CONTAINER}","TRUE")
	$(MAKE) petalinux-${XILINX_VER}_docker
endif
	$(MAKE) petalinux_os
#	$(MAKE) sw_platform

clean_all: clean_hw_platform clean_docker clean_petalinux_os clean_sw_platform

# =========================================================
# REQUIREMENTS
# =========================================================

.PHONY: check_all check_vivado check_vitis check_curl check_docker check_max_user_watches

VIVADO_VER	:= $(shell vivado -version 2>/dev/null | grep "Vivado ")
VITIS_VER	:= $(shell vitis -version 2>/dev/null | grep "Vitis " | sed 's/\*//g')

check_all: check_vivado check_vitis check_docker check_max_user_watches ${PETALINUX_INSTALLER} ${BSP} ${COMMON_IMAGE}
	$(WAIT) "Checking if PetaLinux installer is in the src/ directory"
	$(OK) "PetaLinux installer"
	$(WAIT) "Checking if VCK190 BSP is in the src/ directory"
	$(OK) "VCK190 BSP"

check_vivado:
	$(WAIT) "Checking Vivado version"
ifndef VIVADO_VER
	$(ERROR) "Vivado not installed or its settings are not sourced. Make sure to source it before running this script.\nsource <XILINX_INSTALL_DIR>/Vivado/${XILINX_VER}/settings64.sh"
	$(EXIT)
endif
ifeq (,$(findstring ${XILINX_VER},${VIVADO_VER}))
	$(ERROR) "${VIVADO_VER}\nUnsupported Vivado version. Please use v${XILINX_VER}"
	$(EXIT)
endif
	$(OK) "Vivado v${XILINX_VER}"

check_vitis:
	$(WAIT) "Checking Vitis version"
ifndef VITIS_VER
	$(ERROR) "Vitis not installed or its settings are not sourced. Make sure to source it before running this script.\nsource <XILINX_INSTALL_DIR>/Vitis/${XILINX_VER}/settings64.sh"
	$(EXIT)
endif
ifeq (,$(findstring ${XILINX_VER},${VITIS_VER}))
	$(ERROR) "${VITIS_VER}\nUnsupported Vitis version. Please use v${XILINX_VER}"
	$(EXIT)
endif
	$(OK) "Vitis v${XILINX_VER}"

check_curl:
	$(WAIT) "Checking curl installation"
ifeq (,$(shell curl -V))
	$(INSTALL) curl
endif
	$(OK) "curl installed"

check_docker:
ifeq ("${CONTAINER}","TRUE")
	$(WAIT) "Checking Docker installation"
ifeq (,$(shell docker -v))
	$(INFO) "Docker not found. Installing it using ${DISTRO} tools"
	$(MAKE) check_curl
	curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
	sudo systemctl enable docker.service
	sudo systemctl enable containerd.service
	sudo systemctl start docker
endif
	$(OK) "Docker installed"
endif

check_max_user_watches:
	$(WAIT) "Modifying max_user_watches"
	@sudo sysctl -n -w fs.inotify.max_user_watches=524288
	$(OK) "max_user_watches modified"

${PETALINUX_INSTALLER}:
	$(ERROR) "Missing the PetaLinux ${XILINX_VER} installer.\nPlease download it from:\nhttps://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-platforms/${XILINX_VER:.=-}.html\nand place it in the ./src/ directory.\nYou can run 'make petalinux-${XILINX_VER}_docker' afterwards if necessary."
	$(EXIT)

${BSP}:
	$(ERROR) "Missing the Versal AI Core series VCK190 BSP.\nPlease download it from:\nhttps://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-platforms/${XILINX_VER:.=-}.html\nand place it in the ./src/ directory."
	$(EXIT)

${COMMON_IMAGE}:
	$(ERROR) "Missing the Versal Common Image.\nPlease download it from:\nhttps://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-platforms/${XILINX_VER:.=-}.html\nand place it in the ./src/ directory."
	$(EXIT)

# =========================================================
# HW PLATFORM
# =========================================================

.PHONY: clean_hw_platform hw_platform launch_vivado

hw_platform: check_vivado ${XSA}
${XSA}:
	$(MAKE) xsa -C ${PLATFORM_DIR}/vivado ${MAKE_VIVADO_ARGS}

launch_vivado:
	$(MAKE) launch -C ${PLATFORM_DIR}/vivado ${MAKE_VIVADO_ARGS}

clean_hw_platform:
	$(MAKE) clean -C ${PLATFORM_DIR}/vivado ${MAKE_VIVADO_ARGS}

# =========================================================
# PETALINUX DOCKER
# =========================================================

.PHONY: run_petalinux_docker clean_docker

petalinux-${XILINX_VER}_docker: | check_docker ${PETALINUX_INSTALLER}
	$(MAKE) clean_docker
	$(WAIT) "Building the Docker image with PetaLinux ${XILINX_VER}"
	@sudo docker build \
		-t petalinux:${XILINX_VER} \
		--build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg PETA_VERSION=${XILINX_VER} \
		${PLATFORM_DIR}
	@touch petalinux-${XILINX_VER}_docker
	$(OK) "Successfully built \"petalinux-${XILINX_VER}_docker\" image"

run_petalinux_docker: | petalinux-${XILINX_VER}_docker
	$(WAIT) "Launching the \"petalinux-${XILINX_VER}_docker\" container"
	@sudo docker run -it --rm \
		--net="host" \
		${DOCKER_ENV_VAR} \
		${DOCKER_VOLUMES} \
		petalinux:${XILINX_VER} \
		/bin/bash
	$(OK) "Successfully exited the \"petalinux-${XILINX_VER}_docker\" container"

clean_docker: check_docker
	$(WAIT) "Removing the \"petalinux-${XILINX_VER}_docker\" container from the system"
	@sudo docker rmi -f petalinux:${XILINX_VER}
	$(RM) ${PLATFORM_DIR}/petalinux-${XILINX_VER}_docker
	$(OK) "Successfully removed the \"petalinux-${XILINX_VER}_docker\" container from the system"

# =========================================================
# PETALINUX
# =========================================================

.PHONY: petalinux_os update_petalinux_os qemu clean_petalinux_os

petalinux_os ${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_platform:
ifeq ("${CONTAINER}","TRUE")
	$(WAIT) "Running Docker container to build PetaLinux"
	@sudo sysctl -n -w fs.inotify.max_user_watches=524288
	@sudo docker run -it --rm \
		--net="host" \
		${DOCKER_ENV_VAR} \
		${DOCKER_VOLUMES} \
		petalinux:${XILINX_VER} \
		bash -c " \
			source ${XILINX_PATH}/PetaLinux/${XILINX_VER}/settings.sh; \
			make all ${MAKE_PETALINUX_ARGS}"
	$(OK) "Exited Docker container"
else
	$(MAKE) all -C ${PLATFORM_DIR}/petalinux ${MAKE_PETALINUX_ARGS}
endif

qemu:
ifeq ("${CONTAINER}","TRUE")
	$(WAIT) "Running Docker container to launch QEMU"
	@sudo docker run -it --rm \
		--net="host" \
		${DOCKER_ENV_VAR} \
		${DOCKER_VOLUMES} \
		petalinux:${XILINX_VER} \
		bash -c " \
			source ${XILINX_PATH}/PetaLinux/${XILINX_VER}/settings.sh; \
			make qemu ${MAKE_PETALINUX_ARGS}"
	$(OK) "Exited Docker container"
else
	$(MAKE) qemu -C ${PLATFORM_DIR}/petalinux ${MAKE_PETALINUX_ARGS}
endif

clean_petalinux_os:
	$(MAKE) clean -C ${PLATFORM_DIR}/petalinux

# =========================================================
# SW PLATFORM
# =========================================================

.PHONY: sw_platform clean_sw_platform

sw_platform: check_vitis
	$(MAKE) all -C ${PLATFORM_DIR}/vitis ${MAKE_VITIS_ARGS}

clean_sw_platform:
	$(MAKE) clean -C ${PLATFORM_DIR}/vitis ${MAKE_VITIS_ARGS}
