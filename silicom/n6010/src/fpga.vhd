-- fpga.vhd: N6010 board top level entity and architecture
-- Copyright (C) 2022 CESNET z. s. p. o.
-- Author(s): Martin Matějka <xmatej55@vutbr.cz>
--
-- SPDX-License-Identifier: BSD-3-Clause

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.combo_const.all;
use work.combo_user_const.all;

use work.math_pack.all;
use work.type_pack.all;

entity FPGA is
port (
    -- FPGA system clock
    SYS_CLK_100M       : in    std_logic;

    -- =========================================================================
    -- PCIe
    -- =========================================================================
    PCIE_REFCLK0       : in    std_logic;
    PCIE_REFCLK1       : in    std_logic;
    PCIE_SYSRST_N      : in    std_logic;
    PCIE_RX_P          : in    std_logic_vector(15 downto 0);
    PCIE_RX_N          : in    std_logic_vector(15 downto 0);
    PCIE_TX_P          : out   std_logic_vector(15 downto 0);
    PCIE_TX_N          : out   std_logic_vector(15 downto 0);

    -- =========================================================================
    -- QSFP
    -- =========================================================================
    QSFP_REFCLK_156M    : in    std_logic;

    -- QSFP data
    QSFP0_RX_P          : in    std_logic_vector(4-1 downto 0);
    QSFP0_RX_N          : in    std_logic_vector(4-1 downto 0);
    QSFP0_TX_P          : out   std_logic_vector(4-1 downto 0);
    QSFP0_TX_N          : out   std_logic_vector(4-1 downto 0);

    QSFP1_RX_P          : in    std_logic_vector(4-1 downto 0);
    QSFP1_RX_N          : in    std_logic_vector(4-1 downto 0);
    QSFP1_TX_P          : out   std_logic_vector(4-1 downto 0);
    QSFP1_TX_N          : out   std_logic_vector(4-1 downto 0);

    -- QSFP control
    QSFP0_I2C_SCL       : inout std_logic;
    QSFP0_I2C_SDA       : inout std_logic;
    QSFP0_LPMODE        : out   std_logic;
    QSFP0_RESET_N       : out   std_logic;
    QSFP0_MODESEL_N     : out   std_logic;
    QSFP0_MODPRS_N      : in    std_logic;
    QSFP0_INT_N         : in    std_logic;

    QSFP1_I2C_SCL       : inout std_logic;
    QSFP1_I2C_SDA       : inout std_logic;
    QSFP1_LPMODE        : out   std_logic;
    QSFP1_RESET_N       : out   std_logic;
    QSFP1_MODESEL_N     : out   std_logic;
    QSFP1_MODPRS_N      : in    std_logic;
    QSFP1_INT_N         : in    std_logic;

    -- QSFP leds
    QSFP0_LED_G         : out   std_logic;
    QSFP0_LED_R         : out   std_logic;
    QSFP1_LED_G         : out   std_logic;
    QSFP1_LED_R         : out   std_logic;

    -- =========================================================================
    -- BMC INTERFACE
    -- =========================================================================
    QSPI_DCLK                : out   std_logic;
    QSPI_NCS                 : out   std_logic;
    QSPI_DATA                : inout std_logic_vector(4-1 downto 0);
    NCSI_RBT_NCSI_CLK        : in    std_logic;
    NCSI_RBT_NCSI_TXD        : in    std_logic_vector(2-1 downto 0);
    NCSI_RBT_NCSI_TX_EN      : in    std_logic;
    NCSI_RBT_NCSI_RXD        : out   std_logic_vector(2-1 downto 0);
    NCSI_RBT_NCSI_CRS_DV     : out   std_logic;
    NCSI_RBT_NCSI_ARB_IN     : in    std_logic;
    NCSI_RBT_NCSI_ARB_OUT    : out   std_logic;
    M10_GPIO_FPGA_USR_100M   : in    std_logic;
    M10_GPIO_FPGA_M10_HB     : in    std_logic;
    M10_GPIO_M10_SEU_ERROR   : in    std_logic;
    M10_GPIO_FPGA_THERM_SHDN : out   std_logic;
    M10_GPIO_FPGA_SEU_ERROR  : out   std_logic;
    SPI_INGRESS_SCLK         : out   std_logic;
    SPI_INGRESS_CSN          : out   std_logic;
    SPI_INGRESS_MISO         : in    std_logic;
    SPI_INGRESS_MOSI         : out   std_logic;
    SPI_EGRESS_MOSI          : in    std_logic;
    SPI_EGRESS_CSN           : in    std_logic;
    SPI_EGRESS_SCLK          : in    std_logic;
    SPI_EGRESS_MISO          : out   std_logic
);
end entity;

