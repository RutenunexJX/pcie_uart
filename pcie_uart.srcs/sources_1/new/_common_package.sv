package common_package;

typedef	logic	[7:0]	u8_t	;
typedef	logic	[15:0]	u16_t	;
typedef	logic	[31:0]	u32_t	;
typedef	logic	[63:0]	u64_t	;
typedef	logic	[127:0]	u128_t	;
typedef	logic	[255:0]	u256_t	;
typedef	logic	[511:0]	u512_t	;

typedef	logic	signed	[7:0]	s8_t	;
typedef	logic	signed	[15:0]	s16_t	;
typedef	logic	signed	[31:0]	s32_t	;
typedef	logic	signed	[63:0]	s64_t	;

typedef	logic	[7:0]	byte_t	;
typedef	logic	[31:0]	word_t	;
typedef	logic	[63:0]	dword_t	;

typedef enum logic [1:0] {
	E_RESP_OKAY		= 2'b00,
	E_RESP_EXOKAY	= 2'b01,
	E_RESP_SLVERR	= 2'b10,
	E_RESP_DECERR	= 2'b11
}rresp_e;

typedef enum logic [1:0] {
	E_BURST_FIXED = 2'b00,
	E_BURST_INCR  = 2'b01,
	E_BURST_WRAP  = 2'b10
}burst_e;

parameter	bit	P_ENABLE	= 1'd1;
parameter	bit	P_DISABLE	= 1'd0;

parameter	bit	P_YES		= 1'd1;
parameter	bit	P_NO		= 1'd0;

parameter	bit	P_TRUE		= 1'd1;
parameter	bit	P_FALSE		= 1'd0;

parameter	bit	P_ON		= 1'd1;
parameter	bit	P_OFF		= 1'd0;

function automatic int max(input int a, input int b);
	return (a > b) ? a : b;
endfunction

function automatic int min(input int a, input int b);
	return (a < b) ? a : b;
endfunction

function automatic logic is_power_of_2(input int unsigned value);
	return (value != 0) && ((value & (value - 1)) == 0);
endfunction

function automatic int unsigned onehot_to_idx(input logic [31:0] onehot);
	for (int i = 0; i < 32; i++) begin
	  if (onehot[i]) return i;
	end

	return 0;
endfunction

function automatic logic [7:0] get_trailing_zeros(
	input logic	[127:0]	val			,
	input int			actual_width  //
);
	if(val == '0)
		return 8'(actual_width);
	else
		return 8'($clog2(val & (-val)));
endfunction

function automatic logic [31:0] sat_dec(input logic [31:0] val);
	return (val > 0) ? (val - 1) : '0;
endfunction

endpackage