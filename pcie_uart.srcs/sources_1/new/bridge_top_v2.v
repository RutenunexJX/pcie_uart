`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/19 23:51:46
// Design Name: 
// Module Name: 
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
// `define TEST

`define VERSION 16'h0002
`define R_BASE_ADDR_CH1  64'h0000_0000_0011_0000	
`define R_BASE_ADDR_CH2  64'h0000_0000_0012_0000	
`define R_BASE_ADDR_CH3  64'h0000_0000_0013_0000	
`define R_BASE_ADDR_CH4  64'h0000_0000_0014_0000	
`define R_BASE_ADDR_CH5  64'h0000_0000_0015_0000	
`define R_BASE_ADDR_CH6  64'h0000_0000_0016_0000	
`define R_BASE_ADDR_CH7  64'h0000_0000_0017_0000	
`define R_BASE_ADDR_CH8  64'h0000_0000_0018_0000	
`define R_BASE_ADDR_CH9  64'h0000_0000_0019_0000	
`define R_BASE_ADDR_CH10 64'h0000_0000_001a_0000	
`define R_BASE_ADDR_CH11 64'h0000_0000_001b_0000	
`define R_BASE_ADDR_CH12 64'h0000_0000_001c_0000
	
`define W_BASE_ADDR_CH1  64'h0000_0000_0021_0000	
`define W_BASE_ADDR_CH2  64'h0000_0000_0022_0000	
`define W_BASE_ADDR_CH3  64'h0000_0000_0023_0000	
`define W_BASE_ADDR_CH4  64'h0000_0000_0024_0000	
`define W_BASE_ADDR_CH5  64'h0000_0000_0025_0000	
`define W_BASE_ADDR_CH6  64'h0000_0000_0026_0000	
`define W_BASE_ADDR_CH7  64'h0000_0000_0027_0000	
`define W_BASE_ADDR_CH8  64'h0000_0000_0028_0000	
`define W_BASE_ADDR_CH9  64'h0000_0000_0029_0000	
`define W_BASE_ADDR_CH10 64'h0000_0000_002a_0000	
`define W_BASE_ADDR_CH11 64'h0000_0000_002b_0000	
`define W_BASE_ADDR_CH12 64'h0000_0000_002c_0000	

`define LITE_BASE_ADDR 32'h0000_0000

