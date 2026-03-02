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
module xdma_bar_ctrl #(
	parameter LITE_BASE_ADDR = 32'h0000_0000
)(

    input                   clk								,
    input                   rst								,
	//				
    input       [31:0]      lite_awaddr						,
    input       [2:0]       lite_awprot						,
    output                  lite_awready					,
    input                   lite_awvalid					,

    input       [31:0]      lite_wdata						,
    output                  lite_wready						,
    input       [3:0]       lite_wstrb						,
    input                   lite_wvalid						,


    input                   lite_bready						,
    output      [1:0]       lite_bresp 						,
    output                  lite_bvalid						,

    input       [31:0]      lite_araddr 					,
    input       [2:0]       lite_arprot 					,
    output                  lite_arready					,
    input                   lite_arvalid					,

    output      [31:0]      lite_rdata 						,
    input                   lite_rready						,
    output      [1:0]       lite_rresp 						,
    output                  lite_rvalid						,
	//			
	output  				interupt_req					,
	input					interupt_ack					,
	input 		[11:0]		got_whole_brust_pkt				,
	input 		[31:0]		LOGIC_VERSION    				,
	input 		[31:0]		LOGIC_SUB_VERSION				,
	//_____________________________________________________________SYSCTRL
	output	reg [15:0]		LITE_REG_AXI_RD_LEN				,
	output	reg [15:0]		LITE_REG_AXI_WR_MAX_LEN			,
	//_____________________________________________________________RSYNC
	output	reg				LITE_REG_RSYNC_REQ				,
	output	reg	[31:0]		LITE_REG_RSYNC_BAUD_RATE		,
	output	reg	[3:0]		LITE_REG_RSYNC_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_RSYNC_P_CHK			,
	output	reg	[3:0]		LITE_REG_RSYNC_D_WIDTH			,
	output	reg				LITE_REG_RSYNC_STOP_PCHK_ENA	,
	output	reg				LITE_REG_RSYNC_FSM_RST_REQ		,
	output	reg	[7:0]		LITE_REG_RSYNC_AXI_BRUST_LEN	,
	//_____________________________________________________________TSYNC
	output	reg				LITE_REG_TSYNC_REQ				,
	output	reg	[31:0]		LITE_REG_TSYNC_BAUD_RATE		,
	output	reg	[3:0]		LITE_REG_TSYNC_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_TSYNC_P_CHK			,
	output	reg	[3:0]		LITE_REG_TSYNC_D_WIDTH			,
	output	reg	[1:0]		LITE_REG_TSYNC_INVL_MODE		,
	output	reg	[15:0]		LITE_REG_TSYNC_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_TSYNC_INVL_CLK_PD		,
	//_____________________________________________________________R1
	output	reg				LITE_REG_R1_CFG_REQ				,
	input		[1:0]		LITE_REG_R1_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R1_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R1_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R1_P_CHK				,
	output	reg	[3:0]		LITE_REG_R1_D_WIDTH				,
	output	reg				LITE_REG_R1_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R1_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R1_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R1_FSM_RST_REQ			,
	input					LITE_REG_R1_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R1_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R1_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R1_TIMEOUT_THRD		,
	//_____________________________________________________________R2
	output	reg				LITE_REG_R2_CFG_REQ				,
	input		[1:0]		LITE_REG_R2_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R2_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R2_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R2_P_CHK				,
	output	reg	[3:0]		LITE_REG_R2_D_WIDTH				,
	output	reg				LITE_REG_R2_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R2_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R2_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R2_FSM_RST_REQ			,
	input					LITE_REG_R2_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R2_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R2_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R2_TIMEOUT_THRD		,
	//_____________________________________________________________R3
	output	reg				LITE_REG_R3_CFG_REQ				,
	input		[1:0]		LITE_REG_R3_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R3_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R3_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R3_P_CHK				,
	output	reg	[3:0]		LITE_REG_R3_D_WIDTH				,
	output	reg				LITE_REG_R3_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R3_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R3_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R3_FSM_RST_REQ			,
	input					LITE_REG_R3_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R3_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R3_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R3_TIMEOUT_THRD		,
	//_____________________________________________________________R4
	output	reg				LITE_REG_R4_CFG_REQ				,
	input		[1:0]		LITE_REG_R4_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R4_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R4_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R4_P_CHK				,
	output	reg	[3:0]		LITE_REG_R4_D_WIDTH				,
	output	reg				LITE_REG_R4_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R4_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R4_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R4_FSM_RST_REQ			,
	input					LITE_REG_R4_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R4_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R4_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R4_TIMEOUT_THRD		,
	//_____________________________________________________________R5
	output	reg				LITE_REG_R5_CFG_REQ				,
	input		[1:0]		LITE_REG_R5_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R5_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R5_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R5_P_CHK				,
	output	reg	[3:0]		LITE_REG_R5_D_WIDTH				,
	output	reg				LITE_REG_R5_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R5_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R5_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R5_FSM_RST_REQ			,
	input					LITE_REG_R5_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R5_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R5_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R5_TIMEOUT_THRD		,
	//_____________________________________________________________R6
	output	reg				LITE_REG_R6_CFG_REQ				,
	input		[1:0]		LITE_REG_R6_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R6_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R6_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R6_P_CHK				,
	output	reg	[3:0]		LITE_REG_R6_D_WIDTH				,
	output	reg				LITE_REG_R6_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R6_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R6_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R6_FSM_RST_REQ			,
	input					LITE_REG_R6_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R6_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R6_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R6_TIMEOUT_THRD		,
	//_____________________________________________________________R7
	output	reg				LITE_REG_R7_CFG_REQ				,
	input		[1:0]		LITE_REG_R7_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R7_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R7_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R7_P_CHK				,
	output	reg	[3:0]		LITE_REG_R7_D_WIDTH				,
	output	reg				LITE_REG_R7_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R7_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R7_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R7_FSM_RST_REQ			,
	input					LITE_REG_R7_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R7_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R7_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R7_TIMEOUT_THRD		,
	//_____________________________________________________________R8
	output	reg				LITE_REG_R8_CFG_REQ				,
	input		[1:0]		LITE_REG_R8_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R8_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R8_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R8_P_CHK				,
	output	reg	[3:0]		LITE_REG_R8_D_WIDTH				,
	output	reg				LITE_REG_R8_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R8_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R8_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R8_FSM_RST_REQ			,
	input					LITE_REG_R8_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R8_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R8_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R8_TIMEOUT_THRD		,
	//_____________________________________________________________R9
	output	reg				LITE_REG_R9_CFG_REQ				,
	input		[1:0]		LITE_REG_R9_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R9_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R9_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R9_P_CHK				,
	output	reg	[3:0]		LITE_REG_R9_D_WIDTH				,
	output	reg				LITE_REG_R9_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R9_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R9_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R9_FSM_RST_REQ			,
	input					LITE_REG_R9_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R9_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R9_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R9_TIMEOUT_THRD		,
	//_____________________________________________________________R10
	output	reg				LITE_REG_R10_CFG_REQ			,
	input		[1:0]		LITE_REG_R10_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R10_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R10_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R10_P_CHK				,
	output	reg	[3:0]		LITE_REG_R10_D_WIDTH			,
	output	reg				LITE_REG_R10_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R10_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R10_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R10_FSM_RST_REQ		,
	input					LITE_REG_R10_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R10_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R10_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R10_TIMEOUT_THRD		,
	//_____________________________________________________________R11
	output	reg				LITE_REG_R11_CFG_REQ			,
	input		[1:0]		LITE_REG_R11_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R11_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R11_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R11_P_CHK				,
	output	reg	[3:0]		LITE_REG_R11_D_WIDTH			,
	output	reg				LITE_REG_R11_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R11_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R11_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R11_FSM_RST_REQ		,
	input					LITE_REG_R11_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R11_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R11_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R11_TIMEOUT_THRD		,
	//_____________________________________________________________R12
	output	reg				LITE_REG_R12_CFG_REQ			,
	input		[1:0]		LITE_REG_R12_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_R12_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_R12_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_R12_P_CHK				,
	output	reg	[3:0]		LITE_REG_R12_D_WIDTH			,
	output	reg				LITE_REG_R12_STOP_PCHK_ENA		,
	input		[15:0]		LITE_REG_R12_STOP_BIT_ERR_CNT	,
	input		[15:0]		LITE_REG_R12_PCHK_ERR_CNT		,
	output	reg				LITE_REG_R12_FSM_RST_REQ		,
	input					LITE_REG_R12_FSM_RST_DONE		,
	output	reg	[7:0]		LITE_REG_R12_AXI_BRUST_LEN		,
	input		[15:0]		LITE_REG_R12_RFF_USEDW			,
	output	reg	[31:0]		LITE_REG_R12_TIMEOUT_THRD		,
	//_____________________________________________________________T1
	output	reg				LITE_REG_T1_CFG_REQ				,
	input		[1:0]		LITE_REG_T1_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T1_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T1_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T1_P_CHK				,
	output	reg	[3:0]		LITE_REG_T1_D_WDITH				,
	output	reg	[1:0]		LITE_REG_T1_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T1_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T1_INVL_CLK_PD			,
	input		[15:0]		LITE_REG_T1_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T1_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T2
	output	reg				LITE_REG_T2_CFG_REQ				,
	input		[1:0]		LITE_REG_T2_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T2_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T2_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T2_P_CHK				,
	output	reg	[3:0]		LITE_REG_T2_D_WDITH				,
	output	reg	[1:0]		LITE_REG_T2_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T2_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T2_INVL_CLK_PD			,
	input		[15:0]		LITE_REG_T2_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T2_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T3
	output	reg				LITE_REG_T3_CFG_REQ				,
	input		[1:0]		LITE_REG_T3_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T3_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T3_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T3_P_CHK				,
	output	reg	[3:0]		LITE_REG_T3_D_WDITH				,
	output	reg	[1:0]		LITE_REG_T3_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T3_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T3_INVL_CLK_PD			,
	input		[15:0]		LITE_REG_T3_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T3_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T4
	output	reg				LITE_REG_T4_CFG_REQ				,
	input		[1:0]		LITE_REG_T4_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T4_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T4_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T4_P_CHK				,
	output	reg	[3:0]		LITE_REG_T4_D_WDITH				,
	output	reg	[1:0]		LITE_REG_T4_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T4_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T4_INVL_CLK_PD			,
	input		[15:0]		LITE_REG_T4_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T4_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T5
	output	reg				LITE_REG_T5_CFG_REQ				,
	input		[1:0]		LITE_REG_T5_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T5_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T5_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T5_P_CHK				,
	output	reg	[3:0]		LITE_REG_T5_D_WDITH				,
	output	reg	[1:0]		LITE_REG_T5_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T5_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T5_INVL_CLK_PD			,
	input		[15:0]		LITE_REG_T5_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T5_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T6
	output	reg				LITE_REG_T6_CFG_REQ				,
	input		[1:0]		LITE_REG_T6_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T6_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T6_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T6_P_CHK				,
	output	reg	[3:0]		LITE_REG_T6_D_WDITH				,
	output	reg	[1:0]		LITE_REG_T6_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T6_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T6_INVL_CLK_PD			,
	input		[15:0]		LITE_REG_T6_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T6_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T7
	output	reg				LITE_REG_T7_CFG_REQ				,
	input		[1:0]		LITE_REG_T7_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T7_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T7_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T7_P_CHK				,
	output	reg	[3:0]		LITE_REG_T7_D_WDITH				,
	output	reg	[1:0]		LITE_REG_T7_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T7_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T7_INVL_CLK_PD			,
	input		[15:0]		LITE_REG_T7_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T7_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T8
	output	reg				LITE_REG_T8_CFG_REQ				,
	input		[1:0]		LITE_REG_T8_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T8_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T8_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T8_P_CHK				,
	output	reg	[3:0]		LITE_REG_T8_D_WDITH				,
	output	reg	[1:0]		LITE_REG_T8_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T8_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T8_INVL_CLK_PD			,
	input		[15:0]		LITE_REG_T8_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T8_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T9
	output	reg				LITE_REG_T9_CFG_REQ				,
	input		[1:0]		LITE_REG_T9_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T9_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T9_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T9_P_CHK				,
	output	reg	[3:0]		LITE_REG_T9_D_WDITH				,
	output	reg	[1:0]		LITE_REG_T9_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T9_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T9_INVL_CLK_PD			,
	input		[15:0]		LITE_REG_T9_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T9_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T10
	output	reg				LITE_REG_T10_CFG_REQ			,
	input		[1:0]		LITE_REG_T10_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T10_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T10_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T10_P_CHK				,
	output	reg	[3:0]		LITE_REG_T10_D_WDITH			,
	output	reg	[1:0]		LITE_REG_T10_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T10_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T10_INVL_CLK_PD		,
	input		[15:0]		LITE_REG_T10_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T10_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T11
	output	reg				LITE_REG_T11_CFG_REQ			,
	input		[1:0]		LITE_REG_T11_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T11_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T11_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T11_P_CHK				,
	output	reg	[3:0]		LITE_REG_T11_D_WDITH			,
	output	reg	[1:0]		LITE_REG_T11_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T11_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T11_INVL_CLK_PD		,
	input		[15:0]		LITE_REG_T11_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T11_AXI_WR_EFF_LEN		,
	//_____________________________________________________________T12
	output	reg				LITE_REG_T12_CFG_REQ			,
	input		[1:0]		LITE_REG_T12_CFG_DONE			,
	output	reg	[31:0]		LITE_REG_T12_BAUD_RATE			,
	output	reg	[3:0]		LITE_REG_T12_STOP_BIT			,
	output	reg	[3:0]		LITE_REG_T12_P_CHK				,
	output	reg	[3:0]		LITE_REG_T12_D_WDITH			,
	output	reg	[1:0]		LITE_REG_T12_INVL_MODE			,
	output	reg	[15:0]		LITE_REG_T12_INVL_HF_BAUD		,
	output	reg	[15:0]		LITE_REG_T12_INVL_CLK_PD		,
	input		[15:0]		LITE_REG_T12_TFF_USEDW			,
	output	reg [15:0]		LITE_REG_T12_AXI_WR_EFF_LEN		,
	//
	input [31:0]			LR_TEST_FLAG0	   	,
	input [31:0]			LR_TEST_FLAG1	   	,
	input [31:0]			LR_TEST_FLAG2	   	,
	input [31:0]			LR_TEST_FLAG3	   	,
	input [31:0]			LR_TEST_FLAG4	   	,
	input [31:0]			LR_TEST_FLAG5	   	,
	input [31:0]			LR_TEST_FLAG6	   	,
	input [31:0]			LR_TEST_FLAG7	   	,
	input [31:0]			LR_TEST_FLAG8	   	,
	input [31:0]			LR_TEST_FLAG9	   	,
	input [31:0]			LR_TEST_FLAG10	   	,
	input [31:0]			LR_TEST_FLAG11	   	,
	input [31:0]			LR_TEST_ERR_INFO0	,
	input [31:0]			LR_TEST_ERR_INFO1	,
	input [31:0]			LR_TEST_ERR_INFO2	,
	input [31:0]			LR_TEST_ERR_INFO3	,
	input [31:0]			LR_TEST_ERR_INFO4	,
	input [31:0]			LR_TEST_ERR_INFO5	,
	input [31:0]			LR_TEST_ERR_INFO6	,
	input [31:0]			LR_TEST_ERR_INFO7	,
	input [31:0]			LR_TEST_ERR_INFO8	,
	input [31:0]			LR_TEST_ERR_INFO9	,
	input [31:0]			LR_TEST_ERR_INFO10	,
	input [31:0]			LR_TEST_ERR_INFO11	  //
	
);

