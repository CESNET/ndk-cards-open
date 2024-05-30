array set PARAMS $IP_PARAMS_L

set IP_COMP_NAME $PARAMS(IP_COMP_NAME)
if {[get_ips -quiet $IP_COMP_NAME] eq ""} {
    if {$PARAMS(IP_GEN_FILES) eq true} {
        create_ip -name pcie4_uscale_plus -vendor xilinx.com -library ip -module_name $IP_COMP_NAME -dir $PARAMS(IP_BUILD_DIR) -force
    } else {
        create_ip -name pcie4_uscale_plus -vendor xilinx.com -library ip -module_name $IP_COMP_NAME
    }
}

set IP [get_ips $IP_COMP_NAME]

# common properties
set_property -dict [list \
    CONFIG.MSI_X_OPTIONS {MSI-X_External} \
    CONFIG.PF0_CLASS_CODE {020000} \
    CONFIG.PF0_DEVICE_ID {00d1} \
    CONFIG.PF0_INTERRUPT_PIN {NONE} \
    CONFIG.PF0_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF0_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF0_REVISION_ID {1} \
    CONFIG.PF0_SRIOV_CAP_INITIAL_VF {0} \
    CONFIG.PF0_SRIOV_FIRST_VF_OFFSET {0} \
    CONFIG.PF0_SUBSYSTEM_ID {00d1} \
    CONFIG.PF0_SUBSYSTEM_VENDOR_ID {1c2c} \
    CONFIG.PF0_Use_Class_Code_Lookup_Assistant {true} \
    CONFIG.PF1_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF1_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF1_MSIX_CAP_TABLE_SIZE {0} \
    CONFIG.PF1_SUBSYSTEM_VENDOR_ID {1c2c} \
    CONFIG.PF2_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF2_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF2_MSIX_CAP_TABLE_SIZE {0} \
    CONFIG.PF2_SUBSYSTEM_VENDOR_ID {1c2c} \
    CONFIG.PF3_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF3_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF3_MSIX_CAP_TABLE_SIZE {0} \
    CONFIG.PF3_SUBSYSTEM_VENDOR_ID {1c2c} \
    CONFIG.PL_DISABLE_LANE_REVERSAL {TRUE} \
    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} \
    CONFIG.SRIOV_CAP_ENABLE {false} \
    CONFIG.SRIOV_FIRST_VF_OFFSET {1} \
    CONFIG.VFG0_MSIX_CAP_PBA_OFFSET {0} \
    CONFIG.VFG0_MSIX_CAP_TABLE_OFFSET {0} \
    CONFIG.VFG1_MSIX_CAP_PBA_OFFSET {0} \
    CONFIG.VFG1_MSIX_CAP_TABLE_OFFSET {0} \
    CONFIG.VFG2_MSIX_CAP_PBA_OFFSET {0} \
    CONFIG.VFG2_MSIX_CAP_TABLE_OFFSET {0} \
    CONFIG.VFG3_MSIX_CAP_PBA_OFFSET {0} \
    CONFIG.VFG3_MSIX_CAP_TABLE_OFFSET {0} \
    CONFIG.axisten_freq {250} \
    CONFIG.axisten_if_enable_client_tag {true} \
    CONFIG.axisten_if_enable_msg_route {00000} \
    CONFIG.cfg_ctl_if {true} \
    CONFIG.cfg_fc_if {true} \
    CONFIG.cfg_mgmt_if {true} \
    CONFIG.cfg_pm_if {true} \
    CONFIG.cfg_status_if {true} \
    CONFIG.cfg_tx_msg_if {true} \
    CONFIG.coreclk_freq {500} \
    CONFIG.en_gt_selection {false} \
    CONFIG.en_pcie_conf {false} \
    CONFIG.ext_pcie_cfg_space_enabled {true} \
    CONFIG.gen_x0y1 {false} \
    CONFIG.gen_x1y2 {true} \
    CONFIG.gen_x1y4 {false} \
    CONFIG.mode_selection {Advanced} \
    CONFIG.pcie_blk_locn {X1Y2} \
    CONFIG.pf0_ari_enabled {false} \
    CONFIG.pf0_bar0_64bit {true} \
    CONFIG.pf0_bar0_scale {Megabytes} \
    CONFIG.pf0_bar0_size {64} \
    CONFIG.pf0_base_class_menu {Network_controller} \
    CONFIG.pf0_class_code_base {02} \
    CONFIG.pf0_class_code_sub {00} \
    CONFIG.pf0_dsn_enabled {true} \
    CONFIG.pf0_msi_enabled {false} \
    CONFIG.pf0_msix_enabled {true} \
    CONFIG.pf0_rbar_cap_bar0 {0xffffffffffff} \
    CONFIG.pf0_sriov_bar0_64bit {true} \
    CONFIG.pf0_sriov_bar0_size {64} \
    CONFIG.pf0_sub_class_interface_menu {Ethernet_controller} \
    CONFIG.pf1_bar0_64bit {true} \
    CONFIG.pf1_bar0_scale {Megabytes} \
    CONFIG.pf1_bar0_size {64} \
    CONFIG.pf1_rbar_cap_bar0 {0xffffffffffff} \
    CONFIG.pf1_sriov_bar0_64bit {true} \
    CONFIG.pf1_sriov_bar0_size {64} \
    CONFIG.pf1_vendor_id {1c2c} \
    CONFIG.pf2_bar0_64bit {true} \
    CONFIG.pf2_bar0_scale {Megabytes} \
    CONFIG.pf2_bar0_size {64} \
    CONFIG.pf2_rbar_cap_bar0 {0xffffffffffff} \
    CONFIG.pf2_sriov_bar0_64bit {true} \
    CONFIG.pf2_sriov_bar0_size {64} \
    CONFIG.pf2_vendor_id {1c2c} \
    CONFIG.pf3_bar0_64bit {true} \
    CONFIG.pf3_bar0_scale {Megabytes} \
    CONFIG.pf3_bar0_size {64} \
    CONFIG.pf3_rbar_cap_bar0 {0xffffffffffff} \
    CONFIG.pf3_sriov_bar0_64bit {true} \
    CONFIG.pf3_sriov_bar0_size {64} \
    CONFIG.pf3_vendor_id {1c2c} \
    CONFIG.plltype {QPLL1} \
    CONFIG.rcv_msg_if {true} \
    CONFIG.select_quad {GTY_Quad_227} \
    CONFIG.tx_fc_if {true} \
    CONFIG.type1_membase_memlimit_enable {Disabled} \
    CONFIG.type1_prefetchable_membase_memlimit {Disabled} \
    CONFIG.vendor_id {1c2c} \
] $IP

