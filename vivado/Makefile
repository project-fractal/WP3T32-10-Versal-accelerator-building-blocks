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

PLATFORM_CUSTOM ?=thin_platform
PRE_SYNTH ?=true
DEVICE_NAME ?=xcvc1902-vsva2197-2MP-e-S
TIME ?= $(shell date "+%Y%m%d-%H%M%S")
JOBS ?=4

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
CFG		:=@./src/config
PWD		:=$(shell pwd)
VIVADO	:=@vivado -mode batch -nojournal -log vivado.log -source

# =========================================================
# DIRECTORIES
# =========================================================

BUILD_DIR	:=${PWD}/${PLATFORM_CUSTOM}
XSA			:=${PLATFORM_CUSTOM}.xsa
XPR			:=${PLATFORM_CUSTOM}.xpr

SRC_DIR	:=${PWD}/src
QOR_SCRIPTS_DIR	:=${SRC_DIR}/qor_scripts

# =========================================================
#  BOARD PART SELECTION (ES1/Production)
# =========================================================

ifeq (${DEVICE_NAME}, xcvc1902-vsva2197-2MP-e-S)
  BOARD_LABEL:=vck190
  BOARD_VER:=2.2
else ifeq (${DEVICE_NAME}, xcvc1902-vsva2197-2MP-e-S-es1)
  BOARD_LABEL:=vck190_es
  BOARD_VER:=1.3
endif

# =========================================================
# XSA CREATION SCRIPT
# =========================================================

CREATE_XSA_TCL	:=${SRC_DIR}/platform_xsa.tcl
LAUNCH_TCL		:=${SRC_DIR}/launch_vivado.tcl

CREATE_XSA_ARGS	:=${PLATFORM_CUSTOM} ${BUILD_DIR} ${DEVICE_NAME} ${BOARD_LABEL} ${BOARD_VER} ${PRE_SYNTH} ${JOBS}

# =========================================================
# DEPENDENCIES
# =========================================================

DEPS := ${CREATE_XSA_TCL}
DEPS += ${QOR_SCRIPTS_DIR}/post_place.tcl
DEPS += ${QOR_SCRIPTS_DIR}/pre_place.tcl
DEPS += ${QOR_SCRIPTS_DIR}/post_route.tcl
DEPS += ${QOR_SCRIPTS_DIR}/post_physopt.tcl
DEPS += ${QOR_SCRIPTS_DIR}/prohibitCascBramAcrossRbrk.tcl
DEPS += ${QOR_SCRIPTS_DIR}/prohibitCascDspAcrossRbrk.tcl
DEPS += ${QOR_SCRIPTS_DIR}/prohibitCascUramAcrossRbrk.tcl
DEPS += ${QOR_SCRIPTS_DIR}/timing.xdc
DEPS += ${QOR_SCRIPTS_DIR}/waive_BLI_AIE_timing_violations_postplace.tcl
DEPS += ${QOR_SCRIPTS_DIR}/waive_BLI_AIE_timing_violations_preplace.tcl
DEPS += ${SRC_DIR}/board_repo
DEPS += ${SRC_DIR}/post_link_pfm_config.tcl
DEPS += ${SRC_DIR}/dr.bd.tcl
DEPS += ${SRC_DIR}/pfm_decls.tcl
DEPS += ${SRC_DIR}/ddr4_dmc_3200_triplet_1.xdc

# =========================================================
# RECIPES
# =========================================================

.PHONY: all clean
all:
	$(MAKE) clean
	$(MAKE) xsa

clean:
	$(WAIT) "Cleaning HW platform"
	$(RM) -r ${BUILD_DIR}/${XSA}
	$(RM) -r ${BUILD_DIR}
	$(RM) -r vivado.log *.jou .Xil
	$(OK) "Successfully cleaned HW platform"

# =========================================================
# HW_PLATFORM
# =========================================================

.PHONY: xsa ${BUILD_DIR}/${XSA}

${SRC_DIR}/board_repo:
	git clone https://github.com/Xilinx/XilinxBoardStore.git ${SRC_DIR}/board_repo

xsa: ${BUILD_DIR}/${XSA}
${BUILD_DIR}/${XPR}: ${BUILD_DIR}/${XSA}
${BUILD_DIR}/${XSA}: ${DEPS}
	$(WAIT) "Creating XSA"
	$(VIVADO) -source ${CREATE_XSA_TCL} -tclargs ${CREATE_XSA_ARGS} && \
	( \
		cp vivado.log ${TIME}_PASS_vivado.log; \
		echo -e "[OK]" "Successfully created XSA"; \
	) || ( \
		cp vivado.log ${TIME}_ERROR_vivado.log; \
		echo -e "[ERROR]" "Failed to create XSA"; \
		exit $$? \
	)

# =========================================================
# LAUNCH
# =========================================================

.PHONY: launch

#launch: ${BUILD_DIR}/${XPR}
launch:
	$(WAIT) "Launching Vivado and opening ${XPR}..."
	$(VIVADO) -source ${LAUNCH_TCL} -nolog
	$(OK) "Successfully exited Vivado"
