`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Xuqinjun
// 
// Create Date: 2024/07/22
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: axi-full to serial signal
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//`define USE_BRUST_REG
//`define DEBUG_uart_f2ser_read
module uart_f2ser_read(
	//
    input               clk                 	    	,
    input               rst                 	    	,	
	//	
	input 				rx_driv_flag					,
	output 				is_start_bit					,
	output reg			got_whole_brust_pkt				,
	//
	input	[15:0]		LR_AXI_RD_LEN					,
	input 	 			LR_CFG_REQ						,
	input 	[3:0]		LR_STOP_BIT						,
	input 	[3:0]		LR_P_CHK						,
	input 	[3:0]		LR_D_WIDTH		    			,
	input 				LR_STOP_PCHK_ENA				,
	input 				LR_FSM_RST_REQ	    			,
	input 	[7:0]		LR_AXI_BRUST_LEN				,
	input	[31:0]		LR_TIMEOUT_THRD					,
	//
	output 	reg	[1:0]	LR_CFG_DONE						,
	output 	reg	 		LR_FSM_RST_DONE					,
	output 	reg	[15:0]	LR_STOP_BIT_ERR_CNT				,
	output 	reg	[15:0]	LR_PCHK_ERR_CNT					,
	output 	reg	[15:0]	LR_RFF_USEDW       				,
	//
	input 	[1:0]		chl_clr_req						,// from uart_driv_flag_gen module
	output	reg			chl_clr_done					,
	//axi-full-----------------------------------------------------------
    input   [3 : 0]                 s_axi_arid                          ,
    input   [63 : 0]                s_axi_araddr                        ,
    input   [7 : 0]                 s_axi_arlen                         ,
    input   [2 : 0]                 s_axi_arsize                        ,
    input   [1 : 0]                 s_axi_arburst                       ,
    input   [2 : 0]                 s_axi_arprot                        ,
    input                           s_axi_arvalid                       ,
    input                           s_axi_arlock                        ,
    input   [3 : 0]                 s_axi_arcache                       ,
    output                          s_axi_arready                       ,

    output  [3 : 0]                 s_axi_rid                           ,
    output  [63 : 0]                s_axi_rdata                         ,
    output  [1 : 0]                 s_axi_rresp                         ,
    output                          s_axi_rlast                         ,
    output                          s_axi_rvalid                        ,
    input                           s_axi_rready                        ,
	//
	input 							UART_RX								  //
);
`define DEBUG_DEF `ifdef DEBUG_uart_f2ser_read (*mark_debug = "true"*)(*keep = "true"*)`else `endif 

`ifdef USE_BRUST_REG
	`define POST_BRUST_LEN  (para_axi_brust_len - 1)
`else 
	`define POST_BRUST_LEN  (LR_AXI_RD_LEN[15:3]+ (LR_AXI_RD_LEN[2:0] != 0) - 1)
`endif

`define RLAST_CDN (((r1_rff_rd_cnt + r1_rff_rd_strb_cnt) >= LR_AXI_RD_LEN) & (r1_rff_rd_cnt < LR_AXI_RD_LEN) & r1_rff_rd_en)

// fsm
localparam	IDLE       = 4'd0;
localparam	RX_DATA    = 4'd1;
localparam	STOP_BIT   = 4'd2;
localparam	PARITY_CHK = 4'd3;
localparam	PARA_CFG   = 4'd4;

localparam	FORCE_RESET= 4'd15;

//para
localparam	STOP_BIT_1   = 4'd0;
localparam	STOP_BIT_1P5 = 4'd1;
localparam	STOP_BIT_2   = 4'd2;

localparam	P_CHK_NONE   = 4'd0;
localparam	P_CHK_ODD    = 4'd1;
localparam	P_CHK_EVEN   = 4'd2;
localparam	P_CHK_MARK   = 4'd3;
localparam	P_CHK_SPACE  = 4'd4;


`DEBUG_DEF	reg [31:0] LR_TIMEOUT_THRD_reg, timeout_cnt;
`DEBUG_DEF	wire timeout_flag = timeout_cnt >= LR_TIMEOUT_THRD_reg;

