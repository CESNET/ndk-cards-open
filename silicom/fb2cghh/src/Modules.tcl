# Modules.tcl: script to compile card
# Copyright (C) 2022 CESNET z. s. p. o.
# Author(s): David Beneš <xbenes52@vutbr.cz>
#            Vladislav Valek <xvalek14@vutbr.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# converting input list to associative array
array set ARCHGRP_ARR $ARCHGRP

# Paths
set LED_SERIAL_CTRL_BASE            "$ENTITY_BASE/comp/led_ctrl"
set BMC_BASE                        "$ENTITY_BASE/comp/bmc_driver"
set AXI_QUAD_FLASH_CONTROLLER_BASE  "$ENTITY_BASE/comp/axi_quad_flash_controller"
set BOOT_CTRL_BASE                  "$OFM_PATH/../core/intel/src/comp/boot_ctrl"
set AXI2AVMM_BRIDGE_BASE            "$OFM_PATH/comp/mem_tools/convertors/axi2avmm_ddr_bridge"  

# Components
lappend COMPONENTS [list "FPGA_COMMON"                  $ARCHGRP_ARR(CORE_BASE)          $ARCHGRP]
lappend COMPONENTS [list "LED_SERIAL_CTRL"              $LED_SERIAL_CTRL_BASE            "FULL"  ]
lappend COMPONENTS [list "BMC"                          $BMC_BASE                        "FULL"  ]
lappend COMPONENTS [list "AXI_QUAD_FLASH_CONTROLLER"    $AXI_QUAD_FLASH_CONTROLLER_BASE  "FULL"  ]
lappend COMPONENTS [list "BOOT_CTRL"                    $BOOT_CTRL_BASE                  "FULL"  ]
lappend COMPONENTS [list "AXI2AVMM_BRIDGE"              $AXI2AVMM_BRIDGE_BASE            "FULL"  ]

# IP sources
if {$ARCHGRP_ARR(PCIE_ENDPOINTS) == 1} {

    if {$ARCHGRP_ARR(PCIE_ENDPOINT_MODE) == 2} {
        lappend MOD "$ENTITY_BASE/ip/pcie4_uscale_plus/x8_low_latency/pcie4_uscale_plus.xci"
    } else {
        lappend MOD "$ENTITY_BASE/ip/pcie4_uscale_plus/x16/pcie4_uscale_plus.xci"
    }
}

if { $ARCHGRP_ARR(NET_MOD_ARCH) == "40GE"} {
    lappend MOD "$ENTITY_BASE/ip/gty_40ge/gty_40ge.xci"
} else {
    lappend MOD "$ENTITY_BASE/ip/cmac_eth_1x100g/cmac_eth_1x100g.xci"
}

lappend MOD "$ENTITY_BASE/ip/xvc_vsec/xvc_vsec.xci"
lappend MOD "$ENTITY_BASE/ip/axi_quad_spi_0/axi_quad_spi_0.xci"
lappend MOD "$ENTITY_BASE/ip/ddr4_axi/ddr4_axi.xci"

#Simulation
#lappend MOD "$ENTITY_BASE/ip/axi_quad_spi_0/axi_quad_spi_0_sim_netlist.vhdl"

# Top-level
lappend MOD "$ENTITY_BASE/fpga.vhd"
