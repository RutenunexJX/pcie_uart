`timescale 1ns / 1ps
`include "_svh.svh"
`define	DEBUG_uart_rx
module uart_rx #(
	parameter bit P_PARA_VALIDITY_CHECK = P_DISABLE
)(
	input	logic				clk				,
	input	logic				rst				,

	input	logic				uart_rx			,

	input	uart_rx_para_t		para			,
	input	uart_rx_ctrl_t		ctrl			,
	output	uart_rx_status_t	status			,

	byte_stream_if.m			m_byte_stream_if

	// debug
	,uart_rx_debug_if			debug
);
`define D `ifdef DEBUG_uart_rx (*mark_debug = "true"*)(*keep = "true"*)`else `endif
`define RLAST_CDN (((r1_rff_rd_cnt + r1_rff_rd_strb_cnt) >= axi_rd_len) & (r1_rff_rd_cnt < axi_rd_len) & r1_rx_fifo_rd_en)

localparam	P_FRAC_THRD = 24'd10_000_000;

uart_rx_para_t	new_para;
uart_rx_para_t	cur_para;

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		new_para <= '{
			baud_rate_phase_acc_step_len		: 'd659706,
			baud_rate_phase_acc_frac_step_len	: 'd9766656,
			data_width							: 'd8,
			parity_check						: E_PARITY_CHECK_NONE,
			stop_bit_width						: E_STOP_BIT_1,
			default								:'0
		};
	else if(P_PARA_VALIDITY_CHECK == P_ENABLE)
		new_para <= '{
			baud_rate_phase_acc_step_len		: para.baud_rate_phase_acc_step_len,
			baud_rate_phase_acc_frac_step_len	: (para.baud_rate_phase_acc_frac_step_len <= E_PARITY_CHECK_END)? para.baud_rate_phase_acc_frac_step_len	: '0,
			data_width							: ((para.data_width != 4'd0) & (para.data_width <= 4'd8))		? para.data_width							: 4'd8,
			parity_check						: (para.parity_check < E_PARITY_CHECK_END)						? para.parity_check							: cur_para.parity_check,
			stop_bit_width						: (para.stop_bit_width < E_STOP_BIT_END)						? para.stop_bit_width						: E_STOP_BIT_1,
			default								: '0
		};
	else
		new_para <= new_para;
end

//	input	[15:0]		axi_rd_len					,
//	input 	[7:0]		LR_AXI_BRUST_LEN				,