module bridge_top_v2(

	//
	input 							clk  									,
	input 							rst 									,
	//
	output 							interupt_req							,
    input                           interupt_ack                            ,
	input   [31:0]                  LOGIC_VERSION                           ,
	input   [31:0]                  LOGIC_SUB_VERSION                       ,
    // _________________________________________________________________________ 1
    input   [3 : 0]                 s01_axi_awid                          	,
    input   [63 : 0]                s01_axi_awaddr                        	,
    input   [7 : 0]                 s01_axi_awlen                         	,
    input   [2 : 0]                 s01_axi_awsize                        	,
    input   [1 : 0]                 s01_axi_awburst                       	,
    input   [2 : 0]                 s01_axi_awprot                        	,
    input                           s01_axi_awvalid                       	,
    input                           s01_axi_awlock                        	,
    input   [3 : 0]                 s01_axi_awcache                       	,
    output                          s01_axi_awready                       	,
	
    input   [63 : 0]                s01_axi_wdata                         	,
    input   [7 : 0]                 s01_axi_wstrb                         	,
    input                           s01_axi_wlast                         	,
    input                           s01_axi_wvalid                        	,
    output                          s01_axi_wready                        	,
	
    output  [3 : 0]                 s01_axi_bid                           	,
    output  [1 : 0]                 s01_axi_bresp                         	,
    output                          s01_axi_bvalid                        	,
    input                           s01_axi_bready                        	,
	
    input   [3 : 0]                 s01_axi_arid                          	,
    input   [63 : 0]                s01_axi_araddr                        	,
    input   [7 : 0]                 s01_axi_arlen                         	,
    input   [2 : 0]                 s01_axi_arsize                        	,
    input   [1 : 0]                 s01_axi_arburst                       	,
    input   [2 : 0]                 s01_axi_arprot                        	,
    input                           s01_axi_arvalid                       	,
    input                           s01_axi_arlock                        	,
    input   [3 : 0]                 s01_axi_arcache                       	,
    output                          s01_axi_arready                       	,
	
    output  [3 : 0]                 s01_axi_rid                           	,
    output  [63 : 0]                s01_axi_rdata                         	,
    output  [1 : 0]                 s01_axi_rresp                         	,
    output                          s01_axi_rlast                         	,
    output                          s01_axi_rvalid                        	,
    input                           s01_axi_rready                        	,
	// _________________________________________________________________________ 2
    input   [3 : 0]                 s02_axi_awid                          	,
    input   [63 : 0]                s02_axi_awaddr                        	,
    input   [7 : 0]                 s02_axi_awlen                         	,
    input   [2 : 0]                 s02_axi_awsize                        	,
    input   [1 : 0]                 s02_axi_awburst                       	,
    input   [2 : 0]                 s02_axi_awprot                        	,
    input                           s02_axi_awvalid                       	,
    input                           s02_axi_awlock                        	,
    input   [3 : 0]                 s02_axi_awcache                       	,
    output                          s02_axi_awready                       	,
									 
    input   [63 : 0]                s02_axi_wdata                         	,
    input   [7 : 0]                 s02_axi_wstrb                         	,
    input                           s02_axi_wlast                         	,
    input                           s02_axi_wvalid                        	,
    output                          s02_axi_wready                        	,
									 
    output  [3 : 0]                 s02_axi_bid                           	,
    output  [1 : 0]                 s02_axi_bresp                         	,
    output                          s02_axi_bvalid                        	,
    input                           s02_axi_bready                        	,
									 
    input   [3 : 0]                 s02_axi_arid                          	,
    input   [63 : 0]                s02_axi_araddr                        	,
    input   [7 : 0]                 s02_axi_arlen                         	,
    input   [2 : 0]                 s02_axi_arsize                        	,
    input   [1 : 0]                 s02_axi_arburst                       	,
    input   [2 : 0]                 s02_axi_arprot                        	,
    input                           s02_axi_arvalid                       	,
    input                           s02_axi_arlock                        	,
    input   [3 : 0]                 s02_axi_arcache                       	,
    output                          s02_axi_arready                       	,
									 
    output  [3 : 0]                 s02_axi_rid                           	,
    output  [63 : 0]                s02_axi_rdata                         	,
    output  [1 : 0]                 s02_axi_rresp                         	,
    output                          s02_axi_rlast                         	,
    output                          s02_axi_rvalid                        	,
    input                           s02_axi_rready                        	,
	// _________________________________________________________________________ 3
    input   [3 : 0]                 s03_axi_awid                          	,
    input   [63 : 0]                s03_axi_awaddr                        	,
    input   [7 : 0]                 s03_axi_awlen                         	,
    input   [2 : 0]                 s03_axi_awsize                        	,
    input   [1 : 0]                 s03_axi_awburst                       	,
    input   [2 : 0]                 s03_axi_awprot                        	,
    input                           s03_axi_awvalid                       	,
    input                           s03_axi_awlock                        	,
    input   [3 : 0]                 s03_axi_awcache                       	,
    output                          s03_axi_awready                       	,
									 
    input   [63 : 0]                s03_axi_wdata                         	,
    input   [7 : 0]                 s03_axi_wstrb                         	,
    input                           s03_axi_wlast                         	,
    input                           s03_axi_wvalid                        	,
    output                          s03_axi_wready                        	,
									 
    output  [3 : 0]                 s03_axi_bid                           	,
    output  [1 : 0]                 s03_axi_bresp                         	,
    output                          s03_axi_bvalid                        	,
    input                           s03_axi_bready                        	,
									 
    input   [3 : 0]                 s03_axi_arid                          	,
    input   [63 : 0]                s03_axi_araddr                        	,
    input   [7 : 0]                 s03_axi_arlen                         	,
    input   [2 : 0]                 s03_axi_arsize                        	,
    input   [1 : 0]                 s03_axi_arburst                       	,
    input   [2 : 0]                 s03_axi_arprot                        	,
    input                           s03_axi_arvalid                       	,
    input                           s03_axi_arlock                        	,
    input   [3 : 0]                 s03_axi_arcache                       	,
    output                          s03_axi_arready                       	,
									 
    output  [3 : 0]                 s03_axi_rid                           	,
    output  [63 : 0]                s03_axi_rdata                         	,
    output  [1 : 0]                 s03_axi_rresp                         	,
    output                          s03_axi_rlast                         	,
    output                          s03_axi_rvalid                        	,
    input                           s03_axi_rready                        	,
	// _________________________________________________________________________ 4
    input   [3 : 0]                 s04_axi_awid                          	,
    input   [63 : 0]                s04_axi_awaddr                        	,
    input   [7 : 0]                 s04_axi_awlen                         	,
    input   [2 : 0]                 s04_axi_awsize                        	,
    input   [1 : 0]                 s04_axi_awburst                       	,
    input   [2 : 0]                 s04_axi_awprot                        	,
    input                           s04_axi_awvalid                       	,
    input                           s04_axi_awlock                        	,
    input   [3 : 0]                 s04_axi_awcache                       	,
    output                          s04_axi_awready                       	,
									 
    input   [63 : 0]                s04_axi_wdata                         	,
    input   [7 : 0]                 s04_axi_wstrb                         	,
    input                           s04_axi_wlast                         	,
    input                           s04_axi_wvalid                        	,
    output                          s04_axi_wready                        	,
									 
    output  [3 : 0]                 s04_axi_bid                           	,
    output  [1 : 0]                 s04_axi_bresp                         	,
    output                          s04_axi_bvalid                        	,
    input                           s04_axi_bready                        	,
									 
    input   [3 : 0]                 s04_axi_arid                          	,
    input   [63 : 0]                s04_axi_araddr                        	,
    input   [7 : 0]                 s04_axi_arlen                         	,
    input   [2 : 0]                 s04_axi_arsize                        	,
    input   [1 : 0]                 s04_axi_arburst                       	,
    input   [2 : 0]                 s04_axi_arprot                        	,
    input                           s04_axi_arvalid                       	,
    input                           s04_axi_arlock                        	,
    input   [3 : 0]                 s04_axi_arcache                       	,
    output                          s04_axi_arready                       	,
									 
    output  [3 : 0]                 s04_axi_rid                           	,
    output  [63 : 0]                s04_axi_rdata                         	,
    output  [1 : 0]                 s04_axi_rresp                         	,
    output                          s04_axi_rlast                         	,
    output                          s04_axi_rvalid                        	,
    input                           s04_axi_rready                        	,
	// _________________________________________________________________________ 5
    input   [3 : 0]                 s05_axi_awid                          	,
    input   [63 : 0]                s05_axi_awaddr                        	,
    input   [7 : 0]                 s05_axi_awlen                         	,
    input   [2 : 0]                 s05_axi_awsize                        	,
    input   [1 : 0]                 s05_axi_awburst                       	,
    input   [2 : 0]                 s05_axi_awprot                        	,
    input                           s05_axi_awvalid                       	,
    input                           s05_axi_awlock                        	,
    input   [3 : 0]                 s05_axi_awcache                       	,
    output                          s05_axi_awready                       	,
									 
    input   [63 : 0]                s05_axi_wdata                         	,
    input   [7 : 0]                 s05_axi_wstrb                         	,
    input                           s05_axi_wlast                         	,
    input                           s05_axi_wvalid                        	,
    output                          s05_axi_wready                        	,
									 
    output  [3 : 0]                 s05_axi_bid                           	,
    output  [1 : 0]                 s05_axi_bresp                         	,
    output                          s05_axi_bvalid                        	,
    input                           s05_axi_bready                        	,
									 
    input   [3 : 0]                 s05_axi_arid                          	,
    input   [63 : 0]                s05_axi_araddr                        	,
    input   [7 : 0]                 s05_axi_arlen                         	,
    input   [2 : 0]                 s05_axi_arsize                        	,
    input   [1 : 0]                 s05_axi_arburst                       	,
    input   [2 : 0]                 s05_axi_arprot                        	,
    input                           s05_axi_arvalid                       	,
    input                           s05_axi_arlock                        	,
    input   [3 : 0]                 s05_axi_arcache                       	,
    output                          s05_axi_arready                       	,
									 
    output  [3 : 0]                 s05_axi_rid                           	,
    output  [63 : 0]                s05_axi_rdata                         	,
    output  [1 : 0]                 s05_axi_rresp                         	,
    output                          s05_axi_rlast                         	,
    output                          s05_axi_rvalid                        	,
    input                           s05_axi_rready                        	,
	// _________________________________________________________________________ 6
    input   [3 : 0]                 s06_axi_awid                          	,
    input   [63 : 0]                s06_axi_awaddr                        	,
    input   [7 : 0]                 s06_axi_awlen                         	,
    input   [2 : 0]                 s06_axi_awsize                        	,
    input   [1 : 0]                 s06_axi_awburst                       	,
    input   [2 : 0]                 s06_axi_awprot                        	,
    input                           s06_axi_awvalid                       	,
    input                           s06_axi_awlock                        	,
    input   [3 : 0]                 s06_axi_awcache                       	,
    output                          s06_axi_awready                       	,
									 
    input   [63 : 0]                s06_axi_wdata                         	,
    input   [7 : 0]                 s06_axi_wstrb                         	,
    input                           s06_axi_wlast                         	,
    input                           s06_axi_wvalid                        	,
    output                          s06_axi_wready                        	,
									 
    output  [3 : 0]                 s06_axi_bid                           	,
    output  [1 : 0]                 s06_axi_bresp                         	,
    output                          s06_axi_bvalid                        	,
    input                           s06_axi_bready                        	,
									 
    input   [3 : 0]                 s06_axi_arid                          	,
    input   [63 : 0]                s06_axi_araddr                        	,
    input   [7 : 0]                 s06_axi_arlen                         	,
    input   [2 : 0]                 s06_axi_arsize                        	,
    input   [1 : 0]                 s06_axi_arburst                       	,
    input   [2 : 0]                 s06_axi_arprot                        	,
    input                           s06_axi_arvalid                       	,
    input                           s06_axi_arlock                        	,
    input   [3 : 0]                 s06_axi_arcache                       	,
    output                          s06_axi_arready                       	,
									 
    output  [3 : 0]                 s06_axi_rid                           	,
    output  [63 : 0]                s06_axi_rdata                         	,
    output  [1 : 0]                 s06_axi_rresp                         	,
    output                          s06_axi_rlast                         	,
    output                          s06_axi_rvalid                        	,
    input                           s06_axi_rready                        	,
	// _________________________________________________________________________ 7
    input   [3 : 0]                 s07_axi_awid                          	,
    input   [63 : 0]                s07_axi_awaddr                        	,
    input   [7 : 0]                 s07_axi_awlen                         	,
    input   [2 : 0]                 s07_axi_awsize                        	,
    input   [1 : 0]                 s07_axi_awburst                       	,
    input   [2 : 0]                 s07_axi_awprot                        	,
    input                           s07_axi_awvalid                       	,
    input                           s07_axi_awlock                        	,
    input   [3 : 0]                 s07_axi_awcache                       	,
    output                          s07_axi_awready                       	,
									 
    input   [63 : 0]                s07_axi_wdata                         	,
    input   [7 : 0]                 s07_axi_wstrb                         	,
    input                           s07_axi_wlast                         	,
    input                           s07_axi_wvalid                        	,
    output                          s07_axi_wready                        	,
									 
    output  [3 : 0]                 s07_axi_bid                           	,
    output  [1 : 0]                 s07_axi_bresp                         	,
    output                          s07_axi_bvalid                        	,
    input                           s07_axi_bready                        	,
									 
    input   [3 : 0]                 s07_axi_arid                          	,
    input   [63 : 0]                s07_axi_araddr                        	,
    input   [7 : 0]                 s07_axi_arlen                         	,
    input   [2 : 0]                 s07_axi_arsize                        	,
    input   [1 : 0]                 s07_axi_arburst                       	,
    input   [2 : 0]                 s07_axi_arprot                        	,
    input                           s07_axi_arvalid                       	,
    input                           s07_axi_arlock                        	,
    input   [3 : 0]                 s07_axi_arcache                       	,
    output                          s07_axi_arready                       	,
									 
    output  [3 : 0]                 s07_axi_rid                           	,
    output  [63 : 0]                s07_axi_rdata                         	,
    output  [1 : 0]                 s07_axi_rresp                         	,
    output                          s07_axi_rlast                         	,
    output                          s07_axi_rvalid                        	,
    input                           s07_axi_rready                        	,
	// _________________________________________________________________________ 8
    input   [3 : 0]                 s08_axi_awid                          	,
    input   [63 : 0]                s08_axi_awaddr                        	,
    input   [7 : 0]                 s08_axi_awlen                         	,
    input   [2 : 0]                 s08_axi_awsize                        	,
    input   [1 : 0]                 s08_axi_awburst                       	,
    input   [2 : 0]                 s08_axi_awprot                        	,
    input                           s08_axi_awvalid                       	,
    input                           s08_axi_awlock                        	,
    input   [3 : 0]                 s08_axi_awcache                       	,
    output                          s08_axi_awready                       	,
									 
    input   [63 : 0]                s08_axi_wdata                         	,
    input   [7 : 0]                 s08_axi_wstrb                         	,
    input                           s08_axi_wlast                         	,
    input                           s08_axi_wvalid                        	,
    output                          s08_axi_wready                        	,
									 
    output  [3 : 0]                 s08_axi_bid                           	,
    output  [1 : 0]                 s08_axi_bresp                         	,
    output                          s08_axi_bvalid                        	,
    input                           s08_axi_bready                        	,
									 
    input   [3 : 0]                 s08_axi_arid                          	,
    input   [63 : 0]                s08_axi_araddr                        	,
    input   [7 : 0]                 s08_axi_arlen                         	,
    input   [2 : 0]                 s08_axi_arsize                        	,
    input   [1 : 0]                 s08_axi_arburst                       	,
    input   [2 : 0]                 s08_axi_arprot                        	,
    input                           s08_axi_arvalid                       	,
    input                           s08_axi_arlock                        	,
    input   [3 : 0]                 s08_axi_arcache                       	,
    output                          s08_axi_arready                       	,
									 
    output  [3 : 0]                 s08_axi_rid                           	,
    output  [63 : 0]                s08_axi_rdata                         	,
    output  [1 : 0]                 s08_axi_rresp                         	,
    output                          s08_axi_rlast                         	,
    output                          s08_axi_rvalid                        	,
    input                           s08_axi_rready                        	,
	// _________________________________________________________________________ 9
    input   [3 : 0]                 s09_axi_awid                          	,
    input   [63 : 0]                s09_axi_awaddr                        	,
    input   [7 : 0]                 s09_axi_awlen                         	,
    input   [2 : 0]                 s09_axi_awsize                        	,
    input   [1 : 0]                 s09_axi_awburst                       	,
    input   [2 : 0]                 s09_axi_awprot                        	,
    input                           s09_axi_awvalid                       	,
    input                           s09_axi_awlock                        	,
    input   [3 : 0]                 s09_axi_awcache                       	,
    output                          s09_axi_awready                       	,
									 
    input   [63 : 0]                s09_axi_wdata                         	,
    input   [7 : 0]                 s09_axi_wstrb                         	,
    input                           s09_axi_wlast                         	,
    input                           s09_axi_wvalid                        	,
    output                          s09_axi_wready                        	,
									 
    output  [3 : 0]                 s09_axi_bid                           	,
    output  [1 : 0]                 s09_axi_bresp                         	,
    output                          s09_axi_bvalid                        	,
    input                           s09_axi_bready                        	,
									 
    input   [3 : 0]                 s09_axi_arid                          	,
    input   [63 : 0]                s09_axi_araddr                        	,
    input   [7 : 0]                 s09_axi_arlen                         	,
    input   [2 : 0]                 s09_axi_arsize                        	,
    input   [1 : 0]                 s09_axi_arburst                       	,
    input   [2 : 0]                 s09_axi_arprot                        	,
    input                           s09_axi_arvalid                       	,
    input                           s09_axi_arlock                        	,
    input   [3 : 0]                 s09_axi_arcache                       	,
    output                          s09_axi_arready                       	,
									 
    output  [3 : 0]                 s09_axi_rid                           	,
    output  [63 : 0]                s09_axi_rdata                         	,
    output  [1 : 0]                 s09_axi_rresp                         	,
    output                          s09_axi_rlast                         	,
    output                          s09_axi_rvalid                        	,
    input                           s09_axi_rready                        	,
	// _________________________________________________________________________ 10
    input   [3 : 0]                 s10_axi_awid                          	,
    input   [63 : 0]                s10_axi_awaddr                        	,
    input   [7 : 0]                 s10_axi_awlen                         	,
    input   [2 : 0]                 s10_axi_awsize                        	,
    input   [1 : 0]                 s10_axi_awburst                       	,
    input   [2 : 0]                 s10_axi_awprot                        	,
    input                           s10_axi_awvalid                       	,
    input                           s10_axi_awlock                        	,
    input   [3 : 0]                 s10_axi_awcache                       	,
    output                          s10_axi_awready                       	,
									  
    input   [63 : 0]                s10_axi_wdata                         	,
    input   [7 : 0]                 s10_axi_wstrb                         	,
    input                           s10_axi_wlast                         	,
    input                           s10_axi_wvalid                        	,
    output                          s10_axi_wready                        	,
									  
    output  [3 : 0]                 s10_axi_bid                           	,
    output  [1 : 0]                 s10_axi_bresp                         	,
    output                          s10_axi_bvalid                        	,
    input                           s10_axi_bready                        	,
									  
    input   [3 : 0]                 s10_axi_arid                          	,
    input   [63 : 0]                s10_axi_araddr                        	,
    input   [7 : 0]                 s10_axi_arlen                         	,
    input   [2 : 0]                 s10_axi_arsize                        	,
    input   [1 : 0]                 s10_axi_arburst                       	,
    input   [2 : 0]                 s10_axi_arprot                        	,
    input                           s10_axi_arvalid                       	,
    input                           s10_axi_arlock                        	,
    input   [3 : 0]                 s10_axi_arcache                       	,
    output                          s10_axi_arready                       	,
									  
    output  [3 : 0]                 s10_axi_rid                           	,
    output  [63 : 0]                s10_axi_rdata                         	,
    output  [1 : 0]                 s10_axi_rresp                         	,
    output                          s10_axi_rlast                         	,
    output                          s10_axi_rvalid                        	,
    input                           s10_axi_rready                        	,
	// _________________________________________________________________________ 11
    input   [3 : 0]                 s11_axi_awid                          	,
    input   [63 : 0]                s11_axi_awaddr                        	,
    input   [7 : 0]                 s11_axi_awlen                         	,
    input   [2 : 0]                 s11_axi_awsize                        	,
    input   [1 : 0]                 s11_axi_awburst                       	,
    input   [2 : 0]                 s11_axi_awprot                        	,
    input                           s11_axi_awvalid                       	,
    input                           s11_axi_awlock                        	,
    input   [3 : 0]                 s11_axi_awcache                       	,
    output                          s11_axi_awready                       	,
									  
    input   [63 : 0]                s11_axi_wdata                         	,
    input   [7 : 0]                 s11_axi_wstrb                         	,
    input                           s11_axi_wlast                         	,
    input                           s11_axi_wvalid                        	,
    output                          s11_axi_wready                        	,
									  
    output  [3 : 0]                 s11_axi_bid                           	,
    output  [1 : 0]                 s11_axi_bresp                         	,
    output                          s11_axi_bvalid                        	,
    input                           s11_axi_bready                        	,
									  
    input   [3 : 0]                 s11_axi_arid                          	,
    input   [63 : 0]                s11_axi_araddr                        	,
    input   [7 : 0]                 s11_axi_arlen                         	,
    input   [2 : 0]                 s11_axi_arsize                        	,
    input   [1 : 0]                 s11_axi_arburst                       	,
    input   [2 : 0]                 s11_axi_arprot                        	,
    input                           s11_axi_arvalid                       	,
    input                           s11_axi_arlock                        	,
    input   [3 : 0]                 s11_axi_arcache                       	,
    output                          s11_axi_arready                       	,
									  
    output  [3 : 0]                 s11_axi_rid                           	,
    output  [63 : 0]                s11_axi_rdata                         	,
    output  [1 : 0]                 s11_axi_rresp                         	,
    output                          s11_axi_rlast                         	,
    output                          s11_axi_rvalid                        	,
    input                           s11_axi_rready                        	,
	// _________________________________________________________________________ 12
    input   [3 : 0]                 s12_axi_awid                          	,
    input   [63 : 0]                s12_axi_awaddr                        	,
    input   [7 : 0]                 s12_axi_awlen                         	,
    input   [2 : 0]                 s12_axi_awsize                        	,
    input   [1 : 0]                 s12_axi_awburst                       	,
    input   [2 : 0]                 s12_axi_awprot                        	,
    input                           s12_axi_awvalid                       	,
    input                           s12_axi_awlock                        	,
    input   [3 : 0]                 s12_axi_awcache                       	,
    output                          s12_axi_awready                       	,
									  
    input   [63 : 0]                s12_axi_wdata                         	,
    input   [7 : 0]                 s12_axi_wstrb                         	,
    input                           s12_axi_wlast                         	,
    input                           s12_axi_wvalid                        	,
    output                          s12_axi_wready                        	,
									  
    output  [3 : 0]                 s12_axi_bid                           	,
    output  [1 : 0]                 s12_axi_bresp                         	,
    output                          s12_axi_bvalid                        	,
    input                           s12_axi_bready                        	,
									  
    input   [3 : 0]                 s12_axi_arid                          	,
    input   [63 : 0]                s12_axi_araddr                        	,
    input   [7 : 0]                 s12_axi_arlen                         	,
    input   [2 : 0]                 s12_axi_arsize                        	,
    input   [1 : 0]                 s12_axi_arburst                       	,
    input   [2 : 0]                 s12_axi_arprot                        	,
    input                           s12_axi_arvalid                       	,
    input                           s12_axi_arlock                        	,
    input   [3 : 0]                 s12_axi_arcache                       	,
    output                          s12_axi_arready                       	,
									  
    output  [3 : 0]                 s12_axi_rid                           	,
    output  [63 : 0]                s12_axi_rdata                         	,
    output  [1 : 0]                 s12_axi_rresp                         	,
    output                          s12_axi_rlast                         	,
    output                          s12_axi_rvalid                        	,
    input                           s12_axi_rready                        	,
    // pcie->bridge axi-lite-----------------------------------------------------------
    input   [31 : 0]                s_axi_lite_awaddr                   	,
    input   [2 : 0]                 s_axi_lite_awprot                   	,
    input                           s_axi_lite_awvalid                  	,
    output                          s_axi_lite_awready                  	,
	
    input   [31 : 0]                s_axi_lite_wdata                    	,
    input   [3 : 0]                 s_axi_lite_wstrb                    	,
    input                           s_axi_lite_wvalid                   	,
    output                          s_axi_lite_wready                   	,
	
    output                          s_axi_lite_bvalid                   	,
    output  [1 : 0]                 s_axi_lite_bresp                    	,
    input                           s_axi_lite_bready                   	,
	
    input   [31 : 0]                s_axi_lite_araddr                   	,
    input   [2 : 0]                 s_axi_lite_arprot                   	,
    input                           s_axi_lite_arvalid                  	,
    output                          s_axi_lite_arready                  	,
	
    output  [31 : 0]                s_axi_lite_rdata                    	,
    output  [1 : 0]                 s_axi_lite_rresp                    	,
    output                          s_axi_lite_rvalid                   	,
    input                           s_axi_lite_rready                   	,
	//UART---------------------------------------------------------------------------
    input   [11:0]                  UART_RX                                 ,
    output  [11:0]                  UART_TX                                   //
);

