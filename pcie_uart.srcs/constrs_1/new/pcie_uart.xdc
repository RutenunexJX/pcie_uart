#PXIE

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
#############SPI Configurate Setting##################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]


set_property PACKAGE_PIN G25 [get_ports PCIE_RST_N]
set_property IOSTANDARD LVCMOS33 [get_ports PCIE_RST_N]
set_property PULLUP true [get_ports PCIE_RST_N]
set_false_path -from [get_ports PCIE_RST_N]



create_clock -period 10.000 -name PCIE_CLK [get_ports PCIE_CLK_P]

set_property IOSTANDARD DIFF_SSTL15 [get_ports PCIE_CLK_P]
set_property IOSTANDARD DIFF_SSTL15 [get_ports PCIE_CLK_N]
set_property PACKAGE_PIN F11 [get_ports PCIE_CLK_P]


set_property LOC GTPE2_CHANNEL_X0Y4 [get_cells {BD/design_1_i/xdma_0/inst/design_1_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN B11 [get_ports {PCIE_MGT_RX_P[0]}]
set_property LOC GTPE2_CHANNEL_X0Y5 [get_cells {BD/design_1_i/xdma_0/inst/design_1_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN D14 [get_ports {PCIE_MGT_RX_P[1]}]


set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_RX[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RS422_TX[0]}]

set_property PACKAGE_PIN E20 [get_ports {RS422_RX[0]}]
set_property PACKAGE_PIN F18 [get_ports {RS422_RX[1]}]
set_property PACKAGE_PIN E18 [get_ports {RS422_RX[2]}]
set_property PACKAGE_PIN F17 [get_ports {RS422_RX[3]}]
set_property PACKAGE_PIN E17 [get_ports {RS422_RX[4]}]
set_property PACKAGE_PIN E16 [get_ports {RS422_RX[5]}]
set_property PACKAGE_PIN F15 [get_ports {RS422_RX[6]}]
set_property PACKAGE_PIN G15 [get_ports {RS422_RX[7]}]
set_property PACKAGE_PIN G16 [get_ports {RS422_RX[8]}]
set_property PACKAGE_PIN D23 [get_ports {RS422_RX[9]}]
set_property PACKAGE_PIN F19 [get_ports {RS422_RX[10]}]
set_property PACKAGE_PIN G17 [get_ports {RS422_RX[11]}]

set_property PACKAGE_PIN B26 [get_ports {RS422_TX[0]}]
set_property PACKAGE_PIN H16 [get_ports {RS422_TX[1]}]
set_property PACKAGE_PIN G19 [get_ports {RS422_TX[2]}]
set_property PACKAGE_PIN H17 [get_ports {RS422_TX[3]}]
set_property PACKAGE_PIN F20 [get_ports {RS422_TX[4]}]
set_property PACKAGE_PIN E21 [get_ports {RS422_TX[5]}]
set_property PACKAGE_PIN C23 [get_ports {RS422_TX[6]}]
set_property PACKAGE_PIN C22 [get_ports {RS422_TX[7]}]
set_property PACKAGE_PIN AA3 [get_ports {RS422_TX[8]}]
set_property PACKAGE_PIN Y7  [get_ports {RS422_TX[9]}]
set_property PACKAGE_PIN C24 [get_ports {RS422_TX[10]}]
set_property PACKAGE_PIN B25 [get_ports {RS422_TX[11]}]


set_property IOSTANDARD LVCMOS33 [get_ports {port_en[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {port_en[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {port_en[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {port_en[0]}]

set_property PACKAGE_PIN AB1 [get_ports {port_en[0]}]
set_property PACKAGE_PIN Y1  [get_ports {port_en[1]}]
set_property PACKAGE_PIN AC2 [get_ports {port_en[2]}]
set_property PACKAGE_PIN Y2  [get_ports {port_en[3]}]

############################
##debug
