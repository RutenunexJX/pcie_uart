`timescale 1ns / 1ps
`include "_svh.svh"
`define	DEBUG_axi_uart_rx
module axi_uart_rx #(
	parameter	_rx_mode_e	P_RX_MODE				= E_RX_MODE_POLLING,
	parameter	bit			P_PARA_VALIDITY_CHECK	= P_DISABLE
)(
	input	logic			clk					,
	input	logic			rst					,

	input	logic			uart_rx				,

	input	rx_para_t		rx_para				,
	input	rx_ctrl_t		rx_ctrl				,
	output	rx_status_t		rx_status			,

	axi_full_if.slave_read	sr_axi_full_if		  //
);
`define D `ifdef DEBUG_axi_uart_rx (*mark_debug = "true"*)(*keep = "true"*)`else `endif
`define RLAST_CDN (((r1_rff_rd_cnt + r1_rff_rd_strb_cnt) >= axi_rd_len) & (r1_rff_rd_cnt < axi_rd_len) & r1_rx_fifo_rd_en)

localparam	P_FRAC_THRD = 24'd10_000_000;

rx_para_t	new_rx_para;
rx_para_t	cur_rx_para;

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		new_rx_para <= '{
			baud_rate_phase_acc_step_len		: 'd659706,
			baud_rate_phase_acc_frac_step_len	: 'd9766656,
			data_width							: 'd8,
			parity_check						: E_PARITY_CHECK_NONE,
			stop_bit_width						: E_STOP_BIT_1,
			fifo_timeout_thrd					: 'd5600,
			default								:'0
		};
	else if(P_PARA_VALIDITY_CHECK == P_ENABLE)
		new_rx_para <= '{
			baud_rate_phase_acc_step_len		: rx_para.baud_rate_phase_acc_step_len,
			baud_rate_phase_acc_frac_step_len	: (rx_para.baud_rate_phase_acc_frac_step_len <= E_PARITY_CHECK_END)	? rx_para.baud_rate_phase_acc_frac_step_len	: '0,
			data_width							: ((rx_para.data_width != 4'd0) & (rx_para.data_width <= 4'd8))		? rx_para.data_width						: 4'd8,
			parity_check						: (rx_para.parity_check < E_PARITY_CHECK_END)						? rx_para.parity_check						: cur_rx_para.parity_check,
			stop_bit_width						: (rx_para.stop_bit_width < E_STOP_BIT_END)							? rx_para.stop_bit_width					: E_STOP_BIT_1,
			fifo_timeout_thrd					: rx_para.fifo_timeout_thrd,
			default								: '0
		};
	else
		new_rx_para <= new_rx_para;
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

logic	[31:0]	timeout_cnt;
logic			is_start_bit_wire;
logic			r1_is_start_bit;
logic	[9:0]	r_UART_RX;

logic	[7:0]	parity_check_data;
logic	[3:0]	rx_cnt;
logic	[3:0]	rx_stop_bit_cnt;
logic			r1_rx_driv_flag;
logic			rx_driv_flag_sft;
logic			stop_bit_done;

logic	parity_check_cdn;
always_comb begin
	case(cur_rx_para.parity_check)
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

logic	[127:0]	rdata_window;
logic	[3:0]	rdata_window_remdr;
logic	[3:0]	r1_rdata_window_remdr;
logic			rd_start;

typedef struct{
	logic	[71:0]	din;
	logic			wr_en;
	logic			rd_en;
	logic	[71:0]	dout;
	logic			full;
	logic			empty;
	logic	[10:0]	data_count;
}rx_fifo_t;

rx_fifo_t	rx_fifo;

logic			r1_rx_fifo_rd_en;
logic	[63:0]	rx_fifo_din_data_pre;
logic	[63:0]	rx_fifo_din_data_eff;
logic	[7:0]	rx_fifo_din_strb_pre;

logic	[15:0]	rx_fifo_rd_cnt;
logic	[15:0]	r1_rff_rd_cnt;
logic	[3:0]	rx_fifo_wr_byte_num;
logic	[3:0]	rx_fifo_rd_strb_cnt;
logic	[3:0]	rx_fifo_wr_strb_cnt;

