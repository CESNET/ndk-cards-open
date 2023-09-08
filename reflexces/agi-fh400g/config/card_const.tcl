# card_const.tcl: Card specific parameters for XpressSX AGI-FH400G (developer only)
# Copyright (C) 2022 CESNET, z. s. p. o.
# Author(s): Jakub Cabal <cabal@cesnet.cz>
#            Vladislav Valek <valekv@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# WARNING: The user should not deliberately change parameters in this file. For
# the description of this file, visit the Parametrization section in the
# documentation of the NDK-CORE repostiory

set CARD_NAME "AGI-FH400G-REV$BOARD_REV"
# Achitecture of Clock generator
set CLOCK_GEN_ARCH "INTEL"
# Achitecture of PCIe module
set PCIE_MOD_ARCH "R_TILE"
# Achitecture of Network module
set NET_MOD_ARCH "F_TILE"
# Achitecture of SDM/SYSMON module
set SDM_SYSMON_ARCH "INTEL_SDM"
# Boot controller type
set BOOT_TYPE 2

# Total number of QSFP cages
set QSFP_CAGES       1
# I2C address of each QSFP cage
set QSFP_I2C_ADDR(0) "0xA0"

# ------------------------------------------------------------------------------
# Checking of parameter compatibility
# ------------------------------------------------------------------------------

if { $BOARD_REV != 0 && $BOARD_REV != 1 } {
    error "Incompatible BOARD_REV value: $BOARD_REV"
}

if {!(($PCIE_ENDPOINTS == 4 && $PCIE_GEN == 4 && $PCIE_ENDPOINT_MODE == 1) ||
      ($PCIE_ENDPOINTS == 2 && $PCIE_GEN == 5 && $PCIE_ENDPOINT_MODE == 1) )} {
    error "Incompatible PCIe configuration: PCIE_ENDPOINTS = $PCIE_ENDPOINTS, PCIE_GEN = $PCIE_GEN, PCIE_ENDPOINT_MODE = $PCIE_ENDPOINT_MODE!
Allowed PCIe configurations:
- 2xGen4x8x8 -- PCIE_GEN=4, PCIE_ENDPOINTS=4, PCIE_ENDPOINT_MODE=1
- 1xGen5x8x8 -- PCIE_GEN=5, PCIE_ENDPOINTS=2, PCIE_ENDPOINT_MODE=1"
}

# Enable/add PCIe Gen5 x16 for experiments only!
#($PCIE_ENDPOINTS == 1 && $PCIE_GEN == 5 && $PCIE_ENDPOINT_MODE == 0) ||
#- 1xGen5x16  -- PCIE_GEN=5, PCIE_ENDPOINTS=1, PCIE_ENDPOINT_MODE=0"

# ------------------------------------------------------------------------------
# Other parameters:
# ------------------------------------------------------------------------------

if {$ETH_PORT_SPEED(0) == 10 || $ETH_PORT_SPEED(0) == 25 || $ETH_PORT_SPEED(0) == 40} {
    # TBD lower frequency for 10GE, 40GE? 
    #set TSU_FREQUENCY 161132812
    # Current setup:
    # 10GE, 25GE, 40GE in F-Tile
    set TSU_FREQUENCY 402832031
} else {
    # 400GE, 200GE, 100GE, 50GE in F-Tile
    set TSU_FREQUENCY 415039062
}

if {$TEST_FW_PCIE1_ONBOARD_DDR4} {
    set MEM_PORTS 1
}

VhdlPkgBool TEST_FW_PCIE1_ONBOARD_DDR4 $TEST_FW_PCIE1_ONBOARD_DDR4
