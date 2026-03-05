package pcie_uart_package;

import common_package::*;
export common_package::*;

typedef struct{
	logic	rx_fsm_deadlock;
	logic	tx_fsm_deadlock;
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