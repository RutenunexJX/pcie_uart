`timescale 1ns / 1ps
`include "_svh.svh"
module axi_uart_rx(
	input					clk					,
	input					rst					,

	input					uart_rx				,

	axi_full_if.slave_read	sr_axi_full_if		,
	input	rx_para_t		rx_para				  //
);


endmodule