localparam [767:0] W_BASE_ADDR = {`W_BASE_ADDR_CH12, `W_BASE_ADDR_CH11, `W_BASE_ADDR_CH10, `W_BASE_ADDR_CH9, `W_BASE_ADDR_CH8, `W_BASE_ADDR_CH7, `W_BASE_ADDR_CH6, `W_BASE_ADDR_CH5, `W_BASE_ADDR_CH4, `W_BASE_ADDR_CH3, `W_BASE_ADDR_CH2, `W_BASE_ADDR_CH1};
localparam [767:0] R_BASE_ADDR = {`R_BASE_ADDR_CH12, `R_BASE_ADDR_CH11, `R_BASE_ADDR_CH10, `R_BASE_ADDR_CH9, `R_BASE_ADDR_CH8, `R_BASE_ADDR_CH7, `R_BASE_ADDR_CH6, `R_BASE_ADDR_CH5, `R_BASE_ADDR_CH4, `R_BASE_ADDR_CH3, `R_BASE_ADDR_CH2, `R_BASE_ADDR_CH1};

genvar i;

wire  	[3 : 0]         FULL_awid    	[11:0]                  ;
wire  	[63 : 0]        FULL_awaddr  	[11:0]                  ;
wire  	[7 : 0]         FULL_awlen   	[11:0]                  ;
wire  	[2 : 0]         FULL_awsize  	[11:0]                  ;
wire  	[1 : 0]         FULL_awburst 	[11:0]                  ;
wire  	[2 : 0]         FULL_awprot  	[11:0]                  ;
wire  	[11 : 0]		FULL_awvalid 	   		                ;
wire  	[11 : 0]		FULL_awlock				                ;
wire  	[3 : 0]         FULL_awcache 	[11:0]                  ;
wire  	[11 : 0]		FULL_awready 		   	                ;
            
wire  	[63 : 0]        FULL_wdata   	[11:0]                  ;
wire  	[7 : 0]         FULL_wstrb   	[11:0]                  ;
wire  	[11 : 0]		FULL_wlast   	  		                ;
wire  	[11 : 0]		FULL_wvalid  	  		                ;
wire  	[11 : 0]		FULL_wready  	  		                ;
            
wire  	[3 : 0]         FULL_bid     	[11:0]                  ;
wire  	[1 : 0]         FULL_bresp   	[11:0]                  ;
wire  	[11 : 0]		FULL_bvalid				                ;
wire  	[11 : 0]		FULL_bready				                ;
            
wire  	[3 : 0]         FULL_arid    	[11:0]                  ;
wire  	[63 : 0]        FULL_araddr  	[11:0]                  ;
wire  	[7 : 0]         FULL_arlen   	[11:0]                  ;
wire  	[2 : 0]         FULL_arsize  	[11:0]                  ;
wire  	[1 : 0]         FULL_arburst 	[11:0]                  ;
wire  	[2 : 0]         FULL_arprot  	[11:0]                  ;
wire  	[11 : 0]		FULL_arvalid  			                ;
wire  	[11 : 0]		FULL_arlock   			                ;
wire  	[3 : 0]         FULL_arcache 	[11:0]                  ;
wire  	[11 : 0]		FULL_arready 	   		                ;
            
wire  	[3 : 0]         FULL_rid     	[11:0]                  ;
wire  	[63 : 0]        FULL_rdata   	[11:0]                  ;
wire  	[1 : 0]         FULL_rresp   	[11:0]                  ;
wire  	[11 : 0]		FULL_rlast   	  		                ;
wire  	[11 : 0]		FULL_rvalid  	  		                ;
wire  	[11 : 0]		FULL_rready  	  		                ;
            
wire    [11:0]          test_tx_flag                            ;
wire    [11:0]          test_rx_flag                            ;
wire    [11:0]          is_start_bit                            ;
            
wire    [11:0]          got_whole_brust_pkt                     ;

wire    [15:0]          LITE_REG_AXI_RD_LEN                     ;
wire    [15:0]          LITE_REG_AXI_WR_MAX_LEN					;
        
wire    			    LITE_REG_RSYNC_REQ				        ;
wire    [31:0]		    LITE_REG_RSYNC_BAUD_RATE		        ;
wire    [3:0]		    LITE_REG_RSYNC_STOP_BIT			        ;
wire    [3:0]		    LITE_REG_RSYNC_P_CHK			        ;
wire    [3:0]		    LITE_REG_RSYNC_D_WIDTH			        ;
wire    			    LITE_REG_RSYNC_STOP_PCHK_ENA	        ;
wire    			    LITE_REG_RSYNC_FSM_RST_REQ		        ;
wire    [7:0]		    LITE_REG_RSYNC_AXI_BRUST_LEN	        ;
        
wire    			    LITE_REG_TSYNC_REQ				        ;
wire    [31:0]		    LITE_REG_TSYNC_BAUD_RATE		        ;
wire    [3:0]		    LITE_REG_TSYNC_STOP_BIT			        ;
wire    [3:0]		    LITE_REG_TSYNC_P_CHK			        ;
wire    [3:0]		    LITE_REG_TSYNC_D_WIDTH			        ;
wire    [1:0]		    LITE_REG_TSYNC_INVL_MODE		        ;
wire    [15:0]		    LITE_REG_TSYNC_INVL_HF_BAUD		        ;
wire    [15:0]		    LITE_REG_TSYNC_INVL_CLK_PD		        ;

wire    			    LITE_REG_RX_CFG_REQ				[11:0]  ;
wire    [1:0]		    LITE_REG_RX_CFG_DONE			[11:0]  ;
wire    [31:0]		    LITE_REG_RX_BAUD_RATE			[11:0]  ;
wire    [3:0]		    LITE_REG_RX_STOP_BIT			[11:0]  ;
wire    [3:0]		    LITE_REG_RX_P_CHK				[11:0]  ;
wire    [3:0]		    LITE_REG_RX_D_WIDTH				[11:0]  ;
wire    			    LITE_REG_RX_STOP_PCHK_ENA		[11:0]  ;
wire    [15:0]		    LITE_REG_RX_STOP_BIT_ERR_CNT	[11:0]  ;
wire    [15:0]		    LITE_REG_RX_PCHK_ERR_CNT		[11:0]  ;
wire    			    LITE_REG_RX_FSM_RST_REQ			[11:0]  ;
wire    			    LITE_REG_RX_FSM_RST_DONE		[11:0]  ;
wire    [7:0]		    LITE_REG_RX_AXI_BRUST_LEN		[11:0]  ;
wire    [15:0]		    LITE_REG_RX_RFF_USEDW			[11:0]  ;
wire    [31:0]          LITE_REG_RX_TIMEOUT_THRD        [11:0]  ;

wire    			    LITE_REG_TX_CFG_REQ				[11:0]  ;
wire    [1:0]		    LITE_REG_TX_CFG_DONE			[11:0]  ;
wire    [31:0]		    LITE_REG_TX_BAUD_RATE			[11:0]  ;
wire    [3:0]		    LITE_REG_TX_STOP_BIT			[11:0]  ;
wire    [3:0]		    LITE_REG_TX_P_CHK				[11:0]  ;
wire    [3:0]		    LITE_REG_TX_D_WDITH				[11:0]  ;
wire    [1:0]		    LITE_REG_TX_INVL_MODE			[11:0]  ;
wire    [15:0]		    LITE_REG_TX_INVL_HF_BAUD		[11:0]  ;
wire    [15:0]		    LITE_REG_TX_INVL_CLK_PD			[11:0]  ;
wire    [15:0]		    LITE_REG_TX_TFF_USEDW			[11:0]  ;
wire 	[15:0]			LITE_REG_TX_AXI_WR_MAX_LEN		[11:0]	;
wire 	[15:0]			LITE_REG_TX_AXI_WR_EFF_LEN		[11:0]	;

reg     [15:0]          sys_axi_rd_len                          ;
reg 	[15:0]			sys_axi_wr_max_len						;

reg    	[11:0] 		    rx_cfg_req				                ;
reg     [1:0]		    rx_cfg_done				        [11:0]  ;
reg     [31:0]		    rx_baud_rate			        [11:0]  ;
reg     [3:0]		    rx_stop_bit				        [11:0]  ;
reg     [3:0]		    rx_p_chk				        [11:0]  ;
reg     [3:0]		    rx_d_width				        [11:0]  ;
reg    			        rx_stop_pchk_ena		        [11:0]  ;
reg     [15:0]		    rx_stop_bit_err_cnt	            [11:0]  ;
reg     [15:0]		    rx_pchk_err_cnt		            [11:0]  ;
reg    			        rx_fsm_rst_req			        [11:0]  ;
reg    			        rx_fsm_rst_done			        [11:0]  ;
reg     [7:0]		    rx_axi_brust_len		        [11:0]  ;
reg     [15:0]          rx_rff_usedw                    [11:0]  ;
reg     [31:0]          rx_timeout_thrd                 [11:0]  ;

reg     [11:0]          tx_cfg_req                              ;
reg     [1:0]		    tx_cfg_done				        [11:0]  ;
reg     [31:0]		    tx_baud_rate			        [11:0]  ;
reg     [3:0]		    tx_stop_bit				        [11:0]  ;
reg     [3:0]		    tx_p_chk				        [11:0]  ;
reg     [3:0]		    tx_d_wdith				        [11:0]  ;
reg     [1:0]		    tx_invl_mode			        [11:0]  ;
reg     [15:0]		    tx_invl_hf_baud			        [11:0]  ;
reg     [15:0]		    tx_invl_clk_pd			        [11:0]  ;
reg     [15:0]		    tx_tff_usedw                    [11:0]  ;
reg 	[15:0]			tx_axi_wr_eff_len				[11:0]	;

wire    [23:0]          rx_chl_clr_req                          ;
wire    [11:0]          rx_chl_clr_done                         ;

wire    [23:0]          tx_chl_clr_req                          ;
wire    [11:0]          tx_chl_clr_done                         ;

wire    [11:0]          rx_driv_flag	                        ;
wire    [11:0]          tx_driv_flag	                        ;

reg                     r1_LITE_REG_RSYNC_REQ                   ;
reg                     r1_LITE_REG_TSYNC_REQ                   ;

wire [31:0] LR_TEST_FLAG	   [11:0]; 
wire [31:0] LR_TEST_ERR_INFO   [11:0];


/* _______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

      AW
   _______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________*/

