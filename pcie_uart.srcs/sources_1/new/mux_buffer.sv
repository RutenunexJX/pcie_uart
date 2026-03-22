`timescale 1ns / 1ps
`include "_svh.svh"
`define DEBUG_mux_buffer

module mux_buffer(
	input	logic				clk					,
	input	logic				rst					,

	byte_stream_if.s			s_byte_stream_if	,
	u64_stream_if.m				m_u64_stream_if		,

	mux_buffer_debug_if.source	debug				  //
);

`define D `ifdef DEBUG_mux_buffer (*mark_debug = "true"*)(*keep = "true"*) `else `endif

// ================================================================================
//                               logic definition
// ================================================================================
logic	[2:0]	byte_cnt;
logic			byte_stream_last_asserting;
logic			byte_stream_last_asserted;
logic			byte_stream_hs;
logic			u64_pre_complete;
logic			u64_completed;
logic			ready_to_wr_fifo;
logic			u64_stream_hs;

// ================================================================================
//                               assignment
// ================================================================================

assign	s_byte_stream_if.ready		= ~fifo.full;
//
assign	byte_stream_hs				= s_byte_stream_if.valid & s_byte_stream_if.ready;
assign	byte_stream_last_asserting	= byte_stream_hs & s_byte_stream_if.last;
assign	u64_pre_complete			= byte_stream_hs & (byte_cnt == 3'd7);
assign	ready_to_wr_fifo			= u64_pre_complete | byte_stream_last_asserting;
//
assign	u64_stream_hs 				= m_u64_stream_if.valid & m_u64_stream_if.ready;

// ================================================================================
//                               struct & enum definition
// ================================================================================
typedef struct{
	logic	[64:0]	din;
	logic			wr_en;
	logic			rd_en;
	logic	[64:0]	dout;
	logic			full;
	logic			empty;
	logic	[10:0]	data_count;

}fifo_t;

fifo_t fifo;

// ================================================================================
//                               fifo
// ================================================================================

ff_65x1024 MUX_BUFFER_FIFO_65X1024_U(
	.clk		(	clk				),
	.din		(	fifo.din		),
	.wr_en		(	fifo.wr_en		),
	.rd_en		(	fifo.rd_en		),
	.dout		(	fifo.dout		),
	.full		(	fifo.full		),
	.empty		(	fifo.empty		),
	.data_count	(	fifo.data_count	)
);

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		byte_cnt <= 'd0;
	else if(byte_stream_hs) begin
		if(s_byte_stream_if.last)
			byte_cnt <= 'd0;
		else
			byte_cnt <= byte_cnt + 1'd1;
	end
	else
		byte_cnt <= byte_cnt;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		byte_stream_last_asserted <= 'd0;
	else
		byte_stream_last_asserted <= byte_stream_hs & s_byte_stream_if.last;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		u64_completed <= 'd0;
	else
		u64_completed <= byte_stream_hs & (byte_cnt == 3'd7);
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		fifo.din <= 'd0;
	else if(byte_stream_hs) begin
		fifo.din[64] <= s_byte_stream_if.last;

		if(u64_completed)
			fifo.din[63:0] <= (64'(s_byte_stream_if.data) << (byte_cnt * 8));
		else
			fifo.din[63:0] <= fifo.din[63:0] | (64'(s_byte_stream_if.data) << (byte_cnt * 8));
	end
	else if(u64_completed | byte_stream_last_asserted)
		fifo.din <= 'd0;
	else
		fifo.din <= fifo.din;
end

always_ff @(posedge clk, posedge rst) begin
	if(rst)
		fifo.wr_en <= 'd0;
	else if(ready_to_wr_fifo & (~fifo.full) & (~fifo.wr_en))
		fifo.wr_en <= 'd1;
	else if((~ready_to_wr_fifo) & fifo.wr_en)
		fifo.wr_en <= 'd0;
	else
		fifo.wr_en <= fifo.wr_en;
end

always_comb begin
	fifo.rd_en				= u64_stream_hs;
	m_u64_stream_if.last	= fifo.dout[64];
	m_u64_stream_if.data	= fifo.dout[63:0];
	m_u64_stream_if.valid	= (~fifo.empty);
end

// ================================================================================
//                               debug
// ================================================================================
assign debug.err_fifo_overflow		= ready_to_wr_fifo & fifo.full & (~fifo.wr_en);
assign debug.err_byte_stream_no_gap	= byte_stream_last_asserted & byte_stream_hs;

// ================================================================================
//                               undef
// ================================================================================


`ifdef D
`undef D
`endif

`ifdef DEBUG_mux_buffer
`undef DEBUG_mux_buffer
`endif

endmodule