`define POST_BRUST_LEN  (axi_rd_len[15:3]+ (axi_rd_len[2:0] != 0) - 1)

typedef enum logic [3:0]{
	RX_IDLE,
	RX_DATA,
	RX_STOP_BIT,
	RX_PARITY_CHECK
}rx_st_e;

rx_st_e cs;
rx_st_e ns;

logic			is_start_bit;
logic			r1_is_start_bit;
logic	[9:0]	r_UART_RX;

logic	[7:0]	parity_check_data;
logic	[3:0]	rx_cnt;
logic	[3:0]	rx_stop_bit_cnt;
logic			r1_rx_driv_flag;
logic			rx_driv_flag_sft;
logic			stop_bit_done;
logic	[7:0]	byte_data;

logic			rx_driv_flag				;
logic	[31:0]	phase_sum					;
logic	[31:0]	r1_phase_sum				;
logic	[23:0]	frac_part					;
logic			frac_carry_bit				;

assign frac_carry_bit = (frac_part >= P_FRAC_THRD);

logic	parity_check_cdn;
always_comb begin
	case(cur_para.parity_check)
		E_PARITY_CHECK_ODD:
			parity_check_cdn = ^parity_check_data;

		E_PARITY_CHECK_EVEN:
			parity_check_cdn = ~^parity_check_data;

		E_PARITY_CHECK_MARK:
			parity_check_cdn = 1'd1;

		E_PARITY_CHECK_SPACE:
			parity_check_cdn = 1'd0;

		default:
			parity_check_cdn = 1'd0;
	endcase
end

typedef struct{
	logic	[7:0]	din;
	logic			wr_en;
	logic			rd_en;
	logic	[7:0]	dout;
	logic			full;
	logic			empty;
	logic	[10:0]	data_count;
}rx_fifo_t;

rx_fifo_t	rx_fifo;

always_ff @(posedge clk, posedge rst) begin
	if(rst) begin
		r_UART_RX				<= 'd0;
		r1_rx_driv_flag			<= 'd0;
		r1_is_start_bit			<= 'd0;
	end
	else begin
		r_UART_RX				<= {r_UART_RX[8:0], uart_rx};
		r1_rx_driv_flag			<= (~r1_is_start_bit) & rx_driv_flag;
		r1_is_start_bit			<= is_start_bit;
	end
end

assign is_start_bit = ((cs == RX_IDLE) || (cs == RX_STOP_BIT)) & ({r_UART_RX[1], r_UART_RX[0]} == 2'b10);// negedge

// ================================================================================
//                               phase acc
// step len = Trunc[(baud rate * 2^32) / (clk_freq / 2)]
// frac step len = Frac[(baud rate * 2^32) / (clk_freq / 2)] * 10_000_000
// ================================================================================
always_ff @(posedge clk, posedge rst) begin

	if(rst)
		phase_sum <= 'd0;
	else if(is_start_bit)
		phase_sum <= 'd0;
	else
		phase_sum <= phase_sum + cur_tx_para.baud_rate_phase_acc_step_len + frac_carry_bit;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst) begin
		r1_phase_sum	<= 'd0;
		r1_rx_driv_flag	<= 'd0;
	end
	else begin
		r1_phase_sum	<= is_start_bit ? '0 : phase_sum;
		r1_rx_driv_flag	<= rx_driv_flag;
	end
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		frac_part <= 24'd0;
	else if(is_start_bit)
		frac_part <= 'd0;
	else if (frac_part >= P_FRAC_THRD)
		frac_part <= frac_part - P_FRAC_THRD + cur_tx_para.baud_rate_phase_acc_frac_step_len;
	else
		frac_part <= frac_part + cur_tx_para.baud_rate_phase_acc_frac_step_len;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		rx_driv_flag <= 'd0;
	else if(r1_phase_sum[31:24] > phase_sum[31:24])
		rx_driv_flag <= 1'd1;
	else
		rx_driv_flag <= 'd0;
end

uart_ff_8k RFF_8K (
		.clk		(	clk					),
		.din		(	rx_fifo.din       	),
		.wr_en		(	rx_fifo.wr_en     	),
		.rd_en		(	rx_fifo.rd_en     	),
		.dout		(	rx_fifo.dout      	),
		.full		(	rx_fifo.full      	),
		.empty		(	rx_fifo.empty     	),
		.data_count	(	rx_fifo.data_count	)
);

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		rx_cnt <= 'd0;
	else if(cs == RX_DATA)
		rx_cnt <=  (r1_rx_driv_flag & rx_driv_flag_sft) ? (rx_cnt + 1'd1) : rx_cnt;
	else
		rx_cnt <= 'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		rx_driv_flag_sft <= 'd0;
	else if(is_start_bit)
		rx_driv_flag_sft <= 'd0;
	else if(rx_driv_flag & (~r1_is_start_bit))
		rx_driv_flag_sft <= ~rx_driv_flag_sft;
	else
		rx_driv_flag_sft <= rx_driv_flag_sft;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		rx_stop_bit_cnt <= 'd0;
	else if(cs == RX_STOP_BIT)
		rx_stop_bit_cnt <= r1_rx_driv_flag ? (rx_stop_bit_cnt + 1'd1) : rx_stop_bit_cnt;
	else
		rx_stop_bit_cnt <= 'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		stop_bit_done <= 'd0;
	else
		stop_bit_done <= (rx_stop_bit_cnt == (cur_para.stop_bit_width + 1)) & r1_rx_driv_flag;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		parity_check_data <= 'd0;
	else if(cur_para.parity_check != E_PARITY_CHECK_NONE)
		parity_check_data <= (cs == RX_DATA) ? rx_fifo.din[(rx_fifo_wr_byte_num*8)+:8] : parity_check_data;
	else
		parity_check_data <= 'd0;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		cs <= RX_IDLE;
	else
		cs <= ns;
end

always_comb begin
	case(cs)
		RX_IDLE:
			if(is_start_bit)
				ns = RX_DATA;
			else
				ns = RX_IDLE;

		RX_DATA:
			if((rx_cnt == 8) & r1_rx_driv_flag & rx_driv_flag_sft)
				if(cur_para.parity_check == cur_para.parity_check)
					ns = RX_STOP_BIT;
				else
					ns = RX_PARITY_CHECK;
			else
				ns = RX_DATA;

		RX_PARITY_CHECK:
			if(r1_rx_driv_flag & rx_driv_flag_sft)
				ns = RX_STOP_BIT;
			else
				ns = RX_PARITY_CHECK;

		RX_STOP_BIT:
			if(stop_bit_done)
				ns = RX_IDLE;
			else
				ns = RX_STOP_BIT;

		default:
			ns = RX_IDLE;
	endcase
end

always@(posedge clk, posedge rst) begin
	if(rst)
		byte_data <= 'd0;
	else if((cs == RX_DATA) & (r1_rx_driv_flag & rx_driv_flag_sft) & (rx_cnt >= 1) & (rx_cnt <= 8))
		byte_data[rx_cnt - 1] <= r_UART_RX[6];
	else
		byte_data <= byte_data;
end

`ifdef D
`undef D
`endif

`ifdef DEBUG_uart_rx
`undef DEBUG_uart_rx
`endif

endmodule