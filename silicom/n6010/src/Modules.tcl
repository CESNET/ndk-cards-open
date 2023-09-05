# Modules.tcl: script to compile card
# Copyright (C) 2023 CESNET z. s. p. o.
# Author(s): Martin Matějka <xmatej55@vutbr.cz>
#

set PMCI_TOP_BASE "$ENTITY_BASE/comp/pmci"

# converting input list to associative array
array set ARCHGRP_ARR $ARCHGRP

lappend COMPONENTS [list "FPGA_COMMON"       $ARCHGRP_ARR(CORE_BASE) $ARCHGRP]
lappend COMPONENTS [list "PMCI_TOP"          $PMCI_TOP_BASE            "FULL"]

# IP sources
lappend MOD "$ENTITY_BASE/ip/iopll_ip.ip"
lappend MOD "$ENTITY_BASE/ip/reset_release_ip.ip"
lappend MOD "$ENTITY_BASE/ip/mailbox_client_ip.ip"

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
