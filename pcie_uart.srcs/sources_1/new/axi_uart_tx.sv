`timescale 1ns / 1ps
`include "_svh.svh"
`define DEBUG_axi_uart_tx
`define TX_PARA_VALIDITY_CHECK
module axi_uart_tx(
	input						clk					,
	input						rst					,

	output						uart_tx				,

	axi_full_if.slave_write		sw_axi_full_if		,
	input	tx_para_t			tx_para				  //
);

`define D `ifdef DEBUG_axi_uart_tx (*mark_debug = "true"*)(*keep = "true"*)`else `endif

logic			awready	;
logic			wready	;
logic	[3:0]	bid		;
logic	[1:0]	bresp	;
logic			bvalid	;

assign	sw_axi_full_if.awready	= awready;
assign	sw_axi_full_if.wready	= wready;
assign	sw_axi_full_if.bid		= bid;
assign	sw_axi_full_if.bresp	= bresp;
assign	sw_axi_full_if.bvalid	= bvalid;

`define CFG_DONE_CDN (((para_cfg_req_post == 2'd1) & (LR_CFG_DONE > 2'd1)) || ((para_cfg_req_post == 2'd2) & chl_clr_done))
`define BYTE_CNT_THRD ((tff_rd_strb_cnt > 0) ? (tff_rd_strb_cnt - 1) : 0)

