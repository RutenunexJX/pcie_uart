`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/19 19:44:55
// Design Name: 
// Module Name: uart_driv_flag_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//rx 0-11, tx 12-23
//`define DEBUG
module uart_driv_flag_gen (
    input               	clk                 	,
    input               	rst                 	,
	//
	input 	[31:0]			LR_BAUD0			    ,
	input 	[31:0]			LR_BAUD1			    ,
	input 	[31:0]			LR_BAUD2			    ,
	input 	[31:0]			LR_BAUD3			    ,
	input 	[31:0]			LR_BAUD4			    ,
	input 	[31:0]			LR_BAUD5			    ,
	input 	[31:0]			LR_BAUD6			    ,
	input 	[31:0]			LR_BAUD7			    ,
	input 	[31:0]			LR_BAUD8			    ,
	input 	[31:0]			LR_BAUD9			    ,
	input 	[31:0]			LR_BAUD10			    ,
	input 	[31:0]			LR_BAUD11			    ,
	input 	[31:0]			LR_BAUD12			    ,
	input 	[31:0]			LR_BAUD13			    ,
	input 	[31:0]			LR_BAUD14			    ,
	input 	[31:0]			LR_BAUD15			    ,
	input 	[31:0]			LR_BAUD16			    ,
	input 	[31:0]			LR_BAUD17			    ,
	input 	[31:0]			LR_BAUD18			    ,
	input 	[31:0]			LR_BAUD19			    ,
	input 	[31:0]			LR_BAUD20			    ,
	input 	[31:0]			LR_BAUD21			    ,
	input 	[31:0]			LR_BAUD22			    ,
	input 	[31:0]			LR_BAUD23			    ,
	input   [23:0]          LR_BAUD_VLD             ,
	input 	[1:0]			is_baud_sync			,
	//
	input 		[23:0]		is_start_bit			,
    output  reg	[47:0]		chl_clr_req             ,
    input       [23:0]      chl_clr_done            ,
    output  reg [23:0]		uart_driv_flag          //
);
`define DEBUG_DEF `ifdef DEBUG (*mark_debug = "true"*)(*keep = "true"*)`else `endif 

genvar i;

localparam _62p5M_FLOAT = 64'h418D_CD65_0000_0000;// double, phase sum's step len = (baud_rate * 2^32) / (125_000_000 / 2), generate the flag that its period = 0.5*baud_rate
localparam _125M_FLOAT = 64'h419D_CD65_0000_0000;// double 
localparam _250M_FLOAT = 64'h41AD_CD65_0000_0000;// double 
localparam FRAC_THRESHOLD = 24'd10_000_000;
localparam [119:0] INDEX = {5'd23, 5'd22, 5'd21, 5'd20, 5'd19, 5'd18, 5'd17, 5'd16, 5'd15, 5'd14, 5'd13, 5'd12, 5'd11, 5'd10, 5'd9, 5'd8, 5'd7, 5'd6, 5'd5, 5'd4, 5'd3, 5'd2, 5'd1, 5'd0};

//fsm
localparam IDLE               = 4'd0;
localparam FIX2FLOAT          = 4'd1;
localparam DIV                = 4'd2;
localparam FINAL_CAL          = 4'd3;
localparam FINAL_CAL_DONE     = 4'd4;
localparam CHL_RST            = 4'd5;
localparam LOAD_NEW_STEP_LEN  = 4'd6;
//
localparam BAUD_LOAD          = 4'd8;

`DEBUG_DEF	wire [1:0] 	is_baud_sync_wire = is_baud_sync;
`DEBUG_DEF	wire [31:0]	baud0_wire = LR_BAUD0;
`DEBUG_DEF	wire [31:0]	baud12_wire = LR_BAUD12;

`DEBUG_DEF	reg [3:0]  	cs[23:0];
`DEBUG_DEF	reg [3:0]  	ns[23:0];
`DEBUG_DEF	reg [3:0]  	mcs, mns;
reg [31:0]  crt_baud [23:0];
reg [31:0]  crt_rx_sync_baud;
reg [31:0]  crt_tx_sync_baud;
wire[31:0]  LR_BAUD      [23:0];
reg [31:0]  LR_BAUD_post [23:0];
reg [23:0]	LR_BAUD_VLD_post;
reg			direc;
reg [4:0]	chl_cnt, r1_chl_cnt;
reg 		chl_cnt_sft;

