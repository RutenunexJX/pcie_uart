`timescale 1ns / 1ps
`include "_svh.svh"
module TB_mux_buffer;
`define q @(posedge clk) #1ns

logic clk, rst;
initial clk = 0;
always #4 clk = ~clk;

logic rst_deassert;

initial begin
	rst_deassert = 'd0;

	#200ns;
	rst_deassert = 'd1;
end

initial begin
	rst = 'd1;

	wait(rst_deassert);
	`q
	rst = 'd0;
end

byte_stream_if  		s_byte_stream_if();
u64_stream_if   		m_u64_stream_if();
mux_buffer_debug_if		debug();

mux_buffer DUT (
    .clk              (clk),
    .rst              (rst),
    .s_byte_stream_if (s_byte_stream_if),
    .m_u64_stream_if  (m_u64_stream_if),
    .debug(debug)
);

initial m_u64_stream_if.ready = 1'b1;

u32_t tmp_cnt;
initial begin
	s_byte_stream_if.data	= 'd0;
	s_byte_stream_if.valid	= 'd0;
	s_byte_stream_if.last	= 'd0;
	tmp_cnt = 'd0;

	wait(rst_deassert);
	`q

	while(1) begin
		`q
		s_byte_stream_if.data	= s_byte_stream_if.data + 1'd1;
		s_byte_stream_if.valid	= 'd1;
		s_byte_stream_if.last	= tmp_cnt == u32_t'(255);

		if(tmp_cnt == u32_t'(255))
			break;
	end

	`q
	s_byte_stream_if.data	= 'd0;
	s_byte_stream_if.valid	= 'd0;
	s_byte_stream_if.last	= 'd0;
end

endmodule