`define EFF_STRB_SFT (8 - ((LR_AXI_WR_EFF_LEN - axi_wr_cnt) + wstrb_right_part_zero_cnt[7]))

// fsm
typedef enum logic [3:0]{
	TX_IDLE				,
	TX_DATA				,
	TX_STOP_BIT			,
	TX_PARITY_CHECK		,
	TX_PARA_CFG			,
	TX_CHL_CLR
}tx_st_e;

tx_st_e cs;
tx_st_e ns;

tx_para_t	new_tx_para = '{default:'0};
tx_para_t	cur_tx_para = '{default:'0};

always_ff @(posedge clk, posedge rst) begin
	if(rst) begin
		new_tx_para.baud_rate_phase_acc_step_len		<= 'd659706;
		new_tx_para.baud_rate_phase_acc_frac_step_len	<= 'd9766656;
		new_tx_para.data_width							<= 'd8;
		new_tx_para.parity_check						<= E_PARITY_CHECK_NONE;
		new_tx_para.stop_bit_width						<= E_STOP_BIT_1;
		new_tx_para.frame_interval_unit_s				<= 'd0;
		new_tx_para.frame_interval_unit_ms				<= 'd0;
		new_tx_para.frame_interval_unit_us				<= 'd0;
		new_tx_para.frame_interval_unit_baud_rate		<= 'd1;
	end
`ifdef TX_PARA_VALIDITY_CHECK
	else begin
		new_tx_para.baud_rate_phase_acc_step_len		<= tx_para.baud_rate_phase_acc_step_len;
		new_tx_para.baud_rate_phase_acc_frac_step_len	<= (tx_para.baud_rate_phase_acc_frac_step_len <= 24'd10_000_000)	? tx_para.baud_rate_phase_acc_frac_step_len	: '0;
		new_tx_para.data_width							<= (tx_para.data_width != 4'd0) & (tx_para.data_width <= 4'd8)		? tx_para.data_width						: 4'd8;
		new_tx_para.parity_check						<= (tx_para.parity_check < E_PARITY_CHECK_END)						? tx_para.parity_check						: E_PARITY_CHECK_NONE;
		new_tx_para.stop_bit_width						<= (tx_para.stop_bit_width < E_STOP_BIT_END)						? tx_para.stop_bit_width					: E_STOP_BIT_1;
		new_tx_para.frame_interval_unit_s				<= (tx_para.frame_interval_unit_s < 10'd1000) 						? tx_para.frame_interval_unit_s				: '0;
		new_tx_para.frame_interval_unit_ms				<= (tx_para.frame_interval_unit_ms < 10'd1000) 						? tx_para.frame_interval_unit_ms			: '0;
		new_tx_para.frame_interval_unit_us				<= (tx_para.frame_interval_unit_us < 10'd1000)						? tx_para.frame_interval_unit_us			: '0;
		new_tx_para.frame_interval_unit_baud_rate		<= tx_para.frame_interval_unit_baud_rate;
	end
`else
	else
		new_tx_para										<= tx_para;
`endif
end

always_ff @(posedge clk, posedge rst) begin
	if(rst) begin

	end
end

`D	reg r1_UART_TX;

`D	reg [7:0]p_chk_data;
`D	reg [3:0]tx_cnt, tx_stop_bit_cnt;
`D	reg r1_tx_driv_flag, tx_driv_flag_sft, stop_bit_done;
`D	reg [1:0] para_cfg_req_post;
`D	reg [3:0]		tff_rd_strb_cnt;
`D	wire[3:0]		tff_rd_strb_right_part_zero_cnt [7:0];
`D  reg [15:0] axi_wr_cnt;
`D  wire [3:0] wstrb_cnt = wstrb[7 ] + wstrb[6 ] + wstrb[5 ] + wstrb[4 ] + wstrb[3 ] + wstrb[2 ] + wstrb[1 ] + wstrb[0 ];
`D  reg  [7:0] eff_wstrb;
`D  wire [63:0]eff_wdata;
`D	wire [3:0] wstrb_right_part_zero_cnt [7:0];

wire	[4:0]	strb_cnt;
reg		[4:0]	strb_cnt_latch;
wire 	[63:0]	strb_fix_data;
reg 	[63:0]	strb_fix_data_latch;

`D	reg  [71 : 0]	tff_din       ;
`D	reg 			tff_wr_en     ;
`D	wire			tff_rd_en     ;
`D	reg 			tff_rd_en_pre ;
`D	wire [71 : 0]	tff_dout      ;
`D	reg  [71 : 0]	tff_dout_post ;
`D	wire			tff_full      ;
`D	wire			tff_empty     ;
`D	wire [10 : 0]	tff_data_count;
`D	reg  [3:0]		tff_rd_byte_num;

`D	logic	aw_hs		;
`D	logic	w_hs		;
`D	logic	b_hs		;
`D	logic	act_wlast	;

assign	aw_hs		= sw_axi_full_if.awready & sw_axi_full_if.awvalid;
assign	w_hs		= sw_axi_full_if.wvalid & sw_axi_full_if.wready;
assign	b_hs		= sw_axi_full_if.bvalid & sw_axi_full_if.bready;
assign	act_wlast	= sw_axi_full_if.wlast & sw_axi_full_if.wvalid;

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		bvalid <= 1'd0;
	else if(act_wlast & w_hs & (~bvalid))
		bvalid <= 1'd1;
	else if(b_hs)
		bvalid <= 1'd0;
	else
		bvalid <= bvalid;
end

always_ff @(posedge clk, posedge rst) begin
	bid   <= 'd0;
	bresp <= 'd0;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		awready <= 1'd1;
	else if (act_wlast)
		awready <= 1'd1;
	else if (aw_hs)
		awready <= 1'd0;
	else
		awready <= awready;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		wready <= 'd0;
	else if(aw_hs)
		wready <= 'd1;
	else if(act_wlast)
		wready <= 'd0;
	else
		wready <= wready;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		r1_tx_driv_flag <= 'd0;
	else
		r1_tx_driv_flag <= tx_driv_flag;
end



reg 	uart_driv_flag          ;


reg 	[31:0]	phase_sum		;
reg  	[31:0]	r1_phase_sum	;
reg    	[23:0] 	frac_part		;
wire           	frac_carry_bit	;

localparam FRAC_THRESHOLD = 24'd10_000_000;


always_ff @(posedge clk, posedge rst) begin
	if(rst)
		phase_sum <= 'd0;
	else
		phase_sum <= phase_sum + step_len + frac_carry_bit;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		r1_phase_sum <= 'd0;
	else
		r1_phase_sum <= phase_sum;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		frac_part <= 24'd0;
	else if (frac_part >= FRAC_THRESHOLD)
		frac_part <= frac_part - FRAC_THRESHOLD + frac_step_len;
	else
		frac_part <= frac_part + frac_step_len;
end

assign frac_carry_bit = (frac_part >= FRAC_THRESHOLD);

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		uart_driv_flag <= 'd0;
	else if(r1_phase_sum[31:24] > phase_sum[31:24])
		uart_driv_flag <= 1'd1;
	else
		uart_driv_flag <= 'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		tx_driv_flag_sft <= 'd0;
	else if(stop_bit_done & (para_stop_bit == STOP_BIT_1P5))
		tx_driv_flag_sft <= 1'd1;
	else if(tx_driv_flag)
		tx_driv_flag_sft <= ~tx_driv_flag_sft;
	else
		tx_driv_flag_sft <= tx_driv_flag_sft;
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		para_stop_bit         <= STOP_BIT_1;
		para_parity_chk       <= P_CHK_NONE;
		para_data_width       <= 4'd8;
		para_tx_invl_mode     <= 'd0;
		para_tx_invl_0p5_baud <= 'd0;
		para_tx_invl_clk_prd  <= 'd0;
	end
	else if(cs == TX_PARA_CFG) begin
		para_stop_bit         <= (LR_STOP_BIT <= STOP_BIT_2)? LR_STOP_BIT   : para_stop_bit  ;
		para_parity_chk       <= (LR_P_CHK <= P_CHK_SPACE) 	? LR_P_CHK 		: para_parity_chk;
		para_data_width       <= (LR_D_WDITH <= 4'd8)		? LR_D_WDITH 	: para_data_width;
		para_tx_invl_mode     <= LR_INVL_MODE;
		para_tx_invl_0p5_baud <= LR_INVL_HF_BAUD;
		para_tx_invl_clk_prd  <= LR_INVL_CLK_PD ;
	end
	else begin
		para_stop_bit         <= para_stop_bit  ;
		para_parity_chk       <= para_parity_chk;
		para_data_width       <= para_data_width;
		para_tx_invl_mode     <= para_tx_invl_mode;
		para_tx_invl_0p5_baud <= para_tx_invl_0p5_baud;
		para_tx_invl_clk_prd  <= para_tx_invl_clk_prd ;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst)
		para_cfg_req_post <= 'd0;
	else case(para_cfg_req_post)
		0: if(LR_CFG_REQ)
			para_cfg_req_post <= 2'd1;
		else if(chl_clr_req == 2'd1)
			para_cfg_req_post <= 2'd2;
		else
			para_cfg_req_post <= para_cfg_req_post;

		1: if(chl_clr_req == 2'd1)
			para_cfg_req_post <= 2'd2;
		else if((cs == TX_PARA_CFG) & (LR_CFG_DONE > 2'd1))
			para_cfg_req_post <= 2'd0;
		else
			para_cfg_req_post <= para_cfg_req_post;

		2: if(chl_clr_done)
			para_cfg_req_post <= 2'd0;
		else
			para_cfg_req_post <= para_cfg_req_post;

		default:para_cfg_req_post <= para_cfg_req_post;
	endcase
end

always@(posedge clk, posedge rst) begin
	if(rst)
		LR_CFG_DONE <= 'd0;
	else if(cs == TX_PARA_CFG)
		if((LR_STOP_BIT <= STOP_BIT_2) & (LR_P_CHK <= P_CHK_SPACE) & (LR_D_WDITH <= 4'd8))
			LR_CFG_DONE <= 2'd2;
		else
			LR_CFG_DONE <= 2'd3;
	else
		LR_CFG_DONE <= 'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		chl_clr_done <= 'd0;
	else if((cs == TX_PARA_CFG) & (para_cfg_req_post == 2'd2) & (chl_clr_req == 2'd2))
		chl_clr_done <= 1'd1;
	else
		chl_clr_done <= 1'd0;
end


uart_ff_8k TFF_8K (
		.clk		(	clk				),
		.din		(	tff_din       	),
		.wr_en		(	tff_wr_en     	),
		.rd_en		(	tff_rd_en     	),
		.dout		(	tff_dout      	),
		.full		(	tff_full      	),
		.empty		(	tff_empty     	),
		.data_count	(	tff_data_count	)
);

always@(posedge clk, posedge rst) begin
	if(rst)
		tff_wr_en <= 'd0;
	else
		tff_wr_en <= (!tff_full) & w_hs & (eff_wstrb != 0);//fix_w_hs;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		tff_dout_post <= tff_dout;
	else if(tff_rd_en_pre)
		tff_dout_post <= {(tff_dout[71:64] >> tff_rd_strb_right_part_zero_cnt[7]), (tff_dout[63:0] >> (tff_rd_strb_right_part_zero_cnt[7]*8))};
	else
		tff_dout_post <= tff_dout_post;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		tff_din <= 'd0;
	else
		tff_din <= {eff_wstrb, eff_wdata};//strb_fix_data;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		LR_TFF_USEDW <= 'd0;
	else
		LR_TFF_USEDW <= tff_data_count;
end

assign tff_rd_en = tff_rd_en_pre;

always@(posedge clk, posedge rst) begin
	if(rst)
		tff_rd_en_pre <= 'd0;
	else if(para_tx_invl_mode == 0)
		if(cs == TX_IDLE)
			tff_rd_en_pre <= (!tff_empty) & (tff_rd_byte_num == 4'd0) & r1_tx_driv_flag & tx_driv_flag_sft;
		else if(cs == TX_STOP_BIT)
			tff_rd_en_pre <= stop_bit_done & (!tff_empty) & (tff_rd_byte_num == `BYTE_CNT_THRD/*4'd7*/);
		else if(cs == TX_PARA_CFG)
			tff_rd_en_pre <= `CFG_DONE_CDN & (!tff_empty) & (tff_rd_byte_num == `BYTE_CNT_THRD/*4'd7*/) & r1_tx_driv_flag & tx_driv_flag_sft;
	else
		tff_rd_en_pre <= (!tff_empty) & (cs == TX_IDLE) & (tff_rd_byte_num == 4'd0) & r1_tx_driv_flag & tx_driv_flag_sft;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		cs <= TX_IDLE;
	else
		cs <= ns;
end

always@* begin
	case(cs)
		TX_IDLE	:	//if((!tff_empty) & (tff_rd_byte_num == 4'd0) & r1_tx_driv_flag & tx_driv_flag_sft)
					if(tff_rd_en_pre)
						ns <= TX_DATA;
					else
						ns <= para_cfg_req_post ? TX_PARA_CFG : TX_IDLE;

		TX_DATA	:	if((tx_cnt == 8) & r1_tx_driv_flag & tx_driv_flag_sft)
						if(para_parity_chk == P_CHK_NONE)
							ns <= TX_STOP_BIT;
						else
							ns <= TX_PARITY_CHECK;
					else
						ns <= TX_DATA;

		TX_PARITY_CHECK: if(r1_tx_driv_flag & tx_driv_flag_sft)
						ns <= TX_STOP_BIT;
					else
						ns <= TX_PARITY_CHECK;

		TX_STOP_BIT:	if(stop_bit_done)
						if(tff_rd_byte_num < `BYTE_CNT_THRD)
							ns <= para_cfg_req_post ? TX_PARA_CFG : TX_DATA;
						else
							ns <= para_cfg_req_post ? TX_PARA_CFG : (para_tx_invl_mode != 2'd0) ? TX_IDLE : tff_rd_en_pre ? TX_DATA : TX_IDLE;
					else
						ns <= TX_STOP_BIT;

		TX_PARA_CFG:	if(para_cfg_req_post == 2'd1)
						if(LR_CFG_DONE > 2'd1)
							if((tff_rd_byte_num > 4'd0) & r1_tx_driv_flag & tx_driv_flag_sft)
								ns <= TX_DATA;
							else
								ns <= (para_tx_invl_mode != 2'd0) ? TX_IDLE : tff_rd_en_pre ? TX_DATA : TX_IDLE;
						else
							ns <= TX_PARA_CFG;
					else if(para_cfg_req_post == 2'd2)
						if(chl_clr_done)
							if((tff_rd_byte_num > 4'd0) & r1_tx_driv_flag & tx_driv_flag_sft)
								ns <= TX_DATA;
							else
								ns <= (para_tx_invl_mode != 2'd0) ? TX_IDLE : tff_rd_en_pre ? TX_DATA : TX_IDLE;
						else
							ns <= TX_PARA_CFG;
					else
						ns <= TX_PARA_CFG;

		default: ns <= TX_IDLE;
	endcase
end

always@(posedge clk, posedge rst) begin
	if(rst)
		tx_cnt <= 'd0;
	else if(cs == TX_DATA)
		tx_cnt <=  (r1_tx_driv_flag & tx_driv_flag_sft) ? (tx_cnt + 1'd1) : tx_cnt;
	else
		tx_cnt <= 'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		tx_stop_bit_cnt <= 'd0;
	else if(cs == TX_STOP_BIT)
		tx_stop_bit_cnt <= r1_tx_driv_flag ? (tx_stop_bit_cnt + 1'd1) : tx_stop_bit_cnt;
	else
		tx_stop_bit_cnt <= 'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		stop_bit_done <= 'd0;
	else
		stop_bit_done <= (tx_stop_bit_cnt == (para_stop_bit + 1)) & r1_tx_driv_flag;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		tff_rd_byte_num <= 'd0;
	else if(tff_rd_byte_num >= tff_rd_strb_cnt)
		tff_rd_byte_num <= 'd0;
	else if((cs == TX_STOP_BIT) & stop_bit_done)
		tff_rd_byte_num <= tff_rd_byte_num + 1'd1;
	else
		tff_rd_byte_num <= tff_rd_byte_num;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		p_chk_data <= 'd0;
	else if(para_parity_chk != P_CHK_NONE)
		p_chk_data <= (cs == TX_DATA) ? tff_dout_post[(tff_rd_byte_num*8)+:8] : p_chk_data;
	else
		p_chk_data <= 'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		r1_UART_TX <= 1'd1;
	else if(cs == TX_DATA)
		case(tx_cnt)
			0:	r1_UART_TX <= 1'd0;
			1:	r1_UART_TX <= tff_dout_post[(tff_rd_byte_num*8) + 0];
			2:	r1_UART_TX <= tff_dout_post[(tff_rd_byte_num*8) + 1];
			3:	r1_UART_TX <= tff_dout_post[(tff_rd_byte_num*8) + 2];
			4:	r1_UART_TX <= tff_dout_post[(tff_rd_byte_num*8) + 3];
			5:	r1_UART_TX <= tff_dout_post[(tff_rd_byte_num*8) + 4];
			6:	r1_UART_TX <= tff_dout_post[(tff_rd_byte_num*8) + 5];
			7:	r1_UART_TX <= tff_dout_post[(tff_rd_byte_num*8) + 6];
			8:	r1_UART_TX <= tff_dout_post[(tff_rd_byte_num*8) + 7];
		default:r1_UART_TX <= 1'd1;
	endcase
	else if(cs == TX_PARITY_CHECK)
		r1_UART_TX <=   (para_parity_chk == P_CHK_ODD  ) ? (^p_chk_data)
					:(para_parity_chk == P_CHK_EVEN ) ? (~^p_chk_data)
					:(para_parity_chk == P_CHK_MARK ) ? 1'd1
					:(para_parity_chk == P_CHK_SPACE) ? 1'd0 : 1'd1;
	else if(cs == TX_STOP_BIT)
		r1_UART_TX <= 1'd1;
	else
		r1_UART_TX <= r1_UART_TX;
end

assign strb_cnt = w_hs ? (strb_cnt_latch +
wstrb[7 ] + wstrb[6 ] + wstrb[5 ] + wstrb[4 ] +
wstrb[3 ] + wstrb[2 ] + wstrb[1 ] + wstrb[0 ]) : strb_cnt_latch;

always@(posedge clk, posedge rst) begin
	if(rst)
		strb_cnt_latch <= 'd0;
	else if(strb_cnt >= 8)
		strb_cnt_latch <= 'd0;
	else
		strb_cnt_latch <= strb_cnt;
end

// assign strb_fix_data = (wdata & wstrb) | (strb_fix_data_latch & (~wstrb));

generate for (i = 0; i < 8; i = i + 1) begin : GF_STRB

	assign strb_fix_data[8*i+:8] = w_hs ? (({8{wstrb[i]}} & wdata[8*i+:8]) | ({8{(~wstrb[i])}} & strb_fix_data_latch[8*i+:8])) : strb_fix_data_latch[8*i+:8];

	if(i == 0)
		assign tff_rd_strb_right_part_zero_cnt[i] = (!tff_rd_en_pre) ? 4'd0 : {3'd0, (!tff_dout[64+i])};
	else
		assign tff_rd_strb_right_part_zero_cnt[i] = (!tff_rd_en_pre) ? 4'd0 : (tff_rd_strb_right_part_zero_cnt[i-1] != i) ? tff_rd_strb_right_part_zero_cnt[i-1] : (tff_rd_strb_right_part_zero_cnt[i-1] + (!tff_dout[64+i]));

	if(i == 0)
		assign wstrb_right_part_zero_cnt[i] = (!w_hs) ? 4'd0 : {3'd0, (!wstrb[i])};
	else
		assign wstrb_right_part_zero_cnt[i] = (!w_hs) ? 4'd0 : (wstrb_right_part_zero_cnt[i-1] != i) ? wstrb_right_part_zero_cnt[i-1] : (wstrb_right_part_zero_cnt[i-1] + (!wstrb[i]));

	assign eff_wdata[8*i+:8] = w_hs ? ({8{eff_wstrb[i]}} & wdata[8*i+:8]) : 8'd0;

end endgenerate

always@(posedge clk, posedge rst) begin
	if(rst)
		tff_rd_strb_cnt <= 'd0;
	else if(tff_rd_en_pre)
		tff_rd_strb_cnt <= (tff_dout[71] + tff_dout[70] + tff_dout[69] + tff_dout[68] + tff_dout[67] + tff_dout[66] + tff_dout[65] + tff_dout[64]);
	else
		tff_rd_strb_cnt <= tff_rd_strb_cnt;
end


always@(posedge clk, posedge rst) begin
	if(rst)
		strb_fix_data_latch <= 'd0;
	else
		strb_fix_data_latch <= strb_fix_data;
end

assign UART_TX = r1_UART_TX;

always@(posedge clk, posedge rst) begin
	if(rst)
		axi_wr_cnt <= 'd0;
	else if(w_hs)
		if((axi_wr_cnt + wstrb_cnt) >= LR_AXI_WR_MAX_LEN)
			axi_wr_cnt <= 'd0;
		else
			axi_wr_cnt <= axi_wr_cnt + wstrb_cnt;
	else
		axi_wr_cnt <= axi_wr_cnt;
end


always@(*) begin
	if(w_hs & (axi_wr_cnt >= LR_AXI_WR_EFF_LEN))
		eff_wstrb <= 'd0;
	else if(w_hs & ((axi_wr_cnt + wstrb_cnt) >= LR_AXI_WR_EFF_LEN) & (axi_wr_cnt < LR_AXI_WR_EFF_LEN))
		eff_wstrb <= wstrb & (8'hff >> `EFF_STRB_SFT);
	else
		eff_wstrb <= wstrb;
end

`ifdef `D
`undef `D
`endif

`ifdef `DEBUG_axi_uart_tx
`undef `DEBUG_axi_uart_tx
`endif
endmodule