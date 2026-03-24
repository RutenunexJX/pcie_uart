`timescale 1ns / 1ps
`include "_svh.svh"
`define DEBUG_axi_mux
// Date                   Author    Version    Description
// 2026-03-24 17:54:08    xqj       1.0        Initial Creation
// 0x5a[header] 16b[total_payload_len] 8b[chl_num] 16b[payload len] ?Byte[payload] 0xbc
module axi_mux #(
	parameter	P_CHL_NUM = 12
)(
	input						clk				,
	input						rst				,

	input	axi_mux_para_t		para			,
//	input	axi_mux_ctrl_t		ctrl			,
	output	axi_mux_status_t	status			,

	axi_full_if.slave_read		sr_axi_full_if	,
	u64_stream_if.s				s_u64_stream_if[P_CHL_NUM - 1:0] //

	// debug
	,axi_mux_debug_if.source	s_axi_mux_debug_if
);
`define D `ifdef DEBUG_axi_mux (*mark_debug = "true"*)(*keep = "true"*)`else `endif

localparam P_CHL_NUM_CLOG2 = $clog2(P_CHL_NUM);

// ================================================================================
//                               logic assignment
// ================================================================================
logic	[3:0]				rid				;
logic	[63:0]				rdata			;
logic	[1:0]				rresp			;
logic						rlast			;
logic						rvalid			;
logic						r_hs			;

logic						arready			;
logic						ar_hs			;
logic						r1_ar_hs		;
logic	[15:0]				ar_burst_len	;

logic	[15:0]				cur_axi_rd_len	;
logic	[P_CHL_NUM_CLOG2:0]	cur_chl			;

logic						axi_rd_trans_not_done	;
logic						ready_to_read			;
// ================================================================================
//                               struct and enum definition
// ================================================================================
typedef enum logic[3:0]{
	IDLE,
	PKT_HDR,
	PKT_PAYLOAD_LEN,
	CHL_NUM,
	CHL_PAYLOAD_LEN,
	CHL_PAYLOAD,
	WAIT_NXT_CHL,
	CHL_END,
	PKT_TAIL
}st_e;

st_e cs;
st_e ns;

axi_mux_para_t new_para;
axi_mux_para_t cur_para;
// ================================================================================
//                               comb logic assignment
// ================================================================================
assign ar_hs					= sr_axi_full_if.arvalid & sr_axi_full_if.arready;
assign r_hs						= sr_axi_full_if.rvalid & sr_axi_full_if.rready;

assign sr_axi_full_if.rid		= rid;
assign sr_axi_full_if.rdata		= rdata;
assign sr_axi_full_if.rresp		= rresp;
assign sr_axi_full_if.rlast		= rlast;
assign sr_axi_full_if.rvalid	= rvalid;

assign sr_axi_full_if.arready	= arready;

// ================================================================================
//                               delay
// ================================================================================
always_ff @(posedge clk, posedge rst) begin
	if(rst)
		r1_ar_hs <= 'd0;
	else
		r1_ar_hs <= ar_hs;
end
// ================================================================================
//                               axi logic
// ================================================================================
always_ff @(posedge clk, posedge rst) begin
	if(rst)
		arready <= 1'd0;
	else if (r_hs)
		arready <= 1'd0;
	else
		arready <= 1'd1;
end

always_ff @(posedge clk) begin
	rid		<= 'd0;
	rresp	<= 'd0;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		ar_burst_len <= 'd0;
	else if(ar_hs)
		ar_burst_len <= (1 << sr_axi_full_if.arsize) * (sr_axi_full_if.arlen + 1);
	else
		ar_burst_len <= ar_burst_len;
end

// ================================================================================
//                               flags
// ================================================================================
// Sets ready_to_read on AR handshake, clears it on the last R handshake.
always_ff @(posedge clk, posedge rst) begin
	if(rst)
		ready_to_read <= 'd0;
	else if((~ready_to_read) & ar_hs)
		ready_to_read <= 'd1;
	else if(ready_to_read & rlast & r_hs)
		ready_to_read <= 'd0;
	else
		ready_to_read <= ready_to_read;
end

// Tracks whether an AXI read transaction is in progress: set on single-beat AR handshake, cleared when burst length is reached.
always_ff @(posedge clk, posedge rst) begin
	if(rst)
		axi_rd_trans_not_done <= 'd0;
	else if((~axi_rd_trans_not_done) & ar_hs & (cur_axi_rd_len == '0))
		axi_rd_trans_not_done <= 'd1;
	else if((~axi_rd_trans_not_done) & (cur_axi_rd_len == cur_para.axi_rd_burst_len))
		axi_rd_trans_not_done <= 'd0;
	else
		axi_rd_trans_not_done <= axi_rd_trans_not_done;
end

always_comb begin
	status.ready_to_load = axi_rd_trans_not_done;
end

// ================================================================================
//                               para logic
// ================================================================================
always_ff @(posedge clk, posedge rst) begin
	if(rst)
		new_para <= '{default:'0};
	else
		new_para <= para;
end

// Latches new_para into cur_para, holding each bitmask field until its AXI transaction completes.
always_ff @(posedge clk, posedge rst) begin
	if(rst)
		cur_para <= '{default:'0};
	else begin
		cur_para <= '{
			rd_chl_ena_bitmask	: axi_rd_trans_not_done ? cur_para.rd_chl_ena_bitmask	: new_para.rd_chl_ena_bitmask,
			axi_rd_burst_len	: axi_rd_trans_not_done ? cur_para.axi_rd_burst_len		: new_para.axi_rd_burst_len,
			default				: '0
		};
	end
end

// ================================================================================
//                               cnt logics
// ================================================================================
always_ff @(posedge clk, posedge rst) begin
	if(rst)
		cur_axi_rd_len <= 'd0;
	else if(r1_ar_hs & axi_rd_trans_not_done)
		cur_axi_rd_len <= (cur_axi_rd_len + ar_burst_len);
	else
		cur_axi_rd_len <= cur_axi_rd_len;
end

// ================================================================================
//                               FSM
// ================================================================================
always_ff @(posedge clk, posedge rst) begin
	if(rst)
		cs <= IDLE;
	else
		cs <= ns;
end

always_comb begin
	case(cs)
		IDLE:
			if(ready_to_read)
				ns = PKT_HDR;
			else
				ns = IDLE;




		default:
			ns = IDLE;
	endcase
end

// ================================================================================
//                               GF_1
// ================================================================================
for(genvar i = 0; i < P_CHL_NUM; i = i + 1) begin: GF_1

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		s_u64_stream_if[i].ready <= 'd0;
	else
		s_u64_stream_if[i].ready <= cur_para.rd_chl_ena_bitmask[i];
end

end: GF_1
// ================================================================================
//                               debug
// ================================================================================
assign s_axi_mux_debug_if.erro_ = 'd0;

// ================================================================================
//                               undef
// ================================================================================
`ifdef D
`undef D
`endif

`ifdef DEBUG_axi_mux
`undef DEBUG_axi_mux
`endif
endmodule