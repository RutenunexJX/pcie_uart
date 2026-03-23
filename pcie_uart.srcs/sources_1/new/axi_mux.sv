`timescale 1ns / 1ps
`include "_svh.svh"
`define DEBUG_axi_mux
module axi_mux #(
	parameter	P_CHL_NUM = 12
)(
	input						clk				,
	input						rst				,

	axi_full_if.slave_read		sr_axi_full_if	,

//	input	axi_mux_ctrl_t		axi_mux_ctrl	,
//	output	axi_mux_status_t	axi_mux_status	,

	byte_stream_if.s 			s_byte_stream_if[P_CHL_NUM - 1:0]
);

u64_stream_if _u64_stream_if [P_CHL_NUM - 1:0]() ;

// ================================================================================
//                               axi logic
// ================================================================================
logic	[3:0]	rid		;
logic	[63:0]	rdata	;
logic	[1:0]	rresp	;
logic			rlast	;
logic			rvalid	;
logic			r_hs	;
logic			ready_to_read;

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
/*
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
	end
	else if (ready_to_read || `RLAST_CDN)begin
		rid			<= 'd0;
		rdata		<= rdata_window[63:0];
		rresp		<= 'd0;
	end
	else begin
		rid			<= 'd0;
		rdata		<= 'd0;
		rresp		<= 'd0;
	end
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		rlast <= 'd0;
	else if(ready_to_read || `RLAST_CDN) begin
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
	else if(ready_to_read || `RLAST_CDN) begin
		if((`RLAST_CDN & (rdata_window_remdr != 0)) || ((`RLAST_CDN == 1'd0) & (~((rdata_window_remdr == 0) & rlast_cdn & (r1_rdata_window_remdr != 0)))))
			rvalid <= ((r1_rdata_window_remdr + r1_rff_rd_strb_cnt) >= 8) & r1_rx_fifo_rd_en & (axi_rd_len > 8);
		else
			rvalid <= ((rdata_window_remdr == 0) & rlast_cdn & (r1_rdata_window_remdr != 0)) || (`RLAST_CDN & (rdata_window_remdr == 0));
	end
	else
		rvalid <= 'd0;
end
*/
always@(posedge clk, posedge rst) begin
	if(rst)
		ready_to_read <= 'd0;
	else if((~ready_to_read) & ar_hs)
		ready_to_read <= 'd1;
	else if(ready_to_read & rlast & r_hs)
		ready_to_read <= 'd0;
	else
		ready_to_read <= ready_to_read;
end

for(genvar i = 0; i < P_CHL_NUM; i = i + 1) begin: GF_CHL
	mux_buffer U_MUX_BUFFER(
		.clk				(	clk					),
		.rst				(	rst					),
		.s_byte_stream_if	(	s_byte_stream_if[i]	),
		.m_u64_stream_if	(	_u64_stream_if.s[i]	),
		.debug(debug)
	);
end: GF_CHL
endmodule