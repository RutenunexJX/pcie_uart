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
//`define TEST
//`define DEBUG_uart_f2ser_write
module uart_f2ser_write #(
	parameter BASE_ADDR = 64'ha000_0000_0000_0000
)(
    input               clk                 		,
    input               rst                 		,
	
	input				tx_driv_flag				,
	//

	input 				LR_CFG_REQ		    		,                    
	input 	[3:0]		LR_STOP_BIT	        		,                
	input 	[3:0]		LR_P_CHK		    		,                    
	input 	[3:0]		LR_D_WDITH		    		,                    
	input 	[1:0]		LR_INVL_MODE	    		,                    
	input 	[15:0]		LR_INVL_HF_BAUD     		,                   
	input 	[15:0]		LR_INVL_CLK_PD	    		,
	input 	[15:0]		LR_AXI_WR_MAX_LEN			,
	input   [15:0]		LR_AXI_WR_EFF_LEN			,                    

	output reg	[1:0]	LR_CFG_DONE					,	                    
	output reg	[10:0]	LR_TFF_USEDW				,   
	
	output reg  [31:0]	LR_TEST_FLAG				,
	output reg  [31:0]	LR_TEST_ERR_INFO			,

	input	[1:0]		chl_clr_req					,// from uart_driv_flag_gen module
	output reg			chl_clr_done				,
	//axi-full-----------------------------------------------------------
    input   [3 : 0]                 s_axi_awid                          ,
    input   [63 : 0]                s_axi_awaddr                        ,
    input   [7 : 0]                 s_axi_awlen                         ,
    input   [2 : 0]                 s_axi_awsize                        ,
    input   [1 : 0]                 s_axi_awburst                       ,
    input   [2 : 0]                 s_axi_awprot                        ,
    input                           s_axi_awvalid                       ,
    input                           s_axi_awlock                        ,
    input   [3 : 0]                 s_axi_awcache                       ,
    output                          s_axi_awready                       ,

    input   [63 : 0]				s_axi_wdata                         ,
    input   [7 : 0]                	s_axi_wstrb                         ,
    input                           s_axi_wlast                         ,
    input                           s_axi_wvalid                        ,
    output                          s_axi_wready                        ,

    output  [3 : 0]                 s_axi_bid                           ,
    output  [1 : 0]                 s_axi_bresp                         ,
    output                          s_axi_bvalid                        ,
    input                           s_axi_bready                        ,

	//
	output  						UART_TX								 //
);


`define DEBUG_DEF `ifdef DEBUG_uart_f2ser_write (*mark_debug = "true"*)(*keep = "true"*)`else `endif 