assign LR_BAUD[0]  = LR_BAUD0 ;
assign LR_BAUD[1]  = LR_BAUD1 ;
assign LR_BAUD[2]  = LR_BAUD2 ;
assign LR_BAUD[3]  = LR_BAUD3 ;
assign LR_BAUD[4]  = LR_BAUD4 ;
assign LR_BAUD[5]  = LR_BAUD5 ;
assign LR_BAUD[6]  = LR_BAUD6 ;
assign LR_BAUD[7]  = LR_BAUD7 ;
assign LR_BAUD[8]  = LR_BAUD8 ;
assign LR_BAUD[9]  = LR_BAUD9 ;
assign LR_BAUD[10] = LR_BAUD10;
assign LR_BAUD[11] = LR_BAUD11;
assign LR_BAUD[12] = LR_BAUD12;
assign LR_BAUD[13] = LR_BAUD13;
assign LR_BAUD[14] = LR_BAUD14;
assign LR_BAUD[15] = LR_BAUD15;
assign LR_BAUD[16] = LR_BAUD16;
assign LR_BAUD[17] = LR_BAUD17;
assign LR_BAUD[18] = LR_BAUD18;
assign LR_BAUD[19] = LR_BAUD19;
assign LR_BAUD[20] = LR_BAUD20;
assign LR_BAUD[21] = LR_BAUD21;
assign LR_BAUD[22] = LR_BAUD22;
assign LR_BAUD[23] = LR_BAUD23;
//
`DEBUG_DEF	reg				fix2flt_i_tvalid, div_i_tvalid, final_i_tvalid;
`DEBUG_DEF	wire			fix2flt_i_tready, div_i_tready, final_i_tready;
`DEBUG_DEF	reg		[63:0]	fix2flt_i_tdata;
`DEBUG_DEF	reg		[63:0]	div_i_tdata;
`DEBUG_DEF	reg 	[63:0]	final_i_tdata ;
`DEBUG_DEF	reg 	[4:0]	fix2flt_i_tuser, div_i_tuser, final_i_tuser;