`DEBUG_DEF	wire 		is_start_bit_wire;
`DEBUG_DEF	reg			r1_is_start_bit;
`DEBUG_DEF	reg	[9:0] 	r_UART_RX;

`DEBUG_DEF	reg [7:0]p_chk_data;
`DEBUG_DEF	reg [3:0]cs, ns, rx_cnt, r1_rx_cnt, rx_stop_bit_cnt;
`DEBUG_DEF	reg r1_rx_driv_flag, rx_driv_flag_sft, stop_bit_done, force_jump;
`DEBUG_DEF	reg [1:0]para_cfg_req_post;

`DEBUG_DEF	wire [15:0]		LR_AXI_RD_LEN_wire = LR_AXI_RD_LEN;
`DEBUG_DEF	wire [15:0]		LR_RFF_USEDW_wire  = LR_RFF_USEDW;

reg  [3:0]		para_stop_bit;
reg  [3:0]		para_parity_chk;
reg  [3:0]		para_data_width;
reg  [7:0]		para_axi_brust_len;

wire p_chk_cdn = ((para_parity_chk == P_CHK_ODD  ) ? (^p_chk_data)
				 :(para_parity_chk == P_CHK_EVEN ) ? (~^p_chk_data)
				 :(para_parity_chk == P_CHK_MARK ) ? 1'd1
				 :(para_parity_chk == P_CHK_SPACE) ? 1'd0 : 1'd1);

`DEBUG_DEF	reg  [127: 0]	rdata_window;
`DEBUG_DEF	reg  [3  : 0]	rdata_window_remdr, r1_rdata_window_remdr;
`DEBUG_DEF	reg 			rd_start;

`DEBUG_DEF	wire [71 : 0]	rff_din       ;
`DEBUG_DEF	reg  [63 : 0]	rff_din_data_pre;
`DEBUG_DEF	reg  [63 : 0]	rff_din_data_eff;
`DEBUG_DEF	reg  [7 : 0]	rff_din_strb_pre;
`DEBUG_DEF	reg 			rff_wr_en     ;
`DEBUG_DEF	reg 			rff_rd_en     ;
`DEBUG_DEF	reg 			r1_rff_rd_en  ;
`DEBUG_DEF	wire [71 : 0]	rff_dout      ;
`DEBUG_DEF	wire			rff_full      ;
`DEBUG_DEF	wire			rff_empty     ;
`DEBUG_DEF	wire [10 : 0]	rff_data_count;
`DEBUG_DEF	reg  [15:0]		rff_rd_cnt, r1_rff_rd_cnt;
`DEBUG_DEF	reg  [3:0]		rff_wr_byte_num;
`DEBUG_DEF	wire [3:0]		rff_rd_strb_cnt = rff_dout[71] + rff_dout[70] + rff_dout[69] + rff_dout[68] + rff_dout[67] + rff_dout[66] + rff_dout[65] + rff_dout[64];
`DEBUG_DEF	reg  [3:0]		r1_rff_rd_strb_cnt;
`DEBUG_DEF	wire [3:0]		rff_wr_strb_cnt = rff_din[71] + rff_din[70] + rff_din[69] + rff_din[68] + rff_din[67] + rff_din[66] + rff_din[65] + rff_din[64];
reg					pad, pad1;

// _________________________________________________________________________ full read data	
reg [3 : 0]   		rid   					;
`DEBUG_DEF	reg  [63 : 0] 		rdata 					;
reg [1 : 0]   		rresp 					;
`DEBUG_DEF	reg           		rlast 					;
`DEBUG_DEF	reg           		rlast_cdn				;
`DEBUG_DEF	reg           		rvalid					;
`DEBUG_DEF	wire          		rready = s_axi_rready	;
`DEBUG_DEF	wire 				r_hs = rready & rvalid	;

assign s_axi_rid    = rid   ;
assign s_axi_rdata  = rdata ;
assign s_axi_rresp  = rresp ;
assign s_axi_rlast  = rlast ;
assign s_axi_rvalid = rvalid;