`define NO_REQ 	1'd0
`define REQ		1'd1
`define TIMEOUT_THRD 3750 // 30us, @125Mhz clock

`define EXTD_RD_DONE (bar_rd_done || (rdone_timeout_cnt >= `TIMEOUT_THRD))
`define EHOST_RONLY begin bar_reg[LITE_STA_ERR_ADDR] <= w_addr << 2; bar_reg[w_addr] <= bar_reg[w_addr]; end // error code: The host attempts to write data to a read-only address
`define PARA_IEGAL begin bar_reg[LITE_STA_ERR_ADDR] <= {32{1'd1}}; bar_reg[w_addr] <= wdata; end else begin bar_reg[LITE_STA_ERR_ADDR] <= w_addr << 2; bar_reg[w_addr] <= bar_reg[w_addr]; end

`define R1to12_CFG_REQ          R1_CFG_REQ         , R2_CFG_REQ         , R3_CFG_REQ         , R4_CFG_REQ         , R5_CFG_REQ         , R6_CFG_REQ         , R7_CFG_REQ         , R8_CFG_REQ         , R9_CFG_REQ         , R10_CFG_REQ         , R11_CFG_REQ         , R12_CFG_REQ         
`define R1to12_BAUD_RATE        R1_BAUD_RATE       , R2_BAUD_RATE       , R3_BAUD_RATE       , R4_BAUD_RATE       , R5_BAUD_RATE       , R6_BAUD_RATE       , R7_BAUD_RATE       , R8_BAUD_RATE       , R9_BAUD_RATE       , R10_BAUD_RATE       , R11_BAUD_RATE       , R12_BAUD_RATE       
`define R1to12_STOP_BIT         R1_STOP_BIT        , R2_STOP_BIT        , R3_STOP_BIT        , R4_STOP_BIT        , R5_STOP_BIT        , R6_STOP_BIT        , R7_STOP_BIT        , R8_STOP_BIT        , R9_STOP_BIT        , R10_STOP_BIT        , R11_STOP_BIT        , R12_STOP_BIT        
`define R1to12_P_CHK            R1_P_CHK           , R2_P_CHK           , R3_P_CHK           , R4_P_CHK           , R5_P_CHK           , R6_P_CHK           , R7_P_CHK           , R8_P_CHK           , R9_P_CHK           , R10_P_CHK           , R11_P_CHK           , R12_P_CHK           
`define R1to12_D_WIDTH          R1_D_WIDTH         , R2_D_WIDTH         , R3_D_WIDTH         , R4_D_WIDTH         , R5_D_WIDTH         , R6_D_WIDTH         , R7_D_WIDTH         , R8_D_WIDTH         , R9_D_WIDTH         , R10_D_WIDTH         , R11_D_WIDTH         , R12_D_WIDTH         
`define R1to12_STOP_PCHK_ENA    R1_STOP_PCHK_ENA   , R2_STOP_PCHK_ENA   , R3_STOP_PCHK_ENA   , R4_STOP_PCHK_ENA   , R5_STOP_PCHK_ENA   , R6_STOP_PCHK_ENA   , R7_STOP_PCHK_ENA   , R8_STOP_PCHK_ENA   , R9_STOP_PCHK_ENA   , R10_STOP_PCHK_ENA   , R11_STOP_PCHK_ENA   , R12_STOP_PCHK_ENA   
`define R1to12_STOP_BIT_ERR_CNT R1_STOP_BIT_ERR_CNT, R2_STOP_BIT_ERR_CNT, R3_STOP_BIT_ERR_CNT, R4_STOP_BIT_ERR_CNT, R5_STOP_BIT_ERR_CNT, R6_STOP_BIT_ERR_CNT, R7_STOP_BIT_ERR_CNT, R8_STOP_BIT_ERR_CNT, R9_STOP_BIT_ERR_CNT, R10_STOP_BIT_ERR_CNT, R11_STOP_BIT_ERR_CNT, R12_STOP_BIT_ERR_CNT
`define R1to12_PCHK_ERR_CNT     R1_PCHK_ERR_CNT    , R2_PCHK_ERR_CNT    , R3_PCHK_ERR_CNT    , R4_PCHK_ERR_CNT    , R5_PCHK_ERR_CNT    , R6_PCHK_ERR_CNT    , R7_PCHK_ERR_CNT    , R8_PCHK_ERR_CNT    , R9_PCHK_ERR_CNT    , R10_PCHK_ERR_CNT    , R11_PCHK_ERR_CNT    , R12_PCHK_ERR_CNT    
`define R1to12_FSM_RST_REQ      R1_FSM_RST_REQ     , R2_FSM_RST_REQ     , R3_FSM_RST_REQ     , R4_FSM_RST_REQ     , R5_FSM_RST_REQ     , R6_FSM_RST_REQ     , R7_FSM_RST_REQ     , R8_FSM_RST_REQ     , R9_FSM_RST_REQ     , R10_FSM_RST_REQ     , R11_FSM_RST_REQ     , R12_FSM_RST_REQ     
`define R1to12_AXI_BRUST_LEN    R1_AXI_BRUST_LEN   , R2_AXI_BRUST_LEN   , R3_AXI_BRUST_LEN   , R4_AXI_BRUST_LEN   , R5_AXI_BRUST_LEN   , R6_AXI_BRUST_LEN   , R7_AXI_BRUST_LEN   , R8_AXI_BRUST_LEN   , R9_AXI_BRUST_LEN   , R10_AXI_BRUST_LEN   , R11_AXI_BRUST_LEN   , R12_AXI_BRUST_LEN   
`define R1to12_RFF_USEDW        R1_RFF_USEDW       , R2_RFF_USEDW       , R3_RFF_USEDW       , R4_RFF_USEDW       , R5_RFF_USEDW       , R6_RFF_USEDW       , R7_RFF_USEDW       , R8_RFF_USEDW       , R9_RFF_USEDW       , R10_RFF_USEDW       , R11_RFF_USEDW       , R12_RFF_USEDW       

`define T1to12_CFG_REQ      T1_CFG_REQ     , T2_CFG_REQ     , T3_CFG_REQ     , T4_CFG_REQ     , T5_CFG_REQ     , T6_CFG_REQ     , T7_CFG_REQ     , T8_CFG_REQ     , T9_CFG_REQ     , T10_CFG_REQ     , T11_CFG_REQ     , T12_CFG_REQ     
`define T1to12_BAUD_RATE    T1_BAUD_RATE   , T2_BAUD_RATE   , T3_BAUD_RATE   , T4_BAUD_RATE   , T5_BAUD_RATE   , T6_BAUD_RATE   , T7_BAUD_RATE   , T8_BAUD_RATE   , T9_BAUD_RATE   , T10_BAUD_RATE   , T11_BAUD_RATE   , T12_BAUD_RATE   
`define T1to12_STOP_BIT     T1_STOP_BIT    , T2_STOP_BIT    , T3_STOP_BIT    , T4_STOP_BIT    , T5_STOP_BIT    , T6_STOP_BIT    , T7_STOP_BIT    , T8_STOP_BIT    , T9_STOP_BIT    , T10_STOP_BIT    , T11_STOP_BIT    , T12_STOP_BIT    
`define T1to12_P_CHK        T1_P_CHK       , T2_P_CHK       , T3_P_CHK       , T4_P_CHK       , T5_P_CHK       , T6_P_CHK       , T7_P_CHK       , T8_P_CHK       , T9_P_CHK       , T10_P_CHK       , T11_P_CHK       , T12_P_CHK       
`define T1to12_D_WDITH      T1_D_WDITH     , T2_D_WDITH     , T3_D_WDITH     , T4_D_WDITH     , T5_D_WDITH     , T6_D_WDITH     , T7_D_WDITH     , T8_D_WDITH     , T9_D_WDITH     , T10_D_WDITH     , T11_D_WDITH     , T12_D_WDITH     
`define T1to12_INVL_MODE    T1_INVL_MODE   , T2_INVL_MODE   , T3_INVL_MODE   , T4_INVL_MODE   , T5_INVL_MODE   , T6_INVL_MODE   , T7_INVL_MODE   , T8_INVL_MODE   , T9_INVL_MODE   , T10_INVL_MODE   , T11_INVL_MODE   , T12_INVL_MODE   
`define T1to12_INVL_HF_BAUD T1_INVL_HF_BAUD, T2_INVL_HF_BAUD, T3_INVL_HF_BAUD, T4_INVL_HF_BAUD, T5_INVL_HF_BAUD, T6_INVL_HF_BAUD, T7_INVL_HF_BAUD, T8_INVL_HF_BAUD, T9_INVL_HF_BAUD, T10_INVL_HF_BAUD, T11_INVL_HF_BAUD, T12_INVL_HF_BAUD
`define T1to12_INVL_CLK_PD  T1_INVL_CLK_PD , T2_INVL_CLK_PD , T3_INVL_CLK_PD , T4_INVL_CLK_PD , T5_INVL_CLK_PD , T6_INVL_CLK_PD , T7_INVL_CLK_PD , T8_INVL_CLK_PD , T9_INVL_CLK_PD , T10_INVL_CLK_PD , T11_INVL_CLK_PD , T12_INVL_CLK_PD 
`define T1to12_TFF_USEDW    T1_TFF_USEDW   , T2_TFF_USEDW   , T3_TFF_USEDW   , T4_TFF_USEDW   , T5_TFF_USEDW   , T6_TFF_USEDW   , T7_TFF_USEDW   , T8_TFF_USEDW   , T9_TFF_USEDW   , T10_TFF_USEDW   , T11_TFF_USEDW   , T12_TFF_USEDW   

localparam INIT			= 4'd0;
localparam READ_REQ		= 4'd1;
localparam INTERUPT		= 4'd2;
localparam WAIT_CLR		= 4'd3;
localparam WAIT_R_DONE	= 4'd4;	
localparam WAIT_NX_PKT	= 4'd5;	
//_________________________________________________________________________________________________________ 00-0f
localparam [31:0]	LOG_VERSION			= 32'h0000_0000;/* 0x00     --logic version */
localparam [31:0]	LOG_SUB_VERSION		= 32'h0000_0001;/* 0x04     --logic subversion */
localparam [31:0]	LITE_ONLINE			= 32'h0000_0002;/* 0x08     --5a5abcbc */
localparam [31:0]	INTERUPT_CLEAR   	= 32'h0000_0003;/* 0x0c     --host set it to 1, fpga clear */
localparam [31:0]	HOST_READ_DONE   	= 32'h0000_0004;/* 0x10     --host set it to 1, fpga clear */
localparam [31:0]	FPGA_RD_REQ_CHL  	= 32'h0000_0005;/* 0x14		--fpga set read channel num */
localparam [31:0]	INRPT_CLR_MODE		= 32'h0000_0006;/* 0x18		--1: use reg 0x00; 0: use ack pin */
localparam [31:0]	XDMA_TIMEOUT		= 32'h0000_0007;/* 0x1c		--31:16 interrpt clr timeout; 15:0 rdone timeout*/
localparam [31:0]	INTERRUPT_EN		= 32'h0000_0008;/* 0x20		--                                                                                           */
localparam [31:0]	AXI_RD_LEN			= 32'h0000_0009;/* 0x24		--                                                                                           */
localparam [31:0]	AXI_WR_MAX_LEN		= 32'h0000_000a;/* 0x28		--                                                                                           *//*
localparam [31:0]						= 32'h0000_000b;/* 0x2c		--                                                                                           *//*
localparam [31:0]						= 32'h0000_000c;/* 0x30		--                                                                                           *//*
localparam [31:0]						= 32'h0000_000d;/* 0x34     --                                                                                           *//*
localparam [31:0]				     	= 32'h0000_000e;/* 0x38     --                                                                                           *//*
localparam [31:0]						= 32'h0000_000f;/* 0x3c		--                                                                                           */
//_________________________________________________________________________________________________________ 10-1f
localparam [31:0]	RX_ALL_CHL_PARA_SYNC= 32'h0000_0010;/* 0x40     --1: rx all channels use the same parameters; 0: rx all channels use their own parameters*/
localparam [31:0]	RSYNC_REQ			= 32'h0000_0011;/* 0x44		--parameter config req */
localparam [31:0]	RSYNC_BAUD_RATE		= 32'h0000_0012;/* 0x48     --baud rate */
localparam [31:0]	RSYNC_STOP_BIT		= 32'h0000_0013;/* 0x4c		--stop bit  */
localparam [31:0]	RSYNC_P_CHK			= 32'h0000_0014;/* 0x50		--parity check */
localparam [31:0]	RSYNC_D_WIDTH		= 32'h0000_0015;/* 0x54		--data width */
localparam [31:0]	RSYNC_STOP_PCHK_ENA	= 32'h0000_0016;/* 0x58		--stop bit and parity check enable */
localparam [31:0]	RSYNC_FSM_RST_REQ	= 32'h0000_0017;/* 0x5c		--reset fsm, use it when uart terminal modified baud rate */
localparam [31:0]	RSYNC_AXI_BRUST_LEN	= 32'h0000_0018;/* 0x60		--axi r channel brusrt length, logic need know the value in advance, s_axi_arbrust is too late *//*
localparam [31:0]						= 32'h0000_0019;/* 0x64		--                                                                                           *//*
localparam [31:0]						= 32'h0000_001a;/* 0x68		--                                                                                           *//*
localparam [31:0]						= 32'h0000_001b;/* 0x6c		--                                                                                           *//*
localparam [31:0]						= 32'h0000_001c;/* 0x70		--                                                                                           *//*
localparam [31:0]						= 32'h0000_001d;/* 0x74		--                                                                                           *//*
localparam [31:0]						= 32'h0000_001e;/* 0x78		--                                                                                           *//*
localparam [31:0]						= 32'h0000_001f;/* 0x7c     --                                                                                           */
//_________________________________________________________________________________________________________ 20-2f
localparam [31:0]	TX_ALL_CHL_PARA_SYNC= 32'h0000_0020;/* 0x80     --1: tx all channels use the same parameters; 0: tx all channels use their own parameters;   */
localparam [31:0]	TSYNC_REQ			= 32'h0000_0021;/* 0x84		--para cfg req */
localparam [31:0]	TSYNC_BAUD_RATE 	= 32'h0000_0022;/* 0x88     --baud rate */
localparam [31:0]	TSYNC_STOP_BIT		= 32'h0000_0023;/* 0x8c		--stop bit */
localparam [31:0]	TSYNC_P_CHK			= 32'h0000_0024;/* 0x90		--parity check */
localparam [31:0]	TSYNC_D_WIDTH		= 32'h0000_0025;/* 0x94		--data width */
localparam [31:0]	TSYNC_INVL_MODE		= 32'h0000_0026;/* 0x98		--interval mode */
localparam [31:0]	TSYNC_INVL_HF_BAUD	= 32'h0000_0027;/* 0x9c		--interval(unit: 0.5baud) */
localparam [31:0]	TSYNC_INVL_CLK_PD	= 32'h0000_0028;/* 0xa0		--interval(unit: clk period) *//*
localparam [31:0]						= 32'h0000_0029;/* 0xa4		--                                                                                           *//*
localparam [31:0]						= 32'h0000_002a;/* 0xa8		--                                                                                           *//*
localparam [31:0]						= 32'h0000_002b;/* 0xac		--                                                                                           *//*
localparam [31:0]						= 32'h0000_002c;/* 0xb0		--                                                                                           *//*
localparam [31:0]						= 32'h0000_002d;/* 0xb4		--                                                                                           *//*
localparam [31:0]						= 32'h0000_002e;/* 0xb8		--                                                                                           *//*
localparam [31:0]						= 32'h0000_002f;/* 0xbc     --                                                                                           *//*
//_________________________________________________________________________________________________________ 30-3f
localparam [31:0]						= 32'h0000_0030;/* 0xc0     --                                                                                           *//*
localparam [31:0]						= 32'h0000_0031;/* 0xc4		--                                                                                           *//*
localparam [31:0]					 	= 32'h0000_0032;/* 0xc8     --                                                                                           *//*
localparam [31:0]						= 32'h0000_0033;/* 0xcc		--                                                                                           *//*
localparam [31:0]						= 32'h0000_0034;/* 0xd0		--                                                                                           *//*
localparam [31:0]						= 32'h0000_0035;/* 0xd4		--                                                                                           *//*
localparam [31:0]						= 32'h0000_0036;/* 0xd8		--                                                                                           *//*
localparam [31:0]						= 32'h0000_0037;/* 0xdc		--                                                                                           *//*
localparam [31:0]						= 32'h0000_0038;/* 0xe0		--                                                                                           *//*
localparam [31:0]						= 32'h0000_0039;/* 0xe4		--                                                                                           *//*
localparam [31:0]						= 32'h0000_003a;/* 0xe8		--                                                                                           *//*
localparam [31:0]						= 32'h0000_003b;/* 0xec		--                                                                                           *//*
localparam [31:0]						= 32'h0000_003c;/* 0xf0		--                                                                                           *//*
localparam [31:0]						= 32'h0000_003d;/* 0xf4		--                                                                                           *//*
localparam [31:0]						= 32'h0000_003e;/* 0xf8		--                                                                                           *//*
localparam [31:0]						= 32'h0000_003f;/* 0xfc     --                                                                                           */
//_________________________________________________________________________________________________________ 40-4f
localparam [31:0]	R1_CFG_REQ			= 32'h0000_0040;/* 0x100    --                                                                                           */  
localparam [31:0]	R1_BAUD_RATE		= 32'h0000_0041;/* 0x104	--                                                                                           */  
localparam [31:0]	R1_STOP_BIT			= 32'h0000_0042;/* 0x108    --                                                                                           */  
localparam [31:0]	R1_P_CHK			= 32'h0000_0043;/* 0x10c	--                                                                                           */  
localparam [31:0]	R1_D_WIDTH			= 32'h0000_0044;/* 0x110	--                                                                                           */  
localparam [31:0]	R1_STOP_PCHK_ENA	= 32'h0000_0045;/* 0x114	--                                                                                           */  
localparam [31:0]	R1_STOP_BIT_ERR_CNT	= 32'h0000_0046;/* 0x118	--                                                                                           */  
localparam [31:0]	R1_PCHK_ERR_CNT		= 32'h0000_0047;/* 0x11c	--                                                                                           */  
localparam [31:0]	R1_FSM_RST_REQ		= 32'h0000_0048;/* 0x120	--                                                                                           */  
localparam [31:0]	R1_AXI_BRUST_LEN	= 32'h0000_0049;/* 0x124	--                                                                                           */  
localparam [31:0]	R1_RFF_USEDW		= 32'h0000_004a;/* 0x128	--                                                                                           */
localparam [31:0]	R1_TIMEOUT_THRD		= 32'h0000_004b;/* 0x12c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_004c;/* 0x130	--                                                                                           *//*
localparam [31:0]						= 32'h0000_004d;/* 0x134	--                                                                                           *//*
localparam [31:0]						= 32'h0000_004e;/* 0x138	--                                                                                           *//*
localparam [31:0]						= 32'h0000_004f;/* 0x13c	--                                                                                           */  
//_________________________________________________________________________________________________________ 50-5f
localparam [31:0]	R2_CFG_REQ			= 32'h0000_0050;/* 0x140	--                                                                                           */  
localparam [31:0]	R2_BAUD_RATE		= 32'h0000_0051;/* 0x144	--                                                                                           */  
localparam [31:0]	R2_STOP_BIT			= 32'h0000_0052;/* 0x148	--                                                                                           */  
localparam [31:0]	R2_P_CHK			= 32'h0000_0053;/* 0x14c	--                                                                                           */  
localparam [31:0]	R2_D_WIDTH			= 32'h0000_0054;/* 0x150	--                                                                                           */  
localparam [31:0]	R2_STOP_PCHK_ENA	= 32'h0000_0055;/* 0x154	--                                                                                           */  
localparam [31:0]	R2_STOP_BIT_ERR_CNT	= 32'h0000_0056;/* 0x158	--                                                                                           */  
localparam [31:0]	R2_PCHK_ERR_CNT		= 32'h0000_0057;/* 0x15c	--                                                                                           */  
localparam [31:0]	R2_FSM_RST_REQ		= 32'h0000_0058;/* 0x160	--                                                                                           */  
localparam [31:0]	R2_AXI_BRUST_LEN	= 32'h0000_0059;/* 0x164	--                                                                                           */  
localparam [31:0]	R2_RFF_USEDW		= 32'h0000_005a;/* 0x168	--                                                                                           */
localparam [31:0]	R2_TIMEOUT_THRD		= 32'h0000_005b;/* 0x16c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_005c;/* 0x170	--                                                                                           *//*
localparam [31:0]						= 32'h0000_005d;/* 0x174	--                                                                                           *//*
localparam [31:0]						= 32'h0000_005e;/* 0x178	--                                                                                           *//*
localparam [31:0]						= 32'h0000_005f;/* 0x17c	--                                                                                           */  
//_________________________________________________________________________________________________________ 60-6f
localparam [31:0]	R3_CFG_REQ			= 32'h0000_0060;/* 0x180	--                                                                                           */  
localparam [31:0]	R3_BAUD_RATE		= 32'h0000_0061;/* 0x184	--                                                                                           */  
localparam [31:0]	R3_STOP_BIT			= 32'h0000_0062;/* 0x188	--                                                                                           */  
localparam [31:0]	R3_P_CHK			= 32'h0000_0063;/* 0x18c	--                                                                                           */  
localparam [31:0]	R3_D_WIDTH			= 32'h0000_0064;/* 0x190	--                                                                                           */  
localparam [31:0]	R3_STOP_PCHK_ENA	= 32'h0000_0065;/* 0x194	--                                                                                           */  
localparam [31:0]	R3_STOP_BIT_ERR_CNT	= 32'h0000_0066;/* 0x198	--                                                                                           */  
localparam [31:0]	R3_PCHK_ERR_CNT		= 32'h0000_0067;/* 0x19c	--                                                                                           */  
localparam [31:0]	R3_FSM_RST_REQ		= 32'h0000_0068;/* 0x1a0	--                                                                                           */  
localparam [31:0]	R3_AXI_BRUST_LEN	= 32'h0000_0069;/* 0x1a4	--                                                                                           */  
localparam [31:0]	R3_RFF_USEDW		= 32'h0000_006a;/* 0x1a8	--                                                                                           */
localparam [31:0]	R3_TIMEOUT_THRD		= 32'h0000_006b;/* 0x1ac	--                                                                                           *//*
localparam [31:0]						= 32'h0000_006c;/* 0x1b0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_006d;/* 0x1b4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_006e;/* 0x1b8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_006f;/* 0x1bc	--                                                                                           */  
//_________________________________________________________________________________________________________ 70-7f
localparam [31:0]	R4_CFG_REQ			= 32'h0000_0070;/* 0x1c0	--                                                                                           */  
localparam [31:0]	R4_BAUD_RATE		= 32'h0000_0071;/* 0x1c4	--                                                                                           */  
localparam [31:0]	R4_STOP_BIT			= 32'h0000_0072;/* 0x1c8	--                                                                                           */  
localparam [31:0]	R4_P_CHK			= 32'h0000_0073;/* 0x1cc	--                                                                                           */  
localparam [31:0]	R4_D_WIDTH			= 32'h0000_0074;/* 0x1d0	--                                                                                           */  
localparam [31:0]	R4_STOP_PCHK_ENA	= 32'h0000_0075;/* 0x1d4	--                                                                                           */  
localparam [31:0]	R4_STOP_BIT_ERR_CNT	= 32'h0000_0076;/* 0x1d8	--                                                                                           */  
localparam [31:0]	R4_PCHK_ERR_CNT		= 32'h0000_0077;/* 0x1dc	--                                                                                           */  
localparam [31:0]	R4_FSM_RST_REQ		= 32'h0000_0078;/* 0x1e0	--                                                                                           */  
localparam [31:0]	R4_AXI_BRUST_LEN	= 32'h0000_0079;/* 0x1e4	--                                                                                           */  
localparam [31:0]	R4_RFF_USEDW		= 32'h0000_007a;/* 0x1e8	--                                                                                           */
localparam [31:0]	R4_TIMEOUT_THRD		= 32'h0000_007b;/* 0x1ec	--                                                                                           *//*
localparam [31:0]						= 32'h0000_007c;/* 0x1f0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_007d;/* 0x1f4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_007e;/* 0x1f8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_007f;/* 0x1fc    --                                                                                           */  
//_________________________________________________________________________________________________________ 80-8f
localparam [31:0]	R5_CFG_REQ			= 32'h0000_0080;/* 0x200    --                                                                                           */  
localparam [31:0]	R5_BAUD_RATE		= 32'h0000_0081;/* 0x204	--                                                                                           */  
localparam [31:0]	R5_STOP_BIT			= 32'h0000_0082;/* 0x208    --                                                                                           */  
localparam [31:0]	R5_P_CHK			= 32'h0000_0083;/* 0x20c	--                                                                                           */  
localparam [31:0]	R5_D_WIDTH			= 32'h0000_0084;/* 0x210	--                                                                                           */  
localparam [31:0]	R5_STOP_PCHK_ENA	= 32'h0000_0085;/* 0x214	--                                                                                           */  
localparam [31:0]	R5_STOP_BIT_ERR_CNT	= 32'h0000_0086;/* 0x218	--                                                                                           */  
localparam [31:0]	R5_PCHK_ERR_CNT		= 32'h0000_0087;/* 0x21c	--                                                                                           */  
localparam [31:0]	R5_FSM_RST_REQ		= 32'h0000_0088;/* 0x220	--                                                                                           */  
localparam [31:0]	R5_AXI_BRUST_LEN	= 32'h0000_0089;/* 0x224	--                                                                                           */  
localparam [31:0]	R5_RFF_USEDW		= 32'h0000_008a;/* 0x228	--                                                                                           */
localparam [31:0]	R5_TIMEOUT_THRD		= 32'h0000_008b;/* 0x22c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_008c;/* 0x230	--                                                                                           *//*
localparam [31:0]						= 32'h0000_008d;/* 0x234	--                                                                                           *//*
localparam [31:0]						= 32'h0000_008e;/* 0x238	--                                                                                           *//*
localparam [31:0]						= 32'h0000_008f;/* 0x23c    --                                                                                           */  
//_________________________________________________________________________________________________________ 90-9f
localparam [31:0]	R6_CFG_REQ			= 32'h0000_0090;/* 0x240    --                                                                                           */  
localparam [31:0]	R6_BAUD_RATE		= 32'h0000_0091;/* 0x244	--                                                                                           */  
localparam [31:0]	R6_STOP_BIT			= 32'h0000_0092;/* 0x248    --                                                                                           */  
localparam [31:0]	R6_P_CHK			= 32'h0000_0093;/* 0x24c	--                                                                                           */  
localparam [31:0]	R6_D_WIDTH			= 32'h0000_0094;/* 0x250	--                                                                                           */  
localparam [31:0]	R6_STOP_PCHK_ENA	= 32'h0000_0095;/* 0x254	--                                                                                           */  
localparam [31:0]	R6_STOP_BIT_ERR_CNT	= 32'h0000_0096;/* 0x258	--                                                                                           */  
localparam [31:0]	R6_PCHK_ERR_CNT		= 32'h0000_0097;/* 0x25c	--                                                                                           */  
localparam [31:0]	R6_FSM_RST_REQ		= 32'h0000_0098;/* 0x260	--                                                                                           */  
localparam [31:0]	R6_AXI_BRUST_LEN	= 32'h0000_0099;/* 0x264	--                                                                                           */  
localparam [31:0]	R6_RFF_USEDW		= 32'h0000_009a;/* 0x268	--                                                                                           */
localparam [31:0]	R6_TIMEOUT_THRD		= 32'h0000_009b;/* 0x26c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_009c;/* 0x270	--                                                                                           *//*
localparam [31:0]						= 32'h0000_009d;/* 0x274	--                                                                                           *//*
localparam [31:0]						= 32'h0000_009e;/* 0x278	--                                                                                           *//*
localparam [31:0]						= 32'h0000_009f;/* 0x27c    --                                                                                           */  
//_________________________________________________________________________________________________________ a0-af
localparam [31:0]	R7_CFG_REQ			= 32'h0000_00a0;/* 0x280    --                                                                                           */  
localparam [31:0]	R7_BAUD_RATE		= 32'h0000_00a1;/* 0x284	--                                                                                           */  
localparam [31:0]	R7_STOP_BIT			= 32'h0000_00a2;/* 0x288    --                                                                                           */  
localparam [31:0]	R7_P_CHK			= 32'h0000_00a3;/* 0x28c	--                                                                                           */  
localparam [31:0]	R7_D_WIDTH			= 32'h0000_00a4;/* 0x290	--                                                                                           */  
localparam [31:0]	R7_STOP_PCHK_ENA	= 32'h0000_00a5;/* 0x294	--                                                                                           */  
localparam [31:0]	R7_STOP_BIT_ERR_CNT	= 32'h0000_00a6;/* 0x298	--                                                                                           */  
localparam [31:0]	R7_PCHK_ERR_CNT		= 32'h0000_00a7;/* 0x29c	--                                                                                           */  
localparam [31:0]	R7_FSM_RST_REQ		= 32'h0000_00a8;/* 0x2a0	--                                                                                           */  
localparam [31:0]	R7_AXI_BRUST_LEN	= 32'h0000_00a9;/* 0x2a4	--                                                                                           */  
localparam [31:0]	R7_RFF_USEDW		= 32'h0000_00aa;/* 0x2a8	--                                                                                           */
localparam [31:0]	R7_TIMEOUT_THRD		= 32'h0000_00ab;/* 0x2ac	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00ac;/* 0x2b0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00ad;/* 0x2b4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00ae;/* 0x2b8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00af;/* 0x2bc    --                                                                                           */  
//_________________________________________________________________________________________________________ b0-bf
localparam [31:0]	R8_CFG_REQ			= 32'h0000_00b0;/* 0x2c0    --                                                                                           */  
localparam [31:0]	R8_BAUD_RATE		= 32'h0000_00b1;/* 0x2c4	--                                                                                           */  
localparam [31:0]	R8_STOP_BIT			= 32'h0000_00b2;/* 0x2c8    --                                                                                           */  
localparam [31:0]	R8_P_CHK			= 32'h0000_00b3;/* 0x2cc	--                                                                                           */  
localparam [31:0]	R8_D_WIDTH			= 32'h0000_00b4;/* 0x2d0	--                                                                                           */  
localparam [31:0]	R8_STOP_PCHK_ENA	= 32'h0000_00b5;/* 0x2d4	--                                                                                           */  
localparam [31:0]	R8_STOP_BIT_ERR_CNT	= 32'h0000_00b6;/* 0x2d8	--                                                                                           */  
localparam [31:0]	R8_PCHK_ERR_CNT		= 32'h0000_00b7;/* 0x2dc	--                                                                                           */  
localparam [31:0]	R8_FSM_RST_REQ		= 32'h0000_00b8;/* 0x2e0	--                                                                                           */  
localparam [31:0]	R8_AXI_BRUST_LEN	= 32'h0000_00b9;/* 0x2e4	--                                                                                           */  
localparam [31:0]	R8_RFF_USEDW		= 32'h0000_00ba;/* 0x2e8	--                                                                                           */
localparam [31:0]	R8_TIMEOUT_THRD		= 32'h0000_00bb;/* 0x2ec	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00bc;/* 0x2f0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00bd;/* 0x2f4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00be;/* 0x2f8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00bf;/* 0x2fc    --                                                                                           */  
//_________________________________________________________________________________________________________ c0-cf
localparam [31:0]	R9_CFG_REQ			= 32'h0000_00c0;/* 0x300    --                                                                                           */  
localparam [31:0]	R9_BAUD_RATE		= 32'h0000_00c1;/* 0x304	--                                                                                           */  
localparam [31:0]	R9_STOP_BIT			= 32'h0000_00c2;/* 0x308    --                                                                                           */  
localparam [31:0]	R9_P_CHK			= 32'h0000_00c3;/* 0x30c	--                                                                                           */  
localparam [31:0]	R9_D_WIDTH			= 32'h0000_00c4;/* 0x310	--                                                                                           */  
localparam [31:0]	R9_STOP_PCHK_ENA	= 32'h0000_00c5;/* 0x314	--                                                                                           */  
localparam [31:0]	R9_STOP_BIT_ERR_CNT	= 32'h0000_00c6;/* 0x318	--                                                                                           */  
localparam [31:0]	R9_PCHK_ERR_CNT		= 32'h0000_00c7;/* 0x31c	--                                                                                           */  
localparam [31:0]	R9_FSM_RST_REQ		= 32'h0000_00c8;/* 0x320	--                                                                                           */  
localparam [31:0]	R9_AXI_BRUST_LEN	= 32'h0000_00c9;/* 0x324	--                                                                                           */  
localparam [31:0]	R9_RFF_USEDW		= 32'h0000_00ca;/* 0x328	--                                                                                           */
localparam [31:0]	R9_TIMEOUT_THRD		= 32'h0000_00cb;/* 0x32c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00cc;/* 0x330	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00cd;/* 0x334	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00ce;/* 0x338	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00cf;/* 0x33c    --                                                                                           */  
//_________________________________________________________________________________________________________ d0-df
localparam [31:0]	R10_CFG_REQ			= 32'h0000_00d0;/* 0x340    --                                                                                           */  
localparam [31:0]	R10_BAUD_RATE		= 32'h0000_00d1;/* 0x344	--                                                                                           */  
localparam [31:0]	R10_STOP_BIT		= 32'h0000_00d2;/* 0x348    --                                                                                           */  
localparam [31:0]	R10_P_CHK			= 32'h0000_00d3;/* 0x34c	--                                                                                           */  
localparam [31:0]	R10_D_WIDTH			= 32'h0000_00d4;/* 0x350	--                                                                                           */  
localparam [31:0]	R10_STOP_PCHK_ENA	= 32'h0000_00d5;/* 0x354	--                                                                                           */  
localparam [31:0]	R10_STOP_BIT_ERR_CNT= 32'h0000_00d6;/* 0x358	--                                                                                           */  
localparam [31:0]	R10_PCHK_ERR_CNT	= 32'h0000_00d7;/* 0x35c	--                                                                                           */  
localparam [31:0]	R10_FSM_RST_REQ		= 32'h0000_00d8;/* 0x360	--                                                                                           */  
localparam [31:0]	R10_AXI_BRUST_LEN	= 32'h0000_00d9;/* 0x364	--                                                                                           */  
localparam [31:0]	R10_RFF_USEDW		= 32'h0000_00da;/* 0x368	--                                                                                           */
localparam [31:0]	R10_TIMEOUT_THRD	= 32'h0000_00db;/* 0x36c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00dc;/* 0x370	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00dd;/* 0x374	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00de;/* 0x378	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00df;/* 0x37c    --                                                                                           */  
//_________________________________________________________________________________________________________ e0-ef
localparam [31:0]	R11_CFG_REQ			= 32'h0000_00e0;/* 0x380    --                                                                                           */  
localparam [31:0]	R11_BAUD_RATE		= 32'h0000_00e1;/* 0x384	--                                                                                           */  
localparam [31:0]	R11_STOP_BIT		= 32'h0000_00e2;/* 0x388    --                                                                                           */  
localparam [31:0]	R11_P_CHK			= 32'h0000_00e3;/* 0x38c	--                                                                                           */  
localparam [31:0]	R11_D_WIDTH			= 32'h0000_00e4;/* 0x390	--                                                                                           */  
localparam [31:0]	R11_STOP_PCHK_ENA	= 32'h0000_00e5;/* 0x394	--                                                                                           */  
localparam [31:0]	R11_STOP_BIT_ERR_CNT= 32'h0000_00e6;/* 0x398	--                                                                                           */  
localparam [31:0]	R11_PCHK_ERR_CNT	= 32'h0000_00e7;/* 0x39c	--                                                                                           */  
localparam [31:0]	R11_FSM_RST_REQ		= 32'h0000_00e8;/* 0x3a0	--                                                                                           */  
localparam [31:0]	R11_AXI_BRUST_LEN	= 32'h0000_00e9;/* 0x3a4	--                                                                                           */  
localparam [31:0]	R11_RFF_USEDW		= 32'h0000_00ea;/* 0x3a8	--                                                                                           */
localparam [31:0]	R11_TIMEOUT_THRD	= 32'h0000_00eb;/* 0x3ac	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00ec;/* 0x3b0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00ed;/* 0x3b4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00ee;/* 0x3b8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00ef;/* 0x3bc    --                                                                                           */  
//_________________________________________________________________________________________________________ f0-ff
localparam [31:0]	R12_CFG_REQ			= 32'h0000_00f0;/* 0x3c0    --                                                                                           */  
localparam [31:0]	R12_BAUD_RATE		= 32'h0000_00f1;/* 0x3c4	--                                                                                           */  
localparam [31:0]	R12_STOP_BIT		= 32'h0000_00f2;/* 0x3c8    --                                                                                           */  
localparam [31:0]	R12_P_CHK			= 32'h0000_00f3;/* 0x3cc	--                                                                                           */  
localparam [31:0]	R12_D_WIDTH			= 32'h0000_00f4;/* 0x3d0	--                                                                                           */  
localparam [31:0]	R12_STOP_PCHK_ENA	= 32'h0000_00f5;/* 0x3d4	--                                                                                           */  
localparam [31:0]	R12_STOP_BIT_ERR_CNT= 32'h0000_00f6;/* 0x3d8	--                                                                                           */  
localparam [31:0]	R12_PCHK_ERR_CNT	= 32'h0000_00f7;/* 0x3dc	--                                                                                           */  
localparam [31:0]	R12_FSM_RST_REQ		= 32'h0000_00f8;/* 0x3e0	--                                                                                           */  
localparam [31:0]	R12_AXI_BRUST_LEN	= 32'h0000_00f9;/* 0x3e4	--                                                                                           */  
localparam [31:0]	R12_RFF_USEDW		= 32'h0000_00fa;/* 0x3e8	--                                                                                           */
localparam [31:0]	R12_TIMEOUT_THRD	= 32'h0000_00fb;/* 0x3ec	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00fc;/* 0x3f0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00fd;/* 0x3f4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00fe;/* 0x3f8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_00ff;/* 0x3fc    --                                                                                           */  
//_________________________________________________________________________________________________________ 100-10f
localparam [31:0]	T1_CFG_REQ			= 32'h0000_0100;/* 0x400    --                                                                                           */  
localparam [31:0]	T1_BAUD_RATE		= 32'h0000_0101;/* 0x404	--                                                                                           */  
localparam [31:0]	T1_STOP_BIT			= 32'h0000_0102;/* 0x408    --                                                                                           */  
localparam [31:0]	T1_P_CHK			= 32'h0000_0103;/* 0x40c	--                                                                                           */  
localparam [31:0]	T1_D_WDITH			= 32'h0000_0104;/* 0x410	--                                                                                           */  
localparam [31:0]	T1_INVL_MODE		= 32'h0000_0105;/* 0x414	--                                                                                           */  
localparam [31:0]	T1_INVL_HF_BAUD		= 32'h0000_0106;/* 0x418	--                                                                                           */  
localparam [31:0]	T1_INVL_CLK_PD		= 32'h0000_0107;/* 0x41c	--                                                                                           */  
localparam [31:0]	T1_TFF_USEDW		= 32'h0000_0108;/* 0x420	--                                                                                           */
localparam [31:0]	T1_AXI_WR_EFF_LEN	= 32'h0000_0109;/* 0x424	--                                                                                           *//*
localparam [31:0]						= 32'h0000_010a;/* 0x428	--                                                                                           *//*
localparam [31:0]						= 32'h0000_010b;/* 0x42c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_010c;/* 0x430	--                                                                                           *//*
localparam [31:0]						= 32'h0000_010d;/* 0x434	--                                                                                           *//*
localparam [31:0]						= 32'h0000_010e;/* 0x438	--                                                                                           *//*
localparam [31:0]						= 32'h0000_010f;/* 0x43c    --                                                                                           */  
//_________________________________________________________________________________________________________ 110-11f
localparam [31:0]	T2_CFG_REQ			= 32'h0000_0110;/* 0x440    --                                                                                           */  
localparam [31:0]	T2_BAUD_RATE		= 32'h0000_0111;/* 0x444	--                                                                                           */  
localparam [31:0]	T2_STOP_BIT			= 32'h0000_0112;/* 0x448    --                                                                                           */  
localparam [31:0]	T2_P_CHK			= 32'h0000_0113;/* 0x44c	--                                                                                           */  
localparam [31:0]	T2_D_WDITH			= 32'h0000_0114;/* 0x450	--                                                                                           */  
localparam [31:0]	T2_INVL_MODE		= 32'h0000_0115;/* 0x454	--                                                                                           */  
localparam [31:0]	T2_INVL_HF_BAUD		= 32'h0000_0116;/* 0x458	--                                                                                           */  
localparam [31:0]	T2_INVL_CLK_PD		= 32'h0000_0117;/* 0x45c	--                                                                                           */  
localparam [31:0]	T2_TFF_USEDW		= 32'h0000_0118;/* 0x460	--                                                                                           */
localparam [31:0]	T2_AXI_WR_EFF_LEN	= 32'h0000_0119;/* 0x464	--                                                                                           *//*
localparam [31:0]						= 32'h0000_011a;/* 0x468	--                                                                                           *//*
localparam [31:0]						= 32'h0000_011b;/* 0x46c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_011c;/* 0x470	--                                                                                           *//*
localparam [31:0]						= 32'h0000_011d;/* 0x474	--                                                                                           *//*
localparam [31:0]						= 32'h0000_011e;/* 0x478	--                                                                                           *//*
localparam [31:0]						= 32'h0000_011f;/* 0x47c    --                                                                                           */  
//_________________________________________________________________________________________________________ 120-12f
localparam [31:0]	T3_CFG_REQ			= 32'h0000_0120;/* 0x480    --                                                                                           */  
localparam [31:0]	T3_BAUD_RATE		= 32'h0000_0121;/* 0x484	--                                                                                           */  
localparam [31:0]	T3_STOP_BIT			= 32'h0000_0122;/* 0x488    --                                                                                           */  
localparam [31:0]	T3_P_CHK			= 32'h0000_0123;/* 0x48c	--                                                                                           */  
localparam [31:0]	T3_D_WDITH			= 32'h0000_0124;/* 0x490	--                                                                                           */  
localparam [31:0]	T3_INVL_MODE		= 32'h0000_0125;/* 0x494	--                                                                                           */  
localparam [31:0]	T3_INVL_HF_BAUD		= 32'h0000_0126;/* 0x498	--                                                                                           */  
localparam [31:0]	T3_INVL_CLK_PD		= 32'h0000_0127;/* 0x49c	--                                                                                           */  
localparam [31:0]	T3_TFF_USEDW		= 32'h0000_0128;/* 0x4a0	--                                                                                           */
localparam [31:0]	T3_AXI_WR_EFF_LEN	= 32'h0000_0129;/* 0x4a4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_012a;/* 0x4a8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_012b;/* 0x4ac	--                                                                                           *//*
localparam [31:0]						= 32'h0000_012c;/* 0x4b0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_012d;/* 0x4b4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_012e;/* 0x4b8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_012f;/* 0x4bc    --                                                                                           */  
//_________________________________________________________________________________________________________ 130-13f
localparam [31:0]	T4_CFG_REQ			= 32'h0000_0130;/* 0x4c0    --                                                                                           */  
localparam [31:0]	T4_BAUD_RATE		= 32'h0000_0131;/* 0x4c4	--                                                                                           */  
localparam [31:0]	T4_STOP_BIT			= 32'h0000_0132;/* 0x4c8    --                                                                                           */  
localparam [31:0]	T4_P_CHK			= 32'h0000_0133;/* 0x4cc	--                                                                                           */  
localparam [31:0]	T4_D_WDITH			= 32'h0000_0134;/* 0x4d0	--                                                                                           */  
localparam [31:0]	T4_INVL_MODE		= 32'h0000_0135;/* 0x4d4	--                                                                                           */  
localparam [31:0]	T4_INVL_HF_BAUD		= 32'h0000_0136;/* 0x4d8	--                                                                                           */  
localparam [31:0]	T4_INVL_CLK_PD		= 32'h0000_0137;/* 0x4dc	--                                                                                           */  
localparam [31:0]	T4_TFF_USEDW		= 32'h0000_0138;/* 0x4e0	--                                                                                           */
localparam [31:0]	T4_AXI_WR_EFF_LEN	= 32'h0000_0139;/* 0x4e4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_013a;/* 0x4e8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_013b;/* 0x4ec	--                                                                                           *//*
localparam [31:0]						= 32'h0000_013c;/* 0x4f0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_013d;/* 0x4f4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_013e;/* 0x4f8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_013f;/* 0x4fc    --                                                                                           */  
//_________________________________________________________________________________________________________ 140-14f
localparam [31:0]	T5_CFG_REQ			= 32'h0000_0140;/* 0x500    --                                                                                           */  
localparam [31:0]	T5_BAUD_RATE		= 32'h0000_0141;/* 0x504	--                                                                                           */  
localparam [31:0]	T5_STOP_BIT			= 32'h0000_0142;/* 0x508    --                                                                                           */  
localparam [31:0]	T5_P_CHK			= 32'h0000_0143;/* 0x50c	--                                                                                           */  
localparam [31:0]	T5_D_WDITH			= 32'h0000_0144;/* 0x510	--                                                                                           */  
localparam [31:0]	T5_INVL_MODE		= 32'h0000_0145;/* 0x514	--                                                                                           */  
localparam [31:0]	T5_INVL_HF_BAUD		= 32'h0000_0146;/* 0x518	--                                                                                           */  
localparam [31:0]	T5_INVL_CLK_PD		= 32'h0000_0147;/* 0x51c	--                                                                                           */  
localparam [31:0]	T5_TFF_USEDW		= 32'h0000_0148;/* 0x520	--                                                                                           */
localparam [31:0]	T5_AXI_WR_EFF_LEN	= 32'h0000_0149;/* 0x524	--                                                                                           *//*
localparam [31:0]						= 32'h0000_014a;/* 0x528	--                                                                                           *//*
localparam [31:0]						= 32'h0000_014b;/* 0x52c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_014c;/* 0x530	--                                                                                           *//*
localparam [31:0]						= 32'h0000_014d;/* 0x534	--                                                                                           *//*
localparam [31:0]						= 32'h0000_014e;/* 0x538	--                                                                                           *//*
localparam [31:0]						= 32'h0000_014f;/* 0x53c    --                                                                                           */  
//_________________________________________________________________________________________________________ 150-15f
localparam [31:0]	T6_CFG_REQ			= 32'h0000_0150;/* 0x540    --                                                                                           */  
localparam [31:0]	T6_BAUD_RATE		= 32'h0000_0151;/* 0x544	--                                                                                           */  
localparam [31:0]	T6_STOP_BIT			= 32'h0000_0152;/* 0x548    --                                                                                           */  
localparam [31:0]	T6_P_CHK			= 32'h0000_0153;/* 0x54c	--                                                                                           */  
localparam [31:0]	T6_D_WDITH			= 32'h0000_0154;/* 0x550	--                                                                                           */  
localparam [31:0]	T6_INVL_MODE		= 32'h0000_0155;/* 0x554	--                                                                                           */  
localparam [31:0]	T6_INVL_HF_BAUD		= 32'h0000_0156;/* 0x558	--                                                                                           */  
localparam [31:0]	T6_INVL_CLK_PD		= 32'h0000_0157;/* 0x55c	--                                                                                           */  
localparam [31:0]	T6_TFF_USEDW		= 32'h0000_0158;/* 0x560	--                                                                                           */
localparam [31:0]	T6_AXI_WR_EFF_LEN	= 32'h0000_0159;/* 0x564	--                                                                                           *//*
localparam [31:0]						= 32'h0000_015a;/* 0x568	--                                                                                           *//*
localparam [31:0]						= 32'h0000_015b;/* 0x56c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_015c;/* 0x570	--                                                                                           *//*
localparam [31:0]						= 32'h0000_015d;/* 0x574	--                                                                                           *//*
localparam [31:0]						= 32'h0000_015e;/* 0x578	--                                                                                           *//*
localparam [31:0]						= 32'h0000_015f;/* 0x57c    --                                                                                           */  
//_________________________________________________________________________________________________________ 160-16f
localparam [31:0]	T7_CFG_REQ			= 32'h0000_0160;/* 0x580    --                                                                                           */  
localparam [31:0]	T7_BAUD_RATE		= 32'h0000_0161;/* 0x584	--                                                                                           */  
localparam [31:0]	T7_STOP_BIT			= 32'h0000_0162;/* 0x588    --                                                                                           */  
localparam [31:0]	T7_P_CHK			= 32'h0000_0163;/* 0x58c	--                                                                                           */  
localparam [31:0]	T7_D_WDITH			= 32'h0000_0164;/* 0x590	--                                                                                           */  
localparam [31:0]	T7_INVL_MODE		= 32'h0000_0165;/* 0x594	--                                                                                           */  
localparam [31:0]	T7_INVL_HF_BAUD		= 32'h0000_0166;/* 0x598	--                                                                                           */  
localparam [31:0]	T7_INVL_CLK_PD		= 32'h0000_0167;/* 0x59c	--                                                                                           */  
localparam [31:0]	T7_TFF_USEDW		= 32'h0000_0168;/* 0x5a0	--                                                                                           */
localparam [31:0]	T7_AXI_WR_EFF_LEN	= 32'h0000_0169;/* 0x5a4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_016a;/* 0x5a8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_016b;/* 0x5ac	--                                                                                           *//*
localparam [31:0]						= 32'h0000_016c;/* 0x5b0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_016d;/* 0x5b4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_016e;/* 0x5b8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_016f;/* 0x5bc    --                                                                                           */  
//_________________________________________________________________________________________________________ 170-17f
localparam [31:0]	T8_CFG_REQ			= 32'h0000_0170;/* 0x5c0    --                                                                                           */  
localparam [31:0]	T8_BAUD_RATE		= 32'h0000_0171;/* 0x5c4	--                                                                                           */  
localparam [31:0]	T8_STOP_BIT			= 32'h0000_0172;/* 0x5c8    --                                                                                           */  
localparam [31:0]	T8_P_CHK			= 32'h0000_0173;/* 0x5cc	--                                                                                           */  
localparam [31:0]	T8_D_WDITH			= 32'h0000_0174;/* 0x5d0	--                                                                                           */  
localparam [31:0]	T8_INVL_MODE		= 32'h0000_0175;/* 0x5d4	--                                                                                           */  
localparam [31:0]	T8_INVL_HF_BAUD		= 32'h0000_0176;/* 0x5d8	--                                                                                           */  
localparam [31:0]	T8_INVL_CLK_PD		= 32'h0000_0177;/* 0x5dc	--                                                                                           */  
localparam [31:0]	T8_TFF_USEDW		= 32'h0000_0178;/* 0x5e0	--                                                                                           */
localparam [31:0]	T8_AXI_WR_EFF_LEN	= 32'h0000_0179;/* 0x5e4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_017a;/* 0x5e8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_017b;/* 0x5ec	--                                                                                           *//*
localparam [31:0]						= 32'h0000_017c;/* 0x5f0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_017d;/* 0x5f4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_017e;/* 0x5f8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_017f;/* 0x5fc    --                                                                                           */  
//_________________________________________________________________________________________________________ 180-18f
localparam [31:0]	T9_CFG_REQ			= 32'h0000_0180;/* 0x600    --                                                                                           */  
localparam [31:0]	T9_BAUD_RATE		= 32'h0000_0181;/* 0x604	--                                                                                           */  
localparam [31:0]	T9_STOP_BIT			= 32'h0000_0182;/* 0x608    --                                                                                           */  
localparam [31:0]	T9_P_CHK			= 32'h0000_0183;/* 0x60c	--                                                                                           */  
localparam [31:0]	T9_D_WDITH			= 32'h0000_0184;/* 0x610	--                                                                                           */  
localparam [31:0]	T9_INVL_MODE		= 32'h0000_0185;/* 0x614	--                                                                                           */  
localparam [31:0]	T9_INVL_HF_BAUD		= 32'h0000_0186;/* 0x618	--                                                                                           */  
localparam [31:0]	T9_INVL_CLK_PD		= 32'h0000_0187;/* 0x61c	--                                                                                           */  
localparam [31:0]	T9_TFF_USEDW		= 32'h0000_0188;/* 0x620	--                                                                                           */
localparam [31:0]	T9_AXI_WR_EFF_LEN	= 32'h0000_0189;/* 0x624	--                                                                                           *//*
localparam [31:0]						= 32'h0000_018a;/* 0x628	--                                                                                           *//*
localparam [31:0]						= 32'h0000_018b;/* 0x62c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_018c;/* 0x630	--                                                                                           *//*
localparam [31:0]						= 32'h0000_018d;/* 0x634	--                                                                                           *//*
localparam [31:0]						= 32'h0000_018e;/* 0x638	--                                                                                           *//*
localparam [31:0]						= 32'h0000_018f;/* 0x63c    --                                                                                           */  
//_________________________________________________________________________________________________________ 190-19f
localparam [31:0]	T10_CFG_REQ			= 32'h0000_0190;/* 0x640    --                                                                                           */  
localparam [31:0]	T10_BAUD_RATE		= 32'h0000_0191;/* 0x644	--                                                                                           */  
localparam [31:0]	T10_STOP_BIT		= 32'h0000_0192;/* 0x648    --                                                                                           */  
localparam [31:0]	T10_P_CHK			= 32'h0000_0193;/* 0x64c	--                                                                                           */  
localparam [31:0]	T10_D_WDITH			= 32'h0000_0194;/* 0x650	--                                                                                           */  
localparam [31:0]	T10_INVL_MODE		= 32'h0000_0195;/* 0x654	--                                                                                           */  
localparam [31:0]	T10_INVL_HF_BAUD	= 32'h0000_0196;/* 0x658	--                                                                                           */  
localparam [31:0]	T10_INVL_CLK_PD		= 32'h0000_0197;/* 0x65c	--                                                                                           */  
localparam [31:0]	T10_TFF_USEDW		= 32'h0000_0198;/* 0x660	--                                                                                           */
localparam [31:0]	T10_AXI_WR_EFF_LEN	= 32'h0000_0199;/* 0x664	--                                                                                           *//*
localparam [31:0]						= 32'h0000_019a;/* 0x668	--                                                                                           *//*
localparam [31:0]						= 32'h0000_019b;/* 0x66c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_019c;/* 0x670	--                                                                                           *//*
localparam [31:0]						= 32'h0000_019d;/* 0x674	--                                                                                           *//*
localparam [31:0]						= 32'h0000_019e;/* 0x678	--                                                                                           *//*
localparam [31:0]						= 32'h0000_019f;/* 0x67c    --                                                                                           */  
//_________________________________________________________________________________________________________ 1a0-1af
localparam [31:0]	T11_CFG_REQ			= 32'h0000_01a0;/* 0x680    --                                                                                           */  
localparam [31:0]	T11_BAUD_RATE		= 32'h0000_01a1;/* 0x684	--                                                                                           */  
localparam [31:0]	T11_STOP_BIT		= 32'h0000_01a2;/* 0x688    --                                                                                           */  
localparam [31:0]	T11_P_CHK			= 32'h0000_01a3;/* 0x68c	--                                                                                           */  
localparam [31:0]	T11_D_WDITH			= 32'h0000_01a4;/* 0x690	--                                                                                           */  
localparam [31:0]	T11_INVL_MODE		= 32'h0000_01a5;/* 0x694	--                                                                                           */  
localparam [31:0]	T11_INVL_HF_BAUD	= 32'h0000_01a6;/* 0x698	--                                                                                           */  
localparam [31:0]	T11_INVL_CLK_PD		= 32'h0000_01a7;/* 0x69c	--                                                                                           */  
localparam [31:0]	T11_TFF_USEDW		= 32'h0000_01a8;/* 0x6a0	--                                                                                           */
localparam [31:0]	T11_AXI_WR_EFF_LEN	= 32'h0000_01a9;/* 0x6a4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01aa;/* 0x6a8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01ab;/* 0x6ac	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01ac;/* 0x6b0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01ad;/* 0x6b4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01ae;/* 0x6b8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01af;/* 0x6bc    --                                                                                           */  
//_________________________________________________________________________________________________________ 1b0-1bf
localparam [31:0]	T12_CFG_REQ			= 32'h0000_01b0;/* 0x6c0    --                                                                                           */  
localparam [31:0]	T12_BAUD_RATE		= 32'h0000_01b1;/* 0x6c4	--                                                                                           */  
localparam [31:0]	T12_STOP_BIT		= 32'h0000_01b2;/* 0x6c8    --                                                                                           */  
localparam [31:0]	T12_P_CHK			= 32'h0000_01b3;/* 0x6cc	--                                                                                           */  
localparam [31:0]	T12_D_WDITH			= 32'h0000_01b4;/* 0x6d0	--                                                                                           */  
localparam [31:0]	T12_INVL_MODE		= 32'h0000_01b5;/* 0x6d4	--                                                                                           */  
localparam [31:0]	T12_INVL_HF_BAUD	= 32'h0000_01b6;/* 0x6d8	--                                                                                           */  
localparam [31:0]	T12_INVL_CLK_PD		= 32'h0000_01b7;/* 0x6dc	--                                                                                           */  
localparam [31:0]	T12_TFF_USEDW		= 32'h0000_01b8;/* 0x6e0	--                                                                                           */
localparam [31:0]	T12_AXI_WR_EFF_LEN	= 32'h0000_01b9;/* 0x6e4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01ba;/* 0x6e8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01bb;/* 0x6ec	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01bc;/* 0x6f0	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01bd;/* 0x6f4	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01be;/* 0x6f8	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01bf;/* 0x6fc    --                                                                                           */
//_________________________________________________________________________________________________________ 1c0-1cf
localparam [31:0]	LITE_STA_ERR_ADDR	= 32'h0000_01c0;/* 0x700    --                                                                                           *//*
localparam [31:0]						= 32'h0000_01c1;/* 0x704	--                                                                                           *//*
localparam [31:0]					 	= 32'h0000_01c2;/* 0x708    --                                                                                           *//*
localparam [31:0]						= 32'h0000_01c3;/* 0x70c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01c4;/* 0x710	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01c5;/* 0x714	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01c6;/* 0x718	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01c7;/* 0x71c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01c8;/* 0x720	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01c9;/* 0x724	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01ca;/* 0x728	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01cb;/* 0x72c	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01cc;/* 0x730	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01cd;/* 0x734	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01ce;/* 0x738	--                                                                                           *//*
localparam [31:0]						= 32'h0000_01cf;/* 0x73c    --                                                                                           */
//_________________________________________________________________________________________________________test
localparam [31:0]	TEST_FLAG0	   		= 32'h0000_01d0;/* 0x740    */
localparam [31:0]	TEST_FLAG1	   		= 32'h0000_01d1;/* 0x744	*/
localparam [31:0]	TEST_FLAG2	   		= 32'h0000_01d2;/* 0x748    */
localparam [31:0]	TEST_FLAG3	   		= 32'h0000_01d3;/* 0x74c	*/
localparam [31:0]	TEST_FLAG4	   		= 32'h0000_01d4;/* 0x750	*/
localparam [31:0]	TEST_FLAG5	   		= 32'h0000_01d5;/* 0x754	*/
localparam [31:0]	TEST_FLAG6	   		= 32'h0000_01d6;/* 0x758	*/
localparam [31:0]	TEST_FLAG7	   		= 32'h0000_01d7;/* 0x75c	*/
localparam [31:0]	TEST_FLAG8	   		= 32'h0000_01d8;/* 0x760	*/
localparam [31:0]	TEST_FLAG9	   		= 32'h0000_01d9;/* 0x764	*/
localparam [31:0]	TEST_FLAG10	   		= 32'h0000_01da;/* 0x768	*/
localparam [31:0]	TEST_FLAG11	   		= 32'h0000_01db;/* 0x76c	*/
localparam [31:0]	TEST_ERR_INFO0		= 32'h0000_01dc;/* 0x770	*/
localparam [31:0]	TEST_ERR_INFO1		= 32'h0000_01dd;/* 0x774	*/
localparam [31:0]	TEST_ERR_INFO2		= 32'h0000_01de;/* 0x778	*/
localparam [31:0]	TEST_ERR_INFO3		= 32'h0000_01df;/* 0x77c    */

localparam [31:0]	TEST_ERR_INFO4		= 32'h0000_01e0;/* 0x780    */
localparam [31:0]	TEST_ERR_INFO5		= 32'h0000_01e1;/* 0x784	*/
localparam [31:0]	TEST_ERR_INFO6		= 32'h0000_01e2;/* 0x788    */
localparam [31:0]	TEST_ERR_INFO7		= 32'h0000_01e3;/* 0x78c	*/
localparam [31:0]	TEST_ERR_INFO8		= 32'h0000_01e4;/* 0x790	*/
localparam [31:0]	TEST_ERR_INFO9		= 32'h0000_01e5;/* 0x794	*/
localparam [31:0]	TEST_ERR_INFO10		= 32'h0000_01e6;/* 0x798	*/
localparam [31:0]	TEST_ERR_INFO11		= 32'h0000_01e7;/* 0x79c	*/


reg  [31:0] bar_reg     [1023:0];
reg  [31:0] w_addr;
reg  [31:0] r_addr;
reg			r1_ar_hs;
(*mark_debug = "true"*)(*keep = "true"*)reg  [3:0] 	r_arbt;
(*mark_debug = "true"*)(*keep = "true"*)reg			r_req;
(*mark_debug = "true"*)(*keep = "true"*)reg  		bar_rd_done;
(*mark_debug = "true"*)(*keep = "true"*)reg  [3:0] 	cs,ns;
(*mark_debug = "true"*)(*keep = "true"*)reg			interupt_clr;
(*mark_debug = "true"*)(*keep = "true"*)reg 		interupt_req_r;
(*mark_debug = "true"*)(*keep = "true"*)reg 		interupt_en;
reg [1:0]	inrpt_clr_mode;
reg [15:0]	inrp_timeout_cnt;
reg [15:0]	rdone_timeout_cnt;
reg [15:0]	sta_inrp_timeout;
reg [15:0]	sta_rdone_timeout;

wire[23:0]	rx_cfg_done_bus = { LITE_REG_R12_CFG_DONE, LITE_REG_R11_CFG_DONE, LITE_REG_R10_CFG_DONE, LITE_REG_R9_CFG_DONE, 
								LITE_REG_R8_CFG_DONE , LITE_REG_R7_CFG_DONE , LITE_REG_R6_CFG_DONE , LITE_REG_R5_CFG_DONE, 
								LITE_REG_R4_CFG_DONE , LITE_REG_R3_CFG_DONE , LITE_REG_R2_CFG_DONE , LITE_REG_R1_CFG_DONE};
								
wire[23:0]	tx_cfg_done_bus = { LITE_REG_T12_CFG_DONE, LITE_REG_T11_CFG_DONE, LITE_REG_T10_CFG_DONE, LITE_REG_T9_CFG_DONE, 
								LITE_REG_T8_CFG_DONE , LITE_REG_T7_CFG_DONE , LITE_REG_T6_CFG_DONE , LITE_REG_T5_CFG_DONE, 
								LITE_REG_T4_CFG_DONE , LITE_REG_T3_CFG_DONE , LITE_REG_T2_CFG_DONE , LITE_REG_T1_CFG_DONE};
								
wire[11:0]	rx_cfg_fsm_rst_done_bus = { LITE_REG_R12_FSM_RST_DONE, LITE_REG_R11_FSM_RST_DONE, LITE_REG_R10_FSM_RST_DONE, LITE_REG_R9_FSM_RST_DONE, 
										LITE_REG_R8_FSM_RST_DONE , LITE_REG_R7_FSM_RST_DONE , LITE_REG_R6_FSM_RST_DONE , LITE_REG_R5_FSM_RST_DONE, 
										LITE_REG_R4_FSM_RST_DONE , LITE_REG_R3_FSM_RST_DONE , LITE_REG_R2_FSM_RST_DONE , LITE_REG_R1_FSM_RST_DONE};
reg [11:0]	rx_cfg_req_is_1orf;
reg [11:0]	tx_cfg_req_is_1orf;

assign interupt_req = interupt_req_r;

// ____________________________________________________w addr
reg  		awready;
wire [31:0] awaddr  = lite_awaddr      ;
wire [2:0] 	awprot  = lite_awprot      ;
wire 		awvalid = lite_awvalid     ;
wire 		aw_hs   = awvalid & awready;

assign lite_awready = awready;
// ____________________________________________________w data
reg  		wready;
wire [31:0] wdata 	= lite_wdata     ;
wire [3:0]  wstrb 	= lite_wstrb     ;
wire 		wvalid 	= lite_wvalid    ;
wire 		w_hs   	= wvalid & wready;

assign lite_wready = wready;
// ____________________________________________________w resp
reg [1:0] 	bresp ;
reg 		bvalid;
wire 		bready 	= lite_bready    ;
wire 		b_hs 	= bvalid & bready;

assign lite_bresp  = bresp ;
assign lite_bvalid = bvalid;
// ____________________________________________________r addr
reg 		arready;
wire [31:0] araddr 	= lite_araddr 	   ;
wire [2:0] 	arprot 	= lite_arprot 	   ;
wire 		arvalid = lite_arvalid 	   ;
wire 		ar_hs 	= arvalid & arready;

assign lite_arready = arready;
// ____________________________________________________r data
reg [31:0]	rdata ;
reg [1:0] 	rresp ;
reg 		rvalid;
wire 		rready	= lite_rready    ;
wire 		r_hs 	= rvalid & rready;

assign lite_rdata  = rdata ;
assign lite_rresp  = rresp ;
assign lite_rvalid = rvalid;

always@(posedge clk,posedge rst) begin
    if(rst)
		r1_ar_hs <= 'd0;
	else
		r1_ar_hs <= ar_hs;
end

always@(posedge clk,posedge rst) begin
    if(rst)
        awready <= 'd1;
    else if(aw_hs)
        awready <= 'd0;
    else if(b_hs)
        awready <= 'd1;
    else 
        awready <= awready;
end

always@(posedge clk,posedge rst) begin
    if(rst)
        wready <= 'd0;
    else if(w_hs)
        wready <= 'd0;
    else if(aw_hs)
        wready <= 'd1;
    else 
        wready <= wready;
end

always@(posedge clk,posedge rst) begin
    if(rst) begin 
        bresp  <= 'd0;
        bvalid <= 'd0;
    end 
	else if(b_hs) begin
        bresp  <= 'd0;
        bvalid <= 'd0;
    end 
	else if(w_hs) begin
        bresp  <= 'd0;
        bvalid <= 'd1;
    end 
	else begin
        bresp  <= bresp ;
        bvalid <= bvalid;
    end
end

always@(posedge clk,posedge rst) begin
    if(rst)
        arready <= 'd1;
    else if(ar_hs)
        arready <= 'd0;
    else if(r_hs)
        arready <= 'd1;
    else 
        arready <= arready;
end

always@(posedge clk, posedge rst) begin
    if(rst) begin
        rdata  <= 'd0;
        rresp  <= 'd0;
        rvalid <= 'd0;
    end
	else if(r1_ar_hs) begin
	    rdata  <= bar_reg[r_addr];
	    rresp  <= 'd0;
	    rvalid <= 'd1;
	end	
	else if(r_hs) begin
        rdata  <= 'd0;
        rresp  <= 'd0;
        rvalid <= 'd0;
    end 
	else begin
        rdata  <= rdata ;
        rresp  <= rresp ;
        rvalid <= rvalid;
    end 
end

always@(posedge clk, posedge rst) begin
	if(rst)
		w_addr <= 'd0;
	else if(aw_hs)
		w_addr <= (awaddr > LITE_BASE_ADDR) ? ((awaddr - LITE_BASE_ADDR) >> 2) : 0;
	else
		w_addr <= w_addr;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		r_addr <= 'd0;
	else if(ar_hs)
		r_addr <= (araddr > LITE_BASE_ADDR) ? ((araddr - LITE_BASE_ADDR) >> 2) : 0;
	else
		r_addr <= r_addr;
end

always@(posedge clk, posedge rst) begin
	if(rst) begin // initial
		bar_reg[INTERUPT_CLEAR               	] <= 0;
		bar_reg[HOST_READ_DONE               	] <= 0;
		bar_reg[INRPT_CLR_MODE               	] <= 1;
		bar_reg[INTERRUPT_EN					] <= 0;
		bar_reg[AXI_RD_LEN						] <= 1;
		bar_reg[AXI_WR_MAX_LEN					] <= 1;

		bar_reg[RX_ALL_CHL_PARA_SYNC         	] <= 0;
		bar_reg[RSYNC_REQ                    	] <= 0;
		bar_reg[RSYNC_BAUD_RATE              	] <= 921600;
		bar_reg[RSYNC_STOP_BIT               	] <= 0;
		bar_reg[RSYNC_P_CHK                  	] <= 0;
		bar_reg[RSYNC_D_WIDTH                	] <= 8;
		bar_reg[RSYNC_STOP_PCHK_ENA          	] <= 0;
		bar_reg[RSYNC_FSM_RST_REQ            	] <= 0;
		bar_reg[RSYNC_AXI_BRUST_LEN          	] <= 15;

		bar_reg[TX_ALL_CHL_PARA_SYNC         	] <= 0;
		bar_reg[TSYNC_REQ                    	] <= 0;
		bar_reg[TSYNC_BAUD_RATE              	] <= 921600;
		bar_reg[TSYNC_STOP_BIT               	] <= 0;
		bar_reg[TSYNC_P_CHK                  	] <= 0;
		bar_reg[TSYNC_D_WIDTH                	] <= 8;
		bar_reg[TSYNC_INVL_MODE              	] <= 0;
		bar_reg[TSYNC_INVL_HF_BAUD           	] <= 1;
		bar_reg[TSYNC_INVL_CLK_PD            	] <= 1;

		bar_reg[R1_CFG_REQ         				] <= 0;
		bar_reg[R1_BAUD_RATE       				] <= 921600;
		bar_reg[R1_STOP_BIT        				] <= 0;
		bar_reg[R1_P_CHK           				] <= 0;
		bar_reg[R1_D_WIDTH         				] <= 8;
		bar_reg[R1_STOP_PCHK_ENA   				] <= 0;
		bar_reg[R1_FSM_RST_REQ     				] <= 0;
		bar_reg[R1_AXI_BRUST_LEN   				] <= 15;
		bar_reg[R1_TIMEOUT_THRD					] <= 5600;


		bar_reg[R2_CFG_REQ         				] <= 0;
		bar_reg[R2_BAUD_RATE       				] <= 921600;
		bar_reg[R2_STOP_BIT        				] <= 0;
		bar_reg[R2_P_CHK           				] <= 0;
		bar_reg[R2_D_WIDTH         				] <= 8;
		bar_reg[R2_STOP_PCHK_ENA   				] <= 0;
		bar_reg[R2_FSM_RST_REQ     				] <= 0;
		bar_reg[R2_AXI_BRUST_LEN   				] <= 15;
		bar_reg[R2_TIMEOUT_THRD					] <= 5600;


		bar_reg[R3_CFG_REQ         				] <= 0;
		bar_reg[R3_BAUD_RATE       				] <= 921600;
		bar_reg[R3_STOP_BIT        				] <= 0;
		bar_reg[R3_P_CHK           				] <= 0;
		bar_reg[R3_D_WIDTH         				] <= 8;
		bar_reg[R3_STOP_PCHK_ENA   				] <= 0;
		bar_reg[R3_FSM_RST_REQ     				] <= 0;
		bar_reg[R3_AXI_BRUST_LEN   				] <= 15;
		bar_reg[R3_TIMEOUT_THRD					] <= 5600;


		bar_reg[R4_CFG_REQ         				] <= 0;
		bar_reg[R4_BAUD_RATE       				] <= 921600;
		bar_reg[R4_STOP_BIT        				] <= 0;
		bar_reg[R4_P_CHK           				] <= 0;
		bar_reg[R4_D_WIDTH         				] <= 8;
		bar_reg[R4_STOP_PCHK_ENA   				] <= 0;
		bar_reg[R4_FSM_RST_REQ     				] <= 0;
		bar_reg[R4_AXI_BRUST_LEN   				] <= 15;
		bar_reg[R4_TIMEOUT_THRD					] <= 5600;


		bar_reg[R5_CFG_REQ         				] <= 0;
		bar_reg[R5_BAUD_RATE       				] <= 921600;
		bar_reg[R5_STOP_BIT        				] <= 0;
		bar_reg[R5_P_CHK           				] <= 0;
		bar_reg[R5_D_WIDTH         				] <= 8;
		bar_reg[R5_STOP_PCHK_ENA   				] <= 0;
		bar_reg[R5_FSM_RST_REQ     				] <= 0;
		bar_reg[R5_AXI_BRUST_LEN   				] <= 15;
		bar_reg[R5_TIMEOUT_THRD					] <= 5600;


		bar_reg[R6_CFG_REQ         				] <= 0;
		bar_reg[R6_BAUD_RATE       				] <= 921600;
		bar_reg[R6_STOP_BIT        				] <= 0;
		bar_reg[R6_P_CHK           				] <= 0;
		bar_reg[R6_D_WIDTH         				] <= 8;
		bar_reg[R6_STOP_PCHK_ENA   				] <= 0;
		bar_reg[R6_FSM_RST_REQ     				] <= 0;
		bar_reg[R6_AXI_BRUST_LEN   				] <= 15;
		bar_reg[R6_TIMEOUT_THRD					] <= 5600;


		bar_reg[R7_CFG_REQ         				] <= 0;
		bar_reg[R7_BAUD_RATE       				] <= 921600;
		bar_reg[R7_STOP_BIT        				] <= 0;
		bar_reg[R7_P_CHK           				] <= 0;
		bar_reg[R7_D_WIDTH         				] <= 8;
		bar_reg[R7_STOP_PCHK_ENA   				] <= 0;
		bar_reg[R7_FSM_RST_REQ     				] <= 0;
		bar_reg[R7_AXI_BRUST_LEN   				] <= 15;
		bar_reg[R7_TIMEOUT_THRD					] <= 5600;


		bar_reg[R8_CFG_REQ         				] <= 0;
		bar_reg[R8_BAUD_RATE       				] <= 921600;
		bar_reg[R8_STOP_BIT        				] <= 0;
		bar_reg[R8_P_CHK           				] <= 0;
		bar_reg[R8_D_WIDTH         				] <= 8;
		bar_reg[R8_STOP_PCHK_ENA   				] <= 0;
		bar_reg[R8_FSM_RST_REQ     				] <= 0;
		bar_reg[R8_AXI_BRUST_LEN   				] <= 15;
		bar_reg[R8_TIMEOUT_THRD					] <= 5600;


		bar_reg[R9_CFG_REQ         				] <= 0;
		bar_reg[R9_BAUD_RATE       				] <= 921600;
		bar_reg[R9_STOP_BIT        				] <= 0;
		bar_reg[R9_P_CHK           				] <= 0;
		bar_reg[R9_D_WIDTH         				] <= 8;
		bar_reg[R9_STOP_PCHK_ENA   				] <= 0;
		bar_reg[R9_FSM_RST_REQ     				] <= 0;
		bar_reg[R9_AXI_BRUST_LEN   				] <= 15;
		bar_reg[R9_TIMEOUT_THRD					] <= 5600;


		bar_reg[R10_CFG_REQ         			] <= 0;
		bar_reg[R10_BAUD_RATE       			] <= 921600;
		bar_reg[R10_STOP_BIT        			] <= 0;
		bar_reg[R10_P_CHK           			] <= 0;
		bar_reg[R10_D_WIDTH         			] <= 8;
		bar_reg[R10_STOP_PCHK_ENA   			] <= 0;
		bar_reg[R10_FSM_RST_REQ     			] <= 0;
		bar_reg[R10_AXI_BRUST_LEN   			] <= 15;
		bar_reg[R10_TIMEOUT_THRD				] <= 5600;


		bar_reg[R11_CFG_REQ         			] <= 0;
		bar_reg[R11_BAUD_RATE       			] <= 921600;
		bar_reg[R11_STOP_BIT        			] <= 0;
		bar_reg[R11_P_CHK           			] <= 0;
		bar_reg[R11_D_WIDTH         			] <= 8;
		bar_reg[R11_STOP_PCHK_ENA   			] <= 0;
		bar_reg[R11_FSM_RST_REQ     			] <= 0;
		bar_reg[R11_AXI_BRUST_LEN   			] <= 15;
		bar_reg[R11_TIMEOUT_THRD				] <= 5600;


		bar_reg[R12_CFG_REQ         			] <= 0;
		bar_reg[R12_BAUD_RATE       			] <= 921600;
		bar_reg[R12_STOP_BIT        			] <= 0;
		bar_reg[R12_P_CHK           			] <= 0;
		bar_reg[R12_D_WIDTH         			] <= 8;
		bar_reg[R12_STOP_PCHK_ENA   			] <= 0;
		bar_reg[R12_FSM_RST_REQ     			] <= 0;
		bar_reg[R12_AXI_BRUST_LEN   			] <= 15;
		bar_reg[R12_TIMEOUT_THRD				] <= 5600;


		bar_reg[T1_CFG_REQ     					] <= 0;
		bar_reg[T1_BAUD_RATE   					] <= 921600;
		bar_reg[T1_STOP_BIT    					] <= 0;
		bar_reg[T1_P_CHK       					] <= 0;
		bar_reg[T1_D_WDITH     					] <= 8;
		bar_reg[T1_INVL_MODE   					] <= 0;
		bar_reg[T1_INVL_HF_BAUD					] <= 1;
		bar_reg[T1_INVL_CLK_PD 					] <= 1;
		bar_reg[T1_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T2_CFG_REQ     					] <= 0;
		bar_reg[T2_BAUD_RATE   					] <= 921600;
		bar_reg[T2_STOP_BIT    					] <= 0;
		bar_reg[T2_P_CHK       					] <= 0;
		bar_reg[T2_D_WDITH     					] <= 8;
		bar_reg[T2_INVL_MODE   					] <= 0;
		bar_reg[T2_INVL_HF_BAUD					] <= 1;
		bar_reg[T2_INVL_CLK_PD 					] <= 1;
		bar_reg[T2_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T3_CFG_REQ     					] <= 0;
		bar_reg[T3_BAUD_RATE   					] <= 921600;
		bar_reg[T3_STOP_BIT    					] <= 0;
		bar_reg[T3_P_CHK       					] <= 0;
		bar_reg[T3_D_WDITH     					] <= 8;
		bar_reg[T3_INVL_MODE   					] <= 0;
		bar_reg[T3_INVL_HF_BAUD					] <= 1;
		bar_reg[T3_INVL_CLK_PD 					] <= 1;
		bar_reg[T3_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T4_CFG_REQ     					] <= 0;
		bar_reg[T4_BAUD_RATE   					] <= 921600;
		bar_reg[T4_STOP_BIT    					] <= 0;
		bar_reg[T4_P_CHK       					] <= 0;
		bar_reg[T4_D_WDITH     					] <= 8;
		bar_reg[T4_INVL_MODE   					] <= 0;
		bar_reg[T4_INVL_HF_BAUD					] <= 1;
		bar_reg[T4_INVL_CLK_PD 					] <= 1;
		bar_reg[T4_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T5_CFG_REQ     					] <= 0;
		bar_reg[T5_BAUD_RATE   					] <= 921600;
		bar_reg[T5_STOP_BIT    					] <= 0;
		bar_reg[T5_P_CHK       					] <= 0;
		bar_reg[T5_D_WDITH     					] <= 8;
		bar_reg[T5_INVL_MODE   					] <= 0;
		bar_reg[T5_INVL_HF_BAUD					] <= 1;
		bar_reg[T5_INVL_CLK_PD 					] <= 1;
		bar_reg[T5_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T6_CFG_REQ     					] <= 0;
		bar_reg[T6_BAUD_RATE   					] <= 921600;
		bar_reg[T6_STOP_BIT    					] <= 0;
		bar_reg[T6_P_CHK       					] <= 0;
		bar_reg[T6_D_WDITH     					] <= 8;
		bar_reg[T6_INVL_MODE   					] <= 0;
		bar_reg[T6_INVL_HF_BAUD					] <= 1;
		bar_reg[T6_INVL_CLK_PD 					] <= 1;
		bar_reg[T6_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T7_CFG_REQ     					] <= 0;
		bar_reg[T7_BAUD_RATE   					] <= 921600;
		bar_reg[T7_STOP_BIT    					] <= 0;
		bar_reg[T7_P_CHK       					] <= 0;
		bar_reg[T7_D_WDITH     					] <= 8;
		bar_reg[T7_INVL_MODE   					] <= 0;
		bar_reg[T7_INVL_HF_BAUD					] <= 1;
		bar_reg[T7_INVL_CLK_PD 					] <= 1;
		bar_reg[T7_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T8_CFG_REQ     					] <= 0;
		bar_reg[T8_BAUD_RATE   					] <= 921600;
		bar_reg[T8_STOP_BIT    					] <= 0;
		bar_reg[T8_P_CHK       					] <= 0;
		bar_reg[T8_D_WDITH     					] <= 8;
		bar_reg[T8_INVL_MODE   					] <= 0;
		bar_reg[T8_INVL_HF_BAUD					] <= 1;
		bar_reg[T8_INVL_CLK_PD 					] <= 1;
		bar_reg[T8_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T9_CFG_REQ     					] <= 0;
		bar_reg[T9_BAUD_RATE   					] <= 921600;
		bar_reg[T9_STOP_BIT    					] <= 0;
		bar_reg[T9_P_CHK       					] <= 0;
		bar_reg[T9_D_WDITH     					] <= 8;
		bar_reg[T9_INVL_MODE   					] <= 0;
		bar_reg[T9_INVL_HF_BAUD					] <= 1;
		bar_reg[T9_INVL_CLK_PD 					] <= 1;
		bar_reg[T9_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T10_CFG_REQ     				] <= 0;
		bar_reg[T10_BAUD_RATE   				] <= 921600;
		bar_reg[T10_STOP_BIT    				] <= 0;
		bar_reg[T10_P_CHK       				] <= 0;
		bar_reg[T10_D_WDITH     				] <= 8;
		bar_reg[T10_INVL_MODE   				] <= 0;
		bar_reg[T10_INVL_HF_BAUD				] <= 1;
		bar_reg[T10_INVL_CLK_PD 				] <= 1;
		bar_reg[T10_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T11_CFG_REQ     				] <= 0;
		bar_reg[T11_BAUD_RATE   				] <= 921600;
		bar_reg[T11_STOP_BIT    				] <= 0;
		bar_reg[T11_P_CHK       				] <= 0;
		bar_reg[T11_D_WDITH     				] <= 8;
		bar_reg[T11_INVL_MODE   				] <= 0;
		bar_reg[T11_INVL_HF_BAUD				] <= 1;
		bar_reg[T11_INVL_CLK_PD 				] <= 1;
		bar_reg[T11_AXI_WR_EFF_LEN				] <= 1;

		bar_reg[T12_CFG_REQ     				] <= 0;
		bar_reg[T12_BAUD_RATE   				] <= 921600;
		bar_reg[T12_STOP_BIT    				] <= 0;
		bar_reg[T12_P_CHK       				] <= 0;
		bar_reg[T12_D_WDITH     				] <= 8;
		bar_reg[T12_INVL_MODE   				] <= 0;
		bar_reg[T12_INVL_HF_BAUD				] <= 1;
		bar_reg[T12_INVL_CLK_PD 				] <= 1;
		bar_reg[T12_AXI_WR_EFF_LEN				] <= 1;
		
		
		bar_reg[TEST_FLAG0	   					] <= 0;
		bar_reg[TEST_FLAG1	   					] <= 0;
		bar_reg[TEST_FLAG2	   					] <= 0;
		bar_reg[TEST_FLAG3	   					] <= 0;
		bar_reg[TEST_FLAG4	   					] <= 0;
		bar_reg[TEST_FLAG5	   					] <= 0;
		bar_reg[TEST_FLAG6	   					] <= 0;
		bar_reg[TEST_FLAG7	   					] <= 0;
		bar_reg[TEST_FLAG8	   					] <= 0;
		bar_reg[TEST_FLAG9	   					] <= 0;
		bar_reg[TEST_FLAG10	   					] <= 0;
		bar_reg[TEST_FLAG11	   					] <= 0;
		
		bar_reg[TEST_ERR_INFO0					] <= 0;
		bar_reg[TEST_ERR_INFO1					] <= 0;
		bar_reg[TEST_ERR_INFO2					] <= 0;
		bar_reg[TEST_ERR_INFO3					] <= 0;
		bar_reg[TEST_ERR_INFO4					] <= 0;
		bar_reg[TEST_ERR_INFO5					] <= 0;
		bar_reg[TEST_ERR_INFO6					] <= 0;
		bar_reg[TEST_ERR_INFO7					] <= 0;
		bar_reg[TEST_ERR_INFO8					] <= 0;
		bar_reg[TEST_ERR_INFO9					] <= 0;
		bar_reg[TEST_ERR_INFO10					] <= 0;
		bar_reg[TEST_ERR_INFO11					] <= 0;
		
		
	end
	else if(w_hs) case(w_addr)
		LOG_VERSION                  	:	`EHOST_RONLY
		LOG_SUB_VERSION              	:	`EHOST_RONLY
		LITE_ONLINE                  	:	`EHOST_RONLY
		INTERUPT_CLEAR               	:if((bar_reg[w_addr] == 0) & (wdata == 1))	`PARA_IEGAL
		HOST_READ_DONE               	:if((bar_reg[w_addr] == 0) & (wdata == 1)) 	`PARA_IEGAL
		FPGA_RD_REQ_CHL              	:	`EHOST_RONLY
		INRPT_CLR_MODE               	:if((bar_reg[w_addr] == 0) & (wdata == 1))	`PARA_IEGAL
		XDMA_TIMEOUT                 	:	`EHOST_RONLY
		INTERRUPT_EN					:if(wdata <= 1) 							`PARA_IEGAL
		AXI_RD_LEN						:if((wdata >= 1) & (wdata <= 8192))			`PARA_IEGAL
		
		RX_ALL_CHL_PARA_SYNC         	:if((rx_cfg_req_is_1orf == 0) & (wdata <= 1))														`PARA_IEGAL
		RSYNC_REQ                    	:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 1) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		RSYNC_BAUD_RATE              	:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		RSYNC_STOP_BIT               	:if(wdata <= 2)																						`PARA_IEGAL
		RSYNC_P_CHK                  	:if(wdata <= 4)																						`PARA_IEGAL
		RSYNC_D_WIDTH                	:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		RSYNC_STOP_PCHK_ENA          	:if(wdata <= 1) 																					`PARA_IEGAL
		RSYNC_FSM_RST_REQ            	:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		RSYNC_AXI_BRUST_LEN          	:if(wdata <= 255)																					`PARA_IEGAL

		TX_ALL_CHL_PARA_SYNC         	:if((tx_cfg_req_is_1orf == 0) & (wdata <= 1))														`PARA_IEGAL
		TSYNC_REQ                    	:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 1) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		TSYNC_BAUD_RATE              	:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		TSYNC_STOP_BIT               	:if(wdata <= 2)																						`PARA_IEGAL
		TSYNC_P_CHK                  	:if(wdata <= 4)																						`PARA_IEGAL
		TSYNC_D_WIDTH                	:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		TSYNC_INVL_MODE              	:if(wdata <= 3)																						`PARA_IEGAL
		TSYNC_INVL_HF_BAUD           	:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		TSYNC_INVL_CLK_PD            	:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL

/*		`R1to12_CFG_REQ         		:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		`R1to12_BAUD_RATE       		:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		`R1to12_STOP_BIT        		:if(wdata <= 2)																						`PARA_IEGAL
		`R1to12_P_CHK           		:if(wdata <= 4)																						`PARA_IEGAL
		`R1to12_D_WIDTH         		:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		`R1to12_STOP_PCHK_ENA   		:if(wdata <= 1) 																					`PARA_IEGAL
		`R1to12_STOP_BIT_ERR_CNT		:	`EHOST_RONLY
		`R1to12_PCHK_ERR_CNT    		:	`EHOST_RONLY
		`R1to12_FSM_RST_REQ     		:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		`R1to12_AXI_BRUST_LEN   		:if(wdata <= 255)																					`PARA_IEGAL
		`R1to12_RFF_USEDW       		:	`EHOST_RONLY

		
		`T1to12_CFG_REQ     			:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		`T1to12_BAUD_RATE   			:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		`T1to12_STOP_BIT    			:if(wdata <= 2)																						`PARA_IEGAL
		`T1to12_P_CHK       			:if(wdata <= 4)																						`PARA_IEGAL
		`T1to12_D_WDITH     			:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		`T1to12_INVL_MODE   			:if(wdata <= 3)																						`PARA_IEGAL
		`T1to12_INVL_HF_BAUD			:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		`T1to12_INVL_CLK_PD 			:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		`T1to12_TFF_USEDW   			:	`EHOST_RONLY*/

		R1_CFG_REQ         				:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R1_BAUD_RATE       				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R1_STOP_BIT        				:if(wdata <= 2)																						`PARA_IEGAL
		R1_P_CHK           				:if(wdata <= 4)																						`PARA_IEGAL
		R1_D_WIDTH         				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R1_STOP_PCHK_ENA   				:if(wdata <= 1) 																					`PARA_IEGAL
		R1_STOP_BIT_ERR_CNT				:	`EHOST_RONLY
		R1_PCHK_ERR_CNT    				:	`EHOST_RONLY
		R1_FSM_RST_REQ     				:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R1_AXI_BRUST_LEN   				:if(wdata <= 255)																					`PARA_IEGAL
		R1_RFF_USEDW       				:	`EHOST_RONLY

		R2_CFG_REQ         				:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R2_BAUD_RATE       				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R2_STOP_BIT        				:if(wdata <= 2)																						`PARA_IEGAL
		R2_P_CHK           				:if(wdata <= 4)																						`PARA_IEGAL
		R2_D_WIDTH         				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R2_STOP_PCHK_ENA   				:if(wdata <= 1) 																					`PARA_IEGAL
		R2_STOP_BIT_ERR_CNT				:	`EHOST_RONLY
		R2_PCHK_ERR_CNT    				:	`EHOST_RONLY
		R2_FSM_RST_REQ     				:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R2_AXI_BRUST_LEN   				:if(wdata <= 255)																					`PARA_IEGAL
		R2_RFF_USEDW       				:	`EHOST_RONLY

		
		R3_CFG_REQ         				:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R3_BAUD_RATE       				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R3_STOP_BIT        				:if(wdata <= 2)																						`PARA_IEGAL
		R3_P_CHK           				:if(wdata <= 4)																						`PARA_IEGAL
		R3_D_WIDTH         				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R3_STOP_PCHK_ENA   				:if(wdata <= 1) 																					`PARA_IEGAL
		R3_STOP_BIT_ERR_CNT				:	`EHOST_RONLY
		R3_PCHK_ERR_CNT    				:	`EHOST_RONLY
		R3_FSM_RST_REQ     				:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R3_AXI_BRUST_LEN   				:if(wdata <= 255)																					`PARA_IEGAL
		R3_RFF_USEDW       				:	`EHOST_RONLY

	
		R4_CFG_REQ         				:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R4_BAUD_RATE       				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R4_STOP_BIT        				:if(wdata <= 2)																						`PARA_IEGAL
		R4_P_CHK           				:if(wdata <= 4)																						`PARA_IEGAL
		R4_D_WIDTH         				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R4_STOP_PCHK_ENA   				:if(wdata <= 1) 																					`PARA_IEGAL
		R4_STOP_BIT_ERR_CNT				:	`EHOST_RONLY
		R4_PCHK_ERR_CNT    				:	`EHOST_RONLY
		R4_FSM_RST_REQ     				:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R4_AXI_BRUST_LEN   				:if(wdata <= 255)																					`PARA_IEGAL
		R4_RFF_USEDW       				:	`EHOST_RONLY

	
		R5_CFG_REQ         				:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R5_BAUD_RATE       				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R5_STOP_BIT        				:if(wdata <= 2)																						`PARA_IEGAL
		R5_P_CHK           				:if(wdata <= 4)																						`PARA_IEGAL
		R5_D_WIDTH         				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R5_STOP_PCHK_ENA   				:if(wdata <= 1) 																					`PARA_IEGAL
		R5_STOP_BIT_ERR_CNT				:	`EHOST_RONLY
		R5_PCHK_ERR_CNT    				:	`EHOST_RONLY
		R5_FSM_RST_REQ     				:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R5_AXI_BRUST_LEN   				:if(wdata <= 255)																					`PARA_IEGAL
		R5_RFF_USEDW       				:	`EHOST_RONLY

	
		R6_CFG_REQ         				:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R6_BAUD_RATE       				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R6_STOP_BIT        				:if(wdata <= 2)																						`PARA_IEGAL
		R6_P_CHK           				:if(wdata <= 4)																						`PARA_IEGAL
		R6_D_WIDTH         				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R6_STOP_PCHK_ENA   				:if(wdata <= 1) 																					`PARA_IEGAL
		R6_STOP_BIT_ERR_CNT				:	`EHOST_RONLY
		R6_PCHK_ERR_CNT    				:	`EHOST_RONLY
		R6_FSM_RST_REQ     				:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R6_AXI_BRUST_LEN   				:if(wdata <= 255)																					`PARA_IEGAL
		R6_RFF_USEDW       				:	`EHOST_RONLY

	
		R7_CFG_REQ         				:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R7_BAUD_RATE       				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R7_STOP_BIT        				:if(wdata <= 2)																						`PARA_IEGAL
		R7_P_CHK           				:if(wdata <= 4)																						`PARA_IEGAL
		R7_D_WIDTH         				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R7_STOP_PCHK_ENA   				:if(wdata <= 1) 																					`PARA_IEGAL
		R7_STOP_BIT_ERR_CNT				:	`EHOST_RONLY
		R7_PCHK_ERR_CNT    				:	`EHOST_RONLY
		R7_FSM_RST_REQ     				:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R7_AXI_BRUST_LEN   				:if(wdata <= 255)																					`PARA_IEGAL
		R7_RFF_USEDW       				:	`EHOST_RONLY

	
		R8_CFG_REQ         				:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R8_BAUD_RATE       				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R8_STOP_BIT        				:if(wdata <= 2)																						`PARA_IEGAL
		R8_P_CHK           				:if(wdata <= 4)																						`PARA_IEGAL
		R8_D_WIDTH         				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R8_STOP_PCHK_ENA   				:if(wdata <= 1) 																					`PARA_IEGAL
		R8_STOP_BIT_ERR_CNT				:	`EHOST_RONLY
		R8_PCHK_ERR_CNT    				:	`EHOST_RONLY
		R8_FSM_RST_REQ     				:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R8_AXI_BRUST_LEN   				:if(wdata <= 255)																					`PARA_IEGAL
		R8_RFF_USEDW       				:	`EHOST_RONLY

	
		R9_CFG_REQ         				:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R9_BAUD_RATE       				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R9_STOP_BIT        				:if(wdata <= 2)																						`PARA_IEGAL
		R9_P_CHK           				:if(wdata <= 4)																						`PARA_IEGAL
		R9_D_WIDTH         				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R9_STOP_PCHK_ENA   				:if(wdata <= 1) 																					`PARA_IEGAL
		R9_STOP_BIT_ERR_CNT				:	`EHOST_RONLY
		R9_PCHK_ERR_CNT    				:	`EHOST_RONLY
		R9_FSM_RST_REQ     				:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R9_AXI_BRUST_LEN   				:if(wdata <= 255)																					`PARA_IEGAL
		R9_RFF_USEDW       				:	`EHOST_RONLY

	
		R10_CFG_REQ         			:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R10_BAUD_RATE       			:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R10_STOP_BIT        			:if(wdata <= 2)																						`PARA_IEGAL
		R10_P_CHK           			:if(wdata <= 4)																						`PARA_IEGAL
		R10_D_WIDTH         			:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R10_STOP_PCHK_ENA   			:if(wdata <= 1) 																					`PARA_IEGAL
		R10_STOP_BIT_ERR_CNT			:	`EHOST_RONLY
		R10_PCHK_ERR_CNT    			:	`EHOST_RONLY
		R10_FSM_RST_REQ     			:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R10_AXI_BRUST_LEN   			:if(wdata <= 255)																					`PARA_IEGAL
		R10_RFF_USEDW       			:	`EHOST_RONLY

		R11_CFG_REQ         			:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R11_BAUD_RATE       			:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R11_STOP_BIT        			:if(wdata <= 2)																						`PARA_IEGAL
		R11_P_CHK           			:if(wdata <= 4)																						`PARA_IEGAL
		R11_D_WIDTH         			:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R11_STOP_PCHK_ENA   			:if(wdata <= 1) 																					`PARA_IEGAL
		R11_STOP_BIT_ERR_CNT			:	`EHOST_RONLY
		R11_PCHK_ERR_CNT    			:	`EHOST_RONLY
		R11_FSM_RST_REQ     			:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R11_AXI_BRUST_LEN   			:if(wdata <= 255)																					`PARA_IEGAL
		R11_RFF_USEDW       			:	`EHOST_RONLY

		R12_CFG_REQ         			:if((bar_reg[RX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		R12_BAUD_RATE       			:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		R12_STOP_BIT        			:if(wdata <= 2)																						`PARA_IEGAL
		R12_P_CHK           			:if(wdata <= 4)																						`PARA_IEGAL
		R12_D_WIDTH         			:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		R12_STOP_PCHK_ENA   			:if(wdata <= 1) 																					`PARA_IEGAL
		R12_STOP_BIT_ERR_CNT			:	`EHOST_RONLY
		R12_PCHK_ERR_CNT    			:	`EHOST_RONLY
		R12_FSM_RST_REQ     			:if(((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2)) & (wdata == 1))								`PARA_IEGAL
		R12_AXI_BRUST_LEN   			:if(wdata <= 255)																					`PARA_IEGAL
		R12_RFF_USEDW       			:	`EHOST_RONLY

	
		T1_CFG_REQ     					:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T1_BAUD_RATE   					:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T1_STOP_BIT    					:if(wdata <= 2)																						`PARA_IEGAL
		T1_P_CHK       					:if(wdata <= 4)																						`PARA_IEGAL
		T1_D_WDITH     					:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T1_INVL_MODE   					:if(wdata <= 3)																						`PARA_IEGAL
		T1_INVL_HF_BAUD					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T1_INVL_CLK_PD 					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T1_TFF_USEDW   					:	`EHOST_RONLY

		T2_CFG_REQ     					:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T2_BAUD_RATE   					:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T2_STOP_BIT    					:if(wdata <= 2)																						`PARA_IEGAL
		T2_P_CHK       					:if(wdata <= 4)																						`PARA_IEGAL
		T2_D_WDITH     					:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T2_INVL_MODE   					:if(wdata <= 3)																						`PARA_IEGAL
		T2_INVL_HF_BAUD					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T2_INVL_CLK_PD 					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T2_TFF_USEDW   					:	`EHOST_RONLY

		T3_CFG_REQ     					:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T3_BAUD_RATE   					:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T3_STOP_BIT    					:if(wdata <= 2)																						`PARA_IEGAL
		T3_P_CHK       					:if(wdata <= 4)																						`PARA_IEGAL
		T3_D_WDITH     					:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T3_INVL_MODE   					:if(wdata <= 3)																						`PARA_IEGAL
		T3_INVL_HF_BAUD					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T3_INVL_CLK_PD 					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T3_TFF_USEDW   					:	`EHOST_RONLY


		T4_CFG_REQ     					:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T4_BAUD_RATE   					:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T4_STOP_BIT    					:if(wdata <= 2)																						`PARA_IEGAL
		T4_P_CHK       					:if(wdata <= 4)																						`PARA_IEGAL
		T4_D_WDITH     					:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T4_INVL_MODE   					:if(wdata <= 3)																						`PARA_IEGAL
		T4_INVL_HF_BAUD					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T4_INVL_CLK_PD 					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T4_TFF_USEDW   					:	`EHOST_RONLY


		T5_CFG_REQ     					:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T5_BAUD_RATE   					:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T5_STOP_BIT    					:if(wdata <= 2)																						`PARA_IEGAL
		T5_P_CHK       					:if(wdata <= 4)																						`PARA_IEGAL
		T5_D_WDITH     					:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T5_INVL_MODE   					:if(wdata <= 3)																						`PARA_IEGAL
		T5_INVL_HF_BAUD					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T5_INVL_CLK_PD 					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T5_TFF_USEDW   					:	`EHOST_RONLY


		T6_CFG_REQ     					:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T6_BAUD_RATE   					:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T6_STOP_BIT    					:if(wdata <= 2)																						`PARA_IEGAL
		T6_P_CHK       					:if(wdata <= 4)																						`PARA_IEGAL
		T6_D_WDITH     					:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T6_INVL_MODE   					:if(wdata <= 3)																						`PARA_IEGAL
		T6_INVL_HF_BAUD					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T6_INVL_CLK_PD 					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T6_TFF_USEDW   					:	`EHOST_RONLY


		T7_CFG_REQ     					:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T7_BAUD_RATE   					:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T7_STOP_BIT    					:if(wdata <= 2)																						`PARA_IEGAL
		T7_P_CHK       					:if(wdata <= 4)																						`PARA_IEGAL
		T7_D_WDITH     					:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T7_INVL_MODE   					:if(wdata <= 3)																						`PARA_IEGAL
		T7_INVL_HF_BAUD					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T7_INVL_CLK_PD 					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T7_TFF_USEDW   					:	`EHOST_RONLY


		T8_CFG_REQ     					:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T8_BAUD_RATE   					:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T8_STOP_BIT    					:if(wdata <= 2)																						`PARA_IEGAL
		T8_P_CHK       					:if(wdata <= 4)																						`PARA_IEGAL
		T8_D_WDITH     					:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T8_INVL_MODE   					:if(wdata <= 3)																						`PARA_IEGAL
		T8_INVL_HF_BAUD					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T8_INVL_CLK_PD 					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T8_TFF_USEDW   					:	`EHOST_RONLY


		T9_CFG_REQ     					:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T9_BAUD_RATE   					:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T9_STOP_BIT    					:if(wdata <= 2)																						`PARA_IEGAL
		T9_P_CHK       					:if(wdata <= 4)																						`PARA_IEGAL
		T9_D_WDITH     					:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T9_INVL_MODE   					:if(wdata <= 3)																						`PARA_IEGAL
		T9_INVL_HF_BAUD					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T9_INVL_CLK_PD 					:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T9_TFF_USEDW   					:	`EHOST_RONLY


		T10_CFG_REQ     				:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T10_BAUD_RATE   				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T10_STOP_BIT    				:if(wdata <= 2)																						`PARA_IEGAL
		T10_P_CHK       				:if(wdata <= 4)																						`PARA_IEGAL
		T10_D_WDITH     				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T10_INVL_MODE   				:if(wdata <= 3)																						`PARA_IEGAL
		T10_INVL_HF_BAUD				:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T10_INVL_CLK_PD 				:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T10_TFF_USEDW   				:	`EHOST_RONLY


		T11_CFG_REQ     				:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T11_BAUD_RATE   				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T11_STOP_BIT    				:if(wdata <= 2)																						`PARA_IEGAL
		T11_P_CHK       				:if(wdata <= 4)																						`PARA_IEGAL
		T11_D_WDITH     				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T11_INVL_MODE   				:if(wdata <= 3)																						`PARA_IEGAL
		T11_INVL_HF_BAUD				:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T11_INVL_CLK_PD 				:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T11_TFF_USEDW   				:	`EHOST_RONLY


		T12_CFG_REQ     				:if((bar_reg[TX_ALL_CHL_PARA_SYNC] == 0) & ((bar_reg[w_addr] == 0) || (bar_reg[w_addr] == 2) || (bar_reg[w_addr] == 3)) & (wdata == 1))	`PARA_IEGAL
		T12_BAUD_RATE   				:if((wdata >= 1) & (wdata <= 10_000_000)) 															`PARA_IEGAL
		T12_STOP_BIT    				:if(wdata <= 2)																						`PARA_IEGAL
		T12_P_CHK       				:if(wdata <= 4)																						`PARA_IEGAL
		T12_D_WDITH     				:if((wdata >= 5) & (wdata <= 8))																	`PARA_IEGAL
		T12_INVL_MODE   				:if(wdata <= 3)																						`PARA_IEGAL
		T12_INVL_HF_BAUD				:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T12_INVL_CLK_PD 				:if((wdata >= 1) & (wdata <= 65535))																`PARA_IEGAL
		T12_TFF_USEDW   				:	`EHOST_RONLY


		default: begin 
			bar_reg[w_addr] <= wdata;
			bar_reg[LITE_STA_ERR_ADDR] <= {32{1'd1}};
		end
	endcase
	else begin
		bar_reg[INTERUPT_CLEAR]  <= (bar_reg[INTERUPT_CLEAR] == 32'd1) ? 32'd0 : bar_reg[INTERUPT_CLEAR];
		bar_reg[HOST_READ_DONE]  <= (bar_reg[HOST_READ_DONE] == 32'd1) ? 32'd0 : bar_reg[HOST_READ_DONE];
		bar_reg[FPGA_RD_REQ_CHL] <= r_req ? {28'd0, r_arbt} : bar_reg[FPGA_RD_REQ_CHL];

		bar_reg[LITE_ONLINE			] <= 32'h5a5a_bcbc;
		bar_reg[LOG_VERSION			] <= LOGIC_VERSION;
		bar_reg[LOG_SUB_VERSION		] <= LOGIC_SUB_VERSION;
		bar_reg[XDMA_TIMEOUT		] <= {inrp_timeout_cnt, rdone_timeout_cnt};

		bar_reg[R1_STOP_BIT_ERR_CNT	] <= {16'd0, LITE_REG_R1_STOP_BIT_ERR_CNT	};
		bar_reg[R1_PCHK_ERR_CNT		] <= {16'd0, LITE_REG_R1_PCHK_ERR_CNT		};
		bar_reg[R1_RFF_USEDW		] <= {21'd0, LITE_REG_R1_RFF_USEDW			};

		bar_reg[R2_STOP_BIT_ERR_CNT	] <= {16'd0, LITE_REG_R2_STOP_BIT_ERR_CNT	};
		bar_reg[R2_PCHK_ERR_CNT		] <= {16'd0, LITE_REG_R2_PCHK_ERR_CNT		};
		bar_reg[R2_RFF_USEDW		] <= {21'd0, LITE_REG_R2_RFF_USEDW			};

		bar_reg[R3_STOP_BIT_ERR_CNT	] <= {16'd0, LITE_REG_R3_STOP_BIT_ERR_CNT	};
		bar_reg[R3_PCHK_ERR_CNT		] <= {16'd0, LITE_REG_R3_PCHK_ERR_CNT		};
		bar_reg[R3_RFF_USEDW		] <= {21'd0, LITE_REG_R3_RFF_USEDW			};

		bar_reg[R4_STOP_BIT_ERR_CNT	] <= {16'd0, LITE_REG_R4_STOP_BIT_ERR_CNT	};
		bar_reg[R4_PCHK_ERR_CNT		] <= {16'd0, LITE_REG_R4_PCHK_ERR_CNT		};
		bar_reg[R4_RFF_USEDW		] <= {21'd0, LITE_REG_R4_RFF_USEDW			};

		bar_reg[R5_STOP_BIT_ERR_CNT	] <= {16'd0, LITE_REG_R5_STOP_BIT_ERR_CNT	};
		bar_reg[R5_PCHK_ERR_CNT		] <= {16'd0, LITE_REG_R5_PCHK_ERR_CNT		};
		bar_reg[R5_RFF_USEDW		] <= {21'd0, LITE_REG_R5_RFF_USEDW			};

		bar_reg[R6_STOP_BIT_ERR_CNT	] <= {16'd0, LITE_REG_R6_STOP_BIT_ERR_CNT	};
		bar_reg[R6_PCHK_ERR_CNT		] <= {16'd0, LITE_REG_R6_PCHK_ERR_CNT		};
		bar_reg[R6_RFF_USEDW		] <= {21'd0, LITE_REG_R6_RFF_USEDW			};

		bar_reg[R7_STOP_BIT_ERR_CNT	] <= {16'd0, LITE_REG_R7_STOP_BIT_ERR_CNT	};
		bar_reg[R7_PCHK_ERR_CNT		] <= {16'd0, LITE_REG_R7_PCHK_ERR_CNT		};
		bar_reg[R7_RFF_USEDW		] <= {21'd0, LITE_REG_R7_RFF_USEDW			};

		bar_reg[R8_STOP_BIT_ERR_CNT	] <= {16'd0, LITE_REG_R8_STOP_BIT_ERR_CNT	};
		bar_reg[R8_PCHK_ERR_CNT		] <= {16'd0, LITE_REG_R8_PCHK_ERR_CNT		};
		bar_reg[R8_RFF_USEDW		] <= {21'd0, LITE_REG_R8_RFF_USEDW			};

		bar_reg[R9_STOP_BIT_ERR_CNT	] <= {16'd0, LITE_REG_R9_STOP_BIT_ERR_CNT	};
		bar_reg[R9_PCHK_ERR_CNT		] <= {16'd0, LITE_REG_R9_PCHK_ERR_CNT		};
		bar_reg[R9_RFF_USEDW		] <= {21'd0, LITE_REG_R9_RFF_USEDW			};

		bar_reg[R10_STOP_BIT_ERR_CNT] <= {16'd0, LITE_REG_R10_STOP_BIT_ERR_CNT	};
		bar_reg[R10_PCHK_ERR_CNT	] <= {16'd0, LITE_REG_R10_PCHK_ERR_CNT		};
		bar_reg[R10_RFF_USEDW		] <= {21'd0, LITE_REG_R10_RFF_USEDW			};

		bar_reg[R11_STOP_BIT_ERR_CNT] <= {16'd0, LITE_REG_R11_STOP_BIT_ERR_CNT	};
		bar_reg[R11_PCHK_ERR_CNT	] <= {16'd0, LITE_REG_R11_PCHK_ERR_CNT		};
		bar_reg[R11_RFF_USEDW		] <= {21'd0, LITE_REG_R11_RFF_USEDW			};

		bar_reg[R12_STOP_BIT_ERR_CNT] <= {16'd0, LITE_REG_R12_STOP_BIT_ERR_CNT	};
		bar_reg[R12_PCHK_ERR_CNT	] <= {16'd0, LITE_REG_R12_PCHK_ERR_CNT		};
		bar_reg[R12_RFF_USEDW		] <= {21'd0, LITE_REG_R12_RFF_USEDW			};

		bar_reg[T1_TFF_USEDW		] <= {21'd0, LITE_REG_T1_TFF_USEDW			};
		bar_reg[T2_TFF_USEDW		] <= {21'd0, LITE_REG_T2_TFF_USEDW			};
		bar_reg[T3_TFF_USEDW		] <= {21'd0, LITE_REG_T3_TFF_USEDW			};
		bar_reg[T4_TFF_USEDW		] <= {21'd0, LITE_REG_T4_TFF_USEDW			};
		bar_reg[T5_TFF_USEDW		] <= {21'd0, LITE_REG_T5_TFF_USEDW			};
		bar_reg[T6_TFF_USEDW		] <= {21'd0, LITE_REG_T6_TFF_USEDW			};
		bar_reg[T7_TFF_USEDW		] <= {21'd0, LITE_REG_T7_TFF_USEDW			};
		bar_reg[T8_TFF_USEDW		] <= {21'd0, LITE_REG_T8_TFF_USEDW			};
		bar_reg[T9_TFF_USEDW		] <= {21'd0, LITE_REG_T9_TFF_USEDW			};
		bar_reg[T10_TFF_USEDW		] <= {21'd0, LITE_REG_T10_TFF_USEDW			};
		bar_reg[T11_TFF_USEDW		] <= {21'd0, LITE_REG_T11_TFF_USEDW			};
		bar_reg[T12_TFF_USEDW		] <= {21'd0, LITE_REG_T12_TFF_USEDW			};

		bar_reg[RSYNC_REQ					]	<=	(bar_reg[RSYNC_REQ			] == 1) ? 15 : (rx_cfg_done_bus == {12{2'd2}}) ? 2 : (rx_cfg_done_bus == {12{2'd3}}) ? 3 : bar_reg[RSYNC_REQ];
		bar_reg[RSYNC_FSM_RST_REQ			]	<=	(bar_reg[RSYNC_FSM_RST_REQ	] == 1) ? 15 : (rx_cfg_fsm_rst_done_bus == {12{1'd1}}) ? 2 : bar_reg[RSYNC_FSM_RST_REQ];
 
		bar_reg[TSYNC_REQ					]	<=	(bar_reg[TSYNC_REQ			] == 1) ? 15 : (tx_cfg_done_bus == {12{2'd2}}) ? 2 : (tx_cfg_done_bus == {12{2'd3}}) ? 3 : bar_reg[TSYNC_REQ];
 
		bar_reg[R1_CFG_REQ					]	<=	(bar_reg[R1_CFG_REQ		] == 1) ? 15 : (LITE_REG_R1_CFG_DONE > 2'd1)         ? {30'd0, LITE_REG_R1_CFG_DONE}  : bar_reg[R1_CFG_REQ	];
		bar_reg[R1_FSM_RST_REQ				]	<=	(bar_reg[R1_FSM_RST_REQ	] == 1) ? 15 : (LITE_REG_R1_FSM_RST_DONE == 1'd1)    ? 2                              : bar_reg[R1_FSM_RST_REQ];
		bar_reg[R2_CFG_REQ					]	<=	(bar_reg[R2_CFG_REQ		] == 1) ? 15 : (LITE_REG_R2_CFG_DONE > 2'd1)         ? {30'd0, LITE_REG_R2_CFG_DONE}  : bar_reg[R2_CFG_REQ	];
		bar_reg[R2_FSM_RST_REQ				]	<=	(bar_reg[R2_FSM_RST_REQ	] == 1) ? 15 : (LITE_REG_R2_FSM_RST_DONE == 1'd1)    ? 2                              : bar_reg[R2_FSM_RST_REQ];
		bar_reg[R3_CFG_REQ					]	<=	(bar_reg[R3_CFG_REQ		] == 1) ? 15 : (LITE_REG_R3_CFG_DONE > 2'd1)         ? {30'd0, LITE_REG_R3_CFG_DONE}  : bar_reg[R3_CFG_REQ	];
		bar_reg[R3_FSM_RST_REQ				]	<=	(bar_reg[R3_FSM_RST_REQ	] == 1) ? 15 : (LITE_REG_R3_FSM_RST_DONE == 1'd1)    ? 2                              : bar_reg[R3_FSM_RST_REQ];
		bar_reg[R4_CFG_REQ					]	<=	(bar_reg[R4_CFG_REQ		] == 1) ? 15 : (LITE_REG_R4_CFG_DONE > 2'd1)         ? {30'd0, LITE_REG_R4_CFG_DONE}  : bar_reg[R4_CFG_REQ	];
		bar_reg[R4_FSM_RST_REQ				]	<=	(bar_reg[R4_FSM_RST_REQ	] == 1) ? 15 : (LITE_REG_R4_FSM_RST_DONE == 1'd1)    ? 2                              : bar_reg[R4_FSM_RST_REQ];
		bar_reg[R5_CFG_REQ					]	<=	(bar_reg[R5_CFG_REQ		] == 1) ? 15 : (LITE_REG_R5_CFG_DONE > 2'd1)         ? {30'd0, LITE_REG_R5_CFG_DONE}  : bar_reg[R5_CFG_REQ	];
		bar_reg[R5_FSM_RST_REQ				]	<=	(bar_reg[R5_FSM_RST_REQ	] == 1) ? 15 : (LITE_REG_R5_FSM_RST_DONE == 1'd1)    ? 2                              : bar_reg[R5_FSM_RST_REQ];
		bar_reg[R6_CFG_REQ					]	<=	(bar_reg[R6_CFG_REQ		] == 1) ? 15 : (LITE_REG_R6_CFG_DONE > 2'd1)         ? {30'd0, LITE_REG_R6_CFG_DONE}  : bar_reg[R6_CFG_REQ	];
		bar_reg[R6_FSM_RST_REQ				]	<=	(bar_reg[R6_FSM_RST_REQ	] == 1) ? 15 : (LITE_REG_R6_FSM_RST_DONE == 1'd1)    ? 2                              : bar_reg[R6_FSM_RST_REQ];
		bar_reg[R7_CFG_REQ					]	<=	(bar_reg[R7_CFG_REQ		] == 1) ? 15 : (LITE_REG_R7_CFG_DONE > 2'd1)         ? {30'd0, LITE_REG_R7_CFG_DONE}  : bar_reg[R7_CFG_REQ	];
		bar_reg[R7_FSM_RST_REQ				]	<=	(bar_reg[R7_FSM_RST_REQ	] == 1) ? 15 : (LITE_REG_R7_FSM_RST_DONE == 1'd1)    ? 2                              : bar_reg[R7_FSM_RST_REQ];
		bar_reg[R8_CFG_REQ					]	<=	(bar_reg[R8_CFG_REQ		] == 1) ? 15 : (LITE_REG_R8_CFG_DONE > 2'd1)         ? {30'd0, LITE_REG_R8_CFG_DONE}  : bar_reg[R8_CFG_REQ	];
		bar_reg[R8_FSM_RST_REQ				]	<=	(bar_reg[R8_FSM_RST_REQ	] == 1) ? 15 : (LITE_REG_R8_FSM_RST_DONE == 1'd1)    ? 2                              : bar_reg[R8_FSM_RST_REQ];
		bar_reg[R9_CFG_REQ					]	<=	(bar_reg[R9_CFG_REQ		] == 1) ? 15 : (LITE_REG_R9_CFG_DONE > 2'd1)         ? {30'd0, LITE_REG_R9_CFG_DONE}  : bar_reg[R9_CFG_REQ	];
		bar_reg[R9_FSM_RST_REQ				]	<=	(bar_reg[R9_FSM_RST_REQ	] == 1) ? 15 : (LITE_REG_R9_FSM_RST_DONE == 1'd1)    ? 2                              : bar_reg[R9_FSM_RST_REQ];
		bar_reg[R10_CFG_REQ					]	<=	(bar_reg[R10_CFG_REQ	] == 1) ? 15 : (LITE_REG_R10_CFG_DONE > 2'd1)        ? {30'd0, LITE_REG_R10_CFG_DONE} : bar_reg[R10_CFG_REQ	];
		bar_reg[R10_FSM_RST_REQ				]	<=	(bar_reg[R10_FSM_RST_REQ] == 1) ? 15 : (LITE_REG_R10_FSM_RST_DONE == 1'd1)   ? 2                              : bar_reg[R10_FSM_RST_REQ];
		bar_reg[R11_CFG_REQ					]	<=	(bar_reg[R11_CFG_REQ	] == 1) ? 15 : (LITE_REG_R11_CFG_DONE > 2'd1)        ? {30'd0, LITE_REG_R11_CFG_DONE} : bar_reg[R11_CFG_REQ	];
		bar_reg[R11_FSM_RST_REQ				]	<=	(bar_reg[R11_FSM_RST_REQ] == 1) ? 15 : (LITE_REG_R11_FSM_RST_DONE == 1'd1)   ? 2                              : bar_reg[R11_FSM_RST_REQ];
		bar_reg[R12_CFG_REQ					]	<=	(bar_reg[R12_CFG_REQ	] == 1) ? 15 : (LITE_REG_R12_CFG_DONE > 2'd1)        ? {30'd0, LITE_REG_R12_CFG_DONE} : bar_reg[R12_CFG_REQ	];
		bar_reg[R12_FSM_RST_REQ				]	<=	(bar_reg[R12_FSM_RST_REQ] == 1) ? 15 : (LITE_REG_R12_FSM_RST_DONE == 1'd1)   ? 2                              : bar_reg[R12_FSM_RST_REQ];

		bar_reg[T1_CFG_REQ					]	<=	(bar_reg[T1_CFG_REQ	] == 1) ? 15 : (LITE_REG_T1_CFG_DONE  > 2'd1) ? {30'd0, LITE_REG_T1_CFG_DONE } : bar_reg[T1_CFG_REQ	];
		bar_reg[T2_CFG_REQ					]	<=	(bar_reg[T2_CFG_REQ	] == 1) ? 15 : (LITE_REG_T2_CFG_DONE  > 2'd1) ? {30'd0, LITE_REG_T2_CFG_DONE } : bar_reg[T2_CFG_REQ	];
		bar_reg[T3_CFG_REQ					]	<=	(bar_reg[T3_CFG_REQ	] == 1) ? 15 : (LITE_REG_T3_CFG_DONE  > 2'd1) ? {30'd0, LITE_REG_T3_CFG_DONE } : bar_reg[T3_CFG_REQ	];
		bar_reg[T4_CFG_REQ					]	<=	(bar_reg[T4_CFG_REQ	] == 1) ? 15 : (LITE_REG_T4_CFG_DONE  > 2'd1) ? {30'd0, LITE_REG_T4_CFG_DONE } : bar_reg[T4_CFG_REQ	];
		bar_reg[T5_CFG_REQ					]	<=	(bar_reg[T5_CFG_REQ	] == 1) ? 15 : (LITE_REG_T5_CFG_DONE  > 2'd1) ? {30'd0, LITE_REG_T5_CFG_DONE } : bar_reg[T5_CFG_REQ	];
		bar_reg[T6_CFG_REQ					]	<=	(bar_reg[T6_CFG_REQ	] == 1) ? 15 : (LITE_REG_T6_CFG_DONE  > 2'd1) ? {30'd0, LITE_REG_T6_CFG_DONE } : bar_reg[T6_CFG_REQ	];
		bar_reg[T7_CFG_REQ					]	<=	(bar_reg[T7_CFG_REQ	] == 1) ? 15 : (LITE_REG_T7_CFG_DONE  > 2'd1) ? {30'd0, LITE_REG_T7_CFG_DONE } : bar_reg[T7_CFG_REQ	];
		bar_reg[T8_CFG_REQ					]	<=	(bar_reg[T8_CFG_REQ	] == 1) ? 15 : (LITE_REG_T8_CFG_DONE  > 2'd1) ? {30'd0, LITE_REG_T8_CFG_DONE } : bar_reg[T8_CFG_REQ	];
		bar_reg[T9_CFG_REQ					]	<=	(bar_reg[T9_CFG_REQ	] == 1) ? 15 : (LITE_REG_T9_CFG_DONE  > 2'd1) ? {30'd0, LITE_REG_T9_CFG_DONE } : bar_reg[T9_CFG_REQ	];
		bar_reg[T10_CFG_REQ					]	<=	(bar_reg[T10_CFG_REQ] == 1) ? 15 : (LITE_REG_T10_CFG_DONE > 2'd1) ? {30'd0, LITE_REG_T10_CFG_DONE} : bar_reg[T10_CFG_REQ];
		bar_reg[T11_CFG_REQ					]	<=	(bar_reg[T11_CFG_REQ] == 1) ? 15 : (LITE_REG_T11_CFG_DONE > 2'd1) ? {30'd0, LITE_REG_T11_CFG_DONE} : bar_reg[T11_CFG_REQ];
		bar_reg[T12_CFG_REQ					]	<=	(bar_reg[T12_CFG_REQ] == 1) ? 15 : (LITE_REG_T12_CFG_DONE > 2'd1) ? {30'd0, LITE_REG_T12_CFG_DONE} : bar_reg[T12_CFG_REQ];
		
		bar_reg[TEST_FLAG0	   				]	<= LR_TEST_FLAG0	   	;		
		bar_reg[TEST_FLAG1	   				]	<= LR_TEST_FLAG1	   	;		
		bar_reg[TEST_FLAG2	   				]	<= LR_TEST_FLAG2	   	;		
		bar_reg[TEST_FLAG3	   				]	<= LR_TEST_FLAG3	   	;		
		bar_reg[TEST_FLAG4	   				]	<= LR_TEST_FLAG4	   	;		
		bar_reg[TEST_FLAG5	   				]	<= LR_TEST_FLAG5	   	;		
		bar_reg[TEST_FLAG6	   				]	<= LR_TEST_FLAG6	   	;		
		bar_reg[TEST_FLAG7	   				]	<= LR_TEST_FLAG7	   	;		
		bar_reg[TEST_FLAG8	   				]	<= LR_TEST_FLAG8	   	;		
		bar_reg[TEST_FLAG9	   				]	<= LR_TEST_FLAG9	   	;		
		bar_reg[TEST_FLAG10	   				]	<= LR_TEST_FLAG10	   	;		
		bar_reg[TEST_FLAG11	   				]	<= LR_TEST_FLAG11	   	;		
		
		bar_reg[TEST_ERR_INFO0				]	<= LR_TEST_ERR_INFO0	;
		bar_reg[TEST_ERR_INFO1				]	<= LR_TEST_ERR_INFO1	;
		bar_reg[TEST_ERR_INFO2				]	<= LR_TEST_ERR_INFO2	;
		bar_reg[TEST_ERR_INFO3				]	<= LR_TEST_ERR_INFO3	;
		bar_reg[TEST_ERR_INFO4				]	<= LR_TEST_ERR_INFO4	;
		bar_reg[TEST_ERR_INFO5				]	<= LR_TEST_ERR_INFO5	;
		bar_reg[TEST_ERR_INFO6				]	<= LR_TEST_ERR_INFO6	;
		bar_reg[TEST_ERR_INFO7				]	<= LR_TEST_ERR_INFO7	;
		bar_reg[TEST_ERR_INFO8				]	<= LR_TEST_ERR_INFO8	;
		bar_reg[TEST_ERR_INFO9				]	<= LR_TEST_ERR_INFO9	;
		bar_reg[TEST_ERR_INFO10				]	<= LR_TEST_ERR_INFO10	;
		bar_reg[TEST_ERR_INFO11				]	<= LR_TEST_ERR_INFO11	;
	end	
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		LITE_REG_AXI_RD_LEN				<= 'd0;
		LITE_REG_AXI_WR_MAX_LEN			<= 'd0;

		LITE_REG_RSYNC_REQ				<= 'd0;
		LITE_REG_RSYNC_BAUD_RATE		<= 'd0;
		LITE_REG_RSYNC_STOP_BIT			<= 'd0;
		LITE_REG_RSYNC_P_CHK			<= 'd0;
		LITE_REG_RSYNC_D_WIDTH			<= 'd0;
		LITE_REG_RSYNC_STOP_PCHK_ENA	<= 'd0;
		LITE_REG_RSYNC_FSM_RST_REQ		<= 'd0;
		LITE_REG_RSYNC_AXI_BRUST_LEN	<= 'd0;

		LITE_REG_TSYNC_REQ				<= 'd0;
		LITE_REG_TSYNC_BAUD_RATE		<= 'd0;
		LITE_REG_TSYNC_STOP_BIT			<= 'd0;
		LITE_REG_TSYNC_P_CHK			<= 'd0;
		LITE_REG_TSYNC_D_WIDTH			<= 'd0;
		LITE_REG_TSYNC_INVL_MODE		<= 'd0;
		LITE_REG_TSYNC_INVL_HF_BAUD		<= 'd0;
		LITE_REG_TSYNC_INVL_CLK_PD		<= 'd0;

		LITE_REG_R1_CFG_REQ				<= 'd0;
		LITE_REG_R1_BAUD_RATE			<= 'd0;
		LITE_REG_R1_STOP_BIT			<= 'd0;
		LITE_REG_R1_P_CHK				<= 'd0;
		LITE_REG_R1_D_WIDTH				<= 'd0;
		LITE_REG_R1_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R1_FSM_RST_REQ			<= 'd0;
		LITE_REG_R1_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R1_TIMEOUT_THRD		<= 'd0;

		LITE_REG_R2_CFG_REQ				<= 'd0;
		LITE_REG_R2_BAUD_RATE			<= 'd0;
		LITE_REG_R2_STOP_BIT			<= 'd0;
		LITE_REG_R2_P_CHK				<= 'd0;
		LITE_REG_R2_D_WIDTH				<= 'd0;
		LITE_REG_R2_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R2_FSM_RST_REQ			<= 'd0;
		LITE_REG_R2_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R2_TIMEOUT_THRD		<= 'd0;


		LITE_REG_R3_CFG_REQ				<= 'd0;
		LITE_REG_R3_BAUD_RATE			<= 'd0;
		LITE_REG_R3_STOP_BIT			<= 'd0;
		LITE_REG_R3_P_CHK				<= 'd0;
		LITE_REG_R3_D_WIDTH				<= 'd0;
		LITE_REG_R3_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R3_FSM_RST_REQ			<= 'd0;
		LITE_REG_R3_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R3_TIMEOUT_THRD		<= 'd0;


		LITE_REG_R4_CFG_REQ				<= 'd0;
		LITE_REG_R4_BAUD_RATE			<= 'd0;
		LITE_REG_R4_STOP_BIT			<= 'd0;
		LITE_REG_R4_P_CHK				<= 'd0;
		LITE_REG_R4_D_WIDTH				<= 'd0;
		LITE_REG_R4_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R4_FSM_RST_REQ			<= 'd0;
		LITE_REG_R4_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R4_TIMEOUT_THRD		<= 'd0;


		LITE_REG_R5_CFG_REQ				<= 'd0;
		LITE_REG_R5_BAUD_RATE			<= 'd0;
		LITE_REG_R5_STOP_BIT			<= 'd0;
		LITE_REG_R5_P_CHK				<= 'd0;
		LITE_REG_R5_D_WIDTH				<= 'd0;
		LITE_REG_R5_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R5_FSM_RST_REQ			<= 'd0;
		LITE_REG_R5_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R5_TIMEOUT_THRD		<= 'd0;


		LITE_REG_R6_CFG_REQ				<= 'd0;
		LITE_REG_R6_BAUD_RATE			<= 'd0;
		LITE_REG_R6_STOP_BIT			<= 'd0;
		LITE_REG_R6_P_CHK				<= 'd0;
		LITE_REG_R6_D_WIDTH				<= 'd0;
		LITE_REG_R6_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R6_FSM_RST_REQ			<= 'd0;
		LITE_REG_R6_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R6_TIMEOUT_THRD		<= 'd0;


		LITE_REG_R7_CFG_REQ				<= 'd0;
		LITE_REG_R7_BAUD_RATE			<= 'd0;
		LITE_REG_R7_STOP_BIT			<= 'd0;
		LITE_REG_R7_P_CHK				<= 'd0;
		LITE_REG_R7_D_WIDTH				<= 'd0;
		LITE_REG_R7_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R7_FSM_RST_REQ			<= 'd0;
		LITE_REG_R7_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R7_TIMEOUT_THRD		<= 'd0;


		LITE_REG_R8_CFG_REQ				<= 'd0;
		LITE_REG_R8_BAUD_RATE			<= 'd0;
		LITE_REG_R8_STOP_BIT			<= 'd0;
		LITE_REG_R8_P_CHK				<= 'd0;
		LITE_REG_R8_D_WIDTH				<= 'd0;
		LITE_REG_R8_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R8_FSM_RST_REQ			<= 'd0;
		LITE_REG_R8_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R8_TIMEOUT_THRD		<= 'd0;


		LITE_REG_R9_CFG_REQ				<= 'd0;
		LITE_REG_R9_BAUD_RATE			<= 'd0;
		LITE_REG_R9_STOP_BIT			<= 'd0;
		LITE_REG_R9_P_CHK				<= 'd0;
		LITE_REG_R9_D_WIDTH				<= 'd0;
		LITE_REG_R9_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R9_FSM_RST_REQ			<= 'd0;
		LITE_REG_R9_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R9_TIMEOUT_THRD		<= 'd0;


		LITE_REG_R10_CFG_REQ			<= 'd0;
		LITE_REG_R10_BAUD_RATE			<= 'd0;
		LITE_REG_R10_STOP_BIT			<= 'd0;
		LITE_REG_R10_P_CHK				<= 'd0;
		LITE_REG_R10_D_WIDTH			<= 'd0;
		LITE_REG_R10_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R10_FSM_RST_REQ		<= 'd0;
		LITE_REG_R10_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R10_TIMEOUT_THRD		<= 'd0;


		LITE_REG_R11_CFG_REQ			<= 'd0;
		LITE_REG_R11_BAUD_RATE			<= 'd0;
		LITE_REG_R11_STOP_BIT			<= 'd0;
		LITE_REG_R11_P_CHK				<= 'd0;
		LITE_REG_R11_D_WIDTH			<= 'd0;
		LITE_REG_R11_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R11_FSM_RST_REQ		<= 'd0;
		LITE_REG_R11_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R11_TIMEOUT_THRD		<= 'd0;


		LITE_REG_R12_CFG_REQ			<= 'd0;
		LITE_REG_R12_BAUD_RATE			<= 'd0;
		LITE_REG_R12_STOP_BIT			<= 'd0;
		LITE_REG_R12_P_CHK				<= 'd0;
		LITE_REG_R12_D_WIDTH			<= 'd0;
		LITE_REG_R12_STOP_PCHK_ENA		<= 'd0;
		LITE_REG_R12_FSM_RST_REQ		<= 'd0;
		LITE_REG_R12_AXI_BRUST_LEN		<= 'd0;
		LITE_REG_R12_TIMEOUT_THRD		<= 'd0;


		LITE_REG_T1_CFG_REQ				<= 'd0;
		LITE_REG_T1_BAUD_RATE			<= 'd0;
		LITE_REG_T1_STOP_BIT			<= 'd0;
		LITE_REG_T1_P_CHK				<= 'd0;
		LITE_REG_T1_D_WDITH				<= 'd0;
		LITE_REG_T1_INVL_MODE			<= 'd0;
		LITE_REG_T1_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T1_INVL_CLK_PD			<= 'd0;
		LITE_REG_T1_AXI_WR_EFF_LEN 		<= 'd0;

		LITE_REG_T2_CFG_REQ				<= 'd0;
		LITE_REG_T2_BAUD_RATE			<= 'd0;
		LITE_REG_T2_STOP_BIT			<= 'd0;
		LITE_REG_T2_P_CHK				<= 'd0;
		LITE_REG_T2_D_WDITH				<= 'd0;
		LITE_REG_T2_INVL_MODE			<= 'd0;
		LITE_REG_T2_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T2_INVL_CLK_PD			<= 'd0;
		LITE_REG_T2_AXI_WR_EFF_LEN 		<= 'd0;

		LITE_REG_T3_CFG_REQ				<= 'd0;
		LITE_REG_T3_BAUD_RATE			<= 'd0;
		LITE_REG_T3_STOP_BIT			<= 'd0;
		LITE_REG_T3_P_CHK				<= 'd0;
		LITE_REG_T3_D_WDITH				<= 'd0;
		LITE_REG_T3_INVL_MODE			<= 'd0;
		LITE_REG_T3_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T3_INVL_CLK_PD			<= 'd0;
		LITE_REG_T3_AXI_WR_EFF_LEN 		<= 'd0;

		LITE_REG_T4_CFG_REQ				<= 'd0;
		LITE_REG_T4_BAUD_RATE			<= 'd0;
		LITE_REG_T4_STOP_BIT			<= 'd0;
		LITE_REG_T4_P_CHK				<= 'd0;
		LITE_REG_T4_D_WDITH				<= 'd0;
		LITE_REG_T4_INVL_MODE			<= 'd0;
		LITE_REG_T4_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T4_INVL_CLK_PD			<= 'd0;
		LITE_REG_T4_AXI_WR_EFF_LEN 		<= 'd0;

		LITE_REG_T5_CFG_REQ				<= 'd0;
		LITE_REG_T5_BAUD_RATE			<= 'd0;
		LITE_REG_T5_STOP_BIT			<= 'd0;
		LITE_REG_T5_P_CHK				<= 'd0;
		LITE_REG_T5_D_WDITH				<= 'd0;
		LITE_REG_T5_INVL_MODE			<= 'd0;
		LITE_REG_T5_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T5_INVL_CLK_PD			<= 'd0;
		LITE_REG_T5_AXI_WR_EFF_LEN 		<= 'd0;

		LITE_REG_T6_CFG_REQ				<= 'd0;
		LITE_REG_T6_BAUD_RATE			<= 'd0;
		LITE_REG_T6_STOP_BIT			<= 'd0;
		LITE_REG_T6_P_CHK				<= 'd0;
		LITE_REG_T6_D_WDITH				<= 'd0;
		LITE_REG_T6_INVL_MODE			<= 'd0;
		LITE_REG_T6_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T6_INVL_CLK_PD			<= 'd0;
		LITE_REG_T6_AXI_WR_EFF_LEN 		<= 'd0;

		LITE_REG_T7_CFG_REQ				<= 'd0;
		LITE_REG_T7_BAUD_RATE			<= 'd0;
		LITE_REG_T7_STOP_BIT			<= 'd0;
		LITE_REG_T7_P_CHK				<= 'd0;
		LITE_REG_T7_D_WDITH				<= 'd0;
		LITE_REG_T7_INVL_MODE			<= 'd0;
		LITE_REG_T7_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T7_INVL_CLK_PD			<= 'd0;
		LITE_REG_T7_AXI_WR_EFF_LEN 		<= 'd0;

		LITE_REG_T8_CFG_REQ				<= 'd0;
		LITE_REG_T8_BAUD_RATE			<= 'd0;
		LITE_REG_T8_STOP_BIT			<= 'd0;
		LITE_REG_T8_P_CHK				<= 'd0;
		LITE_REG_T8_D_WDITH				<= 'd0;
		LITE_REG_T8_INVL_MODE			<= 'd0;
		LITE_REG_T8_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T8_INVL_CLK_PD			<= 'd0;
		LITE_REG_T8_AXI_WR_EFF_LEN 		<= 'd0;

		LITE_REG_T9_CFG_REQ				<= 'd0;
		LITE_REG_T9_BAUD_RATE			<= 'd0;
		LITE_REG_T9_STOP_BIT			<= 'd0;
		LITE_REG_T9_P_CHK				<= 'd0;
		LITE_REG_T9_D_WDITH				<= 'd0;
		LITE_REG_T9_INVL_MODE			<= 'd0;
		LITE_REG_T9_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T9_INVL_CLK_PD			<= 'd0;
		LITE_REG_T9_AXI_WR_EFF_LEN 		<= 'd0;

		LITE_REG_T10_CFG_REQ			<= 'd0;
		LITE_REG_T10_BAUD_RATE			<= 'd0;
		LITE_REG_T10_STOP_BIT			<= 'd0;
		LITE_REG_T10_P_CHK				<= 'd0;
		LITE_REG_T10_D_WDITH			<= 'd0;
		LITE_REG_T10_INVL_MODE			<= 'd0;
		LITE_REG_T10_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T10_INVL_CLK_PD		<= 'd0;
		LITE_REG_T10_AXI_WR_EFF_LEN 	<= 'd0;

		LITE_REG_T11_CFG_REQ			<= 'd0;
		LITE_REG_T11_BAUD_RATE			<= 'd0;
		LITE_REG_T11_STOP_BIT			<= 'd0;
		LITE_REG_T11_P_CHK				<= 'd0;
		LITE_REG_T11_D_WDITH			<= 'd0;
		LITE_REG_T11_INVL_MODE			<= 'd0;
		LITE_REG_T11_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T11_INVL_CLK_PD		<= 'd0;
		LITE_REG_T11_AXI_WR_EFF_LEN 	<= 'd0;

		LITE_REG_T12_CFG_REQ			<= 'd0;
		LITE_REG_T12_BAUD_RATE			<= 'd0;
		LITE_REG_T12_STOP_BIT			<= 'd0;
		LITE_REG_T12_P_CHK				<= 'd0;
		LITE_REG_T12_D_WDITH			<= 'd0;
		LITE_REG_T12_INVL_MODE			<= 'd0;
		LITE_REG_T12_INVL_HF_BAUD		<= 'd0;
		LITE_REG_T12_INVL_CLK_PD		<= 'd0;
		LITE_REG_T12_AXI_WR_EFF_LEN 	<= 'd0;
	end
	else begin
		LITE_REG_AXI_RD_LEN				<= (!w_hs) ?  bar_reg[AXI_RD_LEN				][15:0]			: LITE_REG_AXI_RD_LEN				;
		LITE_REG_AXI_WR_MAX_LEN			<= (!w_hs) ?  bar_reg[AXI_WR_MAX_LEN			][15:0]			: LITE_REG_AXI_WR_MAX_LEN			;

		LITE_REG_RSYNC_REQ				<= (!w_hs) ? (bar_reg[RSYNC_REQ					] == 1)			: LITE_REG_RSYNC_REQ				;
		LITE_REG_RSYNC_BAUD_RATE		<= (!w_hs) ?  bar_reg[RSYNC_BAUD_RATE			][31:0]		 	: LITE_REG_RSYNC_BAUD_RATE			;
		LITE_REG_RSYNC_STOP_BIT			<= (!w_hs) ?  bar_reg[RSYNC_STOP_BIT			][3:0]		 	: LITE_REG_RSYNC_STOP_BIT			;
		LITE_REG_RSYNC_P_CHK			<= (!w_hs) ?  bar_reg[RSYNC_P_CHK				][3:0]		 	: LITE_REG_RSYNC_P_CHK				;
		LITE_REG_RSYNC_D_WIDTH			<= (!w_hs) ?  bar_reg[RSYNC_D_WIDTH				][3:0]		 	: LITE_REG_RSYNC_D_WIDTH			;
		LITE_REG_RSYNC_STOP_PCHK_ENA	<= (!w_hs) ?  bar_reg[RSYNC_STOP_PCHK_ENA		][0]			: LITE_REG_RSYNC_STOP_PCHK_ENA		;
		LITE_REG_RSYNC_FSM_RST_REQ		<= (!w_hs) ? (bar_reg[RSYNC_FSM_RST_REQ			] == 1)			: LITE_REG_RSYNC_FSM_RST_REQ		;
		LITE_REG_RSYNC_AXI_BRUST_LEN	<= (!w_hs) ?  bar_reg[RSYNC_AXI_BRUST_LEN		][7:0]		 	: LITE_REG_RSYNC_AXI_BRUST_LEN		;

		LITE_REG_TSYNC_REQ				<= (!w_hs) ? (bar_reg[TSYNC_REQ					] == 1)			: LITE_REG_TSYNC_REQ				;
		LITE_REG_TSYNC_BAUD_RATE		<= (!w_hs) ?  bar_reg[TSYNC_BAUD_RATE			][31:0]		 	: LITE_REG_TSYNC_BAUD_RATE			;
		LITE_REG_TSYNC_STOP_BIT			<= (!w_hs) ?  bar_reg[TSYNC_STOP_BIT			][3:0]		 	: LITE_REG_TSYNC_STOP_BIT			;
		LITE_REG_TSYNC_P_CHK			<= (!w_hs) ?  bar_reg[TSYNC_P_CHK				][3:0]		 	: LITE_REG_TSYNC_P_CHK				;
		LITE_REG_TSYNC_D_WIDTH			<= (!w_hs) ?  bar_reg[TSYNC_D_WIDTH				][3:0]		 	: LITE_REG_TSYNC_D_WIDTH			;
		LITE_REG_TSYNC_INVL_MODE		<= (!w_hs) ?  bar_reg[TSYNC_INVL_MODE			][1:0]		 	: LITE_REG_TSYNC_INVL_MODE			;
		LITE_REG_TSYNC_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[TSYNC_INVL_HF_BAUD		][15:0]		 	: LITE_REG_TSYNC_INVL_HF_BAUD		;
		LITE_REG_TSYNC_INVL_CLK_PD		<= (!w_hs) ?  bar_reg[TSYNC_INVL_CLK_PD			][15:0]		 	: LITE_REG_TSYNC_INVL_CLK_PD		;
													  
		LITE_REG_R1_CFG_REQ				<= (!w_hs) ? (bar_reg[R1_CFG_REQ				] == 1)			: LITE_REG_R1_CFG_REQ				;
		LITE_REG_R1_BAUD_RATE			<= (!w_hs) ?  bar_reg[R1_BAUD_RATE				][31:0]		 	: LITE_REG_R1_BAUD_RATE				;
		LITE_REG_R1_STOP_BIT			<= (!w_hs) ?  bar_reg[R1_STOP_BIT				][3:0]		 	: LITE_REG_R1_STOP_BIT				;
		LITE_REG_R1_P_CHK				<= (!w_hs) ?  bar_reg[R1_P_CHK					][3:0]		 	: LITE_REG_R1_P_CHK					;
		LITE_REG_R1_D_WIDTH				<= (!w_hs) ?  bar_reg[R1_D_WIDTH				][3:0]		 	: LITE_REG_R1_D_WIDTH				;
		LITE_REG_R1_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R1_STOP_PCHK_ENA			][0]			: LITE_REG_R1_STOP_PCHK_ENA			;
		LITE_REG_R1_FSM_RST_REQ			<= (!w_hs) ? (bar_reg[R1_FSM_RST_REQ			] == 1)			: LITE_REG_R1_FSM_RST_REQ			;
		LITE_REG_R1_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R1_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R1_AXI_BRUST_LEN			;
		LITE_REG_R1_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R1_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R1_TIMEOUT_THRD			;
													  
		LITE_REG_R2_CFG_REQ				<= (!w_hs) ? (bar_reg[R2_CFG_REQ				] == 1)			: LITE_REG_R2_CFG_REQ				;
		LITE_REG_R2_BAUD_RATE			<= (!w_hs) ?  bar_reg[R2_BAUD_RATE				][31:0]		 	: LITE_REG_R2_BAUD_RATE				;
		LITE_REG_R2_STOP_BIT			<= (!w_hs) ?  bar_reg[R2_STOP_BIT				][3:0]		 	: LITE_REG_R2_STOP_BIT				;
		LITE_REG_R2_P_CHK				<= (!w_hs) ?  bar_reg[R2_P_CHK					][3:0]		 	: LITE_REG_R2_P_CHK					;
		LITE_REG_R2_D_WIDTH				<= (!w_hs) ?  bar_reg[R2_D_WIDTH				][3:0]		 	: LITE_REG_R2_D_WIDTH				;
		LITE_REG_R2_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R2_STOP_PCHK_ENA			][0]			: LITE_REG_R2_STOP_PCHK_ENA			;
		LITE_REG_R2_FSM_RST_REQ			<= (!w_hs) ? (bar_reg[R2_FSM_RST_REQ			] == 1)			: LITE_REG_R2_FSM_RST_REQ			;
		LITE_REG_R2_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R2_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R2_AXI_BRUST_LEN			;
		LITE_REG_R2_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R2_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R2_TIMEOUT_THRD			;
													  
		LITE_REG_R3_CFG_REQ				<= (!w_hs) ? (bar_reg[R3_CFG_REQ				] == 1)			: LITE_REG_R3_CFG_REQ				;
		LITE_REG_R3_BAUD_RATE			<= (!w_hs) ?  bar_reg[R3_BAUD_RATE				][31:0]		 	: LITE_REG_R3_BAUD_RATE				;
		LITE_REG_R3_STOP_BIT			<= (!w_hs) ?  bar_reg[R3_STOP_BIT				][3:0]		 	: LITE_REG_R3_STOP_BIT				;
		LITE_REG_R3_P_CHK				<= (!w_hs) ?  bar_reg[R3_P_CHK					][3:0]		 	: LITE_REG_R3_P_CHK					;
		LITE_REG_R3_D_WIDTH				<= (!w_hs) ?  bar_reg[R3_D_WIDTH				][3:0]		 	: LITE_REG_R3_D_WIDTH				;
		LITE_REG_R3_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R3_STOP_PCHK_ENA			][0]			: LITE_REG_R3_STOP_PCHK_ENA			;
		LITE_REG_R3_FSM_RST_REQ			<= (!w_hs) ? (bar_reg[R3_FSM_RST_REQ			] == 1)			: LITE_REG_R3_FSM_RST_REQ			;
		LITE_REG_R3_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R3_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R3_AXI_BRUST_LEN			;
		LITE_REG_R3_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R3_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R3_TIMEOUT_THRD			;
													  
		LITE_REG_R4_CFG_REQ				<= (!w_hs) ? (bar_reg[R4_CFG_REQ				] == 1)			: LITE_REG_R4_CFG_REQ				;
		LITE_REG_R4_BAUD_RATE			<= (!w_hs) ?  bar_reg[R4_BAUD_RATE				][31:0]		 	: LITE_REG_R4_BAUD_RATE				;
		LITE_REG_R4_STOP_BIT			<= (!w_hs) ?  bar_reg[R4_STOP_BIT				][3:0]		 	: LITE_REG_R4_STOP_BIT				;
		LITE_REG_R4_P_CHK				<= (!w_hs) ?  bar_reg[R4_P_CHK					][3:0]		 	: LITE_REG_R4_P_CHK					;
		LITE_REG_R4_D_WIDTH				<= (!w_hs) ?  bar_reg[R4_D_WIDTH				][3:0]		 	: LITE_REG_R4_D_WIDTH				;
		LITE_REG_R4_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R4_STOP_PCHK_ENA			][0]			: LITE_REG_R4_STOP_PCHK_ENA			;
		LITE_REG_R4_FSM_RST_REQ			<= (!w_hs) ? (bar_reg[R4_FSM_RST_REQ			] == 1)			: LITE_REG_R4_FSM_RST_REQ			;
		LITE_REG_R4_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R4_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R4_AXI_BRUST_LEN			;
		LITE_REG_R4_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R4_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R4_TIMEOUT_THRD			;
													  
		LITE_REG_R5_CFG_REQ				<= (!w_hs) ? (bar_reg[R5_CFG_REQ				] == 1)			: LITE_REG_R5_CFG_REQ				;
		LITE_REG_R5_BAUD_RATE			<= (!w_hs) ?  bar_reg[R5_BAUD_RATE				][31:0]		 	: LITE_REG_R5_BAUD_RATE				;
		LITE_REG_R5_STOP_BIT			<= (!w_hs) ?  bar_reg[R5_STOP_BIT				][3:0]		 	: LITE_REG_R5_STOP_BIT				;
		LITE_REG_R5_P_CHK				<= (!w_hs) ?  bar_reg[R5_P_CHK					][3:0]		 	: LITE_REG_R5_P_CHK					;
		LITE_REG_R5_D_WIDTH				<= (!w_hs) ?  bar_reg[R5_D_WIDTH				][3:0]		 	: LITE_REG_R5_D_WIDTH				;
		LITE_REG_R5_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R5_STOP_PCHK_ENA			][0]			: LITE_REG_R5_STOP_PCHK_ENA			;
		LITE_REG_R5_FSM_RST_REQ			<= (!w_hs) ? (bar_reg[R5_FSM_RST_REQ			] == 1)			: LITE_REG_R5_FSM_RST_REQ			;
		LITE_REG_R5_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R5_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R5_AXI_BRUST_LEN			;
		LITE_REG_R5_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R5_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R5_TIMEOUT_THRD			;
													  
		LITE_REG_R6_CFG_REQ				<= (!w_hs) ? (bar_reg[R6_CFG_REQ				] == 1)			: LITE_REG_R6_CFG_REQ				;
		LITE_REG_R6_BAUD_RATE			<= (!w_hs) ?  bar_reg[R6_BAUD_RATE				][31:0]		 	: LITE_REG_R6_BAUD_RATE				;
		LITE_REG_R6_STOP_BIT			<= (!w_hs) ?  bar_reg[R6_STOP_BIT				][3:0]		 	: LITE_REG_R6_STOP_BIT				;
		LITE_REG_R6_P_CHK				<= (!w_hs) ?  bar_reg[R6_P_CHK					][3:0]		 	: LITE_REG_R6_P_CHK					;
		LITE_REG_R6_D_WIDTH				<= (!w_hs) ?  bar_reg[R6_D_WIDTH				][3:0]		 	: LITE_REG_R6_D_WIDTH				;
		LITE_REG_R6_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R6_STOP_PCHK_ENA			][0]			: LITE_REG_R6_STOP_PCHK_ENA			;
		LITE_REG_R6_FSM_RST_REQ			<= (!w_hs) ? (bar_reg[R6_FSM_RST_REQ			] == 1)			: LITE_REG_R6_FSM_RST_REQ			;
		LITE_REG_R6_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R6_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R6_AXI_BRUST_LEN			;
		LITE_REG_R6_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R6_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R6_TIMEOUT_THRD			;
													  
		LITE_REG_R7_CFG_REQ				<= (!w_hs) ? (bar_reg[R7_CFG_REQ				] == 1)			: LITE_REG_R7_CFG_REQ				;
		LITE_REG_R7_BAUD_RATE			<= (!w_hs) ?  bar_reg[R7_BAUD_RATE				][31:0]		 	: LITE_REG_R7_BAUD_RATE				;
		LITE_REG_R7_STOP_BIT			<= (!w_hs) ?  bar_reg[R7_STOP_BIT				][3:0]		 	: LITE_REG_R7_STOP_BIT				;
		LITE_REG_R7_P_CHK				<= (!w_hs) ?  bar_reg[R7_P_CHK					][3:0]		 	: LITE_REG_R7_P_CHK					;
		LITE_REG_R7_D_WIDTH				<= (!w_hs) ?  bar_reg[R7_D_WIDTH				][3:0]		 	: LITE_REG_R7_D_WIDTH				;
		LITE_REG_R7_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R7_STOP_PCHK_ENA			][0]			: LITE_REG_R7_STOP_PCHK_ENA			;
		LITE_REG_R7_FSM_RST_REQ			<= (!w_hs) ? (bar_reg[R7_FSM_RST_REQ			] == 1)			: LITE_REG_R7_FSM_RST_REQ			;
		LITE_REG_R7_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R7_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R7_AXI_BRUST_LEN			;
		LITE_REG_R7_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R7_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R7_TIMEOUT_THRD			;
													  
		LITE_REG_R8_CFG_REQ				<= (!w_hs) ? (bar_reg[R8_CFG_REQ				] == 1)			: LITE_REG_R8_CFG_REQ				;
		LITE_REG_R8_BAUD_RATE			<= (!w_hs) ?  bar_reg[R8_BAUD_RATE				][31:0]		 	: LITE_REG_R8_BAUD_RATE				;
		LITE_REG_R8_STOP_BIT			<= (!w_hs) ?  bar_reg[R8_STOP_BIT				][3:0]		 	: LITE_REG_R8_STOP_BIT				;
		LITE_REG_R8_P_CHK				<= (!w_hs) ?  bar_reg[R8_P_CHK					][3:0]		 	: LITE_REG_R8_P_CHK					;
		LITE_REG_R8_D_WIDTH				<= (!w_hs) ?  bar_reg[R8_D_WIDTH				][3:0]		 	: LITE_REG_R8_D_WIDTH				;
		LITE_REG_R8_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R8_STOP_PCHK_ENA			][0]			: LITE_REG_R8_STOP_PCHK_ENA			;
		LITE_REG_R8_FSM_RST_REQ			<= (!w_hs) ? (bar_reg[R8_FSM_RST_REQ			] == 1)			: LITE_REG_R8_FSM_RST_REQ			;
		LITE_REG_R8_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R8_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R8_AXI_BRUST_LEN			;
		LITE_REG_R8_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R8_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R8_TIMEOUT_THRD			;
													  
		LITE_REG_R9_CFG_REQ				<= (!w_hs) ? (bar_reg[R9_CFG_REQ				] == 1)			: LITE_REG_R9_CFG_REQ				;
		LITE_REG_R9_BAUD_RATE			<= (!w_hs) ?  bar_reg[R9_BAUD_RATE				][31:0]		 	: LITE_REG_R9_BAUD_RATE				;
		LITE_REG_R9_STOP_BIT			<= (!w_hs) ?  bar_reg[R9_STOP_BIT				][3:0]		 	: LITE_REG_R9_STOP_BIT				;
		LITE_REG_R9_P_CHK				<= (!w_hs) ?  bar_reg[R9_P_CHK					][3:0]		 	: LITE_REG_R9_P_CHK					;
		LITE_REG_R9_D_WIDTH				<= (!w_hs) ?  bar_reg[R9_D_WIDTH				][3:0]		 	: LITE_REG_R9_D_WIDTH				;
		LITE_REG_R9_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R9_STOP_PCHK_ENA			][0]			: LITE_REG_R9_STOP_PCHK_ENA			;
		LITE_REG_R9_FSM_RST_REQ			<= (!w_hs) ? (bar_reg[R9_FSM_RST_REQ			] == 1)			: LITE_REG_R9_FSM_RST_REQ			;
		LITE_REG_R9_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R9_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R9_AXI_BRUST_LEN			;
		LITE_REG_R9_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R9_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R9_TIMEOUT_THRD			;
													  
		LITE_REG_R10_CFG_REQ			<= (!w_hs) ? (bar_reg[R10_CFG_REQ				] == 1)			: LITE_REG_R10_CFG_REQ				;
		LITE_REG_R10_BAUD_RATE			<= (!w_hs) ?  bar_reg[R10_BAUD_RATE				][31:0]		 	: LITE_REG_R10_BAUD_RATE			;
		LITE_REG_R10_STOP_BIT			<= (!w_hs) ?  bar_reg[R10_STOP_BIT				][3:0]		 	: LITE_REG_R10_STOP_BIT				;
		LITE_REG_R10_P_CHK				<= (!w_hs) ?  bar_reg[R10_P_CHK					][3:0]		 	: LITE_REG_R10_P_CHK				;
		LITE_REG_R10_D_WIDTH			<= (!w_hs) ?  bar_reg[R10_D_WIDTH				][3:0]		 	: LITE_REG_R10_D_WIDTH				;
		LITE_REG_R10_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R10_STOP_PCHK_ENA			][0]			: LITE_REG_R10_STOP_PCHK_ENA		;
		LITE_REG_R10_FSM_RST_REQ		<= (!w_hs) ? (bar_reg[R10_FSM_RST_REQ			] == 1)			: LITE_REG_R10_FSM_RST_REQ			;
		LITE_REG_R10_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R10_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R10_AXI_BRUST_LEN		;
		LITE_REG_R10_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R10_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R10_TIMEOUT_THRD			;
													  
		LITE_REG_R11_CFG_REQ			<= (!w_hs) ? (bar_reg[R11_CFG_REQ				] == 1)			: LITE_REG_R11_CFG_REQ				;
		LITE_REG_R11_BAUD_RATE			<= (!w_hs) ?  bar_reg[R11_BAUD_RATE				][31:0]		 	: LITE_REG_R11_BAUD_RATE			;
		LITE_REG_R11_STOP_BIT			<= (!w_hs) ?  bar_reg[R11_STOP_BIT				][3:0]		 	: LITE_REG_R11_STOP_BIT				;
		LITE_REG_R11_P_CHK				<= (!w_hs) ?  bar_reg[R11_P_CHK					][3:0]		 	: LITE_REG_R11_P_CHK				;
		LITE_REG_R11_D_WIDTH			<= (!w_hs) ?  bar_reg[R11_D_WIDTH				][3:0]		 	: LITE_REG_R11_D_WIDTH				;
		LITE_REG_R11_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R11_STOP_PCHK_ENA			][0]			: LITE_REG_R11_STOP_PCHK_ENA		;
		LITE_REG_R11_FSM_RST_REQ		<= (!w_hs) ? (bar_reg[R11_FSM_RST_REQ			] == 1)			: LITE_REG_R11_FSM_RST_REQ			;
		LITE_REG_R11_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R11_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R11_AXI_BRUST_LEN		;
		LITE_REG_R11_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R11_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R11_TIMEOUT_THRD			;
													  
		LITE_REG_R12_CFG_REQ			<= (!w_hs) ? (bar_reg[R12_CFG_REQ				] == 1)			: LITE_REG_R12_CFG_REQ				;
		LITE_REG_R12_BAUD_RATE			<= (!w_hs) ?  bar_reg[R12_BAUD_RATE				][31:0]		 	: LITE_REG_R12_BAUD_RATE			;
		LITE_REG_R12_STOP_BIT			<= (!w_hs) ?  bar_reg[R12_STOP_BIT				][3:0]		 	: LITE_REG_R12_STOP_BIT				;
		LITE_REG_R12_P_CHK				<= (!w_hs) ?  bar_reg[R12_P_CHK					][3:0]		 	: LITE_REG_R12_P_CHK				;
		LITE_REG_R12_D_WIDTH			<= (!w_hs) ?  bar_reg[R12_D_WIDTH				][3:0]		 	: LITE_REG_R12_D_WIDTH				;
		LITE_REG_R12_STOP_PCHK_ENA		<= (!w_hs) ?  bar_reg[R12_STOP_PCHK_ENA			][0]			: LITE_REG_R12_STOP_PCHK_ENA		;
		LITE_REG_R12_FSM_RST_REQ		<= (!w_hs) ? (bar_reg[R12_FSM_RST_REQ			] == 1)			: LITE_REG_R12_FSM_RST_REQ			;
		LITE_REG_R12_AXI_BRUST_LEN		<= (!w_hs) ?  bar_reg[R12_AXI_BRUST_LEN			][7:0]		 	: LITE_REG_R12_AXI_BRUST_LEN		;
		LITE_REG_R12_TIMEOUT_THRD		<= (!w_hs) ?  bar_reg[R12_TIMEOUT_THRD			][31:0]		 	: LITE_REG_R12_TIMEOUT_THRD			;
													  
		LITE_REG_T1_CFG_REQ				<= (!w_hs) ? (bar_reg[T1_CFG_REQ				] == 1)			: LITE_REG_T1_CFG_REQ				;
		LITE_REG_T1_BAUD_RATE			<= (!w_hs) ?  bar_reg[T1_BAUD_RATE				][31:0]		 	: LITE_REG_T1_BAUD_RATE				;
		LITE_REG_T1_STOP_BIT			<= (!w_hs) ?  bar_reg[T1_STOP_BIT				][3:0]		 	: LITE_REG_T1_STOP_BIT				;
		LITE_REG_T1_P_CHK				<= (!w_hs) ?  bar_reg[T1_P_CHK					][3:0]		 	: LITE_REG_T1_P_CHK					;
		LITE_REG_T1_D_WDITH				<= (!w_hs) ?  bar_reg[T1_D_WDITH				][3:0]		 	: LITE_REG_T1_D_WDITH				;
		LITE_REG_T1_INVL_MODE			<= (!w_hs) ?  bar_reg[T1_INVL_MODE				][1:0]		 	: LITE_REG_T1_INVL_MODE				;
		LITE_REG_T1_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T1_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T1_INVL_HF_BAUD			;
		LITE_REG_T1_INVL_CLK_PD			<= (!w_hs) ?  bar_reg[T1_INVL_CLK_PD			][15:0]		 	: LITE_REG_T1_INVL_CLK_PD			;
		LITE_REG_T1_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T1_AXI_WR_EFF_LEN			][15:0]			: LITE_REG_T1_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T2_CFG_REQ				<= (!w_hs) ? (bar_reg[T2_CFG_REQ				] == 1)			: LITE_REG_T2_CFG_REQ				;
		LITE_REG_T2_BAUD_RATE			<= (!w_hs) ?  bar_reg[T2_BAUD_RATE				][31:0]		 	: LITE_REG_T2_BAUD_RATE				;
		LITE_REG_T2_STOP_BIT			<= (!w_hs) ?  bar_reg[T2_STOP_BIT				][3:0]		 	: LITE_REG_T2_STOP_BIT				;
		LITE_REG_T2_P_CHK				<= (!w_hs) ?  bar_reg[T2_P_CHK					][3:0]		 	: LITE_REG_T2_P_CHK					;
		LITE_REG_T2_D_WDITH				<= (!w_hs) ?  bar_reg[T2_D_WDITH				][3:0]		 	: LITE_REG_T2_D_WDITH				;
		LITE_REG_T2_INVL_MODE			<= (!w_hs) ?  bar_reg[T2_INVL_MODE				][1:0]		 	: LITE_REG_T2_INVL_MODE				;
		LITE_REG_T2_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T2_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T2_INVL_HF_BAUD			;
		LITE_REG_T2_INVL_CLK_PD			<= (!w_hs) ?  bar_reg[T2_INVL_CLK_PD			][15:0]		 	: LITE_REG_T2_INVL_CLK_PD			;
		LITE_REG_T2_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T2_AXI_WR_EFF_LEN			][15:0]			: LITE_REG_T2_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T3_CFG_REQ				<= (!w_hs) ? (bar_reg[T3_CFG_REQ				] == 1)			: LITE_REG_T3_CFG_REQ				;
		LITE_REG_T3_BAUD_RATE			<= (!w_hs) ?  bar_reg[T3_BAUD_RATE				][31:0]		 	: LITE_REG_T3_BAUD_RATE				;
		LITE_REG_T3_STOP_BIT			<= (!w_hs) ?  bar_reg[T3_STOP_BIT				][3:0]		 	: LITE_REG_T3_STOP_BIT				;
		LITE_REG_T3_P_CHK				<= (!w_hs) ?  bar_reg[T3_P_CHK					][3:0]		 	: LITE_REG_T3_P_CHK					;
		LITE_REG_T3_D_WDITH				<= (!w_hs) ?  bar_reg[T3_D_WDITH				][3:0]		 	: LITE_REG_T3_D_WDITH				;
		LITE_REG_T3_INVL_MODE			<= (!w_hs) ?  bar_reg[T3_INVL_MODE				][1:0]		 	: LITE_REG_T3_INVL_MODE				;
		LITE_REG_T3_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T3_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T3_INVL_HF_BAUD			;
		LITE_REG_T3_INVL_CLK_PD			<= (!w_hs) ?  bar_reg[T3_INVL_CLK_PD			][15:0]		 	: LITE_REG_T3_INVL_CLK_PD			;
		LITE_REG_T3_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T3_AXI_WR_EFF_LEN			][15:0]			: LITE_REG_T3_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T4_CFG_REQ				<= (!w_hs) ? (bar_reg[T4_CFG_REQ				] == 1)			: LITE_REG_T4_CFG_REQ				;
		LITE_REG_T4_BAUD_RATE			<= (!w_hs) ?  bar_reg[T4_BAUD_RATE				][31:0]		 	: LITE_REG_T4_BAUD_RATE				;
		LITE_REG_T4_STOP_BIT			<= (!w_hs) ?  bar_reg[T4_STOP_BIT				][3:0]		 	: LITE_REG_T4_STOP_BIT				;
		LITE_REG_T4_P_CHK				<= (!w_hs) ?  bar_reg[T4_P_CHK					][3:0]		 	: LITE_REG_T4_P_CHK					;
		LITE_REG_T4_D_WDITH				<= (!w_hs) ?  bar_reg[T4_D_WDITH				][3:0]		 	: LITE_REG_T4_D_WDITH				;
		LITE_REG_T4_INVL_MODE			<= (!w_hs) ?  bar_reg[T4_INVL_MODE				][1:0]		 	: LITE_REG_T4_INVL_MODE				;
		LITE_REG_T4_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T4_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T4_INVL_HF_BAUD			;
		LITE_REG_T4_INVL_CLK_PD			<= (!w_hs) ?  bar_reg[T4_INVL_CLK_PD			][15:0]		 	: LITE_REG_T4_INVL_CLK_PD			;
		LITE_REG_T4_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T4_AXI_WR_EFF_LEN			][15:0]			: LITE_REG_T4_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T5_CFG_REQ				<= (!w_hs) ? (bar_reg[T5_CFG_REQ				] == 1)			: LITE_REG_T5_CFG_REQ				;
		LITE_REG_T5_BAUD_RATE			<= (!w_hs) ?  bar_reg[T5_BAUD_RATE				][31:0]		 	: LITE_REG_T5_BAUD_RATE				;
		LITE_REG_T5_STOP_BIT			<= (!w_hs) ?  bar_reg[T5_STOP_BIT				][3:0]		 	: LITE_REG_T5_STOP_BIT				;
		LITE_REG_T5_P_CHK				<= (!w_hs) ?  bar_reg[T5_P_CHK					][3:0]		 	: LITE_REG_T5_P_CHK					;
		LITE_REG_T5_D_WDITH				<= (!w_hs) ?  bar_reg[T5_D_WDITH				][3:0]		 	: LITE_REG_T5_D_WDITH				;
		LITE_REG_T5_INVL_MODE			<= (!w_hs) ?  bar_reg[T5_INVL_MODE				][1:0]		 	: LITE_REG_T5_INVL_MODE				;
		LITE_REG_T5_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T5_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T5_INVL_HF_BAUD			;
		LITE_REG_T5_INVL_CLK_PD			<= (!w_hs) ?  bar_reg[T5_INVL_CLK_PD			][15:0]		 	: LITE_REG_T5_INVL_CLK_PD			;
		LITE_REG_T5_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T5_AXI_WR_EFF_LEN			][15:0]			: LITE_REG_T5_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T6_CFG_REQ				<= (!w_hs) ? (bar_reg[T6_CFG_REQ				] == 1)			: LITE_REG_T6_CFG_REQ				;
		LITE_REG_T6_BAUD_RATE			<= (!w_hs) ?  bar_reg[T6_BAUD_RATE				][31:0]		 	: LITE_REG_T6_BAUD_RATE				;
		LITE_REG_T6_STOP_BIT			<= (!w_hs) ?  bar_reg[T6_STOP_BIT				][3:0]		 	: LITE_REG_T6_STOP_BIT				;
		LITE_REG_T6_P_CHK				<= (!w_hs) ?  bar_reg[T6_P_CHK					][3:0]		 	: LITE_REG_T6_P_CHK					;
		LITE_REG_T6_D_WDITH				<= (!w_hs) ?  bar_reg[T6_D_WDITH				][3:0]		 	: LITE_REG_T6_D_WDITH				;
		LITE_REG_T6_INVL_MODE			<= (!w_hs) ?  bar_reg[T6_INVL_MODE				][1:0]		 	: LITE_REG_T6_INVL_MODE				;
		LITE_REG_T6_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T6_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T6_INVL_HF_BAUD			;
		LITE_REG_T6_INVL_CLK_PD			<= (!w_hs) ?  bar_reg[T6_INVL_CLK_PD			][15:0]		 	: LITE_REG_T6_INVL_CLK_PD			;
		LITE_REG_T6_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T6_AXI_WR_EFF_LEN			][15:0]			: LITE_REG_T6_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T7_CFG_REQ				<= (!w_hs) ? (bar_reg[T7_CFG_REQ				] == 1)			: LITE_REG_T7_CFG_REQ				;
		LITE_REG_T7_BAUD_RATE			<= (!w_hs) ?  bar_reg[T7_BAUD_RATE				][31:0]		 	: LITE_REG_T7_BAUD_RATE				;
		LITE_REG_T7_STOP_BIT			<= (!w_hs) ?  bar_reg[T7_STOP_BIT				][3:0]		 	: LITE_REG_T7_STOP_BIT				;
		LITE_REG_T7_P_CHK				<= (!w_hs) ?  bar_reg[T7_P_CHK					][3:0]		 	: LITE_REG_T7_P_CHK					;
		LITE_REG_T7_D_WDITH				<= (!w_hs) ?  bar_reg[T7_D_WDITH				][3:0]		 	: LITE_REG_T7_D_WDITH				;
		LITE_REG_T7_INVL_MODE			<= (!w_hs) ?  bar_reg[T7_INVL_MODE				][1:0]		 	: LITE_REG_T7_INVL_MODE				;
		LITE_REG_T7_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T7_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T7_INVL_HF_BAUD			;
		LITE_REG_T7_INVL_CLK_PD			<= (!w_hs) ?  bar_reg[T7_INVL_CLK_PD			][15:0]		 	: LITE_REG_T7_INVL_CLK_PD			;
		LITE_REG_T7_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T7_AXI_WR_EFF_LEN			][15:0]			: LITE_REG_T7_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T8_CFG_REQ				<= (!w_hs) ? (bar_reg[T8_CFG_REQ				] == 1)			: LITE_REG_T8_CFG_REQ				;
		LITE_REG_T8_BAUD_RATE			<= (!w_hs) ?  bar_reg[T8_BAUD_RATE				][31:0]		 	: LITE_REG_T8_BAUD_RATE				;
		LITE_REG_T8_STOP_BIT			<= (!w_hs) ?  bar_reg[T8_STOP_BIT				][3:0]		 	: LITE_REG_T8_STOP_BIT				;
		LITE_REG_T8_P_CHK				<= (!w_hs) ?  bar_reg[T8_P_CHK					][3:0]		 	: LITE_REG_T8_P_CHK					;
		LITE_REG_T8_D_WDITH				<= (!w_hs) ?  bar_reg[T8_D_WDITH				][3:0]		 	: LITE_REG_T8_D_WDITH				;
		LITE_REG_T8_INVL_MODE			<= (!w_hs) ?  bar_reg[T8_INVL_MODE				][1:0]		 	: LITE_REG_T8_INVL_MODE				;
		LITE_REG_T8_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T8_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T8_INVL_HF_BAUD			;
		LITE_REG_T8_INVL_CLK_PD			<= (!w_hs) ?  bar_reg[T8_INVL_CLK_PD			][15:0]		 	: LITE_REG_T8_INVL_CLK_PD			;
		LITE_REG_T8_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T8_AXI_WR_EFF_LEN			][15:0]			: LITE_REG_T8_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T9_CFG_REQ				<= (!w_hs) ? (bar_reg[T9_CFG_REQ				] == 1)			: LITE_REG_T9_CFG_REQ				;
		LITE_REG_T9_BAUD_RATE			<= (!w_hs) ?  bar_reg[T9_BAUD_RATE				][31:0]		 	: LITE_REG_T9_BAUD_RATE				;
		LITE_REG_T9_STOP_BIT			<= (!w_hs) ?  bar_reg[T9_STOP_BIT				][3:0]		 	: LITE_REG_T9_STOP_BIT				;
		LITE_REG_T9_P_CHK				<= (!w_hs) ?  bar_reg[T9_P_CHK					][3:0]		 	: LITE_REG_T9_P_CHK					;
		LITE_REG_T9_D_WDITH				<= (!w_hs) ?  bar_reg[T9_D_WDITH				][3:0]		 	: LITE_REG_T9_D_WDITH				;
		LITE_REG_T9_INVL_MODE			<= (!w_hs) ?  bar_reg[T9_INVL_MODE				][1:0]		 	: LITE_REG_T9_INVL_MODE				;
		LITE_REG_T9_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T9_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T9_INVL_HF_BAUD			;
		LITE_REG_T9_INVL_CLK_PD			<= (!w_hs) ?  bar_reg[T9_INVL_CLK_PD			][15:0]		 	: LITE_REG_T9_INVL_CLK_PD			;
		LITE_REG_T9_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T9_AXI_WR_EFF_LEN			][15:0]			: LITE_REG_T9_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T10_CFG_REQ			<= (!w_hs) ? (bar_reg[T10_CFG_REQ				] == 1)			: LITE_REG_T10_CFG_REQ				;
		LITE_REG_T10_BAUD_RATE			<= (!w_hs) ?  bar_reg[T10_BAUD_RATE				][31:0]		 	: LITE_REG_T10_BAUD_RATE			;
		LITE_REG_T10_STOP_BIT			<= (!w_hs) ?  bar_reg[T10_STOP_BIT				][3:0]		 	: LITE_REG_T10_STOP_BIT				;
		LITE_REG_T10_P_CHK				<= (!w_hs) ?  bar_reg[T10_P_CHK					][3:0]		 	: LITE_REG_T10_P_CHK				;
		LITE_REG_T10_D_WDITH			<= (!w_hs) ?  bar_reg[T10_D_WDITH				][3:0]		 	: LITE_REG_T10_D_WDITH				;
		LITE_REG_T10_INVL_MODE			<= (!w_hs) ?  bar_reg[T10_INVL_MODE				][1:0]		 	: LITE_REG_T10_INVL_MODE			;
		LITE_REG_T10_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T10_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T10_INVL_HF_BAUD			;
		LITE_REG_T10_INVL_CLK_PD		<= (!w_hs) ?  bar_reg[T10_INVL_CLK_PD			][15:0]		 	: LITE_REG_T10_INVL_CLK_PD			;
		LITE_REG_T10_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T10_AXI_WR_EFF_LEN		][15:0]			: LITE_REG_T10_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T11_CFG_REQ			<= (!w_hs) ? (bar_reg[T11_CFG_REQ				] == 1)			: LITE_REG_T11_CFG_REQ				;
		LITE_REG_T11_BAUD_RATE			<= (!w_hs) ?  bar_reg[T11_BAUD_RATE				][31:0]		 	: LITE_REG_T11_BAUD_RATE			;
		LITE_REG_T11_STOP_BIT			<= (!w_hs) ?  bar_reg[T11_STOP_BIT				][3:0]		 	: LITE_REG_T11_STOP_BIT				;
		LITE_REG_T11_P_CHK				<= (!w_hs) ?  bar_reg[T11_P_CHK					][3:0]		 	: LITE_REG_T11_P_CHK				;
		LITE_REG_T11_D_WDITH			<= (!w_hs) ?  bar_reg[T11_D_WDITH				][3:0]		 	: LITE_REG_T11_D_WDITH				;
		LITE_REG_T11_INVL_MODE			<= (!w_hs) ?  bar_reg[T11_INVL_MODE				][1:0]		 	: LITE_REG_T11_INVL_MODE			;
		LITE_REG_T11_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T11_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T11_INVL_HF_BAUD			;
		LITE_REG_T11_INVL_CLK_PD		<= (!w_hs) ?  bar_reg[T11_INVL_CLK_PD			][15:0]		 	: LITE_REG_T11_INVL_CLK_PD			;
		LITE_REG_T11_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T11_AXI_WR_EFF_LEN		][15:0]			: LITE_REG_T11_AXI_WR_EFF_LEN		;
													  
		LITE_REG_T12_CFG_REQ			<= (!w_hs) ? (bar_reg[T12_CFG_REQ				] == 1)			: LITE_REG_T12_CFG_REQ				;
		LITE_REG_T12_BAUD_RATE			<= (!w_hs) ?  bar_reg[T12_BAUD_RATE				][31:0]		 	: LITE_REG_T12_BAUD_RATE			;
		LITE_REG_T12_STOP_BIT			<= (!w_hs) ?  bar_reg[T12_STOP_BIT				][3:0]		 	: LITE_REG_T12_STOP_BIT				;
		LITE_REG_T12_P_CHK				<= (!w_hs) ?  bar_reg[T12_P_CHK					][3:0]		 	: LITE_REG_T12_P_CHK				;
		LITE_REG_T12_D_WDITH			<= (!w_hs) ?  bar_reg[T12_D_WDITH				][3:0]		 	: LITE_REG_T12_D_WDITH				;
		LITE_REG_T12_INVL_MODE			<= (!w_hs) ?  bar_reg[T12_INVL_MODE				][1:0]		 	: LITE_REG_T12_INVL_MODE			;
		LITE_REG_T12_INVL_HF_BAUD		<= (!w_hs) ?  bar_reg[T12_INVL_HF_BAUD			][15:0]		 	: LITE_REG_T12_INVL_HF_BAUD			;
		LITE_REG_T12_INVL_CLK_PD		<= (!w_hs) ?  bar_reg[T12_INVL_CLK_PD			][15:0]		 	: LITE_REG_T12_INVL_CLK_PD			;
		LITE_REG_T12_AXI_WR_EFF_LEN		<= (!w_hs) ?  bar_reg[T12_AXI_WR_EFF_LEN		][15:0]			: LITE_REG_T12_AXI_WR_EFF_LEN		;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		rx_cfg_req_is_1orf <= 'd0;
		tx_cfg_req_is_1orf <= 'd0;
	end
	else begin
		rx_cfg_req_is_1orf <= { ((bar_reg[R12_CFG_REQ] == 1) || (bar_reg[R12_CFG_REQ] == 15)), 
								((bar_reg[R11_CFG_REQ] == 1) || (bar_reg[R11_CFG_REQ] == 15)), 
								((bar_reg[R10_CFG_REQ] == 1) || (bar_reg[R10_CFG_REQ] == 15)), 
								((bar_reg[R9_CFG_REQ]  == 1) || (bar_reg[R9_CFG_REQ]  == 15)), 
								((bar_reg[R8_CFG_REQ]  == 1) || (bar_reg[R8_CFG_REQ]  == 15)), 
								((bar_reg[R7_CFG_REQ]  == 1) || (bar_reg[R7_CFG_REQ]  == 15)), 
								((bar_reg[R6_CFG_REQ]  == 1) || (bar_reg[R6_CFG_REQ]  == 15)), 
								((bar_reg[R5_CFG_REQ]  == 1) || (bar_reg[R5_CFG_REQ]  == 15)), 
								((bar_reg[R4_CFG_REQ]  == 1) || (bar_reg[R4_CFG_REQ]  == 15)), 
								((bar_reg[R3_CFG_REQ]  == 1) || (bar_reg[R3_CFG_REQ]  == 15)), 
								((bar_reg[R2_CFG_REQ]  == 1) || (bar_reg[R2_CFG_REQ]  == 15)), 
								((bar_reg[R1_CFG_REQ]  == 1) || (bar_reg[R1_CFG_REQ]  == 15))};

		tx_cfg_req_is_1orf <= { ((bar_reg[T12_CFG_REQ] == 1) || (bar_reg[T12_CFG_REQ] == 15)), 
								((bar_reg[T11_CFG_REQ] == 1) || (bar_reg[T11_CFG_REQ] == 15)), 
								((bar_reg[T10_CFG_REQ] == 1) || (bar_reg[T10_CFG_REQ] == 15)), 
								((bar_reg[T9_CFG_REQ]  == 1) || (bar_reg[T9_CFG_REQ]  == 15)), 
								((bar_reg[T8_CFG_REQ]  == 1) || (bar_reg[T8_CFG_REQ]  == 15)), 
								((bar_reg[T7_CFG_REQ]  == 1) || (bar_reg[T7_CFG_REQ]  == 15)), 
								((bar_reg[T6_CFG_REQ]  == 1) || (bar_reg[T6_CFG_REQ]  == 15)), 
								((bar_reg[T5_CFG_REQ]  == 1) || (bar_reg[T5_CFG_REQ]  == 15)), 
								((bar_reg[T4_CFG_REQ]  == 1) || (bar_reg[T4_CFG_REQ]  == 15)), 
								((bar_reg[T3_CFG_REQ]  == 1) || (bar_reg[T3_CFG_REQ]  == 15)), 
								((bar_reg[T2_CFG_REQ]  == 1) || (bar_reg[T2_CFG_REQ]  == 15)), 
								((bar_reg[T1_CFG_REQ]  == 1) || (bar_reg[T1_CFG_REQ]  == 15))};
	end
end


always@(posedge clk, posedge rst) begin
	if(rst)
		bar_rd_done <= 'd0;
	else if(!w_hs)
		bar_rd_done <= bar_reg[HOST_READ_DONE] == 32'd1;
	else
		bar_rd_done <= bar_rd_done;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		interupt_clr <= 'd0;
	else if(!w_hs)
		interupt_clr <= bar_reg[INTERUPT_CLEAR] == 32'd1;
	else
		interupt_clr <= interupt_clr;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		interupt_en <= 'd0;
	else if(!w_hs)
		interupt_en <= bar_reg[INTERRUPT_EN] == 32'd1;
	else
		interupt_en <= interupt_en;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		inrpt_clr_mode <= 'd0;
	else if(!w_hs)
		inrpt_clr_mode <= (bar_reg[INRPT_CLR_MODE] == 32'd1) ? 2'd1 : 2'd0;
	else
		inrpt_clr_mode <= inrpt_clr_mode;
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		inrp_timeout_cnt  <= 'd0;
		rdone_timeout_cnt <= 'd0;
	end
	else begin
		inrp_timeout_cnt  <= (cs == WAIT_CLR) ? (inrp_timeout_cnt + 1'd1) : 16'd0;
		rdone_timeout_cnt <= (cs == WAIT_R_DONE) ? (rdone_timeout_cnt + 1'd1) : 16'd0;
	end
end
always@(posedge clk, posedge rst) begin
	if(rst) begin
		sta_inrp_timeout  <= 'd0;
		sta_rdone_timeout <= 'd0;
	end
	else begin
		sta_inrp_timeout  <= (inrp_timeout_cnt  >= `TIMEOUT_THRD) ? (sta_inrp_timeout  + 1'd1) : sta_inrp_timeout ;
		sta_rdone_timeout <= (rdone_timeout_cnt >= `TIMEOUT_THRD) ? (sta_rdone_timeout + 1'd1) : sta_rdone_timeout;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst)
		interupt_req_r <= 'd0;
	else if(cs == INTERUPT)
		interupt_req_r <= 1'd1;
	else if(cs == WAIT_R_DONE)
		interupt_req_r <= 1'd0;
	else
		interupt_req_r <= interupt_req_r;
end

always@(posedge clk, posedge rst) begin 
	if(rst)
		{r_arbt, r_req} <= 'd0;
	else if(!interupt_en)
		{r_arbt, r_req} <= 'd0;
	else if(r_req)
		{r_arbt, r_req} <= {r_arbt, 1'd0};
	else casez({(`EXTD_RD_DONE || (cs == INIT) || (cs == WAIT_NX_PKT)), r_arbt, got_whole_brust_pkt})
