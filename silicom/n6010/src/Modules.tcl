# Modules.tcl: script to compile card
# Copyright (C) 2023 CESNET z. s. p. o.
# Author(s): Martin Matějka <xmatej55@vutbr.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

set PMCI_TOP_BASE "$ENTITY_BASE/comp/pmci"

# converting input list to associative array
array set ARCHGRP_ARR $ARCHGRP

lappend COMPONENTS [list "FPGA_COMMON"       $ARCHGRP_ARR(CORE_BASE) $ARCHGRP]
lappend COMPONENTS [list "PMCI_TOP"          $PMCI_TOP_BASE            "FULL"]

# IP components
set IP_DEVICE_FAMILY  "Agilex"
set IP_DEVICE         $ARCHGRP_ARR(FPGA)
set IP_TEMPLATE_BASE  "$ARCHGRP_ARR(CORE_BASE)/src/ip/intel"
set IP_MODIFY_BASE    "$ENTITY_BASE/ip"

source $IP_TEMPLATE_BASE/../common.tcl

set PCIE_CONF [dict create 0 "1x16" 1 "2x8"]
set PTILE_PCIE_IP_NAME "ptile_pcie_[dict get $PCIE_CONF $ARCHGRP_ARR(PCIE_ENDPOINT_MODE)]"

set ETH_CONF [dict create 100 "1x100g" 25 "4x25g" 10 "4x10g"]
set ETILE_ETH_IP_NAME "etile_eth_[dict get $ETH_CONF $ARCHGRP_ARR(ETH_PORT_SPEED,0)]"

# modify == 1 -> provide '$IP_MODIFY_BASE/<script_name>.ip.tcl' file with IP modification commands
#                         script_path    script_name       ip_comp_name     type  modify
lappend IP_COMPONENTS [list  "clk"    "iopll"            "iopll_ip"           0      1]
lappend IP_COMPONENTS [list  "mem"    "ddr4_calibration" "ddr4_calibration"   0      1]
lappend IP_COMPONENTS [list  "mem"    "onboard_ddr4"     "onboard_ddr4"       0      1]
lappend IP_COMPONENTS [list  "misc"   "mailbox_client"   "mailbox_client_ip"  0      0]
lappend IP_COMPONENTS [list  "misc"   "reset_release"    "reset_release_ip"   0      0]
lappend IP_COMPONENTS [list  "pcie"   "ptile_pcie"       $PTILE_PCIE_IP_NAME  0      1]

if {$ARCHGRP_ARR(NET_MOD_ARCH) == "E_TILE"} {
    lappend IP_COMPONENTS [list "eth"   "etile_eth"      $ETILE_ETH_IP_NAME   0      1]
}

if {$ARCHGRP_ARR(VIRTUAL_DEBUG_ENABLE) eq true} {
    lappend IP_COMPONENTS [list "misc"  "jtag_op"        "jtag_op_ip"         0      0]
}

foreach ip_comp $IP_COMPONENTS {
    set path   [lindex $ip_comp 0]
    set script [lindex $ip_comp 1]
    set comp   [lindex $ip_comp 2]
    set type   [lindex $ip_comp 3]
    set modify [lindex $ip_comp 4]

    # TODO: trivial check for time-saving purpose (invent better solution in the future)
    set ipfile $ARCHGRP_ARR(IP_BUILD_DIR)/[get_ip_filename $comp]
    if {[file exists $ipfile] && ![file exists $IP_MODIFY_BASE/$script\_ip.qpf]} {
        lappend MOD $ipfile
        continue
    }

    set params_l [concat $ARCHGRP "IP_DEVICE_FAMILY" $IP_DEVICE_FAMILY "IP_DEVICE" $IP_DEVICE "IP_COMP_NAME" $comp "IP_COMP_TYPE" $type]
    lappend MOD [list "$IP_TEMPLATE_BASE/$path/$script.ip.tcl" TYPE "QUARTUS_TCL" PHASE { "ADD_FILES" "IP_TEMPLATE_GEN" } IP_BUILD_DIR $ARCHGRP_ARR(IP_BUILD_DIR) VARS [list IP_PARAMS_L $params_l]]
    if {$modify == 1} {
        lappend MOD [list "$IP_MODIFY_BASE/$script.ip.tcl"     TYPE "QUARTUS_TCL" PHASE { "ADD_FILES" "IP_MODIFY"       } IP_BUILD_DIR $ARCHGRP_ARR(IP_BUILD_DIR) VARS [list IP_PARAMS_L $params_l]]
    }
}

# Top-level
lappend MOD "$ENTITY_BASE/fpga.vhd"
