package pcie_uart_pakcage;

import common_package::*;

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

endpackage