// _________________________________________________________________________ full read addr
wire [3 : 0] 		arid    = s_axi_arid   		;   
wire [63 : 0]		araddr  = s_axi_araddr 		; 
wire [7 : 0] 		arlen   = s_axi_arlen  		;  
wire [2 : 0] 		arsize  = s_axi_arsize 		; 
wire [1 : 0] 		arburst = s_axi_arburst		;
wire [2 : 0] 		arprot  = s_axi_arprot 		; 
wire         		arvalid = s_axi_arvalid		;
wire         		arlock  = s_axi_arlock 		; 
wire [3 : 0] 		arcache = s_axi_arcache		;
reg          		arready						;
`DEBUG_DEF	wire			 	ar_hs = arready & arvalid	;

always@(posedge clk, posedge rst) begin
	if(rst)
		arready <= 1'd0;
	else if (r_hs)
		arready <= 1'd0;
	else
		arready <= 1'd1;
end

assign s_axi_arready = arready;

always@(posedge clk, posedge rst) begin
	if(rst) begin
		rid    <= 'd0;
		rdata  <= 'd0;
		rresp  <= 'd0;
		rlast  <= 'd0;
		rvalid <= 'd0;
		rlast_cdn <= 'd0;
	end
	else if (rd_start || `RLAST_CDN)begin
		rid    <= 'd0;
		rdata  <= rdata_window[63:0];
		rresp  <= 'd0;
		
		rlast_cdn <= `RLAST_CDN;
		
		//rlast  <= (rlast_cdn & (r1_rdata_window_remdr != 0) & (rdata_window_remdr == 0)) || ((~rlast_cdn) & (((r1_rff_rd_cnt + r1_rff_rd_strb_cnt) >= LR_AXI_RD_LEN) & (r1_rff_rd_cnt < LR_AXI_RD_LEN) & r1_rff_rd_en) & (rdata_window_remdr == 0));
		
		if((rdata_window_remdr == 0) & rlast_cdn & (r1_rdata_window_remdr != 0))
			rlast <= 1'd1;
		else 
			rlast <= `RLAST_CDN & (rdata_window_remdr == 0);
		
		
		if((`RLAST_CDN & (rdata_window_remdr != 0)) || ((`RLAST_CDN == 1'd0) & (~((rdata_window_remdr == 0) & rlast_cdn & (r1_rdata_window_remdr != 0)))))
			rvalid <= ((r1_rdata_window_remdr + r1_rff_rd_strb_cnt) >= 8) & r1_rff_rd_en & (LR_AXI_RD_LEN > 8);			
		else
			rvalid <= ((rdata_window_remdr == 0) & rlast_cdn & (r1_rdata_window_remdr != 0)) || (`RLAST_CDN & (rdata_window_remdr == 0));
	end
	else begin 
		rid   		<= 'd0;
		rdata		<= 'd0;
		rresp 		<= 'd0;
		rlast 		<= 'd0;
		rvalid		<= 'd0;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		r_UART_RX				<= 'd0;
		r1_rx_driv_flag			<= 'd0;
		r1_rx_cnt				<= 'd0;
		r1_rff_rd_strb_cnt		<= 'd0;
		r1_rdata_window_remdr	<= 'd0;
		r1_rff_rd_cnt			<= 'd0;
		r1_rff_rd_en			<= 'd0;
		r1_is_start_bit			<= 'd0;
	end
	else begin
		r_UART_RX				<= {r_UART_RX[8:0], UART_RX};
		r1_rx_driv_flag			<= (~r1_is_start_bit) & rx_driv_flag;
		r1_rx_cnt				<= rx_cnt;
		r1_rff_rd_strb_cnt		<= rff_rd_strb_cnt;
		r1_rdata_window_remdr	<= rdata_window_remdr;
		r1_rff_rd_cnt			<= rff_rd_cnt;
		r1_rff_rd_en			<= rff_rd_en;
		r1_is_start_bit			<= is_start_bit;
	end
end

assign is_start_bit_wire = ((cs == IDLE) || (cs == STOP_BIT) || (cs == PARA_CFG)) & ({r_UART_RX[1], r_UART_RX[0]} == 2'b10);// negedge
assign is_start_bit = is_start_bit_wire;
       				
always@(posedge clk, posedge rst) begin
	if(rst) begin
		para_stop_bit         <= STOP_BIT_1;
		para_parity_chk       <= P_CHK_NONE;
		para_data_width       <= 4'd8;
		para_axi_brust_len    <= 15;
	end
	else if(cs == PARA_CFG) begin
		para_stop_bit         <= (LR_STOP_BIT <= STOP_BIT_2)? LR_STOP_BIT	: para_stop_bit  ;
		para_parity_chk       <= (LR_P_CHK <= P_CHK_SPACE) 	? LR_P_CHK 		: para_parity_chk;
		para_data_width       <= (LR_D_WIDTH <= 4'd8)		? LR_D_WIDTH	: para_data_width;
		para_axi_brust_len    <= LR_AXI_BRUST_LEN;
	end
	else begin
		para_stop_bit         <= para_stop_bit  ;
		para_parity_chk       <= para_parity_chk;
		para_data_width       <= para_data_width;
		para_axi_brust_len    <= para_axi_brust_len;
	end
end
/*
always@(posedge clk, posedge rst) begin
	if(rst)
		LR_CFG_DONE <= 'd0;
	else if(cs == PARA_CFG)
		if((LR_STOP_BIT <= STOP_BIT_2) & (LR_P_CHK <= P_CHK_SPACE) & (LR_D_WIDTH <= 4'd8))
			LR_CFG_DONE <= 2'd2;
		else
			LR_CFG_DONE <= 2'd3;
	else
		LR_CFG_DONE <= 'd0;
end
*/

// Burrs may cause FSM to remain in a rx state indefinitely
always@(posedge clk, posedge rst) begin
	if(rst)
		LR_CFG_DONE <= 'd0;
	else if((LR_STOP_BIT <= STOP_BIT_2) & (LR_P_CHK <= P_CHK_SPACE) & (LR_D_WIDTH <= 4'd8))
		LR_CFG_DONE <= 2'd2;
	else
		LR_CFG_DONE <= 2'd3;
end

uart_ff_8k RFF_8K (
		.clk		(	clk				),
		.din		(	rff_din       	),
		.wr_en		(	rff_wr_en     	),
		.rd_en		(	rff_rd_en     	),
		.dout		(	rff_dout      	),
		.full		(	rff_full      	),
		.empty		(	rff_empty     	),
		.data_count	(	rff_data_count	)
);

always@(posedge clk, posedge rst) begin
	if(rst) 
		rff_wr_byte_num <= 'd0;
	else if(rff_wr_en)
		if(rx_cnt == 9)
			rff_wr_byte_num <= 'd1;
		else
			rff_wr_byte_num <= 'd0;
	else if(rx_cnt == 9)
		if(rff_wr_byte_num == 4'd7)
			rff_wr_byte_num <= 'd0;
		else
			rff_wr_byte_num <= rff_wr_byte_num + 1'd1;
	else
		rff_wr_byte_num <= rff_wr_byte_num;
end

always@* begin
	if(!rff_wr_en)
		rff_din_data_eff <= 'd0;
	else case(rx_cnt)
		0: rff_din_data_eff <= rff_din_data_pre;
		9: rff_din_data_eff <= rff_din_data_pre;
		default: rff_din_data_eff <= ({64{1'd1}} >> (8 - rff_wr_byte_num)*8) & rff_din_data_pre;
	endcase
end

assign rff_din = rff_wr_en ? {rff_din_strb_pre, rff_din_data_eff} : 0;

always@(posedge clk, posedge rst) begin
	if(rst) 
		{pad1, rff_din_strb_pre} <= 'd0;
	else if(rff_wr_en)
		if(rx_cnt == 9)	
			{pad1, rff_din_strb_pre} <= 'd1;
		else 
			{pad1, rff_din_strb_pre} <= 'd0;
	else if(rx_cnt == 9)
		{pad1, rff_din_strb_pre} <= {rff_din_strb_pre, 1'd1};
	else 
		{pad1, rff_din_strb_pre} <= {pad1, rff_din_strb_pre};
end

always@(posedge clk, posedge rst) begin
	if(rst) 
		rff_wr_en <= 1'd0;
	else if(((rx_cnt == 9) & (rff_wr_byte_num == 4'd7)) | (timeout_cnt >= LR_TIMEOUT_THRD_reg))
		rff_wr_en <= (!rff_full) & (rff_din_strb_pre != 0);
	else
		rff_wr_en <= 1'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		rff_rd_cnt <= 'd0;
	else if(rlast)
		rff_rd_cnt <= 'd0;
	else if(rff_rd_en)
		rff_rd_cnt <= rff_rd_cnt + rff_rd_strb_cnt;
	else 
		rff_rd_cnt <= rff_rd_cnt;
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
		rff_rd_en <= 'd0;
	else if(((rff_rd_cnt + rff_rd_strb_cnt) <= LR_AXI_RD_LEN) & (rff_rd_strb_cnt != 0) & rd_start)
		if(!rff_rd_en)
			rff_rd_en <= ((rff_rd_cnt + rff_rd_strb_cnt) <= LR_AXI_RD_LEN);
		else 
			rff_rd_en <= ((rff_rd_cnt + rff_rd_strb_cnt) < LR_AXI_RD_LEN);
	else
		rff_rd_en <= 'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst) 
		rdata_window <= 'd0;
	else if(rlast)
		rdata_window <= 'd0;
	else if(rff_rd_en || ((~rff_rd_en) & `RLAST_CDN))
		if(((r1_rdata_window_remdr + r1_rff_rd_strb_cnt) >= 8) & r1_rff_rd_en)
			rdata_window <= ({64'd0, (rff_rd_en ? rff_dout[63:0] : 64'd0)} << (8*rdata_window_remdr)) | (rdata_window >> 64);
		else
			rdata_window <= ({64'd0, rff_dout[63:0]} << (8*rdata_window_remdr)) | rdata_window;
	else
		rdata_window <= rdata_window;
end

always@(posedge clk, posedge rst) begin
	if(rst) 
		rdata_window_remdr <= 'd0;
	else if(`RLAST_CDN)
		rdata_window_remdr <= 'd0;
	else if(rff_rd_en) 
		rdata_window_remdr <= ((rdata_window_remdr + rff_rd_strb_cnt) >= 8) ? ((rdata_window_remdr + rff_rd_strb_cnt) - 8) : (rdata_window_remdr + rff_rd_strb_cnt);
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
	else if(cs == STOP_BIT)
		rx_stop_bit_cnt <= r1_rx_driv_flag ? (rx_stop_bit_cnt + 1'd1) : rx_stop_bit_cnt;
	else
		rx_stop_bit_cnt <= 'd0;
end

always@(posedge clk, posedge rst) begin
	if(rst) 
		stop_bit_done <= 'd0;
	else
		stop_bit_done <= (rx_stop_bit_cnt == (para_stop_bit + 1)) & r1_rx_driv_flag;
end

always@(posedge clk, posedge rst) begin
	if(rst) 
		p_chk_data <= 'd0;
	else if(para_parity_chk != P_CHK_NONE)
		p_chk_data <= (cs == RX_DATA) ? rff_din[(rff_wr_byte_num*8)+:8] : p_chk_data;
	else
		p_chk_data <= 'd0;		
end

always@(posedge clk, posedge rst) begin
	if(rst)
		cs <= IDLE;
	else if(LR_FSM_RST_DONE)
		cs <= FORCE_RESET;
	else
		cs <= ns;
end

/* is to avoid : 1. the UART terminal sends data without intervals and stop bit is too short(0.5buad < stop bit < setting stop bit)
                 2. the new start bit comes when modifying parameters(not include baud rate)*/
always@(posedge clk, posedge rst) begin 
	if(rst)
		force_jump <= 'd0;
	else if(cs == STOP_BIT)
		force_jump <= is_start_bit;
	else if(cs == PARA_CFG)
		force_jump <= is_start_bit ? 1'd1 : force_jump;
	else
		force_jump <= 'd0;
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
		else if((cs == PARA_CFG) & (LR_CFG_DONE > 2'd1))
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
		chl_clr_done <= 'd0;
	else if((cs == PARA_CFG) & (para_cfg_req_post == 2'd2) & (chl_clr_req == 2'd2))
		chl_clr_done <= 1'd1;
	else
		chl_clr_done <= 1'd0;
end

always@* begin
	case(cs)
		IDLE	:	if(is_start_bit)
						ns <= RX_DATA;
					else
						ns <= para_cfg_req_post ? PARA_CFG : IDLE;
		
		RX_DATA	:	if((rx_cnt == 8) & r1_rx_driv_flag & rx_driv_flag_sft)
						if(para_parity_chk == P_CHK_NONE)
							ns <= STOP_BIT;
						else
							ns <= PARITY_CHK;
					else
						ns <= RX_DATA;
		
		PARITY_CHK: if(r1_rx_driv_flag & rx_driv_flag_sft)
						ns <= STOP_BIT;
					else
						ns <= PARITY_CHK;
		
		STOP_BIT:	if(force_jump)
						ns <= RX_DATA;
					else if(LR_STOP_PCHK_ENA == 1'd0)
						ns <= para_cfg_req_post ? PARA_CFG : IDLE;
					else if(stop_bit_done)
						ns <= para_cfg_req_post ? PARA_CFG : IDLE;
					else
						ns <= STOP_BIT;
		
		PARA_CFG:	if(para_cfg_req_post == 2'd1)
						if(LR_CFG_DONE > 2'd1)
							ns <= force_jump ? RX_DATA : IDLE;
						else
							ns <= PARA_CFG;
					else if(para_cfg_req_post == 2'd2)
						if(chl_clr_done)
							ns <= IDLE;
						else
							ns <= PARA_CFG;
					else 
						ns <= PARA_CFG;
						
		default: ns <= IDLE;
	endcase
end


always@(posedge clk, posedge rst) begin
	if(rst) 
		rff_din_data_pre <= 'd0;
	else if(rff_wr_en)//((((rx_cnt == 9) & (rff_wr_byte_num == 4'd7)) | (timeout_cnt >= LR_TIMEOUT_THRD_reg)) & (!rff_full) & (rff_din_strb_pre != 0))
		rff_din_data_pre <= {56'd0, rff_din_data_pre[(rff_wr_byte_num*8)+:8]};
	else if((cs == RX_DATA) & (r1_rx_driv_flag & rx_driv_flag_sft))
		case(rx_cnt)
			0:	rff_din_data_pre <= rff_din_data_pre;
			1:	rff_din_data_pre[(rff_wr_byte_num*8) + 0] <= r_UART_RX[6];
			2:	rff_din_data_pre[(rff_wr_byte_num*8) + 1] <= r_UART_RX[6];
			3:	rff_din_data_pre[(rff_wr_byte_num*8) + 2] <= r_UART_RX[6];
			4:	rff_din_data_pre[(rff_wr_byte_num*8) + 3] <= r_UART_RX[6];
			5:	rff_din_data_pre[(rff_wr_byte_num*8) + 4] <= r_UART_RX[6];
			6:	rff_din_data_pre[(rff_wr_byte_num*8) + 5] <= r_UART_RX[6];
			7:	rff_din_data_pre[(rff_wr_byte_num*8) + 6] <= r_UART_RX[6];
			8:	rff_din_data_pre[(rff_wr_byte_num*8) + 7] <= r_UART_RX[6];
			default:rff_din_data_pre <= rff_din_data_pre;
		endcase
	else
		rff_din_data_pre <= rff_din_data_pre;
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		LR_STOP_BIT_ERR_CNT <= 'd0;
		LR_PCHK_ERR_CNT		<= 'd0;
	end
	else if(LR_STOP_PCHK_ENA)begin
		LR_STOP_BIT_ERR_CNT <= ((cs == STOP_BIT) & is_start_bit) 					? (LR_STOP_BIT_ERR_CNT + 1'd1) 	: LR_STOP_BIT_ERR_CNT;
	    LR_PCHK_ERR_CNT		<= ((cs == PARITY_CHK) & ( r_UART_RX[6] == p_chk_cdn )) 	? (LR_PCHK_ERR_CNT + 1'd1) 		: LR_PCHK_ERR_CNT;
	end
	else begin
		LR_STOP_BIT_ERR_CNT <= 'd0;
	    LR_PCHK_ERR_CNT     <= 'd0;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst)
		//LR_TIMEOUT_THRD_reg <= 32'd2800;//921600, 2 byte
		//LR_TIMEOUT_THRD_reg <= 32'd1400;//921600, 1 byte
		LR_TIMEOUT_THRD_reg <= 'd0;
	else
		LR_TIMEOUT_THRD_reg <= LR_TIMEOUT_THRD;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		timeout_cnt <= 32'd0;
	else if(rx_cnt == 9)
		timeout_cnt <= 'd0;
	else
		timeout_cnt <= (timeout_cnt >= LR_TIMEOUT_THRD_reg) ? 0 : (timeout_cnt + 1'd1);
end

always@(posedge clk, posedge rst) begin
	if(rst)
		LR_RFF_USEDW <= 'd0;
	else if(rff_rd_en & rff_wr_en)
		LR_RFF_USEDW <= LR_RFF_USEDW + rff_wr_strb_cnt - rff_rd_strb_cnt;
	else if(rff_rd_en)
		LR_RFF_USEDW <= LR_RFF_USEDW - rff_rd_strb_cnt;
	else if(rff_wr_en)
		LR_RFF_USEDW <= LR_RFF_USEDW + rff_wr_strb_cnt;
	else
		LR_RFF_USEDW <= LR_RFF_USEDW;
end


endmodule
