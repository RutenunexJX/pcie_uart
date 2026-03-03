`timescale 1ns / 1ps
`include "_svh.svh"
module axi_uart_top(
	input	logic			clk					,
	input	logic			rst					,

	input	logic			uart_rx				,
	output	logic			uart_tx				,

	input	rx_para_t		rx_para				,
	input	tx_para_t		tx_para				,

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
	.tx_para			(	tx_para				)
);


endmodule

