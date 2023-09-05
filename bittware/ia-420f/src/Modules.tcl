# Modules.tcl: script to compile IA-420F card
# Copyright (C) 2022 CESNET z. s. p. o.
# Author(s): Daniel Kříž <xkrizd01@vutbr.cz.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

set IOEXP_BASE "$OFM_PATH/comp/ctrls/i2c_io_exp"
set ASYNC_BASE "$OFM_PATH/comp/base/async"

# converting input list to associative array
array set ARCHGRP_ARR $ARCHGRP

lappend COMPONENTS [list "FPGA_COMMON"       $ARCHGRP_ARR(CORE_BASE) $ARCHGRP]
lappend COMPONENTS [list "I2C IO EXPANDER"   $IOEXP_BASE               "FULL"]
lappend COMPONENTS [list "OPEN_LOOP"         $ASYNC_BASE/open_loop     "FULL"]
lappend COMPONENTS [list "RESET"             $ASYNC_BASE/reset         "FULL"]

# IP sources
lappend MOD "$ENTITY_BASE/ip/iopll_ip.ip"
lappend MOD "$ENTITY_BASE/ip/reset_release_ip.ip"
lappend MOD "$ENTITY_BASE/ip/mailbox_client_ip.ip"
lappend MOD "$ENTITY_BASE/ip/ddr4_calibration.ip"
lappend MOD "$ENTITY_BASE/ip/onboard_ddr4_0.ip"
lappend MOD "$ENTITY_BASE/ip/onboard_ddr4_1.ip"

if {$ARCHGRP_ARR(PCIE_ENDPOINT_MODE) == 0} {
    lappend MOD "$ENTITY_BASE/ip/ptile_pcie_1x16.ip"
}
if {$ARCHGRP_ARR(PCIE_ENDPOINT_MODE) == 1} {
    lappend MOD "$ENTITY_BASE/ip/ptile_pcie_2x8.ip"
}

if {$ARCHGRP_ARR(NET_MOD_ARCH) == "E_TILE"} {
    if {$ARCHGRP_ARR(ETH_PORT_SPEED,0) == 100} {
        lappend MOD "$ENTITY_BASE/ip/etile_eth_1x100g.ip"
    }
    if {$ARCHGRP_ARR(ETH_PORT_SPEED,0) == 25} {
        lappend MOD "$ENTITY_BASE/ip/etile_eth_4x25g.ip"
    }
    if {$ARCHGRP_ARR(ETH_PORT_SPEED,0) == 10} {
        lappend MOD "$ENTITY_BASE/ip/etile_eth_4x10g.ip"
    }
}

# Top-level
lappend MOD "$ENTITY_BASE/fpga.vhd"
