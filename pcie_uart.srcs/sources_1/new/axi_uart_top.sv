`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////
//
// File Name           : axi_uart_top
// Description         :
// Author              : xqj
// Date                : 2026-03-23 16:40:35
// Version             : 1.0
// Modification History:
// Date                   Author    Version    Description
// 2026-03-23 16:40:35    xqj       1.0        Initial Creation
//
//////////////////////////////////////////////////////////////////////////
`include "_svh.svh"

module axi_uart_top #(
	parameter	P_CHL_NUM = 12
)(
	input	logic							clk				,
	input	logic							rst				,

	input	logic		[P_CHL_NUM - 1:0]	uart_rx			,
	output	logic		[P_CHL_NUM - 1:0]	uart_tx			,

	input	uart_rx_para_t	[P_CHL_NUM - 1:0]	rx_para			,
	input	uart_tx_para_t	[P_CHL_NUM - 1:0]	tx_para			,

	input	uart_rx_ctrl_t	[P_CHL_NUM - 1:0]	rx_ctrl			,
	input	uart_tx_ctrl_t	[P_CHL_NUM - 1:0]	tx_ctrl			,

	output	uart_rx_status_t	[P_CHL_NUM - 1:0]	rx_status		,
	output	uart_tx_status_t	[P_CHL_NUM - 1:0]	tx_status		,

	axi_full_if.slave						s_axi_full_if	  //

	// debug
	,mux_buffer_debug_if.source				s_mux_buffer_debug_if[P_CHL_NUM - 1:0]
	,axi_mux_debug_if.source				s_axi_mux_debug_if
	,uart_rx_debug_if.source				s_uart_rx_debug_if[P_CHL_NUM - 1:0]
	,uart_tx_debug_if.source				s_uart_tx_debug_if[P_CHL_NUM - 1:0]
);
byte_stream_if	_byte_stream_if();
u64_stream_if	_u64_stream_if();



// ================================================================================
//                               GF_CHL begin
// ================================================================================
for(genvar i = 0; i < P_CHL_NUM; i = i + 1) begin: GF_CHL

mux_buffer U_MUX_BUFFER(
	.clk					(clk),
	.rst					(rst),

	.s_byte_stream_if		(_byte_stream_if),
	.m_u64_stream_if		(_u64_stream_if),

	.debug					(s_mux_buffer_debug_if[i])
);

uart_rx U_UART_RX(
	.clk					(clk),
	.rst					(rst)
);

uart_tx U_UART_TX(
	.clk					(clk),
	.rst					(rst)
);

end: GF_CHL
// ================================================================================
//                               GF_CHL end
// ================================================================================


endmodule

