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
PLATFORM_NAME	?=thin_platform
XSA				?=thin_platform.xsa

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

# =========================================================
# DIRECTORIES
# =========================================================

PLATFORM_DIR	:=$(dirname "${PWD}")

VIT_IMPORT_FROM_VIVADO_DIR		:=${PWD}/src/import_from_vivado
VIT_IMPORT_FROM_PETALINUX_DIR	:=${PWD}/src/import_from_petalinux

SYSROOT	:=${PLATFORM_DIR}/petalinux/sysroot
ROOTFS	:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_linux/images/linux/rootfs.ext4
IMAGE	:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_linux/images/linux/Image
BL31	:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_linux/images/linux/bl31.elf
DTB		:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_linux/images/linux/system.dtb
UBOOT	:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_linux/images/linux/u-boot.elf
BOOTSCR	:=${PLATFORM_DIR}/petalinux/${PLATFORM_NAME}_linux/images/linux/boot.scr
BIF		:=${PLATFORM_DIR}/petalinux/src/boot_custom.bif


VIT_SW_COMP		:=${VIT_IMPORT_FROM_PETALINUX_DIR}/sw_comp
VIT_BOOT		:=${VIT_IMPORT_FROM_PETALINUX_DIR}/boot
VIT_BOOT_SCR	:=${VIT_IMPORT_FROM_PETALINUX_DIR}/image/boot.scr

# =========================================================
# RECIPES
# =========================================================

.PHONY: all clean

all:
	$(MAKE) clean
	$(MAKE) sw_platform

clean: clean_import_from_vivado clean_import_from_petalinux
# Clean vitis directory
	$(RM) -r ${PLATFORM_DIR}/vitis/RemoteSystemsTempFiles
	$(RM) -r ${PLATFORM_DIR}/vitis/build
	$(RM) -r ${PLATFORM_DIR}/vitis/.Xil

# =========================================================
# IMPORTS
# =========================================================

.PHONY: ${VIT_SW_COMP}/ ${VIT_BOOT}/ ${VIT_BOOT_SCR} ${VIT_IMPORT_FROM_VIVADO_DIR}/${XSA_NAME}

${XSA}:
	$(MAKE) ${XSA} -C ../vivado
${ROOTFS}:
	$(MAKE) ${ROOTFS} -C ../petalinux
${IMAGE}:
	$(MAKE) ${IMAGE}/ -C ../petalinux
${SYSROOT}/:
	$(MAKE) ${SYSROOT}/ -C ../petalinux
${BL31}:
	$(MAKE) ${BL31} -C ../petalinux
${DTB}:
	$(MAKE) ${DTB} -C ../petalinux
${UBOOT}:
	$(MAKE) ${UBOOT} -C ../petalinux
${BOOTSCR}:
	$(MAKE) ${BOOTSCR} -C ../petalinux
${BIF}:
	$(MAKE)  ${BIF} -C ../petalinux

${VIT_SW_COMP}/: ${ROOTFS} ${IMAGE} ${SYSROOT}/
	$(WAIT) "Importing sysroots & filesystem structure & Linux Image from PetaLinux"
	$(INFO) "Copying sysroots & filesystem structure"
	$(CP) -r ${SYSROOT}/* ${VIT_IMPORT_FROM_PETALINUX_DIR}/sw_comp/
	$(CP) ${ROOTFS} ${VIT_IMPORT_FROM_PETALINUX_DIR}/sw_comp/rootfs.ext4
	$(INFO) "Copying Linux Image"
	$(CP) ${IMAGE} ${VIT_IMPORT_FROM_PETALINUX_DIR}/sw_comp/Image
	$(OK) "Successfully imported sysroots & filesystem structure & Linux Image from PetaLinux"

${VIT_BOOT}/: ${BL31} ${DTB} ${UBOOT} ${BIF}
	$(WAIT) "Importing BOOT components & BOOT image generation description file"
	$(INFO) "Copying BOOT components (referred to in linux.bif)""
	$(CP) ${BL31} ${VIT_BOOT}/bl31.elf
	$(CP) ${DTB} ${VIT_BOOT}/system.dtb
	$(CP) ${UBOOT} ${VIT_BOOT}/u-boot.elf
	$(INFO) "Copying BOOT image generation description file"
	$(CP) ${BIF} ${VIT_BOOT}/linux.bif
	$(OK) "Successfully imported BOOT components & BOOT image generation description file"

${VIT_BOOT_SCR}: ${BOOTSCR}
	$(WAIT) "Importing U-Boot configuration file"
	$(CP) ${BOOTSCR} ${VIT_IMPORT_FROM_PETALINUX_DIR}/image/.
	$(OK) "Successfully imported U-Boot configuration file"

${VIT_IMPORT_FROM_VIVADO_DIR}/${XSA_NAME}: ${XSA}
	$(WAIT) "Importing XSA from Vivado"
	$(CP) ${XSA} ${VIT_IMPORT_FROM_VIVADO_DIR}/.
	$(OK) "Successfully imported XSA from Vivado"

# =========================================================
# SW_PLATFORM
# =========================================================

sw_platform: ${VIT_IMPORT_FROM_VIVADO_DIR}/${XSA_NAME} ${VIT_SW_COMP} ${VIT_BOOT} ${VIT_BOOT_SCR}
	$(MAKE) clean_sw_platform
	$(CP) ${PLATFORM_DIR}/vitis && xsct src/build_sw_platform.tcl > vitis/${TIME}_sw_build.log

# =========================================================
# MOVE DATA BETWEEN PROJECTS
# =========================================================

.PHONY: import_from_vivado clean_import_from_vivado import_from_petalinux clean_import_from_petalinux

import_from_vivado: clean_import_from_vivado
	$(MAKE) ${VIT_IMPORT_FROM_VIVADO_DIR}/${XSA_NAME}

import_from_petalinux: clean_import_from_petalinux
	$(MAKE) ${VIT_SW_COMP}/
	$(MAKE) ${VIT_BOOT}/
	$(MAKE) ${VIT_BOOT_SCR}

clean_import_from_vivado:
	$(WAIT) "Cleaning Vivado's imported files"
	$(RM) ${VIT_IMPORT_FROM_VIVADO_DIR}/*
	$(OK) "Successfully cleaned Vivado's imported files"

clean_import_from_petalinux:
	$(WAIT) "Cleaning Petalinux's imported files"
	$(RM) -r ${VIT_IMPORT_FROM_PETALINUX_DIR}/boot/*
	$(RM) -r ${VIT_IMPORT_FROM_PETALINUX_DIR}/image/*
	$(RM) -r ${VIT_IMPORT_FROM_PETALINUX_DIR}/sw_comp/*
	$(OK) "Successfully cleaned Petalinux's imported files"
	