//11:8 aw
assign {FULL_awid   [11], FULL_awid   [10], FULL_awid   [9 ], FULL_awid   [8 ]} = {s12_axi_awid   , s11_axi_awid   , s10_axi_awid   , s09_axi_awid   };
assign {FULL_awaddr [11], FULL_awaddr [10], FULL_awaddr [9 ], FULL_awaddr [8 ]} = {s12_axi_awaddr , s11_axi_awaddr , s10_axi_awaddr , s09_axi_awaddr };
assign {FULL_awlen  [11], FULL_awlen  [10], FULL_awlen  [9 ], FULL_awlen  [8 ]} = {s12_axi_awlen  , s11_axi_awlen  , s10_axi_awlen  , s09_axi_awlen  };
assign {FULL_awsize [11], FULL_awsize [10], FULL_awsize [9 ], FULL_awsize [8 ]} = {s12_axi_awsize , s11_axi_awsize , s10_axi_awsize , s09_axi_awsize };
assign {FULL_awburst[11], FULL_awburst[10], FULL_awburst[9 ], FULL_awburst[8 ]} = {s12_axi_awburst, s11_axi_awburst, s10_axi_awburst, s09_axi_awburst};
assign {FULL_awprot [11], FULL_awprot [10], FULL_awprot [9 ], FULL_awprot [8 ]} = {s12_axi_awprot , s11_axi_awprot , s10_axi_awprot , s09_axi_awprot };
assign FULL_awvalid[11:8]                                                       = {s12_axi_awvalid, s11_axi_awvalid, s10_axi_awvalid, s09_axi_awvalid};
assign FULL_awlock [11:8]                                                       = {s12_axi_awlock , s11_axi_awlock , s10_axi_awlock , s09_axi_awlock };
assign {FULL_awcache[11], FULL_awcache[10], FULL_awcache[9 ], FULL_awcache[8 ]} = {s12_axi_awcache, s11_axi_awcache, s10_axi_awcache, s09_axi_awcache}; 
assign {s12_axi_awready, s11_axi_awready, s10_axi_awready, s09_axi_awready}     = FULL_awready[11:8];

//7:0 aw
assign {FULL_awid   [7], FULL_awid   [6], FULL_awid   [5], FULL_awid   [4], FULL_awid   [3], FULL_awid   [2], FULL_awid   [1], FULL_awid   [0]} 		= {s08_axi_awid   , s07_axi_awid   , s06_axi_awid   , s05_axi_awid   , s04_axi_awid   , s03_axi_awid   , s02_axi_awid   , s01_axi_awid   };
assign {FULL_awaddr [7], FULL_awaddr [6], FULL_awaddr [5], FULL_awaddr [4], FULL_awaddr [3], FULL_awaddr [2], FULL_awaddr [1], FULL_awaddr [0]} 		= {s08_axi_awaddr , s07_axi_awaddr , s06_axi_awaddr , s05_axi_awaddr , s04_axi_awaddr , s03_axi_awaddr , s02_axi_awaddr , s01_axi_awaddr };
assign {FULL_awlen  [7], FULL_awlen  [6], FULL_awlen  [5], FULL_awlen  [4], FULL_awlen  [3], FULL_awlen  [2], FULL_awlen  [1], FULL_awlen  [0]} 		= {s08_axi_awlen  , s07_axi_awlen  , s06_axi_awlen  , s05_axi_awlen  , s04_axi_awlen  , s03_axi_awlen  , s02_axi_awlen  , s01_axi_awlen  };
assign {FULL_awsize [7], FULL_awsize [6], FULL_awsize [5], FULL_awsize [4], FULL_awsize [3], FULL_awsize [2], FULL_awsize [1], FULL_awsize [0]} 		= {s08_axi_awsize , s07_axi_awsize , s06_axi_awsize , s05_axi_awsize , s04_axi_awsize , s03_axi_awsize , s02_axi_awsize , s01_axi_awsize };
assign {FULL_awburst[7], FULL_awburst[6], FULL_awburst[5], FULL_awburst[4], FULL_awburst[3], FULL_awburst[2], FULL_awburst[1], FULL_awburst[0]} 		= {s08_axi_awburst, s07_axi_awburst, s06_axi_awburst, s05_axi_awburst, s04_axi_awburst, s03_axi_awburst, s02_axi_awburst, s01_axi_awburst};
assign {FULL_awprot [7], FULL_awprot [6], FULL_awprot [5], FULL_awprot [4], FULL_awprot [3], FULL_awprot [2], FULL_awprot [1], FULL_awprot [0]} 		= {s08_axi_awprot , s07_axi_awprot , s06_axi_awprot , s05_axi_awprot , s04_axi_awprot , s03_axi_awprot , s02_axi_awprot , s01_axi_awprot };
assign FULL_awvalid[7:0]																																= {s08_axi_awvalid, s07_axi_awvalid, s06_axi_awvalid, s05_axi_awvalid, s04_axi_awvalid, s03_axi_awvalid, s02_axi_awvalid, s01_axi_awvalid};
assign FULL_awlock[7:0]																																	= {s08_axi_awlock , s07_axi_awlock , s06_axi_awlock , s05_axi_awlock , s04_axi_awlock , s03_axi_awlock , s02_axi_awlock , s01_axi_awlock };
assign {FULL_awcache[7], FULL_awcache[6], FULL_awcache[5], FULL_awcache[4], FULL_awcache[3], FULL_awcache[2], FULL_awcache[1], FULL_awcache[0]} 		= {s08_axi_awcache, s07_axi_awcache, s06_axi_awcache, s05_axi_awcache, s04_axi_awcache, s03_axi_awcache, s02_axi_awcache, s01_axi_awcache}; 
assign {s08_axi_awready, s07_axi_awready, s06_axi_awready, s05_axi_awready, s04_axi_awready, s03_axi_awready, s02_axi_awready, s01_axi_awready}         = FULL_awready[7:0];
/* _______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

      W
   _______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________*/

//11:8 w
assign {FULL_wdata  [11], FULL_wdata  [10], FULL_wdata  [9], FULL_wdata  [8]}	= {s12_axi_wdata , s11_axi_wdata , s10_axi_wdata , s09_axi_wdata };
assign {FULL_wstrb  [11], FULL_wstrb  [10], FULL_wstrb  [9], FULL_wstrb  [8]}	= {s12_axi_wstrb , s11_axi_wstrb , s10_axi_wstrb , s09_axi_wstrb };
assign FULL_wlast [11:8]                                                        = {s12_axi_wlast , s11_axi_wlast , s10_axi_wlast , s09_axi_wlast };
assign FULL_wvalid[11:8]                                                        = {s12_axi_wvalid, s11_axi_wvalid, s10_axi_wvalid, s09_axi_wvalid};
assign {s12_axi_wready, s11_axi_wready, s10_axi_wready, s09_axi_wready}         = FULL_wready[11:8];

//7:0 w
assign {FULL_wdata  [7], FULL_wdata  [6], FULL_wdata  [5], FULL_wdata  [4], FULL_wdata  [3], FULL_wdata  [2], FULL_wdata  [1], FULL_wdata  [0]} 		= {s08_axi_wdata , s07_axi_wdata , s06_axi_wdata , s05_axi_wdata , s04_axi_wdata , s03_axi_wdata , s02_axi_wdata , s01_axi_wdata};
assign {FULL_wstrb  [7], FULL_wstrb  [6], FULL_wstrb  [5], FULL_wstrb  [4], FULL_wstrb  [3], FULL_wstrb  [2], FULL_wstrb  [1], FULL_wstrb  [0]} 		= {s08_axi_wstrb , s07_axi_wstrb , s06_axi_wstrb , s05_axi_wstrb , s04_axi_wstrb , s03_axi_wstrb , s02_axi_wstrb , s01_axi_wstrb};
assign FULL_wlast[7:0] 																																	= {s08_axi_wlast , s07_axi_wlast , s06_axi_wlast , s05_axi_wlast , s04_axi_wlast , s03_axi_wlast , s02_axi_wlast , s01_axi_wlast};
assign FULL_wvalid[7:0]																																	= {s08_axi_wvalid, s07_axi_wvalid, s06_axi_wvalid, s05_axi_wvalid, s04_axi_wvalid, s03_axi_wvalid, s02_axi_wvalid, s01_axi_wvalid};
assign {s08_axi_wready, s07_axi_wready, s06_axi_wready, s05_axi_wready, s04_axi_wready, s03_axi_wready, s02_axi_wready, s01_axi_wready}                 = FULL_wready[7:0];

/* _______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

      B
   _______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________*/

//11:8 b
assign {s12_axi_bid   , s11_axi_bid   , s10_axi_bid   , s09_axi_bid   }		= {FULL_bid    [11], FULL_bid    [10], FULL_bid    [9], FULL_bid    [8]} ;
assign {s12_axi_bresp , s11_axi_bresp , s10_axi_bresp , s09_axi_bresp }		= {FULL_bresp  [11], FULL_bresp  [10], FULL_bresp  [9], FULL_bresp  [8]} ;
assign {s12_axi_bvalid, s11_axi_bvalid, s10_axi_bvalid, s09_axi_bvalid}		= FULL_bvalid[11:8];
assign FULL_bready[11:8]                                                    = {s12_axi_bready, s11_axi_bready, s10_axi_bready, s09_axi_bready};

//7:0 b
assign {s08_axi_bid		, s07_axi_bid	, s06_axi_bid	, s05_axi_bid	, s04_axi_bid	, s03_axi_bid	, s02_axi_bid	, s01_axi_bid	}		= {FULL_bid    [7], FULL_bid    [6], FULL_bid    [5], FULL_bid    [4], FULL_bid    [3], FULL_bid    [2], FULL_bid    [1], FULL_bid    [0]} 	;
assign {s08_axi_bresp	, s07_axi_bresp	, s06_axi_bresp	, s05_axi_bresp	, s04_axi_bresp	, s03_axi_bresp	, s02_axi_bresp	, s01_axi_bresp	}		= {FULL_bresp  [7], FULL_bresp  [6], FULL_bresp  [5], FULL_bresp  [4], FULL_bresp  [3], FULL_bresp  [2], FULL_bresp  [1], FULL_bresp  [0]} 	;
assign {s08_axi_bvalid	, s07_axi_bvalid, s06_axi_bvalid, s05_axi_bvalid, s04_axi_bvalid, s03_axi_bvalid, s02_axi_bvalid, s01_axi_bvalid}		= FULL_bvalid[7:0];															;
assign FULL_bready[7:0]																															= {s08_axi_bready, s07_axi_bready	, s06_axi_bready	, s05_axi_bready, s04_axi_bready, s03_axi_bready	, s02_axi_bready	, s01_axi_bready	}		;

/* _______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

      AR
   _______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________*/

//11:8 ar
assign {FULL_arid   [11], FULL_arid   [10], FULL_arid   [9 ], FULL_arid   [8 ]} = {s12_axi_arid   , s11_axi_arid   , s10_axi_arid   , s09_axi_arid   };
assign {FULL_araddr [11], FULL_araddr [10], FULL_araddr [9 ], FULL_araddr [8 ]} = {s12_axi_araddr , s11_axi_araddr , s10_axi_araddr , s09_axi_araddr };
assign {FULL_arlen  [11], FULL_arlen  [10], FULL_arlen  [9 ], FULL_arlen  [8 ]} = {s12_axi_arlen  , s11_axi_arlen  , s10_axi_arlen  , s09_axi_arlen  };
assign {FULL_arsize [11], FULL_arsize [10], FULL_arsize [9 ], FULL_arsize [8 ]} = {s12_axi_arsize , s11_axi_arsize , s10_axi_arsize , s09_axi_arsize };
assign {FULL_arburst[11], FULL_arburst[10], FULL_arburst[9 ], FULL_arburst[8 ]} = {s12_axi_arburst, s11_axi_arburst, s10_axi_arburst, s09_axi_arburst};
assign {FULL_arprot [11], FULL_arprot [10], FULL_arprot [9 ], FULL_arprot [8 ]} = {s12_axi_arprot , s11_axi_arprot , s10_axi_arprot , s09_axi_arprot };
assign FULL_arvalid[11:8]                                                       = {s12_axi_arvalid, s11_axi_arvalid, s10_axi_arvalid, s09_axi_arvalid};
assign FULL_arlock [11:8]                                                       = {s12_axi_arlock , s11_axi_arlock , s10_axi_arlock , s09_axi_arlock };
assign {FULL_arcache[11], FULL_arcache[10], FULL_arcache[9 ], FULL_arcache[8 ]} = {s12_axi_arcache, s11_axi_arcache, s10_axi_arcache, s09_axi_arcache}; 
assign {s12_axi_arready, s11_axi_arready, s10_axi_arready, s09_axi_arready}     = FULL_arready[11:8];

