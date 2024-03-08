# Modules.tcl: script to compile card
# Copyright (C) 2022 CESNET z. s. p. o.
# Author(s): Jakub Cabal <cabal@cesnet.cz>
#            Vladislav Valek <xvalek14@vutbr.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# converting input list to associative array
array set ARCHGRP_ARR $ARCHGRP

# Paths
set SPI_FLASH_DRIVER_BASE "$ENTITY_BASE/comp/spi_flash_driver/"
set BOOT_CTRL_BASE        "$OFM_PATH/../core/intel/src/comp/boot_ctrl"
set AXI2AVMM_BRIDGE_BASE  "$OFM_PATH/comp/mem_tools/convertors/axi2avmm_ddr_bridge"
set GTY_10GE_LL_BASE      "$OFM_PATH/../modules/hft/comp/eth_phy/10ge/pma/ip_refclk_161m"

# Components
lappend COMPONENTS [list "FPGA_COMMON"      $ARCHGRP_ARR(CORE_BASE)  $ARCHGRP]
lappend COMPONENTS [list "BOOT_CTRL"        $BOOT_CTRL_BASE          "FULL"  ]
lappend COMPONENTS [list "SPI_FLASH_DRIVER" $SPI_FLASH_DRIVER_BASE   "FULL"  ]
lappend COMPONENTS [list "AXI2AVMM_BRIDGE"  $AXI2AVMM_BRIDGE_BASE    "FULL"  ]

if {$ARCHGRP_ARR(PCIE_ENDPOINT_MODE) == 2} {
    lappend MOD "$ENTITY_BASE/ip/pcie4_uscale_plus/x8_low_latency/pcie4_uscale_plus.xci"
} else {
    lappend MOD "$ENTITY_BASE/ip/pcie4_uscale_plus/x16/pcie4_uscale_plus.xci"
}

# IP sources
lappend MOD "$ENTITY_BASE/ip/xvc_vsec/xvc_vsec.xci"
lappend MOD "$ENTITY_BASE/ip/ddr4_axi/ddr4_axi.xci"

if { $ARCHGRP_ARR(NET_MOD_ARCH) == "40GE"} {
    lappend MOD "$ENTITY_BASE/ip/gty_40ge/gty_40ge.xci"
} elseif { $ARCHGRP_ARR(NET_MOD_ARCH) == "CESNET_LL10GE"} {
    lappend MOD "$GTY_10GE_LL_BASE/gty_gbaser_ll.xci"
} elseif { $ARCHGRP_ARR(NET_MOD_ARCH) == "CMAC"} {
    lappend MOD "$ENTITY_BASE/ip/cmac_eth_1x100g/cmac_eth_1x100g.xci"
}

# Top-level
lappend MOD "$ENTITY_BASE/fpga.vhd"
