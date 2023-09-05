# timing.sdc: Timing constraints
# Copyright (C) 2022 CESNET z. s. p. o.
# Author(s): Jakub Cabal <cabal@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

derive_clock_uncertainty

create_clock -name {altera_reserved_tck} -period 41.667 [get_ports { altera_reserved_tck }]

create_clock -name {AG_SYSCLK0} -period 10.000 [get_ports { AG_SYSCLK0_P }]
create_clock -name {AG_SYSCLK1} -period 10.000 [get_ports { AG_SYSCLK1_P }]

create_clock -name {PCIE0_CLK0} -period 10.000 [get_ports { PCIE0_CLK0_P }]
create_clock -name {PCIE0_CLK1} -period 10.000 [get_ports { PCIE0_CLK1_P }]
create_clock -name {PCIE1_CLK0} -period 10.000 [get_ports { PCIE1_CLK0_P }]
create_clock -name {PCIE1_CLK1} -period 10.000 [get_ports { PCIE1_CLK1_P }]
#create_clock -name {PCIE2_CLK0} -period 10.000 [get_ports { PCIE2_CLK0_P }]
#create_clock -name {PCIE2_CLK1} -period 10.000 [get_ports { PCIE2_CLK1_P }]
create_clock -name {QSFP_REFCLK_P} -period 6.400 [get_ports { QSFP_REFCLK_P }]

# Cut (set_false_path) this JTAG clock from all other clocks in the design
set_clock_groups -asynchronous -group [get_clocks altera_reserved_tck]

set MI_CLK [get_clocks ag_i|clk_gen_i|iopll_i|iopll_0_outclk3]
set FHIP_400G_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.ftile_eth_ip_i|eth_f_0|tx_clkout|ch23]

# For Ftile_multirate_2x100G-2
set FHIP_100G_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.pam4_100g_g.NRZ_100g_g.eth_ftile_multirate_q[0].ftile_multrate_eth_F_NOF_1x100g_i|eth_f_dr_0|tx_clkout|ch23]                   
set FHIP_ch19_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.pam4_100g_g.NRZ_100g_g.eth_ftile_multirate_q[1].ftile_multrate_eth_F_NOF_1x100g_i|eth_f_dr_0|tx_clkout|ch19]                                        

# For Ftile_multirate_8x25g-1_8x10g-1
set FHIP_CH17_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.NRZ_25g_g.eth_ftile_multirate_g[6].ftile_multirate_eth_1x25g_1x10g_i|eth_f_dr_0|tx_clkout|ch17]                   
set FHIP_CH20_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.NRZ_25g_g.eth_ftile_multirate_g[3].ftile_multirate_eth_1x25g_1x10g_i|eth_f_dr_0|tx_clkout|ch20]
set FHIP_CH22_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.NRZ_25g_g.eth_ftile_multirate_g[1].ftile_multirate_eth_1x25g_1x10g_i|eth_f_dr_0|tx_clkout|ch22]                   
set FHIP_CH21_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.NRZ_25g_g.eth_ftile_multirate_g[2].ftile_multirate_eth_1x25g_1x10g_i|eth_f_dr_0|tx_clkout|ch21]                   
set FHIP_CH16_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.NRZ_25g_g.eth_ftile_multirate_g[7].ftile_multirate_eth_1x25g_1x10g_i|eth_f_dr_0|tx_clkout|ch16]                   
set FHIP_CH18_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.NRZ_25g_g.eth_ftile_multirate_g[5].ftile_multirate_eth_1x25g_1x10g_i|eth_f_dr_0|tx_clkout|ch18]                   
set FHIP_CH19_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.NRZ_25g_g.eth_ftile_multirate_g[4].ftile_multirate_eth_1x25g_1x10g_i|eth_f_dr_0|tx_clkout|ch19]                   
set FHIP_CH23_CLK [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|eth_port_mode_sel_g.NRZ_25g_g.eth_ftile_multirate_g[0].ftile_multirate_eth_1x25g_1x10g_i|eth_f_dr_0|tx_clkout|ch23]                   
set FHIP_OUTCLK3_CLK [get_clocks ag_i|clk_gen_i|iopll_i|iopll_0_outclk3]                   

# Fix hold timing issues on FHIP
set_clock_groups -asynchronous -group $MI_CLK -group $FHIP_400G_CLK

# Fix hold timing issues on Ftile_multirate_2x100G-2
set_clock_groups -asynchronous -group $MI_CLK -group $FHIP_100G_CLK
set_clock_groups -asynchronous -group $FHIP_100G_CLK -group $FHIP_ch19_CLK

# Fix hold timing issues on Ftile_multirate_8x25g-1_8x10g-1
set_clock_groups -asynchronous -group $MI_CLK -group FHIP_CH17_CLK
set_clock_groups -asynchronous -group $MI_CLK -group FHIP_CH20_CLK
set_clock_groups -asynchronous -group $MI_CLK -group FHIP_CH22_CLK
set_clock_groups -asynchronous -group $MI_CLK -group FHIP_CH21_CLK
set_clock_groups -asynchronous -group $MI_CLK -group FHIP_CH16_CLK
set_clock_groups -asynchronous -group $MI_CLK -group FHIP_CH18_CLK
set_clock_groups -asynchronous -group $MI_CLK -group FHIP_CH19_CLK
set_clock_groups -asynchronous -group $MI_CLK -group FHIP_CH23_CLK
set_clock_groups -asynchronous -group $MI_CLK -group FHIP_OUTCLK3_CLK