assign	rx_fifo_rd_strb_cnt = 4'($countones(rx_fifo.dout[71:64]));
assign	rx_fifo_wr_strb_cnt = 4'($countones(rx_fifo.din[71:64]));

logic	[3:0]		r1_rff_rd_strb_cnt;
logic				pad1;

logic	[3:0]	rid;
logic	[63:0]	rdata;
logic	[1:0]	rresp;
logic			rlast;
logic			rlast_cdn;
logic			rvalid;
logic			r_hs;
assign			r_hs = sr_axi_full_if.rready & sr_axi_full_if.rvalid;

assign	sr_axi_full_if.rid		= rid   ;
assign	sr_axi_full_if.rdata	= rdata ;
assign	sr_axi_full_if.rresp	= rresp ;
assign	sr_axi_full_if.rlast	= rlast ;
assign	sr_axi_full_if.rvalid	= rvalid;

logic			arready;
logic			ar_hs;
assign			sr_axi_full_if.arready = arready;
assign			ar_hs = sr_axi_full_if.arready & sr_axi_full_if.arvalid	;

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		arready <= 1'd0;
	else if (r_hs)
		arready <= 1'd0;
	else
		arready <= 1'd1;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst) begin
		rid			<= 'd0;
		rdata		<= 'd0;
		rresp		<= 'd0;
		rlast_cdn	<= 'd0;
	end
	else if (rd_start || `RLAST_CDN)begin
		rid			<= 'd0;
		rdata		<= rdata_window[63:0];
		rresp		<= 'd0;
		rlast_cdn	<= `RLAST_CDN;
	end
	else begin
		rid			<= 'd0;
		rdata		<= 'd0;
		rresp		<= 'd0;
		rlast_cdn	<= rlast_cdn;
	end
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		rlast <= 'd0;
	else if(rd_start || `RLAST_CDN) begin
		if((rdata_window_remdr == 0) & rlast_cdn & (r1_rdata_window_remdr != 0))
			rlast <= 'd1;
		else
			rlast <= `RLAST_CDN & (rdata_window_remdr == 0);
	end
	else
		rlast <= 'd0;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		rvalid <= 'd0;
	else if(rd_start || `RLAST_CDN) begin
		if((`RLAST_CDN & (rdata_window_remdr != 0)) || ((`RLAST_CDN == 1'd0) & (~((rdata_window_remdr == 0) & rlast_cdn & (r1_rdata_window_remdr != 0)))))
			rvalid <= ((r1_rdata_window_remdr + r1_rff_rd_strb_cnt) >= 8) & r1_rx_fifo_rd_en & (axi_rd_len > 8);
		else
			rvalid <= ((rdata_window_remdr == 0) & rlast_cdn & (r1_rdata_window_remdr != 0)) || (`RLAST_CDN & (rdata_window_remdr == 0));
	end
	else
		rvalid <= 'd0;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst) begin
		r_UART_RX				<= 'd0;
		r1_rx_driv_flag			<= 'd0;
		r1_rff_rd_strb_cnt		<= 'd0;
		r1_rdata_window_remdr	<= 'd0;
		r1_rff_rd_cnt			<= 'd0;
		r1_rx_fifo_rd_en			<= 'd0;
		r1_is_start_bit			<= 'd0;
	end
	else begin
		r_UART_RX				<= {r_UART_RX[8:0], uart_rx};
		r1_rx_driv_flag			<= (~r1_is_start_bit) & rx_driv_flag;
		r1_rff_rd_strb_cnt		<= rx_fifo_rd_strb_cnt;
		r1_rdata_window_remdr	<= rdata_window_remdr;
		r1_rff_rd_cnt			<= rx_fifo_rd_cnt;
		r1_rx_fifo_rd_en			<= rx_fifo.rd_en;
		r1_is_start_bit			<= is_start_bit;
	end
end

assign is_start_bit_wire = ((cs == RX_IDLE) || (cs == RX_STOP_BIT) || (cs == PARA_CFG)) & ({r_UART_RX[1], r_UART_RX[0]} == 2'b10);// negedge
assign is_start_bit = is_start_bit_wire;

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

always@(posedge clk, posedge rst) begin
	if(rst)
		rx_fifo_wr_byte_num <= 'd0;
	else if(rx_fifo.wr_en)
		if(rx_cnt == 9)
			rx_fifo_wr_byte_num <= 'd1;
		else
			rx_fifo_wr_byte_num <= 'd0;
	else if(rx_cnt == 9)
		if(rx_fifo_wr_byte_num == 4'd7)
			rx_fifo_wr_byte_num <= 'd0;
		else
			rx_fifo_wr_byte_num <= rx_fifo_wr_byte_num + 1'd1;
	else
		rx_fifo_wr_byte_num <= rx_fifo_wr_byte_num;
end

always@* begin
	if(!rx_fifo.wr_en)
		rx_fifo_din_data_eff = 'd0;
	else case(rx_cnt)
		4'd0: rx_fifo_din_data_eff = rx_fifo_din_data_pre;
		4'd9: rx_fifo_din_data_eff = rx_fifo_din_data_pre;
		default: rx_fifo_din_data_eff = ({64{1'd1}} >> (8 - rx_fifo_wr_byte_num)*8) & rx_fifo_din_data_pre;
	endcase
end

assign rx_fifo.din = rx_fifo.wr_en ? {rx_fifo_din_strb_pre, rx_fifo_din_data_eff} : 0;

always@(posedge clk, posedge rst) begin
	if(rst)
		{pad1, rx_fifo_din_strb_pre} <= 'd0;
	else if(rx_fifo.wr_en)
		if(rx_cnt == 9)
			{pad1, rx_fifo_din_strb_pre} <= 'd1;
		else
			{pad1, rx_fifo_din_strb_pre} <= 'd0;
	else if(rx_cnt == 9)
		{pad1, rx_fifo_din_strb_pre} <= {rx_fifo_din_strb_pre, 1'd1};
	else
		{pad1, rx_fifo_din_strb_pre} <= {pad1, rx_fifo_din_strb_pre};
end

always@(posedge clk, posedge rst) begin
	if(rst)
		rx_fifo.wr_en <= 1'd0;
	else if(((rx_cnt == 9) & (rx_fifo_wr_byte_num == 4'd7)) | (timeout_cnt >= cur_rx_para.fifo_timeout_thrd))
		rx_fifo.wr_en <= (!rx_fifo.full) & (rx_fifo_din_strb_pre != 0);
	else
		rx_fifo.wr_en <= 1'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		rx_fifo_rd_cnt <= 'd0;
	else if(rlast)
		rx_fifo_rd_cnt <= 'd0;
	else if(rx_fifo.rd_en)
		rx_fifo_rd_cnt <= rx_fifo_rd_cnt + rx_fifo_rd_strb_cnt;
	else
		rx_fifo_rd_cnt <= rx_fifo_rd_cnt;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		rd_start <= 'd0;
	else if(rd_start & rlast & r_hs)
		rd_start <= 'd0;
	else if((!rd_start) & ar_hs)
		rd_start <= 'd1;
	else
		rd_start <= rd_start;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		rx_fifo.rd_en <= 'd0;
	else if(((rx_fifo_rd_cnt + rx_fifo_rd_strb_cnt) <= axi_rd_len) & (rx_fifo_rd_strb_cnt != 0) & rd_start)
		if(!rx_fifo.rd_en)
			rx_fifo.rd_en <= ((rx_fifo_rd_cnt + rx_fifo_rd_strb_cnt) <= axi_rd_len);
		else
			rx_fifo.rd_en <= ((rx_fifo_rd_cnt + rx_fifo_rd_strb_cnt) < axi_rd_len);
	else
		rx_fifo.rd_en <= 'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		rdata_window <= 'd0;
	else if(rlast)
		rdata_window <= 'd0;
	else if(rx_fifo.rd_en || ((~rx_fifo.rd_en) & `RLAST_CDN))
		if(((r1_rdata_window_remdr + r1_rff_rd_strb_cnt) >= 8) & r1_rx_fifo_rd_en)
			rdata_window <= ({64'd0, (rx_fifo.rd_en ? rx_fifo.dout[63:0] : 64'd0)} << (8*rdata_window_remdr)) | (rdata_window >> 64);
		else
			rdata_window <= ({64'd0, rx_fifo.dout[63:0]} << (8*rdata_window_remdr)) | rdata_window;
	else
		rdata_window <= rdata_window;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		rdata_window_remdr <= 'd0;
	else if(`RLAST_CDN)
		rdata_window_remdr <= 'd0;
	else if(rx_fifo.rd_en)
		rdata_window_remdr <= ((rdata_window_remdr + rx_fifo_rd_strb_cnt) >= 8) ? ((rdata_window_remdr + rx_fifo_rd_strb_cnt) - 8) : (rdata_window_remdr + rx_fifo_rd_strb_cnt);
	else
		rdata_window_remdr <= rdata_window_remdr;
end

always@(posedge clk, posedge rst) begin
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
		stop_bit_done <= (rx_stop_bit_cnt == (cur_rx_para.stop_bit_width + 1)) & r1_rx_driv_flag;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		parity_check_data <= 'd0;
	else if(cur_rx_para.parity_check != E_PARITY_CHECK_NONE)
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
				if(cur_rx_para.parity_check == cur_rx_para.parity_check)
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
		rx_fifo_din_data_pre <= 'd0;
	else if(rx_fifo.wr_en)//((((rx_cnt == 9) & (rff_wr_byte_num == 4'd7)) | (timeout_cnt >= cur_rx_para.fifo_timeout_thrd)) & (!rx_fifo.full) & (rx_fifo.din_strb_pre != 0))
		rx_fifo_din_data_pre <= {56'd0, rx_fifo_din_data_pre[(rx_fifo_wr_byte_num*8)+:8]};
	else if((cs == RX_DATA) & (r1_rx_driv_flag & rx_driv_flag_sft))
		case(rx_cnt)
			4'd0:	rx_fifo_din_data_pre <= rx_fifo_din_data_pre;
			4'd1:	rx_fifo_din_data_pre[(rx_fifo_wr_byte_num*8) + 0] <= r_UART_RX[6];
			4'd2:	rx_fifo_din_data_pre[(rx_fifo_wr_byte_num*8) + 1] <= r_UART_RX[6];
			4'd3:	rx_fifo_din_data_pre[(rx_fifo_wr_byte_num*8) + 2] <= r_UART_RX[6];
			4'd4:	rx_fifo_din_data_pre[(rx_fifo_wr_byte_num*8) + 3] <= r_UART_RX[6];
			4'd5:	rx_fifo_din_data_pre[(rx_fifo_wr_byte_num*8) + 4] <= r_UART_RX[6];
			4'd6:	rx_fifo_din_data_pre[(rx_fifo_wr_byte_num*8) + 5] <= r_UART_RX[6];
			4'd7:	rx_fifo_din_data_pre[(rx_fifo_wr_byte_num*8) + 6] <= r_UART_RX[6];
			4'd8:	rx_fifo_din_data_pre[(rx_fifo_wr_byte_num*8) + 7] <= r_UART_RX[6];
			default:rx_fifo_din_data_pre <= rx_fifo_din_data_pre;
		endcase
	else
		rx_fifo_din_data_pre <= rx_fifo_din_data_pre;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		timeout_cnt <= 32'd0;
	else if(rx_cnt == 9)
		timeout_cnt <= 'd0;
	else
		timeout_cnt <= (timeout_cnt >= cur_rx_para.fifo_timeout_thrd) ? 0 : (timeout_cnt + 1'd1);
end

always@(posedge clk, posedge rst) begin
	if(rst)
		rx_fifo_usedw <= 'd0;
	else if(rx_fifo.rd_en & rx_fifo.wr_en)
		rx_fifo_usedw <= rx_fifo_usedw + rx_fifo_wr_strb_cnt - rx_fifo_rd_strb_cnt;
	else if(rx_fifo.rd_en)
		rx_fifo_usedw <= rx_fifo_usedw - rx_fifo_rd_strb_cnt;
	else if(rx_fifo.wr_en)
		rx_fifo_usedw <= rx_fifo_usedw + rx_fifo_wr_strb_cnt;
	else
		rx_fifo_usedw <= rx_fifo_usedw;
end


`ifdef D
`undef D
`endif

`ifdef DEBUG_axi_rx_uart
`undef DEBUG_axi_rx_uart
`endif

endmodule