`timescale 1ns / 1ps
`include "_svh.svh"
module axi_uart_top(
	input	logic			clk					,
	input	logic			rst					,

	input	logic			uart_rx				,
	output	logic			uart_tx				,

	input	rx_para_t		rx_para				,
	input	tx_para_t		tx_para				,

	input	logic	[15:0]	axi_wr_max_len		,
	input	logic	[15:0]	axi_wr_eff_len		,
	output	logic	[10:0]	tx_fifo_usedw		,

	axi_full_if.slave		s_axi_full_if		  //
);

axi_uart_rx AXI_UART_RX_U(
	.clk				(	clk					),
	.rst				(	rst					),

	.uart_rx			(	uart_rx				),

	.sr_axi_full_if		(	s_axi_full_if		),
	.rx_para			(	rx_para				)
);

axi_uart_tx AXI_UART_TX_U(
	.clk				(	clk					),
	.rst				(	rst					),

	.uart_tx			(	uart_tx				),

	.sw_axi_full_if		(	s_axi_full_if		),
	.tx_para			(	tx_para				),
	.axi_wr_max_len		(	axi_wr_max_len		),
	.axi_wr_eff_len		(	axi_wr_eff_len		),
	.tx_fifo_usedw		(	tx_fifo_usedw		)
);


endmodule

