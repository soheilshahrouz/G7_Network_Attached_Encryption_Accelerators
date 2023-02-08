
## Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { sys_clk_in }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {sys_clk_in}];


# Ethernet PHY
set_property -dict { PACKAGE_PIN C9    IOSTANDARD LVCMOS33 } [get_ports { mdc }]; #IO_L11P_T1_SRCC_16 Sch=eth_mdc
set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { mdio }]; #IO_L14N_T2_SRCC_16 Sch=eth_mdio
set_property -dict { PACKAGE_PIN B3    IOSTANDARD LVCMOS33 } [get_ports { phy_resetn }]; #IO_L10P_T1_AD15P_35 Sch=eth_rstn
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { phy2rmii_crs_dv }]; #IO_L6N_T0_VREF_16 Sch=eth_crsdv
set_property -dict { PACKAGE_PIN C10   IOSTANDARD LVCMOS33 } [get_ports { phy2rmii_rx_er }]; #IO_L13N_T2_MRCC_16 Sch=eth_rxerr
set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports { phy2rmii_rxd[0] }]; #IO_L13P_T2_MRCC_16 Sch=eth_rxd[0]
set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { phy2rmii_rxd[1] }]; #IO_L19N_T3_VREF_16 Sch=eth_rxd[1]
set_property -dict { PACKAGE_PIN B9    IOSTANDARD LVCMOS33 } [get_ports { rmii2phy_tx_en }]; #IO_L11N_T1_SRCC_16 Sch=eth_txen
set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports { rmii2phy_txd[0] }]; #IO_L14P_T2_SRCC_16 Sch=eth_txd[0]
set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports { rmii2phy_txd[1] }]; #IO_L12N_T1_MRCC_16 Sch=eth_txd[1]
set_property -dict { PACKAGE_PIN D5    IOSTANDARD LVCMOS33 } [get_ports { eth_ref_clk }]; #IO_L11P_T1_SRCC_35 Sch=eth_refclk
# set_property -dict { PACKAGE_PIN B8    IOSTANDARD LVCMOS33 } [get_ports { ETH_INTN }]; #IO_L12P_T1_MRCC_16 Sch=eth_intn
  