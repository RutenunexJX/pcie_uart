package pcie_uart_package;

import common_package::*;

// ---------- global ctrl enum
typedef enum logic[3:0]{
	E_RX_MODE_POLLING,
	E_RX_MODE_INTERRUPT,
	E_RX_MODE_CUSTOM
}_rx_mode_e;

typedef struct{
	logic	rx_status;
	logic	tx_status;
}debug_status_t;

typedef enum logic [3:0]{
	E_STOP_BIT_1	, //4'd0
	E_STOP_BIT_1P5	,
	E_STOP_BIT_2	,
	E_STOP_BIT_END
}stop_bit_e;

typedef enum logic [3:0]{
	E_PARITY_CHECK_NONE	, // 4'd0
	E_PARITY_CHECK_ODD	,
	E_PARITY_CHECK_EVEN	,
	E_PARITY_CHECK_MARK	,
	E_PARITY_CHECK_SPACE,
	E_PARITY_CHECK_END
}parity_check_e;

typedef struct{
	logic		[31:0]	baud_rate_phase_acc_step_len;
	logic		[23:0]	baud_rate_phase_acc_frac_step_len;
	logic		[3:0]	data_width;
	parity_check_e		parity_check;
	stop_bit_e			stop_bit_width;
	logic		[31:0]	fifo_timeout_thrd;
}rx_para_t;

typedef struct{
	logic				global_ena;
	logic				global_rst;
	logic		[15:0]	axi_rd_len;
	logic		[15:0]	axi_intrp_thrd;
}rx_ctrl_t;

typedef struct{
	logic		[15:0]	fifo_usedw;
}rx_status_t;

typedef struct{
	logic		[31:0]	baud_rate_phase_acc_step_len;
	logic		[23:0]	baud_rate_phase_acc_frac_step_len;
	logic		[3:0]	data_width;
	parity_check_e		parity_check;
	stop_bit_e			stop_bit_width;
	logic		[9:0]	frame_interval_unit_s;
	logic		[9:0]	frame_interval_unit_ms;
	logic		[9:0]	frame_interval_unit_us;
	logic		[31:0]	frame_interval_unit_baud_rate;
}tx_para_t;

endpackage