//		rdone  arbt      cba9_8765_4321
		{1'd1, 4'd0, 12'b????_????_???1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 0
		{1'd1, 4'd0, 12'b????_????_??10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 0
		{1'd1, 4'd0, 12'b????_????_?100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 0
		{1'd1, 4'd0, 12'b????_????_1000}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 0

		{1'd1, 4'd0, 12'b????_???1_0000}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 0
		{1'd1, 4'd0, 12'b????_??10_0000}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 0
		{1'd1, 4'd0, 12'b????_?100_0000}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 0
		{1'd1, 4'd0, 12'b????_1000_0000}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 0

		{1'd1, 4'd0, 12'b???1_0000_0000}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 0
		{1'd1, 4'd0, 12'b??10_0000_0000}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 0
		{1'd1, 4'd0, 12'b?100_0000_0000}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 0
		{1'd1, 4'd0, 12'b1000_0000_0000}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 0
		
		{1'd1, 4'd0, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 0

		//_______________________________________________________________________________

		{1'd1, 4'd1, 12'b????_????_??1?}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 1
		{1'd1, 4'd1, 12'b????_????_?10?}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 1
		{1'd1, 4'd1, 12'b????_????_100?}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 1
 
		{1'd1, 4'd1, 12'b????_???1_000?}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 1
		{1'd1, 4'd1, 12'b????_??10_000?}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 1
		{1'd1, 4'd1, 12'b????_?100_000?}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 1
		{1'd1, 4'd1, 12'b????_1000_000?}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 1
		
		{1'd1, 4'd1, 12'b???1_0000_000?}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 1
		{1'd1, 4'd1, 12'b??10_0000_000?}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 1
		{1'd1, 4'd1, 12'b?100_0000_000?}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 1
		{1'd1, 4'd1, 12'b1000_0000_000?}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 1
		
		{1'd1, 4'd1, 12'b0000_0000_0001}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 1
		{1'd1, 4'd1, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 1

		//_______________________________________________________________________________

		{1'd1, 4'd2, 12'b????_????_?1??}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 2
		{1'd1, 4'd2, 12'b????_????_10??}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 2
 
		{1'd1, 4'd2, 12'b????_???1_00??}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 2
		{1'd1, 4'd2, 12'b????_??10_00??}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 2
		{1'd1, 4'd2, 12'b????_?100_00??}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 2
		{1'd1, 4'd2, 12'b????_1000_00??}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 2
		
		{1'd1, 4'd2, 12'b???1_0000_00??}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 2
		{1'd1, 4'd2, 12'b??10_0000_00??}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 2
		{1'd1, 4'd2, 12'b?100_0000_00??}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 2
		{1'd1, 4'd2, 12'b1000_0000_00??}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 2
		
		{1'd1, 4'd2, 12'b0000_0000_00?1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 2
		{1'd1, 4'd2, 12'b0000_0000_0010}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 2
		{1'd1, 4'd2, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 2

		//_______________________________________________________________________________

		{1'd1, 4'd3, 12'b????_????_1???}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 3
 
		{1'd1, 4'd3, 12'b????_???1_0???}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 3
		{1'd1, 4'd3, 12'b????_??10_0???}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 3
		{1'd1, 4'd3, 12'b????_?100_0???}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 3
		{1'd1, 4'd3, 12'b????_1000_0???}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 3
		
		{1'd1, 4'd3, 12'b???1_0000_0???}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 3
		{1'd1, 4'd3, 12'b??10_0000_0???}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 3
		{1'd1, 4'd3, 12'b?100_0000_0???}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 3
		{1'd1, 4'd3, 12'b1000_0000_0???}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 3
		
		{1'd1, 4'd3, 12'b0000_0000_0??1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 3
		{1'd1, 4'd3, 12'b0000_0000_0?10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 3
		{1'd1, 4'd3, 12'b0000_0000_0100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 3
		{1'd1, 4'd3, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 3

		//_______________________________________________________________________________
 
		{1'd1, 4'd4, 12'b????_???1_????}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 4
		{1'd1, 4'd4, 12'b????_??10_????}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 4
		{1'd1, 4'd4, 12'b????_?100_????}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 4
		{1'd1, 4'd4, 12'b????_1000_????}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 4
		
		{1'd1, 4'd4, 12'b???1_0000_????}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 4
		{1'd1, 4'd4, 12'b??10_0000_????}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 4
		{1'd1, 4'd4, 12'b?100_0000_????}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 4
		{1'd1, 4'd4, 12'b1000_0000_????}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 4
		
		{1'd1, 4'd4, 12'b0000_0000_???1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 4
		{1'd1, 4'd4, 12'b0000_0000_??10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 4
		{1'd1, 4'd4, 12'b0000_0000_?100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 4
		{1'd1, 4'd4, 12'b0000_0000_1000}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 4

		{1'd1, 4'd4, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 4

		//_______________________________________________________________________________
 
		{1'd1, 4'd5, 12'b????_??1?_????}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 5
		{1'd1, 4'd5, 12'b????_?10?_????}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 5
		{1'd1, 4'd5, 12'b????_100?_????}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 5

		{1'd1, 4'd5, 12'b???1_000?_????}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 5
		{1'd1, 4'd5, 12'b??10_000?_????}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 5
		{1'd1, 4'd5, 12'b?100_000?_????}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 5
		{1'd1, 4'd5, 12'b1000_000?_????}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 5

		{1'd1, 4'd5, 12'b0000_000?_???1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 5
		{1'd1, 4'd5, 12'b0000_000?_??10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 5
		{1'd1, 4'd5, 12'b0000_000?_?100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 5
		{1'd1, 4'd5, 12'b0000_000?_1000}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 5

		{1'd1, 4'd5, 12'b0000_0001_0000}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 5
		{1'd1, 4'd5, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 5

		//_______________________________________________________________________________
 
		{1'd1, 4'd6, 12'b????_?1??_????}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 6
		{1'd1, 4'd6, 12'b????_10??_????}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 6

		{1'd1, 4'd6, 12'b???1_00??_????}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 6
		{1'd1, 4'd6, 12'b??10_00??_????}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 6
		{1'd1, 4'd6, 12'b?100_00??_????}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 6
		{1'd1, 4'd6, 12'b1000_00??_????}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 6

		{1'd1, 4'd6, 12'b0000_00??_???1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 6
		{1'd1, 4'd6, 12'b0000_00??_??10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 6
		{1'd1, 4'd6, 12'b0000_00??_?100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 6
		{1'd1, 4'd6, 12'b0000_00??_1000}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 6

		{1'd1, 4'd6, 12'b0000_00?1_0000}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 6
		{1'd1, 4'd6, 12'b0000_0010_0000}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 6
		{1'd1, 4'd6, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 6

		//_______________________________________________________________________________
 
		{1'd1, 4'd7, 12'b????_1???_????}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 7

		{1'd1, 4'd7, 12'b???1_0???_????}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 7
		{1'd1, 4'd7, 12'b??10_0???_????}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 7
		{1'd1, 4'd7, 12'b?100_0???_????}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 7
		{1'd1, 4'd7, 12'b1000_0???_????}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 7

		{1'd1, 4'd7, 12'b0000_0???_???1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 7
		{1'd1, 4'd7, 12'b0000_0???_??10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 7
		{1'd1, 4'd7, 12'b0000_0???_?100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 7
		{1'd1, 4'd7, 12'b0000_0???_1000}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 7

		{1'd1, 4'd7, 12'b0000_0??1_0000}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 7
		{1'd1, 4'd7, 12'b0000_0?10_0000}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 7
		{1'd1, 4'd7, 12'b0000_0100_0000}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 7
		{1'd1, 4'd7, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 7

		//_______________________________________________________________________________
 
		{1'd1, 4'd8, 12'b???1_????_????}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 8
		{1'd1, 4'd8, 12'b??10_????_????}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 8
		{1'd1, 4'd8, 12'b?100_????_????}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 8
		{1'd1, 4'd8, 12'b1000_????_????}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 8

		{1'd1, 4'd8, 12'b0000_????_???1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 8
		{1'd1, 4'd8, 12'b0000_????_??10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 8
		{1'd1, 4'd8, 12'b0000_????_?100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 8
		{1'd1, 4'd8, 12'b0000_????_1000}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 8

		{1'd1, 4'd8, 12'b0000_???1_0000}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 8
		{1'd1, 4'd8, 12'b0000_??10_0000}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 8
		{1'd1, 4'd8, 12'b0000_?100_0000}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 8
		{1'd1, 4'd8, 12'b0000_1000_0000}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 8

		{1'd1, 4'd8, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 8

		//_______________________________________________________________________________
 
		{1'd1, 4'd9, 12'b??1?_????_????}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 9
		{1'd1, 4'd9, 12'b?10?_????_????}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 9
		{1'd1, 4'd9, 12'b100?_????_????}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 9

		{1'd1, 4'd9, 12'b000?_????_???1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 9
		{1'd1, 4'd9, 12'b000?_????_??10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 9
		{1'd1, 4'd9, 12'b000?_????_?100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 9
		{1'd1, 4'd9, 12'b000?_????_1000}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 9

		{1'd1, 4'd9, 12'b000?_???1_0000}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 9
		{1'd1, 4'd9, 12'b000?_??10_0000}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 9
		{1'd1, 4'd9, 12'b000?_?100_0000}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 9
		{1'd1, 4'd9, 12'b000?_1000_0000}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 9

		{1'd1, 4'd9, 12'b0001_0000_0000}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 9
		{1'd1, 4'd9, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 9

		//_______________________________________________________________________________
 
		{1'd1, 4'ha, 12'b?1??_????_????}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 10
		{1'd1, 4'ha, 12'b10??_????_????}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 10

		{1'd1, 4'ha, 12'b00??_????_???1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 10
		{1'd1, 4'ha, 12'b00??_????_??10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 10
		{1'd1, 4'ha, 12'b00??_????_?100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 10
		{1'd1, 4'ha, 12'b00??_????_1000}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 10

		{1'd1, 4'ha, 12'b00??_???1_0000}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 10
		{1'd1, 4'ha, 12'b00??_??10_0000}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 10
		{1'd1, 4'ha, 12'b00??_?100_0000}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 10
		{1'd1, 4'ha, 12'b00??_1000_0000}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 10

		{1'd1, 4'ha, 12'b00?1_0000_0000}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 10
		{1'd1, 4'ha, 12'b0011_0000_0000}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 10
		{1'd1, 4'ha, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 10

		//_______________________________________________________________________________
 
		{1'd1, 4'hb, 12'b1???_????_????}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 11

		{1'd1, 4'hb, 12'b0???_????_???1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 11
		{1'd1, 4'hb, 12'b0???_????_??10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 11
		{1'd1, 4'hb, 12'b0???_????_?100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 11
		{1'd1, 4'hb, 12'b0???_????_1000}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 11

		{1'd1, 4'hb, 12'b0???_???1_0000}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 11
		{1'd1, 4'hb, 12'b0???_??10_0000}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 11
		{1'd1, 4'hb, 12'b0???_?100_0000}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 11
		{1'd1, 4'hb, 12'b0???_1000_0000}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 11

		{1'd1, 4'hb, 12'b0??1_0000_0000}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 11
		{1'd1, 4'hb, 12'b0?11_0000_0000}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 11
		{1'd1, 4'hb, 12'b0100_0000_0000}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 11
		{1'd1, 4'hb, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 11

		//_______________________________________________________________________________
 
		{1'd1, 4'hc, 12'b????_????_???1}	:	{r_arbt, r_req} <= {4'd1 , `REQ		};// 12
		{1'd1, 4'hc, 12'b????_????_??10}	:	{r_arbt, r_req} <= {4'd2 , `REQ		};// 12
		{1'd1, 4'hc, 12'b????_????_?100}	:	{r_arbt, r_req} <= {4'd3 , `REQ		};// 12
		{1'd1, 4'hc, 12'b????_????_1000}	:	{r_arbt, r_req} <= {4'd4 , `REQ		};// 12

		{1'd1, 4'hc, 12'b????_???1_0000}	:	{r_arbt, r_req} <= {4'd5 , `REQ		};// 12
		{1'd1, 4'hc, 12'b????_??10_0000}	:	{r_arbt, r_req} <= {4'd6 , `REQ		};// 12
		{1'd1, 4'hc, 12'b????_?100_0000}	:	{r_arbt, r_req} <= {4'd7 , `REQ		};// 12
		{1'd1, 4'hc, 12'b????_1000_0000}	:	{r_arbt, r_req} <= {4'd8 , `REQ		};// 12

		{1'd1, 4'hc, 12'b???1_0000_0000}	:	{r_arbt, r_req} <= {4'd9 , `REQ		};// 12
		{1'd1, 4'hc, 12'b??11_0000_0000}	:	{r_arbt, r_req} <= {4'd10, `REQ		};// 12
		{1'd1, 4'hc, 12'b?100_0000_0000}	:	{r_arbt, r_req} <= {4'd11, `REQ		};// 12
		{1'd1, 4'hc, 12'b1000_0000_0000}	:	{r_arbt, r_req} <= {4'd12, `REQ		};// 12

		{1'd1, 4'hc, 12'b0000_0000_0000}	:	{r_arbt, r_req} <= {4'd0 , `NO_REQ	};// 12
		
		default:{r_arbt, r_req} <= {r_arbt, 1'd0};
	endcase
end

always@(posedge clk, posedge rst) begin
	if(rst)
		cs <= INIT;
	else if(!interupt_en)
		cs <= INIT;
	else
		cs <= ns;
end

always@(*) begin
	case(cs)
		INIT	:	if(r_req)
						ns <= READ_REQ;
					else
						ns <= INIT;
								
		READ_REQ:	ns <= INTERUPT;
		
		INTERUPT:	ns <= WAIT_CLR;
		
		WAIT_CLR: 	if(inrpt_clr_mode == 2'd1)// use reg clear interrupt
						if(interupt_clr || (inrp_timeout_cnt >= `TIMEOUT_THRD))
							ns <= WAIT_R_DONE;
						else
							ns <= WAIT_CLR;
					else // use ack pin clear interrupt
						if(interupt_ack || (inrp_timeout_cnt >= `TIMEOUT_THRD))
							ns <= WAIT_R_DONE;
						else
							ns <= WAIT_CLR;
		
		WAIT_R_DONE:if(`EXTD_RD_DONE)
						ns <= WAIT_NX_PKT;
					else
						ns <= WAIT_R_DONE;
		
		WAIT_NX_PKT:if(r_req)
						ns <= READ_REQ;
					else
						ns <= WAIT_NX_PKT;
		default: ns <= WAIT_NX_PKT;
	endcase
end

endmodule