architecture FULL of FPGA is

    -- DMA debug parameters
    constant DMA_GEN_LOOP_EN : boolean := true;

    constant PCIE_LANES      : natural := 16;
    constant PCIE_CLKS       : natural := 2;
    constant PCIE_CONS       : natural := 1;
    constant MISC_IN_WIDTH   : natural := 4;
    constant MISC_OUT_WIDTH  : natural := 4;
    constant ETH_LANES       : natural := 4;
    constant DMA_MODULES     : natural := ETH_PORTS;
    constant DMA_ENDPOINTS   : natural := tsel(PCIE_ENDPOINT_MODE=1,PCIE_ENDPOINTS,2*PCIE_ENDPOINTS);
    constant STATUS_LEDS     : natural := 4; -- fake leds

    -- TODO DDR4
    constant MEM_PORTS       : natural := 0;
    constant MEM_ADDR_WIDTH  : natural := 27;
    constant MEM_DATA_WIDTH  : natural := 512;
    constant MEM_BURST_WIDTH : natural := 7;
    constant AMM_FREQ_KHZ    : natural := 333333;

    signal eth_rx_p         : std_logic_vector(ETH_PORTS*ETH_LANES-1 downto 0);
    signal eth_rx_n         : std_logic_vector(ETH_PORTS*ETH_LANES-1 downto 0);
    signal eth_tx_p         : std_logic_vector(ETH_PORTS*ETH_LANES-1 downto 0);
    signal eth_tx_n         : std_logic_vector(ETH_PORTS*ETH_LANES-1 downto 0);

    signal eth_refclk_p     : std_logic_vector(ETH_PORTS-1 downto 0);
    signal eth_refclk_n     : std_logic_vector(ETH_PORTS-1 downto 0);

    signal boot_mi_clk      : std_logic;
    signal boot_mi_reset    : std_logic;
    signal boot_mi_dwr      : std_logic_vector(31 downto 0);
    signal boot_mi_addr     : std_logic_vector(31 downto 0);
    signal boot_mi_rd       : std_logic;
    signal boot_mi_wr       : std_logic;
    signal boot_mi_be       : std_logic_vector(3 downto 0);
    signal boot_mi_drd      : std_logic_vector(31 downto 0);
    signal boot_mi_ardy     : std_logic;
    signal boot_mi_drdy     : std_logic;