`define INVL_CDN ((para_tx_invl_mode == 2'd0) ? ((cs == STOP_BIT) || (cs == PARA_CFG)) : 1'd0)
`define CFG_DONE_CDN (((para_cfg_req_post == 2'd1) & (LR_CFG_DONE > 2'd1)) || ((para_cfg_req_post == 2'd2) & chl_clr_done))
`define BYTE_CNT_THRD ((tff_rd_strb_cnt > 0) ? (tff_rd_strb_cnt - 1) : 0)

`define EFF_STRB_SFT (8 - ((LR_AXI_WR_EFF_LEN - axi_wr_cnt) + wstrb_right_part_zero_cnt[7]))

// fsm
localparam	IDLE       = 4'd0;
localparam	TX_DATA    = 4'd1;
localparam	STOP_BIT   = 4'd2;
localparam	PARITY_CHK = 4'd3;
localparam	PARA_CFG   = 4'd4;
localparam 	CHL_CLR	   = 4'd5;

//para
localparam	STOP_BIT_1   = 4'd0;
localparam	STOP_BIT_1P5 = 4'd1;
localparam	STOP_BIT_2   = 4'd2;

localparam	P_CHK_NONE   = 4'd0;
localparam	P_CHK_ODD    = 4'd1;
localparam	P_CHK_EVEN   = 4'd2;
localparam	P_CHK_MARK   = 4'd3;
localparam	P_CHK_SPACE  = 4'd4;

genvar i;

`DEBUG_DEF	reg r1_UART_TX;

`DEBUG_DEF	wire[15:0] LR_AXI_WR_MAX_LEN_wire = LR_AXI_WR_MAX_LEN;
`DEBUG_DEF	wire[15:0] LR_AXI_WR_EFF_LEN_wire = LR_AXI_WR_EFF_LEN;

`DEBUG_DEF	reg [7:0]p_chk_data;
`DEBUG_DEF	reg [3:0]cs, ns, tx_cnt, tx_stop_bit_cnt;
`DEBUG_DEF	reg r1_tx_driv_flag, tx_driv_flag_sft, stop_bit_done;
`DEBUG_DEF	reg [1:0] para_cfg_req_post;
`DEBUG_DEF	reg [3:0]		tff_rd_strb_cnt;
`DEBUG_DEF	wire[3:0]		tff_rd_strb_right_part_zero_cnt [7:0];
`DEBUG_DEF	reg 			is_byte_zero;
`DEBUG_DEF  reg [15:0] axi_wr_cnt;
`DEBUG_DEF  wire [3:0] wstrb_cnt = wstrb[7 ] + wstrb[6 ] + wstrb[5 ] + wstrb[4 ] + wstrb[3 ] + wstrb[2 ] + wstrb[1 ] + wstrb[0 ];
`DEBUG_DEF  reg  [7:0] eff_wstrb;
`DEBUG_DEF  wire [63:0]eff_wdata;
`DEBUG_DEF	wire [3:0] wstrb_right_part_zero_cnt [7:0];

reg [3:0]		para_stop_bit;
reg [3:0]		para_parity_chk;
reg [3:0]		para_data_width;
reg [1:0]		para_tx_invl_mode;
reg [15:0]		para_tx_invl_0p5_baud;
reg [15:0]		para_tx_invl_clk_prd;

reg 			r1_w_hs;
wire	[4:0]	strb_cnt;
reg		[4:0]	strb_cnt_latch;
wire 	[63:0]	strb_fix_data;
reg 	[63:0]	strb_fix_data_latch;

`DEBUG_DEF	reg  [71 : 0]	tff_din       ;
`DEBUG_DEF	reg 			tff_wr_en     ;
`DEBUG_DEF	wire			tff_rd_en     ;
`DEBUG_DEF	reg 			tff_rd_en_pre ;
`DEBUG_DEF	wire [71 : 0]	tff_dout      ;
`DEBUG_DEF	reg  [71 : 0]	tff_dout_post ;
`DEBUG_DEF	wire			tff_full      ;
`DEBUG_DEF	wire			tff_empty     ;
`DEBUG_DEF	wire [10 : 0]	tff_data_count;
`DEBUG_DEF	reg  [3:0]		tff_rd_byte_num;

// _________________________________________________________________________ full write addr
wire [3 : 0] 		awid    = s_axi_awid   ;
`DEBUG_DEF	wire [63 : 0]		awaddr  = s_axi_awaddr ;
wire [7 : 0] 		awlen   = s_axi_awlen  ;
wire [2 : 0] 		awsize  = s_axi_awsize ;
wire [1 : 0] 		awburst = s_axi_awburst;
wire [2 : 0] 		awprot  = s_axi_awprot ;
`DEBUG_DEF	wire         		awvalid = s_axi_awvalid;
wire         		awlock  = s_axi_awlock ;
wire [3 : 0] 		awcache = s_axi_awcache;
`DEBUG_DEF	reg  				awready;
`DEBUG_DEF	wire 				aw_hs = awready & awvalid;

assign s_axi_awready = awready;

// _________________________________________________________________________ full write data
wire				fix_wlast = s_axi_wlast & s_axi_wvalid;

`DEBUG_DEF	wire [63 : 0]		wdata  = s_axi_wdata 	;
`DEBUG_DEF	wire [7 : 0] 		wstrb  = s_axi_wstrb 	;
`DEBUG_DEF	wire 				wlast  = fix_wlast 		; // fix smart connect IP's wlast
`DEBUG_DEF	wire 				wvalid = s_axi_wvalid	;
`DEBUG_DEF	reg  				wready					;
`DEBUG_DEF	wire 				w_hs   = wvalid & wready;
wire 				fix_w_hs = (wstrb == 8'hff) ? w_hs : (w_hs & (strb_cnt == 8));
reg  [63 : 0]		r1_wdata;

assign s_axi_wready = wready;
// _________________________________________________________________________ full write resp
reg  [3:0] 			bid   					;
reg  [1:0] 			bresp 					;
reg        			bvalid					;
wire       			bready = s_axi_bready	;
wire       			b_hs   = bvalid & bready;

assign s_axi_bid    = bid   ;
assign s_axi_bresp  = bresp ;
assign s_axi_bvalid = bvalid;

always@ (posedge clk, posedge rst) begin
	if(rst)
		bvalid <= 1'd0;
	else if(wlast & bready & w_hs)
		bvalid <= 1'd1;
	else
		bvalid <= 1'd0;
end

always@ (posedge clk, posedge rst) begin
	if(rst) begin
		bid   <= 'd0;
		bresp <= 'd0;
	end
	else begin
		bid   <= 'd0;
		bresp <= 'd0;
	end
end

// _________________________________________________________________________ full awready
always@(posedge clk, posedge rst) begin
	if(rst)
		awready <= 1'd1;
	else if (wlast)
		awready <= 1'd1;
	else if (aw_hs)
		awready <= 1'd0;
	else 
		awready <= awready;
end
// _________________________________________________________________________ full wready
always@(posedge clk, posedge rst) begin
	if(rst)
		wready <= 'd0;
	else if(aw_hs)
		wready <= 'd1;
	else if (wlast)
		wready <= 'd0;
	else 
		wready <= wready;
end

always@(posedge clk, posedge rst) begin
	if(rst) begin
		r1_w_hs  <= 'd0;
		r1_wdata <= 'd0;
		r1_tx_driv_flag <= 'd0;
	end
	else begin
		r1_w_hs  <= w_hs;//fix_w_hs ;
		r1_wdata <= wdata;//strb_fix_data;
		r1_tx_driv_flag <= tx_driv_flag;
	end
end

always@(posedge clk, posedge rst) begin
	if(rst)
		LR_TEST_FLAG <= 'd0;
	else case(1'b1)
	
		(LR_TEST_FLAG == 0) & aw_hs       : LR_TEST_FLAG <= 1;
		(LR_TEST_FLAG == 1) & wlast & w_hs: LR_TEST_FLAG <= 2;
		(LR_TEST_FLAG == 2) & b_hs        : LR_TEST_FLAG <= 3;
	
		default:LR_TEST_FLAG <= LR_TEST_FLAG;
	endcase
end
always@(posedge clk, posedge rst) begin
	if(rst)
		LR_TEST_ERR_INFO <= 'd0;
	else if(wlast & bready & (!w_hs))
		LR_TEST_ERR_INFO[0] <= 1'd1;
	else if(wlast & (!bready) & w_hs)
		LR_TEST_ERR_INFO[1] <= 1'd1;
	else
		LR_TEST_ERR_INFO <= LR_TEST_ERR_INFO;
end

// _________________________________________________________________________ uart_tx

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
	else if(cs == PARA_CFG) begin
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
		LR_CFG_DONE <= 'd0;
	else if(cs == PARA_CFG)
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
	else if((cs == PARA_CFG) & (para_cfg_req_post == 2'd2) & (chl_clr_req == 2'd2))
		chl_clr_done <= 1'd1;
	else
		chl_clr_done <= 1'd0;
end

`ifdef TEST
uart_ff_8k TFF_8K(
		.clock			(	clk					),
		.data 			(	tff_din       		),
		.rdreq			(	tff_rd_en     		),
		.wrreq			(	tff_wr_en     		),
		.empty			(	tff_empty      		),
		.full 			(	tff_full      		),
		.q    			(	tff_dout     		),
		.usedw			(	tff_data_count[9:0]	)
);
assign tff_data_count[10] = 1'd0;

`else 
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
`endif
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
		if(cs == IDLE)
			tff_rd_en_pre <= (!tff_empty) & (tff_rd_byte_num == 4'd0) & r1_tx_driv_flag & tx_driv_flag_sft;
		else if(cs == STOP_BIT)
			tff_rd_en_pre <= stop_bit_done & (!tff_empty) & (tff_rd_byte_num == `BYTE_CNT_THRD/*4'd7*/);
		else if(cs == PARA_CFG)
			tff_rd_en_pre <= `CFG_DONE_CDN & (!tff_empty) & (tff_rd_byte_num == `BYTE_CNT_THRD/*4'd7*/) & r1_tx_driv_flag & tx_driv_flag_sft;
	else
		tff_rd_en_pre <= (!tff_empty) & (cs == IDLE) & (tff_rd_byte_num == 4'd0) & r1_tx_driv_flag & tx_driv_flag_sft;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		cs <= IDLE;
	else 
		cs <= ns;
end

always@* begin
	case(cs)
		IDLE	:	//if((!tff_empty) & (tff_rd_byte_num == 4'd0) & r1_tx_driv_flag & tx_driv_flag_sft)
					if(tff_rd_en_pre)
						ns <= TX_DATA;
					else
						ns <= para_cfg_req_post ? PARA_CFG : IDLE;
		
		TX_DATA	:	if((tx_cnt == 8) & r1_tx_driv_flag & tx_driv_flag_sft)
						if(para_parity_chk == P_CHK_NONE)
							ns <= STOP_BIT;
						else
							ns <= PARITY_CHK;
					else
						ns <= TX_DATA;
		
		PARITY_CHK: if(r1_tx_driv_flag & tx_driv_flag_sft)
						ns <= STOP_BIT;
					else
						ns <= PARITY_CHK;
		
		STOP_BIT:	if(stop_bit_done)
						if(tff_rd_byte_num < `BYTE_CNT_THRD)
							ns <= para_cfg_req_post ? PARA_CFG : TX_DATA;
						else
							ns <= para_cfg_req_post ? PARA_CFG : (para_tx_invl_mode != 2'd0) ? IDLE : tff_rd_en_pre ? TX_DATA : IDLE;
					else
						ns <= STOP_BIT;

		PARA_CFG:	if(para_cfg_req_post == 2'd1)
						if(LR_CFG_DONE > 2'd1)
							if((tff_rd_byte_num > 4'd0) & r1_tx_driv_flag & tx_driv_flag_sft)
								ns <= TX_DATA;
							else
								ns <= (para_tx_invl_mode != 2'd0) ? IDLE : tff_rd_en_pre ? TX_DATA : IDLE;
						else
							ns <= PARA_CFG;
					else if(para_cfg_req_post == 2'd2)
						if(chl_clr_done)
							if((tff_rd_byte_num > 4'd0) & r1_tx_driv_flag & tx_driv_flag_sft)
								ns <= TX_DATA;
							else
								ns <= (para_tx_invl_mode != 2'd0) ? IDLE : tff_rd_en_pre ? TX_DATA : IDLE;
						else
							ns <= PARA_CFG;
					else 
						ns <= PARA_CFG;
						
		default: ns <= IDLE;
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
	else if(cs == STOP_BIT)
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
	else if((cs == STOP_BIT) & stop_bit_done)
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
	else if(cs == PARITY_CHK)
		r1_UART_TX <=   (para_parity_chk == P_CHK_ODD  ) ? (^p_chk_data)
					:(para_parity_chk == P_CHK_EVEN ) ? (~^p_chk_data)
					:(para_parity_chk == P_CHK_MARK ) ? 1'd1
					:(para_parity_chk == P_CHK_SPACE) ? 1'd0 : 1'd1;
	else if(cs == STOP_BIT)
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
/*
always@(posedge clk, posedge rst) begin
	if(rst)
		is_byte_zero <= 'd0;
	else if(tx_cnt == 9) & (tff_rd_byte_num == 0)
		is_byte_zero <= 1'd1;*/

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
		

		
		


endmodule
