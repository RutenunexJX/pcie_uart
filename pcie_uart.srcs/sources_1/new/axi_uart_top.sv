`timescale 1ns / 1ps
`include "_svh.svh"
module axi_uart_top(
	input	logic			clk					,
	input	logic			rst					,

	input	logic			uart_rx				,
	output	logic			uart_tx				,

	input	rx_para_t		rx_para				,
	input	tx_para_t		tx_para				,

	input	rx_ctrl_t		rx_ctrl				,
	input	tx_ctrl_t		tx_ctrl				,

	output	rx_status_t		rx_status			,
	output	tx_status_t		tx_status			,

	axi_full_if.slave		s_axi_full_if		  //
);

axi_uart_rx AXI_UART_RX_U(
	.clk				(	clk					),
	.rst				(	rst					),

	.uart_rx			(	uart_rx				),

	.rx_para			(	rx_para				),
	.rx_ctrl			(	rx_ctrl				),
	.rx_status			(	rx_status			),

	.sr_axi_full_if		(	s_axi_full_if		)
);

axi_uart_tx #(
	.P_PARA_VALIDITY_CHECK(	),
	.P_DEBUG0('{
		DEBUG_ENA_TX_OVERFLOW_ERROR		: P_ENABLE,
		DEBUG_ENA_TX_OVERFLOW_WARNING	: P_ENABLE})
)AXI_UART_TX_U(
	.clk				(	clk					),
	.rst				(	rst					),

	.uart_tx			(	uart_tx				),

	.tx_para			(	tx_para				),
	.tx_ctrl			(	tx_ctrl				),
	.tx_status			(	tx_status			),

	.sw_axi_full_if		(	s_axi_full_if		)
);

endmodule

