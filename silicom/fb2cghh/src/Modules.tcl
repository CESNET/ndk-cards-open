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

# IP components
# set IP_TEMPLATE_BASE "$ARCHGRP_ARR(CORE_BASE)/src/ip/usp"
set IP_MODIFY_BASE   "$ENTITY_BASE/ip"

# modify == 1 -> provide '$IP_MODIFY_BASE/<script_name>/<script_name>.ip.tcl' file with IP modification commands
#                         script_path     script_name          ip_comp_name     type  modify
lappend IP_COMPONENTS [list  "mem"    "axi_quad_spi_0"     "axi_quad_spi_0"       0      1]
lappend IP_COMPONENTS [list  "mem"    "ddr4_axi"           "ddr4_axi"             0      1]
lappend IP_COMPONENTS [list  "pcie"   "pcie4_uscale_plus"  "pcie4_uscale_plus"    0      1]
lappend IP_COMPONENTS [list  "misc"   "xvc_vsec"           "xvc_vsec"             0      1]

if { $ARCHGRP_ARR(NET_MOD_ARCH) == "40GE"} {
    lappend IP_COMPONENTS [list "eth"  "gty_40ge"          "gty_40ge"             0      1]
} else {
    lappend IP_COMPONENTS [list "eth"  "cmac_eth_1x100g"   "cmac_eth_1x100g"      0      1]
}

foreach ip_comp $IP_COMPONENTS {
#    set path   [lindex $ip_comp 0]
    set script [lindex $ip_comp 1]
    set comp   [lindex $ip_comp 2]
#    set type   [lindex $ip_comp 3]
    set modify [lindex $ip_comp 4]

    # adjust paths
    set ip_subdir $IP_MODIFY_BASE/$script
    lset ARCHGRP [expr [lsearch $ARCHGRP IP_BUILD_DIR]+1] $ip_subdir

    set params_l [concat $ARCHGRP "IP_COMP_NAME" $comp "IP_EXT_BASE" $ip_subdir]
    if {$modify == 1} {
        lappend MOD [list "$ip_subdir/$script.ip.tcl" TYPE "VIVADO_TCL" PHASE { "ADD_FILES" "IP_MODIFY" } VARS [list IP_PARAMS_L $params_l]]
    }
}

#Simulation
#lappend MOD "$ENTITY_BASE/ip/axi_quad_spi_0/axi_quad_spi_0_sim_netlist.vhdl"

# Top-level
lappend MOD "$ENTITY_BASE/fpga.vhd"
