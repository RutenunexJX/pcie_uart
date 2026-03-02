`timescale 1ns / 1ps
`include "_svh.svh"
module axi_uart_top(
	input	logic			clk					,
	input	logic			rst					,

	input	logic			uart_rx				,
	output	logic			uart_tx				,

	uart_rx_cfg_if.i		i_uart_rx_cfg_if	,
	uart_tx_cfg_if.i		i_uart_tx_cfg_if	,
	axi_full_if.slave		s_axi_full_if		  //
);

axi_uart_rx AXI_UART_RX_U(
	.sr_axi_full_if		(	s_axi_full_if		),
	.i_uart_rx_cfg_if	(	i_uart_rx_cfg_if	)
);

axi_uart_tx AXI_UART_TX_U(

);


endmodule