`DEBUG_DEF	wire			fix2flt_o_tvalid, div_o_tvalid, final_o_tvalid;
`DEBUG_DEF	wire			fix2flt_o_tready, div_o_tready, final_o_tready;
`DEBUG_DEF	wire	[63:0]	fix2flt_o_tdata	, div_o_tdata;
`DEBUG_DEF	wire 	[55:0]	final_o_tdata;
`DEBUG_DEF	wire 	[4:0]	fix2flt_o_tuser, div_o_tuser, final_o_tuser;

reg 			fix2flt_o_tvalid_post, div_o_tvalid_post;

reg 	[31:0]	phase_sum			[23:0];
reg  	[31:0]	r1_phase_sum		[23:0];
reg  	[31:0] 	pre_step_len		[23:0];
reg 	[31:0]	step_len			[23:0];
reg  	[23:0] 	pre_frac_step_len	[23:0];
reg 	[23:0]	frac_step_len		[23:0];
reg    	[23:0] 	frac_part			[23:0];
wire           	frac_carry_bit		[23:0];

always @(posedge clk, posedge rst) begin
	if(rst)
		chl_cnt_sft <= 'd0;
	else 
		chl_cnt_sft <= ~chl_cnt_sft;
end

always @(posedge clk, posedge rst) begin
	if(rst)
		chl_cnt <= 'd0;
	//else if((cs[chl_cnt] == IDLE) & (ns[chl_cnt] == FIX2FLOAT))
	//	chl_cnt <= chl_cnt;
	else 
		chl_cnt <= (chl_cnt >= 23) ? 5'd0 : (chl_cnt + 1'd1);
end

always @(posedge clk, posedge rst) begin
	if(rst)
		r1_chl_cnt <= 'd0;
	else
		r1_chl_cnt <= chl_cnt;
end

always @(posedge clk, posedge rst) begin
	if(rst)
		direc <= 1'd0;
	else if((mcs == IDLE) & (mns == FIX2FLOAT))
		direc <= (is_baud_sync == 2'd2);
	else
		direc <= direc;
end

always @(posedge clk, posedge rst) begin
	if(rst)
		mcs <= IDLE;
	else
		mcs <= mns;
end

always@* begin
	case(mcs)
		IDLE: if(((is_baud_sync == 2'd1) & (crt_rx_sync_baud != LR_BAUD[0]))
		      || ((is_baud_sync == 2'd2) & (crt_tx_sync_baud != LR_BAUD[12])))
				mns <= FIX2FLOAT;
			else if(LR_BAUD_VLD != 0)
				mns <= BAUD_LOAD;
			else
				mns <= IDLE;
		
		FIX2FLOAT : if(fix2flt_i_tvalid & fix2flt_i_tready)
				mns <= DIV;
			else
				mns <= FIX2FLOAT;
		
		DIV : if(div_i_tvalid & div_i_tready)
				mns <= FINAL_CAL;
			else
				mns <= DIV;
		
		FINAL_CAL : if(final_i_tvalid & final_i_tready)
				mns <= FINAL_CAL_DONE;
			else
				mns <= FINAL_CAL;
		
		FINAL_CAL_DONE : if(final_o_tvalid & final_o_tready)
				mns <= CHL_RST;
			else
				mns <= FINAL_CAL_DONE;
				
		CHL_RST : if((direc & (chl_clr_done[23:12] == {12{1'd1}})) || ((!direc) & (chl_clr_done[11:0] == {12{1'd1}})))
				mns <= LOAD_NEW_STEP_LEN;
			else
				mns <= CHL_RST;
		
		LOAD_NEW_STEP_LEN:
				mns <= IDLE;
		
		//
		BAUD_LOAD: if(((is_baud_sync == 2'd1) & (crt_rx_sync_baud != LR_BAUD[0]))
		      || ((is_baud_sync == 2'd2) & (crt_tx_sync_baud != LR_BAUD[12])))
				mns <= FIX2FLOAT;
			else
				mns <= BAUD_LOAD;
		default:;
	endcase
end

always @(posedge clk, posedge rst) begin
	if(rst)
		crt_rx_sync_baud <= 'd0;
	else if(((mcs == IDLE) || (mcs == BAUD_LOAD)) & (crt_rx_sync_baud != LR_BAUD[0]) & (is_baud_sync == 2'd1))
		crt_rx_sync_baud <= LR_BAUD[0];
	else
		crt_rx_sync_baud <= crt_rx_sync_baud;
end

always @(posedge clk, posedge rst) begin
	if(rst)
		crt_tx_sync_baud <= 'd0;
	else if(((mcs == IDLE) || (mcs == BAUD_LOAD)) & (crt_tx_sync_baud != LR_BAUD[12]) & (is_baud_sync == 2'd2))
		crt_tx_sync_baud <= LR_BAUD[12];
	else
		crt_tx_sync_baud <= crt_tx_sync_baud;
end

fix2sgl_float BAUD_FIX2FLOAT (
    .aclk                 ( clk                 ),
	.aresetn			  (	~rst				),
    .s_axis_a_tvalid      ( fix2flt_i_tvalid	),
    .s_axis_a_tready      ( fix2flt_i_tready	),
    .s_axis_a_tdata       ( fix2flt_i_tdata		),
    .s_axis_a_tuser       ( fix2flt_i_tuser		),

    .m_axis_result_tvalid ( fix2flt_o_tvalid	),
    .m_axis_result_tready ( fix2flt_o_tready	),
    .m_axis_result_tdata  ( fix2flt_o_tdata		),
    .m_axis_result_tuser  ( fix2flt_o_tuser		) 
);
assign fix2flt_o_tready = 1'd1;

float_div BAUD_FLOAT_DIV(
    .aclk                 ( clk                 ), 
	.aresetn			  (	~rst				),

    .s_axis_a_tvalid      ( div_i_tvalid		), 
    .s_axis_a_tready      ( div_i_tready		), 
    .s_axis_a_tdata       ( div_i_tdata			), 
    .s_axis_a_tuser       ( div_i_tuser			), 

    .s_axis_b_tvalid      ( 1'd1                ), 
    .s_axis_b_tready      (                     ), 
    .s_axis_b_tdata       ( _62p5M_FLOAT		), 

    .m_axis_result_tvalid ( div_o_tvalid		), 
    .m_axis_result_tready ( div_o_tready		), 
    .m_axis_result_tdata  ( div_o_tdata			),
    .m_axis_result_tuser  ( div_o_tuser			)  
);
assign div_o_tready = 1'd1;

sgl_float2fix BAUD_FLOAT2FIX (
    .aclk                 ( clk					), 
	.aresetn			  (	~rst				),
	
    .s_axis_a_tvalid      ( final_i_tvalid    	), 
    .s_axis_a_tready      ( final_i_tready    	), 
    .s_axis_a_tdata       ( final_i_tdata     	),
    .s_axis_a_tuser       ( final_i_tuser     	),

    .m_axis_result_tvalid ( final_o_tvalid    	), 
    .m_axis_result_tready ( final_o_tready    	), 
    .m_axis_result_tdata  ( final_o_tdata     	),
    .m_axis_result_tuser  ( final_o_tuser     	)  
);

assign final_o_tready = 1'd1;

always @(posedge clk, posedge rst) begin
	if(rst) begin
		fix2flt_i_tvalid <= 'd0;
		fix2flt_i_tdata  <= 'd0;
		fix2flt_i_tuser  <= 'd0;
	end
	else if(mcs == FIX2FLOAT)
		if(fix2flt_i_tready) begin
			fix2flt_i_tvalid <= 1'd1;
			fix2flt_i_tdata  <= direc ? (crt_tx_sync_baud << 32) : (crt_rx_sync_baud << 32); 
			fix2flt_i_tuser  <= direc ? 5'h1f : 5'h1e;//rx_sync:0x1e, tx_sync: 0x1f
		end
		else begin
			fix2flt_i_tvalid <= fix2flt_i_tvalid;
			fix2flt_i_tdata  <= fix2flt_i_tdata;
			fix2flt_i_tuser  <= fix2flt_i_tuser;
		end
	else if(cs[r1_chl_cnt] == FIX2FLOAT) begin
		if(fix2flt_i_tready) begin
			fix2flt_i_tvalid <= 1'd1;
			fix2flt_i_tdata  <= crt_baud[r1_chl_cnt] << 32; 
			fix2flt_i_tuser  <= r1_chl_cnt;
		end
		else begin
			fix2flt_i_tvalid <= fix2flt_i_tvalid;
			fix2flt_i_tdata  <= fix2flt_i_tdata;
			fix2flt_i_tuser  <= fix2flt_i_tuser;
		end
	end
	else begin
		fix2flt_i_tvalid <= 'd0;
		fix2flt_i_tdata  <= 'd0;
		fix2flt_i_tuser  <= 'd0;
	end
end

always @(posedge clk, posedge rst) begin
	if(rst) begin
		div_i_tvalid <= 'd0;
		div_i_tdata  <= 'd0;
		div_i_tuser  <= 'd0;
	end
	else if(!fix2flt_o_tvalid) begin
		div_i_tvalid <= 1'd0;
		div_i_tdata  <= div_i_tdata;
		div_i_tuser  <= div_i_tuser;
	end
	else if((cs[fix2flt_o_tuser] == DIV) || (mcs == DIV))begin
		if(div_i_tready) begin
			div_i_tvalid <= 1'd1;
			div_i_tdata  <= fix2flt_o_tdata;
			div_i_tuser  <= fix2flt_o_tuser;
		end
		else begin
			div_i_tvalid <= div_i_tvalid;
			div_i_tdata  <= fix2flt_o_tdata;
			div_i_tuser  <= fix2flt_o_tuser;
		end
	end
	else begin
		div_i_tvalid <= 'd0;
		div_i_tdata  <= 'd0;
		div_i_tuser  <= 'd0;
	end
end


always @(posedge clk, posedge rst) begin
	if(rst) begin
		final_i_tvalid <= 'd0;
		final_i_tdata  <= 'd0;
		final_i_tuser  <= 'd0;
	end
	else if(!div_o_tvalid) begin
		final_i_tvalid <= 1'd0;
		final_i_tdata  <= div_i_tdata;
		final_i_tuser  <= div_i_tuser;
	end
	else if((cs[div_o_tuser] == FINAL_CAL) || (mcs == FINAL_CAL)) begin
		if(div_i_tready) begin
			final_i_tvalid <= 1'd1;
			final_i_tdata  <= div_o_tdata;
			final_i_tuser  <= div_o_tuser;
		end
		else begin
			final_i_tvalid <= final_i_tvalid;
			final_i_tdata  <= div_o_tdata;
			final_i_tuser  <= div_o_tuser;
		end
	end

	else begin
		final_i_tvalid <= 'd0;
		final_i_tdata  <= 'd0;
		final_i_tuser  <= 'd0;
	end
end

generate for(i = 0; i < 24; i = i + 1) begin : GF_FLAG

always @(posedge clk, posedge rst) begin
	if(rst)
		LR_BAUD_post[i] <= 'd0;
	else if(LR_BAUD_VLD[i])
		LR_BAUD_post[i] <=  LR_BAUD[i];
	else
		LR_BAUD_post[i] <= LR_BAUD_post[i];
end

always @(posedge clk, posedge rst) begin
	if(rst)
		LR_BAUD_VLD_post[i] <= 'd0;
	else if(cs[i] == FIX2FLOAT)
		LR_BAUD_VLD_post[i] <= 'd0;
	else if(LR_BAUD_VLD[i])
		LR_BAUD_VLD_post[i] <=  1'd1;
	else
		LR_BAUD_VLD_post[i] <= LR_BAUD_VLD_post[i];
end
		
always @(posedge clk, posedge rst) begin
	if(rst)
		cs[i] <= IDLE;
	else if(mcs == FIX2FLOAT)
		cs[i] <= IDLE;
	else
		cs[i] <= ns[i];
end

always@* begin
	case(cs[i])
		IDLE: if((mcs == BAUD_LOAD) & LR_BAUD_VLD_post[i] & (LR_BAUD_post[i] != crt_baud[i]) & (chl_cnt == i))
				ns[i] <= FIX2FLOAT;
			else
				ns[i] <= IDLE;
		
		FIX2FLOAT : if((fix2flt_i_tvalid & fix2flt_i_tready) & (fix2flt_i_tuser == i))
				ns[i] <= DIV;
			else
				ns[i] <= FIX2FLOAT;
		
		DIV : if((div_i_tvalid & div_i_tready) & (div_i_tuser == i))
				ns[i] <= FINAL_CAL;
			else
				ns[i] <= DIV;
		
		FINAL_CAL : if((final_i_tvalid & final_i_tready) & (final_i_tuser == i))
				ns[i] <= FINAL_CAL_DONE;
			else
				ns[i] <= FINAL_CAL;
		
		FINAL_CAL_DONE : if((final_o_tvalid & final_o_tready) & (final_o_tuser == i))
				ns[i] <= CHL_RST;
			else
				ns[i] <= FINAL_CAL_DONE;
				
		CHL_RST : if(chl_clr_done)
				ns[i] <= LOAD_NEW_STEP_LEN;
			else
				ns[i] <= CHL_RST;
		
		LOAD_NEW_STEP_LEN:
				ns[i] <= IDLE;
		
		default:ns[i] <= IDLE;
	endcase
end

always @(posedge clk, posedge rst) begin
	if(rst)
		crt_baud[i] <= 'd0;
	else if((cs[i] == IDLE) & (ns[i] == FIX2FLOAT))
		crt_baud[i] <= LR_BAUD_post[i];
	else
		crt_baud[i] <= crt_baud[i];
end

always @(posedge clk, posedge rst) begin
	if(rst) begin
		pre_step_len[i]      <= 'd0;
	    pre_frac_step_len[i] <= 'd0;
	end
	else if ((mcs == FINAL_CAL_DONE) & (mns == CHL_RST))begin
		if(i < 12) begin
			pre_step_len[i]      <= (!direc) ? final_o_tdata[55:24] : pre_step_len[i]      ;
			pre_frac_step_len[i] <= (!direc) ? final_o_tdata[23:0]  : pre_frac_step_len[i] ;
		end
		else begin
			pre_step_len[i]      <= direc ? final_o_tdata[55:24] : pre_step_len[i]      ;
			pre_frac_step_len[i] <= direc ? final_o_tdata[23:0]  : pre_frac_step_len[i] ;
		end
	end
	else if((cs[i] == FINAL_CAL_DONE) & (ns[i] == CHL_RST))begin
		pre_step_len[i]      <= final_o_tdata[55:24];
		pre_frac_step_len[i] <= final_o_tdata[23:0] ;
	end
	else begin
		pre_step_len[i]      <= pre_step_len[i] ;
		pre_frac_step_len[i] <= pre_frac_step_len[i];
	end
end

always @(posedge clk, posedge rst) begin
	if(rst) begin
		step_len[i]      <= 'd0;
	    frac_step_len[i] <= 'd0;
	end
	else if(mcs == LOAD_NEW_STEP_LEN)begin
		if(i < 12) begin
			step_len [i]     <= (!direc) ? pre_step_len[i]      : step_len [i]     ;
			frac_step_len[i] <= (!direc) ? pre_frac_step_len[i] : frac_step_len[i] ;
		end
		else begin
			step_len [i]     <= direc ? pre_step_len[i]      : step_len [i]     ;
			frac_step_len[i] <= direc ? pre_frac_step_len[i] : frac_step_len[i] ;
		end
	end
	else if(cs[i] == LOAD_NEW_STEP_LEN) begin
		step_len [i]     <= pre_step_len[i]     ;
		frac_step_len[i] <= pre_frac_step_len[i];
	end
	else begin
		step_len[i]      <= step_len[i]      ;
		frac_step_len[i] <= frac_step_len[i] ;
	end
end

always @(posedge clk, posedge rst) begin
	if(rst)
		chl_clr_req[i*2+:2] <= 'd0;
	else case(chl_clr_req[i*2+:2])
		0:if(mcs == FIX2FLOAT)
			if(i <= 11)	
				chl_clr_req[i*2+:2] <= direc ? 2'd0 : 2'd1;
			else
				chl_clr_req[i*2+:2] <= direc ? 2'd1 : 2'd0;
		else
			chl_clr_req[i*2+:2] <= ((cs[i] == IDLE) & (ns[i] == FIX2FLOAT)) ? 2'd1 : 2'd0;

		1:		chl_clr_req[i*2+:2] <= (((mcs == FINAL_CAL_DONE) & (mns == CHL_RST)) || ((cs[i] == FINAL_CAL_DONE) & (ns[i] == CHL_RST))) ? 2'd2 : 2'd1;
		2:		chl_clr_req[i*2+:2] <= 'd0;
		default:chl_clr_req[i*2+:2] <= 'd0;
	endcase
end

always @(posedge clk, posedge rst) begin
	if(rst)
		phase_sum[i] <= 32'd0;
	else if(is_start_bit[i])
		phase_sum[i] <= 'd0;
	/*else if(phase_sum[31:24] >= 8'd128)
		phase_sum <= phase_sum + step_len + frac_carry_bit - (128<<24);*/
	else
		phase_sum[i] <= phase_sum[i] + step_len[i] + frac_carry_bit[i];
end

always @(posedge clk, posedge rst) begin
	if(rst)
		r1_phase_sum[i] <= 'd0;
	else if(is_start_bit[i])
		r1_phase_sum[i] <= 'd0;
	else
		r1_phase_sum[i] <= phase_sum[i];
end

always @(posedge clk, posedge rst) begin
	if(rst)
		frac_part[i] <= 24'd0;
	else if(is_start_bit[i])
		frac_part[i] <= 'd0;
	else if (frac_part[i] >= FRAC_THRESHOLD)
		frac_part[i] <= frac_part[i] - FRAC_THRESHOLD + frac_step_len[i];
	else
		frac_part[i] <= frac_part[i] + frac_step_len[i] ;
end

assign frac_carry_bit[i] = ( frac_part[i] >= FRAC_THRESHOLD );

always @(posedge clk, posedge rst) begin
	if(rst)
		uart_driv_flag[i] <= 'd0;
	else if(r1_phase_sum[i][31:24] > phase_sum[i][31:24])
		uart_driv_flag[i] <= 1'd1;
	else
		uart_driv_flag[i] <= 'd0;
end
end endgenerate 

endmodule