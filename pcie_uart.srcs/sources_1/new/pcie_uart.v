`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/23 19:29:43
// Design Name: 
// Module Name: pcie_uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pcie_uart(

`define LOGIC_VERSION     32'h01_00_0a_03// release version
`define LOGIC_SUB_VERSION 32'h00_00_00_0a// 

input           PCIE_CLK_P          ,
input           PCIE_CLK_N          ,
//2.0x8
input  [1:0]    PCIE_MGT_RX_N       ,
input  [1:0]    PCIE_MGT_RX_P       ,
output [1:0]    PCIE_MGT_TX_N       ,
output [1:0]    PCIE_MGT_TX_P       ,
input           PCIE_RST_N          ,
input  [11:0]   RS422_RX            ,
output [11:0]   RS422_TX            ,
output [3:0]    port_en               //
);

assign port_en = 4'b0011;

wire pcie_clk;

//@pcie_clk
IBUFDS_GTE2 IBUFDS_GTE2_u1  
(
    .O                              (pcie_clk               ),
    .ODIV2                          (                       ),
    .CEB                            (0                      ),
    .I                              (PCIE_CLK_P             ),
    .IB                             (PCIE_CLK_N             )
);


design_1_wrapper
    BD(
    .PCIE_CLK           (   pcie_clk            ),
    .PCIE_RSTN          (   PCIE_RST_N          ),

    .UART_RX_0          (   RS422_RX            ),
    .UART_TX_0          (   RS422_TX            ),

    .pcie_mgt_rxn       (   PCIE_MGT_RX_N       ),
    .pcie_mgt_rxp       (   PCIE_MGT_RX_P       ),
    .pcie_mgt_txn       (   PCIE_MGT_TX_N       ),
    .pcie_mgt_txp       (   PCIE_MGT_TX_P       ),

    .LOGIC_VERSION      (   `LOGIC_VERSION      ),
    .LOGIC_SUB_VERSION  (   `LOGIC_SUB_VERSION  ) 

);


endmodule
