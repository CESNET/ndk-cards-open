# Modules.tcl: script to compile XpressSX AGI-FH400G
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Jakub Cabal <cabal@cesnet.cz>,
#            Jakub Záhora <zahora@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# converting input list to associative array
array set ARCHGRP_ARR $ARCHGRP

# Paths
set BOOT_CTRL_BASE "$OFM_PATH/../core/intel/src/comp/boot_ctrl"

# Components
lappend COMPONENTS [list "FPGA_COMMON" $ARCHGRP_ARR(CORE_BASE)  $ARCHGRP]
lappend COMPONENTS [list "BOOT_CTRL"   $BOOT_CTRL_BASE          "FULL"]

# IP sources
lappend MOD "$ENTITY_BASE/ip/iopll_ip.ip"
lappend MOD "$ENTITY_BASE/ip/reset_release_ip.ip"
lappend MOD "$ENTITY_BASE/ip/sodimm.ip"
lappend MOD "$ENTITY_BASE/ip/sodimm_cal.ip"
lappend MOD "$ENTITY_BASE/ip/OnBoard_DDR4.ip"
lappend MOD "$ENTITY_BASE/ip/emif_agi027_cal.ip"
lappend MOD "$ENTITY_BASE/ip/mailbox_client_ip.ip"
lappend MOD "$ENTITY_BASE/ip/ftile_pll.ip"

if {$ARCHGRP_ARR(PCIE_ENDPOINT_MODE) == 0} {
    lappend MOD "$ENTITY_BASE/ip/rtile_pcie_1x16.ip"
}
if {$ARCHGRP_ARR(PCIE_ENDPOINT_MODE) == 1} {
    lappend MOD "$ENTITY_BASE/ip/rtile_pcie_2x8.ip"
}

if {$ARCHGRP_ARR(NET_MOD_ARCH) == "F_TILE"} {
    if {$ARCHGRP_ARR(ETH_PORT_SPEED,0) == 400} {
        lappend MOD "$ENTITY_BASE/ip/ftile_eth_1x400g.ip"
    }
    if {$ARCHGRP_ARR(ETH_PORT_SPEED,0) == 200} {
        lappend MOD "$ENTITY_BASE/ip/ftile_eth_2x200g.ip"
    }
    if {$ARCHGRP_ARR(ETH_PORT_SPEED,0) == 100} {
            if {$ARCHGRP_ARR(ETH_PORT_CHAN,0) == 2} {
                    if {$ARCHGRP_ARR(EHIP_PORT_TYPE,0) == 1} {
                        lappend MOD "$ENTITY_BASE/ip/ftile_multirate_eth_1x100g.ip"
                        lappend MOD "$ENTITY_BASE/ip/dr_ctrl.ip"
                    }
                    if {$ARCHGRP_ARR(EHIP_PORT_TYPE,0) == 0} {
                        lappend MOD "$ENTITY_BASE/ip/ftile_eth_2x100g.ip"
                    }
            }
            if {$ARCHGRP_ARR(ETH_PORT_CHAN,0) == 4} {
                lappend MOD "$ENTITY_BASE/ip/ftile_eth_4x100g.ip"
            }
        }
    if {$ARCHGRP_ARR(ETH_PORT_SPEED,0) == 50} {
        lappend MOD "$ENTITY_BASE/ip/ftile_eth_8x50g.ip"
    }
    if {$ARCHGRP_ARR(ETH_PORT_SPEED,0) == 40} {
        lappend MOD "$ENTITY_BASE/ip/ftile_eth_2x40g.ip"
    }
    if {$ARCHGRP_ARR(ETH_PORT_SPEED,0) == 25} {
        if {$ARCHGRP_ARR(EHIP_PORT_TYPE,0) == 0} {
            lappend MOD "$ENTITY_BASE/ip/ftile_eth_8x25g.ip"
        }
        if {$ARCHGRP_ARR(EHIP_PORT_TYPE,0) == 1} {
            lappend MOD "$ENTITY_BASE/ip/ftile_multirate_eth_1x25g_1x10g.ip"
            lappend MOD "$ENTITY_BASE/ip/dr_ctrl.ip"
        }
    }
    if {$ARCHGRP_ARR(ETH_PORT_SPEED,0) == 10} {
        lappend MOD "$ENTITY_BASE/ip/ftile_eth_8x10g.ip"
    }
}

# Top-level
lappend MOD "$OFM_PATH/comp/ctrls/flash/flashctrl.vhd"
lappend MOD "$ENTITY_BASE/fpga.vhd"