//7:0 ar
assign {FULL_arid   [7], FULL_arid   [6], FULL_arid   [5], FULL_arid   [4], FULL_arid   [3], FULL_arid   [2], FULL_arid   [1], FULL_arid   [0]} = {s08_axi_arid   , s07_axi_arid   , s06_axi_arid   , s05_axi_arid   , s04_axi_arid   , s03_axi_arid   , s02_axi_arid   , s01_axi_arid   };
assign {FULL_araddr [7], FULL_araddr [6], FULL_araddr [5], FULL_araddr [4], FULL_araddr [3], FULL_araddr [2], FULL_araddr [1], FULL_araddr [0]} = {s08_axi_araddr , s07_axi_araddr , s06_axi_araddr , s05_axi_araddr , s04_axi_araddr , s03_axi_araddr , s02_axi_araddr , s01_axi_araddr };
assign {FULL_arlen  [7], FULL_arlen  [6], FULL_arlen  [5], FULL_arlen  [4], FULL_arlen  [3], FULL_arlen  [2], FULL_arlen  [1], FULL_arlen  [0]} = {s08_axi_arlen  , s07_axi_arlen  , s06_axi_arlen  , s05_axi_arlen  , s04_axi_arlen  , s03_axi_arlen  , s02_axi_arlen  , s01_axi_arlen  };
assign {FULL_arsize [7], FULL_arsize [6], FULL_arsize [5], FULL_arsize [4], FULL_arsize [3], FULL_arsize [2], FULL_arsize [1], FULL_arsize [0]} = {s08_axi_arsize , s07_axi_arsize , s06_axi_arsize , s05_axi_arsize , s04_axi_arsize , s03_axi_arsize , s02_axi_arsize , s01_axi_arsize };
assign {FULL_arburst[7], FULL_arburst[6], FULL_arburst[5], FULL_arburst[4], FULL_arburst[3], FULL_arburst[2], FULL_arburst[1], FULL_arburst[0]} = {s08_axi_arburst, s07_axi_arburst, s06_axi_arburst, s05_axi_arburst, s04_axi_arburst, s03_axi_arburst, s02_axi_arburst, s01_axi_arburst};
assign {FULL_arprot [7], FULL_arprot [6], FULL_arprot [5], FULL_arprot [4], FULL_arprot [3], FULL_arprot [2], FULL_arprot [1], FULL_arprot [0]} = {s08_axi_arprot , s07_axi_arprot , s06_axi_arprot , s05_axi_arprot , s04_axi_arprot , s03_axi_arprot , s02_axi_arprot , s01_axi_arprot };
assign FULL_arvalid[7:0]																														= {s08_axi_arvalid, s07_axi_arvalid, s06_axi_arvalid, s05_axi_arvalid, s04_axi_arvalid, s03_axi_arvalid, s02_axi_arvalid, s01_axi_arvalid};
assign FULL_arlock[7:0]																															= {s08_axi_arlock , s07_axi_arlock , s06_axi_arlock , s05_axi_arlock , s04_axi_arlock , s03_axi_arlock , s02_axi_arlock , s01_axi_arlock };
assign {FULL_arcache[7], FULL_arcache[6], FULL_arcache[5], FULL_arcache[4], FULL_arcache[3], FULL_arcache[2], FULL_arcache[1], FULL_arcache[0]} = {s08_axi_arcache, s07_axi_arcache, s06_axi_arcache, s05_axi_arcache, s04_axi_arcache, s03_axi_arcache, s02_axi_arcache, s01_axi_arcache}; 
assign {s08_axi_arready, s07_axi_arready, s06_axi_arready, s05_axi_arready, s04_axi_arready, s03_axi_arready, s02_axi_arready, s01_axi_arready} = FULL_arready[7:0];


/* _______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

      R
   _______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________*/

//11:8 r 
assign {s12_axi_rid   , s11_axi_rid   , s10_axi_rid   , s09_axi_rid   }	= {FULL_rid   [11], FULL_rid   [10], FULL_rid   [9], FULL_rid   [8]};
assign {s12_axi_rdata , s11_axi_rdata , s10_axi_rdata , s09_axi_rdata }	= {FULL_rdata [11], FULL_rdata [10], FULL_rdata [9], FULL_rdata [8]};
assign {s12_axi_rresp , s11_axi_rresp , s10_axi_rresp , s09_axi_rresp }	= {FULL_rresp [11], FULL_rresp [10], FULL_rresp [9], FULL_rresp [8]};
assign {s12_axi_rlast , s11_axi_rlast , s10_axi_rlast , s09_axi_rlast }	= FULL_rlast [11:8];
assign {s12_axi_rvalid, s11_axi_rvalid, s10_axi_rvalid, s09_axi_rvalid}	= FULL_rvalid[11:8];
assign FULL_rready[11:8]                                                = {s12_axi_rready, s11_axi_rready, s10_axi_rready, s09_axi_rready};

//7:0 r 
assign {s08_axi_rid		, s07_axi_rid	, s06_axi_rid	, s05_axi_rid	, s04_axi_rid	, s03_axi_rid	, s02_axi_rid	, s01_axi_rid	}	= {FULL_rid   [7], FULL_rid   [6], FULL_rid   [5], FULL_rid   [4], FULL_rid   [3], FULL_rid   [2], FULL_rid   [1], FULL_rid   [0]};
assign {s08_axi_rdata	, s07_axi_rdata	, s06_axi_rdata	, s05_axi_rdata	, s04_axi_rdata	, s03_axi_rdata	, s02_axi_rdata	, s01_axi_rdata	}	= {FULL_rdata [7], FULL_rdata [6], FULL_rdata [5], FULL_rdata [4], FULL_rdata [3], FULL_rdata [2], FULL_rdata [1], FULL_rdata [0]};
assign {s08_axi_rresp	, s07_axi_rresp	, s06_axi_rresp	, s05_axi_rresp	, s04_axi_rresp	, s03_axi_rresp	, s02_axi_rresp	, s01_axi_rresp	}	= {FULL_rresp [7], FULL_rresp [6], FULL_rresp [5], FULL_rresp [4], FULL_rresp [3], FULL_rresp [2], FULL_rresp [1], FULL_rresp [0]};
assign {s08_axi_rlast	, s07_axi_rlast	, s06_axi_rlast	, s05_axi_rlast	, s04_axi_rlast	, s03_axi_rlast	, s02_axi_rlast	, s01_axi_rlast	}	= FULL_rlast [7:0];
assign {s08_axi_rvalid	, s07_axi_rvalid	, s06_axi_rvalid	, s05_axi_rvalid	, s04_axi_rvalid , s03_axi_rvalid	, s02_axi_rvalid	, s01_axi_rvalid	}	= FULL_rvalid[7:0];
assign FULL_rready[7:0]																														= {s08_axi_rready, s07_axi_rready, s06_axi_rready	, s05_axi_rready, s04_axi_rready, s03_axi_rready	, s02_axi_rready	, s01_axi_rready	};

always @(posedge clk, posedge rst) begin
    if(rst) begin
        r1_LITE_REG_RSYNC_REQ <= 'd0;
        r1_LITE_REG_TSYNC_REQ <= 'd0;
        sys_axi_rd_len        <= 'd0;
		sys_axi_wr_max_len    <= 'd0;
    end
    else begin
        r1_LITE_REG_RSYNC_REQ <= LITE_REG_RSYNC_REQ;
        r1_LITE_REG_TSYNC_REQ <= LITE_REG_TSYNC_REQ;
        sys_axi_rd_len        <= LITE_REG_AXI_RD_LEN;
		sys_axi_wr_max_len    <= LITE_REG_AXI_WR_MAX_LEN;
    end
end

generate for (i = 0; i < 12; i=i+1) begin : GF_CHL

