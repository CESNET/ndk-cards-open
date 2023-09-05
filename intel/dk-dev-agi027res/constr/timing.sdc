# timing.sdc: Timing constraints
# Copyright (C) 2021 CESNET z. s. p. o.
# Author(s): Jakub Cabal <cabal@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

derive_clock_uncertainty

#create_clock -name {clk_sys_100m_p} -period 10.000 -waveform {0 5} {clk_sys_100m_p}
#create_clock -name {clk_sys_bak_50m_p} -period 20.000 -waveform {0 10} {clk_sys_bak_50m_p}
create_clock -name {altera_reserved_tck} -period 41.667 [get_ports { altera_reserved_tck }]

#create_clock -name {refclk_fgt12ach0_p} -period 10.000 [get_ports refclk_fgt12ach0_p]
#create_clock -name {refclk_fgt12ach3_p} -period 6.510 [get_ports refclk_fgt12ach3_p]
create_clock -name {refclk_fgt12ach4_p} -period 6.4 [get_ports refclk_fgt12ach4_p]
#create_clock -name {refclk_fgt12ach5_p} -period 6.4 [get_ports refclk_fgt12ach5_p]
#create_clock -name {refclk_fgt12ach6_p} -period 5.425 [get_ports refclk_fgt12ach6_p]
create_clock -name {CLK_DDR4_CH2_P}     -period 30.0 [get_ports CLK_DDR4_CH2_P]

create_clock -name {refclk_pcie_14c_ch0_p} -period 10.000 -waveform {0 5} {refclk_pcie_14c_ch0_p}
create_clock -name {refclk_pcie_14c_ch1_p} -period 10.000 -waveform {0 5} {refclk_pcie_14c_ch1_p}
create_clock -name {refclk_cxl_15c_ch0_p} -period 10.000 -waveform {0 5} {refclk_cxl_15c_ch0_p}
create_clock -name {refclk_cxl_15c_ch1_p} -period 10.000 -waveform {0 5} {refclk_cxl_15c_ch1_p}

# Cut (set_false_path) this JTAG clock from all other clocks in the design
set_clock_groups -asynchronous -group [get_clocks altera_reserved_tck]

set MI_CLK [get_clocks ag_i|clk_gen_i|iopll_i|iopll_0_outclk3]
set FHIP_400G_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.ftile_eth_ip_i|eth_f_0|tx_clkout|ch23]
set FHIP_100G_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.eth_ftile_g[0].ftile_eth_ip_i|eth_f_0|tx_clkout|ch23]

# Fix hold timing issues on FHIP
set_clock_groups -asynchronous -group $MI_CLK -group $FHIP_400G_CLK
set_clock_groups -asynchronous -group $MI_CLK -group $FHIP_100G_CLK