# x8_low_latency properties
if {$PARAMS(PCIE_ENDPOINT_MODE) == 2} {
    set_property -dict [list \
        CONFIG.AXISTEN_IF_EXT_512_RC_4TLP_STRADDLE {false} \
        CONFIG.AXISTEN_IF_EXT_512_RQ_STRADDLE {false} \
        CONFIG.PF0_MSIX_CAP_PBA_OFFSET {00000050} \
        CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {00000040} \
        CONFIG.PF0_MSIX_CAP_TABLE_SIZE {1} \
        CONFIG.PF0_DEVICE_ID {00d1} \
        CONFIG.PF2_DEVICE_ID {9438} \
        CONFIG.PF3_DEVICE_ID {9638} \
        CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} \
        CONFIG.axisten_if_width {256_bit} \
        CONFIG.msix_type {HARD} \
        CONFIG.pf0_bar2_64bit {true} \
        CONFIG.pf0_bar2_enabled {true} \
        CONFIG.pf0_bar2_scale {Megabytes} \
        CONFIG.pf0_bar2_size {16} \
    ] $IP

# x16 properties
} else {
    set_property -dict [list \
        CONFIG.AXISTEN_IF_EXT_512_RC_4TLP_STRADDLE {true} \
        CONFIG.AXISTEN_IF_EXT_512_RQ_STRADDLE {true} \
        CONFIG.PF0_MSIX_CAP_PBA_OFFSET {01408000} \
        CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {01400000} \
        CONFIG.PF0_MSIX_CAP_TABLE_SIZE {1ff} \
        CONFIG.PF0_DEVICE_ID {00d1} \
        CONFIG.PF2_DEVICE_ID {943F} \
        CONFIG.PF3_DEVICE_ID {963F} \
        CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X16} \
        CONFIG.axisten_if_width {512_bit} \
        CONFIG.msix_type {SOFT} \
    ] $IP
}