always @(posedge clk, posedge rst) begin
    if(rst) begin
        rx_cfg_req		    [i] <= 'd0;
        rx_cfg_done		    [i] <= 'd0;
        rx_baud_rate	    [i] <= 'd0;
        rx_stop_bit		    [i] <= 'd0;
        rx_p_chk		    [i] <= 'd0;
        rx_d_width		    [i] <= 'd0;
        rx_stop_pchk_ena    [i] <= 'd0;
        rx_fsm_rst_req	    [i] <= 'd0;
        rx_fsm_rst_done	    [i] <= 'd0;
        rx_axi_brust_len    [i] <= 'd0;

        rx_stop_bit_err_cnt	[i] <= 'd0;
        rx_pchk_err_cnt	    [i] <= 'd0;
        rx_rff_usedw	    [i] <= 'd0;
        rx_timeout_thrd     [i] <= 'd0;
        //
        tx_cfg_req		    [i] <= 'd0;
        tx_cfg_done		    [i] <= 'd0;
        tx_baud_rate	    [i] <= 'd0;
        tx_stop_bit		    [i] <= 'd0;
        tx_p_chk		    [i] <= 'd0;
        tx_d_wdith		    [i] <= 'd0;
        tx_invl_mode	    [i] <= 'd0;
        tx_invl_hf_baud	    [i] <= 'd0;
        tx_invl_clk_pd	    [i] <= 'd0;
		tx_axi_wr_eff_len 	[i] <= 'd0;
    end 
    else begin  
        rx_cfg_req		    [i] <= (LITE_REG_RSYNC_REQ == 1'd1) ? LITE_REG_RSYNC_REQ			: LITE_REG_RX_CFG_REQ			[i];
        rx_baud_rate	    [i] <= (LITE_REG_RSYNC_REQ == 1'd1) ? LITE_REG_RSYNC_BAUD_RATE		: LITE_REG_RX_BAUD_RATE			[i];
        rx_stop_bit		    [i] <= (LITE_REG_RSYNC_REQ == 1'd1) ? LITE_REG_RSYNC_STOP_BIT		: LITE_REG_RX_STOP_BIT			[i];
        rx_p_chk		    [i] <= (LITE_REG_RSYNC_REQ == 1'd1) ? LITE_REG_RSYNC_P_CHK			: LITE_REG_RX_P_CHK			    [i];
        rx_d_width		    [i] <= (LITE_REG_RSYNC_REQ == 1'd1) ? LITE_REG_RSYNC_D_WIDTH		: LITE_REG_RX_D_WIDTH			[i];
        rx_stop_pchk_ena    [i] <= (LITE_REG_RSYNC_REQ == 1'd1) ? LITE_REG_RSYNC_STOP_PCHK_ENA	: LITE_REG_RX_STOP_PCHK_ENA		[i];
        rx_fsm_rst_req	    [i] <= (LITE_REG_RSYNC_REQ == 1'd1) ? LITE_REG_RSYNC_FSM_RST_REQ	: LITE_REG_RX_FSM_RST_REQ		[i];
        rx_axi_brust_len    [i] <= (LITE_REG_RSYNC_REQ == 1'd1) ? LITE_REG_RSYNC_AXI_BRUST_LEN	: LITE_REG_RX_AXI_BRUST_LEN		[i];

        rx_cfg_done		    [i] <= LITE_REG_RX_CFG_DONE			[i];
        rx_fsm_rst_done	    [i] <= LITE_REG_RX_FSM_RST_DONE		[i];
        rx_stop_bit_err_cnt	[i] <= LITE_REG_RX_STOP_BIT_ERR_CNT	[i];
        rx_pchk_err_cnt	    [i] <= LITE_REG_RX_PCHK_ERR_CNT		[i];
        rx_rff_usedw	    [i] <= LITE_REG_RX_RFF_USEDW        [i];
        rx_timeout_thrd     [i] <= LITE_REG_RX_TIMEOUT_THRD     [i];
        //  
        tx_cfg_req		    [i] <= (LITE_REG_TSYNC_REQ == 1'd1) ? LITE_REG_TSYNC_REQ			: LITE_REG_TX_CFG_REQ			[i];
        tx_baud_rate	    [i] <= (LITE_REG_TSYNC_REQ == 1'd1) ? LITE_REG_TSYNC_BAUD_RATE		: LITE_REG_TX_BAUD_RATE			[i];
        tx_stop_bit		    [i] <= (LITE_REG_TSYNC_REQ == 1'd1) ? LITE_REG_TSYNC_STOP_BIT		: LITE_REG_TX_STOP_BIT			[i];
        tx_p_chk		    [i] <= (LITE_REG_TSYNC_REQ == 1'd1) ? LITE_REG_TSYNC_P_CHK			: LITE_REG_TX_P_CHK				[i];
        tx_d_wdith		    [i] <= (LITE_REG_TSYNC_REQ == 1'd1) ? LITE_REG_TSYNC_D_WIDTH		: LITE_REG_TX_D_WDITH			[i];
        tx_invl_mode	    [i] <= (LITE_REG_TSYNC_REQ == 1'd1) ? LITE_REG_TSYNC_INVL_MODE		: LITE_REG_TX_INVL_MODE			[i];
        tx_invl_hf_baud	    [i] <= (LITE_REG_TSYNC_REQ == 1'd1) ? LITE_REG_TSYNC_INVL_HF_BAUD	: LITE_REG_TX_INVL_HF_BAUD		[i];
        tx_invl_clk_pd	    [i] <= (LITE_REG_TSYNC_REQ == 1'd1) ? LITE_REG_TSYNC_INVL_CLK_PD	: LITE_REG_TX_INVL_CLK_PD		[i];
        
        tx_cfg_done		    [i] <= LITE_REG_TX_CFG_DONE  [i];
        tx_tff_usedw        [i] <= LITE_REG_TX_TFF_USEDW [i];
		
		tx_axi_wr_eff_len 	[i] <= LITE_REG_TX_AXI_WR_EFF_LEN[i];
    end
end



uart_f2ser_read UART_R(
    .clk                 	    			(	clk                 	    			),
    .rst                 	    			(	rst                 	    			),	
`ifdef TEST
	.rx_driv_flag							(   test_rx_flag[i]                         ),
`else
    .rx_driv_flag							(	rx_driv_flag[i]							),
`endif
    .is_start_bit							(	is_start_bit[i]							),
	.got_whole_brust_pkt					(	got_whole_brust_pkt[i]					),
    
    .LR_AXI_RD_LEN                          (   sys_axi_rd_len                          ),
    .LR_CFG_REQ			                    (   rx_cfg_req		                [i]     ),
    .LR_STOP_BIT		                    (   rx_stop_bit		                [i]     ),
    .LR_P_CHK			                    (   rx_p_chk		                [i]     ),
    .LR_D_WIDTH		                        (   rx_d_width		                [i]     ),
    .LR_STOP_PCHK_ENA	                    (   rx_stop_pchk_ena                [i]     ),
    .LR_FSM_RST_REQ	                        (   rx_fsm_rst_req	                [i]     ),
    .LR_AXI_BRUST_LEN	                    (   rx_axi_brust_len                [i]     ),
    .LR_TIMEOUT_THRD                        (   rx_timeout_thrd                 [i]     ),
    //
    .LR_CFG_DONE			                (   LITE_REG_RX_CFG_DONE	        [i]     ),
    .LR_FSM_RST_DONE	                    (   LITE_REG_RX_FSM_RST_DONE        [i]     ),
    .LR_STOP_BIT_ERR_CNT	                (   LITE_REG_RX_STOP_BIT_ERR_CNT	[i]     ),
    .LR_PCHK_ERR_CNT		                (   LITE_REG_RX_PCHK_ERR_CNT		[i]     ),
    .LR_RFF_USEDW                           (   LITE_REG_RX_RFF_USEDW           [i]     ),

	.chl_clr_req							(   rx_chl_clr_req					[i*2+:2]),// from uart_driv_flag_gen module
	.chl_clr_done							(   rx_chl_clr_done					[i]	    ),

	//axi-full-----------------------------------------------------------		
    .s_axi_arid                          	(	FULL_arid     	[i]						),
    .s_axi_araddr                        	(	FULL_araddr   	[i]						),
    .s_axi_arlen                         	(	FULL_arlen    	[i]						),
    .s_axi_arsize                        	(	FULL_arsize   	[i]						),
    .s_axi_arburst                       	(	FULL_arburst  	[i]						),
    .s_axi_arprot                        	(	FULL_arprot   	[i]						),
    .s_axi_arvalid                       	(	FULL_arvalid  	[i]						),
    .s_axi_arlock                        	(	FULL_arlock   	[i]						),
    .s_axi_arcache                       	(	FULL_arcache  	[i]						),
    .s_axi_arready                       	(	FULL_arready  	[i]						),
					
    .s_axi_rid                           	(	FULL_rid      	[i]						),
    .s_axi_rdata                         	(	FULL_rdata    	[i]						),
    .s_axi_rresp                         	(	FULL_rresp    	[i]						),
    .s_axi_rlast                         	(	FULL_rlast    	[i]						),
    .s_axi_rvalid                        	(	FULL_rvalid   	[i]						),
    .s_axi_rready                        	(	FULL_rready   	[i]						),
	//					
	.UART_RX								(	UART_RX			[i]						) //
);



uart_f2ser_write #(
	.BASE_ADDR(W_BASE_ADDR[64*i+:64])
) UART_W(
    .clk                 					(	clk                 					),
    .rst                 					(	rst                 					),
`ifdef TEST
	.tx_driv_flag							(   test_tx_flag[i]                         ),
`else
	.tx_driv_flag							(	tx_driv_flag[i]							),
`endif
    .LR_CFG_REQ		                        (   tx_cfg_req		        [i]             ),
    .LR_STOP_BIT	                        (   tx_stop_bit             [i]             ),		
    .LR_P_CHK		                        (   tx_p_chk		        [i]             ),		
    .LR_D_WDITH		                        (   tx_d_wdith		        [i]             ),	
    .LR_INVL_MODE	                        (   tx_invl_mode	        [i]             ),		
    .LR_INVL_HF_BAUD                        (   tx_invl_hf_baud         [i]             ),		
    .LR_INVL_CLK_PD	                        (   tx_invl_clk_pd	        [i]             ),
	.LR_AXI_WR_MAX_LEN						(	sys_axi_wr_max_len 						),
	.LR_AXI_WR_EFF_LEN						(	tx_axi_wr_eff_len 		[i]				),
    //          
    .LR_CFG_DONE		                    (   LITE_REG_TX_CFG_DONE    [i]             ),	
    .LR_TFF_USEDW                           (   LITE_REG_TX_TFF_USEDW   [i]             ),
	
	/*test*/
	.LR_TEST_FLAG	 (LR_TEST_FLAG	  [i]),
	.LR_TEST_ERR_INFO(LR_TEST_ERR_INFO[i]),
	

	.chl_clr_req							(   tx_chl_clr_req			[i*2+:2]        ),
	.chl_clr_done							(   tx_chl_clr_done			[i]				),
	//axi-full-----------------------------------------------------------
    .s_axi_awid                          	(	FULL_awid     	[i]					),
    .s_axi_awaddr                        	(	FULL_awaddr   	[i]					),
    .s_axi_awlen                         	(	FULL_awlen    	[i]					),
    .s_axi_awsize                        	(	FULL_awsize   	[i]					),
    .s_axi_awburst                       	(	FULL_awburst  	[i]					),
    .s_axi_awprot                        	(	FULL_awprot   	[i]					),
    .s_axi_awvalid                       	(	FULL_awvalid  	[i]					),
    .s_axi_awlock                        	(	FULL_awlock   	[i]					),
    .s_axi_awcache                       	(	FULL_awcache  	[i]					),
    .s_axi_awready                       	(	FULL_awready  	[i]					),
				
    .s_axi_wdata                         	(	FULL_wdata    	[i]					),
    .s_axi_wstrb                         	(	FULL_wstrb    	[i]					),
    .s_axi_wlast                         	(	FULL_wlast    	[i]					),
    .s_axi_wvalid                        	(	FULL_wvalid   	[i]					),
    .s_axi_wready                        	(	FULL_wready   	[i]					),
				
    .s_axi_bid                           	(	FULL_bid      	[i]					),
    .s_axi_bresp                         	(	FULL_bresp    	[i]					),
    .s_axi_bvalid                        	(	FULL_bvalid   	[i]					),
    .s_axi_bready                        	(	FULL_bready   	[i]					),
	//				
	.UART_TX								(	UART_TX			[i]						) //
);

`ifdef TEST
test_flag TT(

    .clk            (   clk     ),
    .rst            (   rst     ),
    //
    .is_start_bit   (  is_start_bit[i]  ),
    .test_tx_flag   (  test_tx_flag[i]  ),
    .test_rx_flag   (  test_rx_flag[i]  )  
    );

`else 
`endif

end endgenerate 

uart_driv_flag_gen FLAG (
    .clk                    (   clk                                 ),
    .rst                    (   rst                                 ),

    .LR_BAUD0	            (   rx_baud_rate[0]                     ),
    .LR_BAUD1	            (   rx_baud_rate[1]                     ),
    .LR_BAUD2	            (   rx_baud_rate[2]                     ),
    .LR_BAUD3	            (   rx_baud_rate[3]                     ),
    .LR_BAUD4	            (   rx_baud_rate[4]                     ),
    .LR_BAUD5	            (   rx_baud_rate[5]                     ),
    .LR_BAUD6	            (   rx_baud_rate[6]                     ),
    .LR_BAUD7	            (   rx_baud_rate[7]                     ),
    .LR_BAUD8	            (   rx_baud_rate[8]                     ),
    .LR_BAUD9	            (   rx_baud_rate[9]                     ),
    .LR_BAUD10	            (   rx_baud_rate[10]                    ),
    .LR_BAUD11	            (   rx_baud_rate[11]                    ),
    .LR_BAUD12	            (   tx_baud_rate[0]                     ),
    .LR_BAUD13	            (   tx_baud_rate[1]                     ),
    .LR_BAUD14	            (   tx_baud_rate[2]                     ),
    .LR_BAUD15	            (   tx_baud_rate[3]                     ),
    .LR_BAUD16	            (   tx_baud_rate[4]                     ),
    .LR_BAUD17	            (   tx_baud_rate[5]                     ),
    .LR_BAUD18	            (   tx_baud_rate[6]                     ),
    .LR_BAUD19	            (   tx_baud_rate[7]                     ),
    .LR_BAUD20	            (   tx_baud_rate[8]                     ),
    .LR_BAUD21	            (   tx_baud_rate[9]                     ),
    .LR_BAUD22	            (   tx_baud_rate[10]                    ),
    .LR_BAUD23	            (   tx_baud_rate[11]                    ),
    .LR_BAUD_VLD            (   {tx_cfg_req, rx_cfg_req}            ),
    .is_baud_sync           (   {r1_LITE_REG_TSYNC_REQ, r1_LITE_REG_RSYNC_REQ}  ),

    .is_start_bit           (	{12'd0, is_start_bit}               ),
    .chl_clr_req            (   {tx_chl_clr_req , rx_chl_clr_req }  ),
    .chl_clr_done           (   {tx_chl_clr_done, rx_chl_clr_done}  ),
    .uart_driv_flag         (   {tx_driv_flag   , rx_driv_flag   }  )//
);

xdma_bar_ctrl #(
	.LITE_BASE_ADDR(`LITE_BASE_ADDR)
) XDMA_BAR(

    .clk				                (   clk	                                ),	
    .rst				                (   rst	                                ),	

    .lite_awaddr		                (   s_axi_lite_awaddr 	                ),	
    .lite_awprot		                (   s_axi_lite_awprot 	                ),	
    .lite_awready		                (   s_axi_lite_awready	                ),	
    .lite_awvalid		                (   s_axi_lite_awvalid	                ),	

    .lite_wdata			                (   s_axi_lite_wdata  	                ),	
    .lite_wready		                (   s_axi_lite_wready 	                ),	
    .lite_wstrb			                (   s_axi_lite_wstrb	                ),	
    .lite_wvalid		                (   s_axi_lite_wvalid 	                ),	

    .lite_bready		                (   s_axi_lite_bready 	                ),	
    .lite_bresp 		                (   s_axi_lite_bresp  	                ),	
    .lite_bvalid		                (   s_axi_lite_bvalid 	                ),	

    .lite_araddr 		                (   s_axi_lite_araddr 	                ),	
    .lite_arprot 		                (   s_axi_lite_arprot 	                ),	
    .lite_arready		                (   s_axi_lite_arready	                ),	
    .lite_arvalid		                (   s_axi_lite_arvalid	                ),	

    .lite_rdata 		                (   s_axi_lite_rdata                    ),	
    .lite_rready		                (   s_axi_lite_rready 	                ),	
    .lite_rresp 		                (   s_axi_lite_rresp                    ),	
    .lite_rvalid		                (   s_axi_lite_rvalid                   ),	

	.interupt_req		                (   interupt_req                        ),
    .interupt_ack                       (   interupt_ack                        ),
    .got_whole_brust_pkt                (   got_whole_brust_pkt                 ),
    //                      
    .LOGIC_VERSION    		            (   LOGIC_VERSION    		            ),
	.LOGIC_SUB_VERSION		            (   LOGIC_SUB_VERSION		            ),
    //
    .LITE_REG_AXI_RD_LEN                (   LITE_REG_AXI_RD_LEN                 ),
	.LITE_REG_AXI_WR_MAX_LEN			(	LITE_REG_AXI_WR_MAX_LEN				),
    //
	.LITE_REG_RSYNC_REQ				    (   LITE_REG_RSYNC_REQ                  ),
	.LITE_REG_RSYNC_BAUD_RATE		    (   LITE_REG_RSYNC_BAUD_RATE            ),
	.LITE_REG_RSYNC_STOP_BIT		    (   LITE_REG_RSYNC_STOP_BIT             ),
	.LITE_REG_RSYNC_P_CHK			    (   LITE_REG_RSYNC_P_CHK                ),
	.LITE_REG_RSYNC_D_WIDTH			    (   LITE_REG_RSYNC_D_WIDTH              ),
	.LITE_REG_RSYNC_STOP_PCHK_ENA	    (   LITE_REG_RSYNC_STOP_PCHK_ENA        ),
	.LITE_REG_RSYNC_FSM_RST_REQ		    (   LITE_REG_RSYNC_FSM_RST_REQ          ),
	.LITE_REG_RSYNC_AXI_BRUST_LEN	    (   LITE_REG_RSYNC_AXI_BRUST_LEN        ),

    .LITE_REG_TSYNC_REQ				    (   LITE_REG_TSYNC_REQ				    ),
	.LITE_REG_TSYNC_BAUD_RATE		    (   LITE_REG_TSYNC_BAUD_RATE		    ),
	.LITE_REG_TSYNC_STOP_BIT		    (   LITE_REG_TSYNC_STOP_BIT		        ),
	.LITE_REG_TSYNC_P_CHK			    (   LITE_REG_TSYNC_P_CHK			    ),
	.LITE_REG_TSYNC_D_WIDTH			    (   LITE_REG_TSYNC_D_WIDTH			    ),
	.LITE_REG_TSYNC_INVL_MODE		    (   LITE_REG_TSYNC_INVL_MODE		    ),
	.LITE_REG_TSYNC_INVL_HF_BAUD	    (   LITE_REG_TSYNC_INVL_HF_BAUD	        ),
	.LITE_REG_TSYNC_INVL_CLK_PD		    (   LITE_REG_TSYNC_INVL_CLK_PD		    ),

    .LITE_REG_R1_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			     [0]),
	.LITE_REG_R1_CFG_DONE			    (   rx_cfg_done         			 [0]),
	.LITE_REG_R1_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			 [0]),
	.LITE_REG_R1_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			 [0]),
	.LITE_REG_R1_P_CHK				    (   LITE_REG_RX_P_CHK				 [0]),
	.LITE_REG_R1_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			     [0]),
	.LITE_REG_R1_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		 [0]),
	.LITE_REG_R1_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt              [0]),
	.LITE_REG_R1_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                  [0]),
	.LITE_REG_R1_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		     [0]),
	.LITE_REG_R1_FSM_RST_DONE		    (   rx_fsm_rst_done     		     [0]),
	.LITE_REG_R1_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		 [0]),
	.LITE_REG_R1_RFF_USEDW			    (   rx_rff_usedw        			 [0]),
    .LITE_REG_R1_TIMEOUT_THRD           (   LITE_REG_RX_TIMEOUT_THRD         [0]),

    .LITE_REG_R2_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			     [1]),
	.LITE_REG_R2_CFG_DONE			    (   rx_cfg_done         			 [1]),
	.LITE_REG_R2_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			 [1]),
	.LITE_REG_R2_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			 [1]),
	.LITE_REG_R2_P_CHK				    (   LITE_REG_RX_P_CHK				 [1]),
	.LITE_REG_R2_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			     [1]),
	.LITE_REG_R2_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		 [1]),
	.LITE_REG_R2_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt              [1]),
	.LITE_REG_R2_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                  [1]),
	.LITE_REG_R2_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		     [1]),
	.LITE_REG_R2_FSM_RST_DONE		    (   rx_fsm_rst_done         		 [1]),
	.LITE_REG_R2_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		 [1]),
	.LITE_REG_R2_RFF_USEDW			    (   rx_rff_usedw        			 [1]),
    .LITE_REG_R2_TIMEOUT_THRD           (   LITE_REG_RX_TIMEOUT_THRD         [1]),

    .LITE_REG_R3_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			     [2]),
	.LITE_REG_R3_CFG_DONE			    (   rx_cfg_done         			 [2]),
	.LITE_REG_R3_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			 [2]),
	.LITE_REG_R3_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			 [2]),
	.LITE_REG_R3_P_CHK				    (   LITE_REG_RX_P_CHK				 [2]),
	.LITE_REG_R3_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			     [2]),
	.LITE_REG_R3_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		 [2]),
	.LITE_REG_R3_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt              [2]),
	.LITE_REG_R3_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                  [2]),
	.LITE_REG_R3_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		     [2]),
	.LITE_REG_R3_FSM_RST_DONE		    (   rx_fsm_rst_done         		 [2]),
	.LITE_REG_R3_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		 [2]),
	.LITE_REG_R3_RFF_USEDW			    (   rx_rff_usedw        			 [2]),
    .LITE_REG_R3_TIMEOUT_THRD           (   LITE_REG_RX_TIMEOUT_THRD         [2]),

    .LITE_REG_R4_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			     [3]),
	.LITE_REG_R4_CFG_DONE			    (   rx_cfg_done         			 [3]),
	.LITE_REG_R4_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			 [3]),
	.LITE_REG_R4_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			 [3]),
	.LITE_REG_R4_P_CHK				    (   LITE_REG_RX_P_CHK				 [3]),
	.LITE_REG_R4_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			     [3]),
	.LITE_REG_R4_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		 [3]),
	.LITE_REG_R4_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt              [3]),
	.LITE_REG_R4_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                  [3]),
	.LITE_REG_R4_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		     [3]),
	.LITE_REG_R4_FSM_RST_DONE		    (   rx_fsm_rst_done         		 [3]),
	.LITE_REG_R4_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		 [3]),
	.LITE_REG_R4_RFF_USEDW			    (   rx_rff_usedw        			 [3]),
    .LITE_REG_R4_TIMEOUT_THRD           (   LITE_REG_RX_TIMEOUT_THRD         [3]),

    .LITE_REG_R5_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			     [4]),
	.LITE_REG_R5_CFG_DONE			    (   rx_cfg_done         			 [4]),
	.LITE_REG_R5_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			 [4]),
	.LITE_REG_R5_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			 [4]),
	.LITE_REG_R5_P_CHK				    (   LITE_REG_RX_P_CHK				 [4]),
	.LITE_REG_R5_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			     [4]),
	.LITE_REG_R5_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		 [4]),
	.LITE_REG_R5_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt              [4]),
	.LITE_REG_R5_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                  [4]),
	.LITE_REG_R5_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		     [4]),
	.LITE_REG_R5_FSM_RST_DONE		    (   rx_fsm_rst_done         		 [4]),
	.LITE_REG_R5_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		 [4]),
	.LITE_REG_R5_RFF_USEDW			    (   rx_rff_usedw        			 [4]),
    .LITE_REG_R5_TIMEOUT_THRD           (   LITE_REG_RX_TIMEOUT_THRD         [4]),

    .LITE_REG_R6_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			     [5]),
	.LITE_REG_R6_CFG_DONE			    (   rx_cfg_done         			 [5]),
	.LITE_REG_R6_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			 [5]),
	.LITE_REG_R6_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			 [5]),
	.LITE_REG_R6_P_CHK				    (   LITE_REG_RX_P_CHK				 [5]),
	.LITE_REG_R6_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			     [5]),
	.LITE_REG_R6_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		 [5]),
	.LITE_REG_R6_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt              [5]),
	.LITE_REG_R6_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                  [5]),
	.LITE_REG_R6_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		     [5]),
	.LITE_REG_R6_FSM_RST_DONE		    (   rx_fsm_rst_done         		 [5]),
	.LITE_REG_R6_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		 [5]),
	.LITE_REG_R6_RFF_USEDW			    (   rx_rff_usedw        			 [5]),
    .LITE_REG_R6_TIMEOUT_THRD           (   LITE_REG_RX_TIMEOUT_THRD         [5]),

    .LITE_REG_R7_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			     [6]),
	.LITE_REG_R7_CFG_DONE			    (   rx_cfg_done         			 [6]),
	.LITE_REG_R7_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			 [6]),
	.LITE_REG_R7_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			 [6]),
	.LITE_REG_R7_P_CHK				    (   LITE_REG_RX_P_CHK				 [6]),
	.LITE_REG_R7_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			     [6]),
	.LITE_REG_R7_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		 [6]),
	.LITE_REG_R7_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt              [6]),
	.LITE_REG_R7_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                  [6]),
	.LITE_REG_R7_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		     [6]),
	.LITE_REG_R7_FSM_RST_DONE		    (   rx_fsm_rst_done         		 [6]),
	.LITE_REG_R7_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		 [6]),
	.LITE_REG_R7_RFF_USEDW			    (   rx_rff_usedw        			 [6]),
    .LITE_REG_R7_TIMEOUT_THRD           (   LITE_REG_RX_TIMEOUT_THRD         [6]),

    .LITE_REG_R8_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			     [7]),
	.LITE_REG_R8_CFG_DONE			    (   rx_cfg_done         			 [7]),
	.LITE_REG_R8_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			 [7]),
	.LITE_REG_R8_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			 [7]),
	.LITE_REG_R8_P_CHK				    (   LITE_REG_RX_P_CHK				 [7]),
	.LITE_REG_R8_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			     [7]),
	.LITE_REG_R8_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		 [7]),
	.LITE_REG_R8_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt              [7]),
	.LITE_REG_R8_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                  [7]),
	.LITE_REG_R8_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		     [7]),
	.LITE_REG_R8_FSM_RST_DONE		    (   rx_fsm_rst_done         		 [7]),
	.LITE_REG_R8_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		 [7]),
	.LITE_REG_R8_RFF_USEDW			    (   rx_rff_usedw        			 [7]),
    .LITE_REG_R8_TIMEOUT_THRD           (   LITE_REG_RX_TIMEOUT_THRD         [7]),

    .LITE_REG_R9_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			     [8]),
	.LITE_REG_R9_CFG_DONE			    (   rx_cfg_done         			 [8]),
	.LITE_REG_R9_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			 [8]),
	.LITE_REG_R9_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			 [8]),
	.LITE_REG_R9_P_CHK				    (   LITE_REG_RX_P_CHK				 [8]),
	.LITE_REG_R9_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			     [8]),
	.LITE_REG_R9_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		 [8]),
	.LITE_REG_R9_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt              [8]),
	.LITE_REG_R9_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                  [8]),
	.LITE_REG_R9_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		     [8]),
	.LITE_REG_R9_FSM_RST_DONE		    (   rx_fsm_rst_done         		 [8]),
	.LITE_REG_R9_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		 [8]),
	.LITE_REG_R9_RFF_USEDW			    (   rx_rff_usedw        			 [8]),
    .LITE_REG_R9_TIMEOUT_THRD           (   LITE_REG_RX_TIMEOUT_THRD         [8]),

    .LITE_REG_R10_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			     [9]),
	.LITE_REG_R10_CFG_DONE			    (   rx_cfg_done         			 [9]),
	.LITE_REG_R10_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			 [9]),
	.LITE_REG_R10_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			 [9]),
	.LITE_REG_R10_P_CHK				    (   LITE_REG_RX_P_CHK				 [9]),
	.LITE_REG_R10_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			     [9]),
	.LITE_REG_R10_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		 [9]),
	.LITE_REG_R10_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt              [9]),
	.LITE_REG_R10_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                  [9]),
	.LITE_REG_R10_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		     [9]),
	.LITE_REG_R10_FSM_RST_DONE		    (   rx_fsm_rst_done         		 [9]),
	.LITE_REG_R10_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		 [9]),
	.LITE_REG_R10_RFF_USEDW			    (   rx_rff_usedw        			 [9]),
    .LITE_REG_R10_TIMEOUT_THRD          (   LITE_REG_RX_TIMEOUT_THRD         [9]),

    .LITE_REG_R11_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			    [10]),
	.LITE_REG_R11_CFG_DONE			    (   rx_cfg_done         			[10]),
	.LITE_REG_R11_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			[10]),
	.LITE_REG_R11_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			[10]),
	.LITE_REG_R11_P_CHK				    (   LITE_REG_RX_P_CHK				[10]),
	.LITE_REG_R11_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			    [10]),
	.LITE_REG_R11_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA		[10]),
	.LITE_REG_R11_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt             [10]),
	.LITE_REG_R11_PCHK_ERR_CNT		    (   rx_pchk_err_cnt                 [10]),
	.LITE_REG_R11_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		    [10]),
	.LITE_REG_R11_FSM_RST_DONE		    (   rx_fsm_rst_done         		[10]),
	.LITE_REG_R11_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		[10]),
	.LITE_REG_R11_RFF_USEDW			    (   rx_rff_usedw        			[10]),
    .LITE_REG_R11_TIMEOUT_THRD          (   LITE_REG_RX_TIMEOUT_THRD        [10]),

    .LITE_REG_R12_CFG_REQ			    (   LITE_REG_RX_CFG_REQ			    [11]),
	.LITE_REG_R12_CFG_DONE			    (   rx_cfg_done         			[11]),
	.LITE_REG_R12_BAUD_RATE			    (   LITE_REG_RX_BAUD_RATE			[11]),
	.LITE_REG_R12_STOP_BIT			    (   LITE_REG_RX_STOP_BIT			[11]),
	.LITE_REG_R12_P_CHK				    (   LITE_REG_RX_P_CHK				[11]),
	.LITE_REG_R12_D_WIDTH			    (   LITE_REG_RX_D_WIDTH			    [11]),
	.LITE_REG_R12_STOP_PCHK_ENA		    (   LITE_REG_RX_STOP_PCHK_ENA       [11]),
	.LITE_REG_R12_STOP_BIT_ERR_CNT	    (   rx_stop_bit_err_cnt             [11]),
	.LITE_REG_R12_PCHK_ERR_CNT		    (   rx_pchk_err_cnt          		[11]),
	.LITE_REG_R12_FSM_RST_REQ		    (   LITE_REG_RX_FSM_RST_REQ		    [11]),
	.LITE_REG_R12_FSM_RST_DONE		    (   rx_fsm_rst_done         		[11]),
	.LITE_REG_R12_AXI_BRUST_LEN		    (   LITE_REG_RX_AXI_BRUST_LEN		[11]),
	.LITE_REG_R12_RFF_USEDW			    (   rx_rff_usedw        			[11]),
    .LITE_REG_R12_TIMEOUT_THRD          (   LITE_REG_RX_TIMEOUT_THRD        [11]),

    .LITE_REG_T1_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			     [0]),
	.LITE_REG_T1_CFG_DONE			    (   tx_cfg_done         			 [0]),
	.LITE_REG_T1_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			 [0]),
	.LITE_REG_T1_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			 [0]),
	.LITE_REG_T1_P_CHK				    (   LITE_REG_TX_P_CHK				 [0]),
	.LITE_REG_T1_D_WDITH			    (   LITE_REG_TX_D_WDITH			     [0]),
	.LITE_REG_T1_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			 [0]),
	.LITE_REG_T1_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		 [0]),
	.LITE_REG_T1_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		     [0]),
	.LITE_REG_T1_TFF_USEDW			    (   tx_tff_usedw        			 [0]),
	.LITE_REG_T1_AXI_WR_EFF_LEN			(	LITE_REG_TX_AXI_WR_EFF_LEN		 [0]),

    .LITE_REG_T2_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			     [1]),
	.LITE_REG_T2_CFG_DONE			    (   tx_cfg_done         			 [1]),
	.LITE_REG_T2_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			 [1]),
	.LITE_REG_T2_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			 [1]),
	.LITE_REG_T2_P_CHK				    (   LITE_REG_TX_P_CHK				 [1]),
	.LITE_REG_T2_D_WDITH			    (   LITE_REG_TX_D_WDITH			     [1]),
	.LITE_REG_T2_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			 [1]),
	.LITE_REG_T2_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		 [1]),
	.LITE_REG_T2_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		     [1]),
	.LITE_REG_T2_TFF_USEDW			    (   tx_tff_usedw        			 [1]),
	.LITE_REG_T2_AXI_WR_EFF_LEN			(	LITE_REG_TX_AXI_WR_EFF_LEN		 [1]),

    .LITE_REG_T3_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			     [2]),
	.LITE_REG_T3_CFG_DONE			    (   tx_cfg_done         			 [2]),
	.LITE_REG_T3_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			 [2]),
	.LITE_REG_T3_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			 [2]),
	.LITE_REG_T3_P_CHK				    (   LITE_REG_TX_P_CHK				 [2]),
	.LITE_REG_T3_D_WDITH			    (   LITE_REG_TX_D_WDITH			     [2]),
	.LITE_REG_T3_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			 [2]),
	.LITE_REG_T3_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		 [2]),
	.LITE_REG_T3_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		     [2]),
	.LITE_REG_T3_TFF_USEDW			    (   tx_tff_usedw        			 [2]),
	.LITE_REG_T3_AXI_WR_EFF_LEN			(	LITE_REG_TX_AXI_WR_EFF_LEN		 [2]),

    .LITE_REG_T4_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			     [3]),
	.LITE_REG_T4_CFG_DONE			    (   tx_cfg_done         			 [3]),
	.LITE_REG_T4_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			 [3]),
	.LITE_REG_T4_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			 [3]),
	.LITE_REG_T4_P_CHK				    (   LITE_REG_TX_P_CHK				 [3]),
	.LITE_REG_T4_D_WDITH			    (   LITE_REG_TX_D_WDITH			     [3]),
	.LITE_REG_T4_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			 [3]),
	.LITE_REG_T4_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		 [3]),
	.LITE_REG_T4_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		     [3]),
	.LITE_REG_T4_TFF_USEDW			    (   tx_tff_usedw        			 [3]),
	.LITE_REG_T4_AXI_WR_EFF_LEN			(	LITE_REG_TX_AXI_WR_EFF_LEN		 [3]),

    .LITE_REG_T5_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			     [4]),
	.LITE_REG_T5_CFG_DONE			    (   tx_cfg_done         			 [4]),
	.LITE_REG_T5_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			 [4]),
	.LITE_REG_T5_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			 [4]),
	.LITE_REG_T5_P_CHK				    (   LITE_REG_TX_P_CHK				 [4]),
	.LITE_REG_T5_D_WDITH			    (   LITE_REG_TX_D_WDITH			     [4]),
	.LITE_REG_T5_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			 [4]),
	.LITE_REG_T5_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		 [4]),
	.LITE_REG_T5_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		     [4]),
	.LITE_REG_T5_TFF_USEDW			    (   tx_tff_usedw        			 [4]),
	.LITE_REG_T5_AXI_WR_EFF_LEN			(	LITE_REG_TX_AXI_WR_EFF_LEN		 [4]),

    .LITE_REG_T6_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			     [5]),
	.LITE_REG_T6_CFG_DONE			    (   tx_cfg_done         			 [5]),
	.LITE_REG_T6_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			 [5]),
	.LITE_REG_T6_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			 [5]),
	.LITE_REG_T6_P_CHK				    (   LITE_REG_TX_P_CHK				 [5]),
	.LITE_REG_T6_D_WDITH			    (   LITE_REG_TX_D_WDITH			     [5]),
	.LITE_REG_T6_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			 [5]),
	.LITE_REG_T6_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		 [5]),
	.LITE_REG_T6_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		     [5]),
	.LITE_REG_T6_TFF_USEDW			    (   tx_tff_usedw        			 [5]),
	.LITE_REG_T6_AXI_WR_EFF_LEN			(	LITE_REG_TX_AXI_WR_EFF_LEN		 [5]),

    .LITE_REG_T7_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			     [6]),
	.LITE_REG_T7_CFG_DONE			    (   tx_cfg_done         			 [6]),
	.LITE_REG_T7_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			 [6]),
	.LITE_REG_T7_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			 [6]),
	.LITE_REG_T7_P_CHK				    (   LITE_REG_TX_P_CHK				 [6]),
	.LITE_REG_T7_D_WDITH			    (   LITE_REG_TX_D_WDITH			     [6]),
	.LITE_REG_T7_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			 [6]),
	.LITE_REG_T7_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		 [6]),
	.LITE_REG_T7_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		     [6]),
	.LITE_REG_T7_TFF_USEDW			    (   tx_tff_usedw        			 [6]),
	.LITE_REG_T7_AXI_WR_EFF_LEN			(	LITE_REG_TX_AXI_WR_EFF_LEN		 [6]),

    .LITE_REG_T8_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			     [7]),
	.LITE_REG_T8_CFG_DONE			    (   tx_cfg_done         			 [7]),
	.LITE_REG_T8_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			 [7]),
	.LITE_REG_T8_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			 [7]),
	.LITE_REG_T8_P_CHK				    (   LITE_REG_TX_P_CHK				 [7]),
	.LITE_REG_T8_D_WDITH			    (   LITE_REG_TX_D_WDITH			     [7]),
	.LITE_REG_T8_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			 [7]),
	.LITE_REG_T8_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		 [7]),
	.LITE_REG_T8_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		     [7]),
	.LITE_REG_T8_TFF_USEDW			    (   tx_tff_usedw        			 [7]),
	.LITE_REG_T8_AXI_WR_EFF_LEN			(	LITE_REG_TX_AXI_WR_EFF_LEN		 [7]),

    .LITE_REG_T9_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			     [8]),
	.LITE_REG_T9_CFG_DONE			    (   tx_cfg_done         			 [8]),
	.LITE_REG_T9_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			 [8]),
	.LITE_REG_T9_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			 [8]),
	.LITE_REG_T9_P_CHK				    (   LITE_REG_TX_P_CHK				 [8]),
	.LITE_REG_T9_D_WDITH			    (   LITE_REG_TX_D_WDITH			     [8]),
	.LITE_REG_T9_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			 [8]),
	.LITE_REG_T9_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		 [8]),
	.LITE_REG_T9_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		     [8]),
	.LITE_REG_T9_TFF_USEDW			    (   tx_tff_usedw        			 [8]),
	.LITE_REG_T9_AXI_WR_EFF_LEN			(	LITE_REG_TX_AXI_WR_EFF_LEN		 [8]),

    .LITE_REG_T10_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			     [9]),
	.LITE_REG_T10_CFG_DONE			    (   tx_cfg_done         			 [9]),
	.LITE_REG_T10_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			 [9]),
	.LITE_REG_T10_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			 [9]),
	.LITE_REG_T10_P_CHK				    (   LITE_REG_TX_P_CHK				 [9]),
	.LITE_REG_T10_D_WDITH			    (   LITE_REG_TX_D_WDITH			     [9]),
	.LITE_REG_T10_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			 [9]),
	.LITE_REG_T10_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		 [9]),
	.LITE_REG_T10_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		     [9]),
	.LITE_REG_T10_TFF_USEDW			    (   tx_tff_usedw        			 [9]),
	.LITE_REG_T10_AXI_WR_EFF_LEN		(	LITE_REG_TX_AXI_WR_EFF_LEN		 [9]),

    .LITE_REG_T11_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			    [10]),
	.LITE_REG_T11_CFG_DONE			    (   tx_cfg_done         			[10]),
	.LITE_REG_T11_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			[10]),
	.LITE_REG_T11_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			[10]),
	.LITE_REG_T11_P_CHK				    (   LITE_REG_TX_P_CHK				[10]),
	.LITE_REG_T11_D_WDITH			    (   LITE_REG_TX_D_WDITH			    [10]),
	.LITE_REG_T11_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			[10]),
	.LITE_REG_T11_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		[10]),
	.LITE_REG_T11_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		    [10]),
	.LITE_REG_T11_TFF_USEDW			    (   tx_tff_usedw        			[10]),
	.LITE_REG_T11_AXI_WR_EFF_LEN		(	LITE_REG_TX_AXI_WR_EFF_LEN		[10]),

    .LITE_REG_T12_CFG_REQ			    (   LITE_REG_TX_CFG_REQ			    [11]),
	.LITE_REG_T12_CFG_DONE			    (   tx_cfg_done  			        [11]),
	.LITE_REG_T12_BAUD_RATE			    (   LITE_REG_TX_BAUD_RATE			[11]),
	.LITE_REG_T12_STOP_BIT			    (   LITE_REG_TX_STOP_BIT			[11]),
	.LITE_REG_T12_P_CHK				    (   LITE_REG_TX_P_CHK				[11]),
	.LITE_REG_T12_D_WDITH			    (   LITE_REG_TX_D_WDITH			    [11]),
	.LITE_REG_T12_INVL_MODE			    (   LITE_REG_TX_INVL_MODE			[11]),
	.LITE_REG_T12_INVL_HF_BAUD		    (   LITE_REG_TX_INVL_HF_BAUD		[11]),
	.LITE_REG_T12_INVL_CLK_PD		    (   LITE_REG_TX_INVL_CLK_PD		    [11]),
	.LITE_REG_T12_TFF_USEDW			    (   tx_tff_usedw        			[11]),
	.LITE_REG_T12_AXI_WR_EFF_LEN		(	LITE_REG_TX_AXI_WR_EFF_LEN		[11]),
	
	
	/*test*/
	
	.LR_TEST_FLAG0	   	(LR_TEST_FLAG[0	   	]),
	.LR_TEST_FLAG1	   	(LR_TEST_FLAG[1	   	]),
	.LR_TEST_FLAG2	   	(LR_TEST_FLAG[2	   	]),
	.LR_TEST_FLAG3	   	(LR_TEST_FLAG[3	   	]),
	.LR_TEST_FLAG4	   	(LR_TEST_FLAG[4	   	]),
	.LR_TEST_FLAG5	   	(LR_TEST_FLAG[5	   	]),
	.LR_TEST_FLAG6	   	(LR_TEST_FLAG[6	   	]),
	.LR_TEST_FLAG7	   	(LR_TEST_FLAG[7	   	]),
	.LR_TEST_FLAG8	   	(LR_TEST_FLAG[8	   	]),
	.LR_TEST_FLAG9	   	(LR_TEST_FLAG[9	   	]),
	.LR_TEST_FLAG10	   	(LR_TEST_FLAG[10	]),
	.LR_TEST_FLAG11	   	(LR_TEST_FLAG[11	]),
	.LR_TEST_ERR_INFO0	(LR_TEST_ERR_INFO[0		]),	
	.LR_TEST_ERR_INFO1	(LR_TEST_ERR_INFO[1		]),	
	.LR_TEST_ERR_INFO2	(LR_TEST_ERR_INFO[2		]),	
	.LR_TEST_ERR_INFO3	(LR_TEST_ERR_INFO[3		]),	
	.LR_TEST_ERR_INFO4	(LR_TEST_ERR_INFO[4		]),	
	.LR_TEST_ERR_INFO5	(LR_TEST_ERR_INFO[5		]),	
	.LR_TEST_ERR_INFO6	(LR_TEST_ERR_INFO[6		]),	
	.LR_TEST_ERR_INFO7	(LR_TEST_ERR_INFO[7		]),	
	.LR_TEST_ERR_INFO8	(LR_TEST_ERR_INFO[8		]),	
	.LR_TEST_ERR_INFO9	(LR_TEST_ERR_INFO[9		]),	
	.LR_TEST_ERR_INFO10	(LR_TEST_ERR_INFO[10	]),
	.LR_TEST_ERR_INFO11	(LR_TEST_ERR_INFO[11	])  //
	
);


endmodule