begin

    cm_i : entity work.FPGA_COMMON
    generic map (
        SYSCLK_FREQ             => 100,
        USE_PCIE_CLK            => false,

        PCIE_LANES              => PCIE_LANES,
        PCIE_CLKS               => PCIE_CLKS,
        PCIE_CONS               => PCIE_CONS,

        ETH_CORE_ARCH           => NET_MOD_ARCH,
        ETH_PORTS               => ETH_PORTS, -- two QSFP cages as two ETH ports
        ETH_PORT_SPEED          => ETH_PORT_SPEED,
        ETH_PORT_CHAN           => ETH_PORT_CHAN,
        ETH_PORT_LEDS           => 1,
        ETH_LANES               => ETH_LANES,
        
        QSFP_PORTS              => ETH_PORTS,
        QSFP_I2C_PORTS          => ETH_PORTS,

        STATUS_LEDS             => STATUS_LEDS,
        MISC_IN_WIDTH           => MISC_IN_WIDTH,
        MISC_OUT_WIDTH          => MISC_OUT_WIDTH,
        
        PCIE_ENDPOINTS          => PCIE_ENDPOINTS,
        PCIE_ENDPOINT_TYPE      => PCIE_MOD_ARCH,
        PCIE_ENDPOINT_MODE      => PCIE_ENDPOINT_MODE,
        
        DMA_ENDPOINTS           => DMA_ENDPOINTS,
        DMA_MODULES             => DMA_MODULES,
        
        DMA_RX_CHANNELS         => DMA_RX_CHANNELS/DMA_MODULES,
        DMA_TX_CHANNELS         => DMA_TX_CHANNELS/DMA_MODULES,
        
        MEM_PORTS               => MEM_PORTS,
        MEM_ADDR_WIDTH          => MEM_ADDR_WIDTH,
        MEM_DATA_WIDTH          => MEM_DATA_WIDTH,
        MEM_BURST_WIDTH         => MEM_BURST_WIDTH,
        AMM_FREQ_KHZ            => AMM_FREQ_KHZ,

        BOARD                   => "N6010",
        DEVICE                  => "AGILEX",
        
        DMA_GEN_LOOP_EN         => DMA_GEN_LOOP_EN
    )
    port map(
        SYSCLK                 => SYS_CLK_100M,
        SYSRST                 => '0',

        PCIE_SYSCLK_P          => PCIE_REFCLK1 & PCIE_REFCLK0,
        PCIE_SYSCLK_N          => (others => '0'),
        PCIE_SYSRST_N(0)       => PCIE_SYSRST_N,

        PCIE_RX_P              => PCIE_RX_P,
        PCIE_RX_N              => PCIE_RX_N,
        PCIE_TX_P              => PCIE_TX_P,
        PCIE_TX_N              => PCIE_TX_N,
        
        ETH_REFCLK_P           => eth_refclk_p,
        ETH_REFCLK_N           => eth_refclk_n,
        
        ETH_RX_P               => eth_rx_p,
        ETH_RX_N               => eth_rx_n,
        ETH_TX_P               => eth_tx_p,
        ETH_TX_N               => eth_tx_n,

        ETH_LED_R(0)           => QSFP0_LED_R,
        ETH_LED_R(1)           => QSFP1_LED_R,
        ETH_LED_G(0)           => QSFP0_LED_G,
        ETH_LED_G(1)           => QSFP1_LED_G,

        QSFP_I2C_SCL(0)        => QSFP0_I2C_SCL,
        QSFP_I2C_SCL(1)        => QSFP1_I2C_SCL,
        QSFP_I2C_SDA(0)        => QSFP0_I2C_SDA,
        QSFP_I2C_SDA(1)        => QSFP1_I2C_SDA,
        QSFP_MODSEL_N(0)       => QSFP0_MODESEL_N,
        QSFP_MODSEL_N(1)       => QSFP1_MODESEL_N,
        QSFP_LPMODE(0)         => QSFP0_LPMODE,
        QSFP_LPMODE(1)         => QSFP1_LPMODE,
        QSFP_RESET_N(0)        => QSFP0_RESET_N,
        QSFP_RESET_N(1)        => QSFP1_RESET_N,
        QSFP_MODPRS_N          => QSFP1_MODPRS_N & QSFP0_MODPRS_N,
        QSFP_INT_N             => QSFP1_INT_N & QSFP0_INT_N,
        
        BOOT_MI_CLK            => boot_mi_clk,
        BOOT_MI_RESET          => boot_mi_reset,
        BOOT_MI_DWR            => boot_mi_dwr,
        BOOT_MI_ADDR           => boot_mi_addr,
        BOOT_MI_RD             => boot_mi_rd,
        BOOT_MI_WR             => boot_mi_wr,
        BOOT_MI_BE             => boot_mi_be,
        BOOT_MI_DRD            => boot_mi_drd,
        BOOT_MI_ARDY           => boot_mi_ardy,
        BOOT_MI_DRDY           => boot_mi_drdy,

        MISC_IN                => (others => '0'),
        MISC_OUT               => open
    );

    -- QSFP MAPPING ------------------------------------------------------------
    eth_refclk_p <= QSFP_REFCLK_156M & QSFP_REFCLK_156M; 
    eth_refclk_n <= (others => '0'); -- Quartus will handle the connection itself

    eth_rx_p <= QSFP1_RX_P & QSFP0_RX_P;
    eth_rx_n <= QSFP1_RX_N & QSFP0_RX_N;

    QSFP0_TX_P <= eth_tx_p(1*ETH_LANES-1 downto 0*ETH_LANES);
    QSFP0_TX_N <= eth_tx_n(1*ETH_LANES-1 downto 0*ETH_LANES);
    QSFP1_TX_P <= eth_tx_p(2*ETH_LANES-1 downto 1*ETH_LANES);
    QSFP1_TX_N <= eth_tx_n(2*ETH_LANES-1 downto 1*ETH_LANES);

    -- BMC controller (ported from OFS) ----------------------------------------
    pmci_i : entity work.PMCI_TOP
    generic map(
        DEVICE => "AGILEX"
    ) port map(
        CLK                      => boot_mi_clk,
        RESET                    => boot_mi_reset,

        MI_DWR                   => boot_mi_dwr,
        MI_ADDR                  => boot_mi_addr,
        MI_RD                    => boot_mi_rd,
        MI_WR                    => boot_mi_wr,
        MI_BE                    => boot_mi_be,
        MI_DRD                   => boot_mi_drd,
        MI_ARDY                  => boot_mi_ardy,
        MI_DRDY                  => boot_mi_drdy,

        QSPI_DCLK                => QSPI_DCLK,
        QSPI_NCS                 => QSPI_NCS,
        QSPI_DATA                => QSPI_DATA,
        NCSI_RBT_NCSI_CLK        => NCSI_RBT_NCSI_CLK,
        NCSI_RBT_NCSI_TXD        => NCSI_RBT_NCSI_TXD,
        NCSI_RBT_NCSI_TX_EN      => NCSI_RBT_NCSI_TX_EN,
        NCSI_RBT_NCSI_RXD        => NCSI_RBT_NCSI_RXD,
        NCSI_RBT_NCSI_CRS_DV     => NCSI_RBT_NCSI_CRS_DV,
        NCSI_RBT_NCSI_ARB_IN     => NCSI_RBT_NCSI_ARB_IN,
        NCSI_RBT_NCSI_ARB_OUT    => NCSI_RBT_NCSI_ARB_OUT,
        M10_GPIO_FPGA_USR_100M   => M10_GPIO_FPGA_USR_100M,
        M10_GPIO_FPGA_M10_HB     => M10_GPIO_FPGA_M10_HB,
        M10_GPIO_M10_SEU_ERROR   => M10_GPIO_M10_SEU_ERROR,
        M10_GPIO_FPGA_THERM_SHDN => M10_GPIO_FPGA_THERM_SHDN,
        M10_GPIO_FPGA_SEU_ERROR  => M10_GPIO_FPGA_SEU_ERROR,
        SPI_INGRESS_SCLK         => SPI_INGRESS_SCLK,
        SPI_INGRESS_CSN          => SPI_INGRESS_CSN,
        SPI_INGRESS_MISO         => SPI_INGRESS_MISO,
        SPI_INGRESS_MOSI         => SPI_INGRESS_MOSI,
        SPI_EGRESS_MOSI          => SPI_EGRESS_MOSI,
        SPI_EGRESS_CSN           => SPI_EGRESS_CSN,
        SPI_EGRESS_SCLK          => SPI_EGRESS_SCLK,
        SPI_EGRESS_MISO          => SPI_EGRESS_MISO
    );

end architecture;
