# Modules.tcl: script to compile card
# Copyright (C) 2023 CESNET z. s. p. o.
# Author(s): Jakub Cabal <cabal@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# converting input list to associative array
array set ARCHGRP_ARR $ARCHGRP

# Paths
set BOOT_CTRL_BASE           "$OFM_PATH/../core/intel/src/comp/boot_ctrl"
set AXI_QSPI_FLASH_CTRL_BASE "$ENTITY_BASE/../../../silicom/fb2cghh/src/comp/axi_quad_flash_controller"
#set MI2AXI4_BASE   "$OFM_PATH/comp/mi_tools/converters/mi2axi4"

# Components
lappend COMPONENTS [list "FPGA_COMMON"         $ARCHGRP_ARR(CORE_BASE)   $ARCHGRP]
lappend COMPONENTS [list "BOOT_CTRL"           $BOOT_CTRL_BASE           "FULL"  ]
lappend COMPONENTS [list "AXI_QSPI_FLASH_CTRL" $AXI_QSPI_FLASH_CTRL_BASE "FULL"  ]
#lappend COMPONENTS [list "MI2AXI4"     $MI2AXI4_BASE           "FULL"  ]

# IP sources
lappend MOD "$ENTITY_BASE/ip/axi_quad_spi/axi_quad_spi_0.xci"
lappend MOD "$ENTITY_BASE/ip/pcie_gen3_x16/pcie4_uscale_plus.xci"
if {$ARCHGRP_ARR(VIRTUAL_DEBUG_ENABLE)} {
    lappend MOD "$ENTITY_BASE/ip/xvc_vsec/xvc_vsec.xci"
}

lappend MOD "$ENTITY_BASE/ip/hbm/hbm_ip.xci"

if {$ARCHGRP_ARR(NET_MOD_ARCH) != "EMPTY"} {
    lappend MOD "$ENTITY_BASE/ip/cmac_eth_1x100g/cmac_eth_1x100g.xci"
}

# Top-level
lappend MOD "$ENTITY_BASE/fpga.vhd"
