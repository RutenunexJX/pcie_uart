//rx 0-11, tx 12-23
module uart_driv_flag_gen (
    input           clk                 	,
    input           rst                 	,
	//
	input 			is_start_bit			,
    output  reg 	uart_driv_flag          //
);


reg 	[31:0]	phase_sum		;
reg  	[31:0]	r1_phase_sum	;
reg    	[23:0] 	frac_part		;
wire           	frac_carry_bit	;

localparam FRAC_THRESHOLD = 24'd10_000_000;


always @(posedge clk, posedge rst) begin
	if(rst)
		phase_sum <= 32'd0;
	else if(is_start_bit)
		phase_sum <= 'd0;
	else
		phase_sum <= phase_sum + step_len + frac_carry_bit;
end

always @(posedge clk, posedge rst) begin
	if(rst)
		r1_phase_sum <= 'd0;
	else if(is_start_bit)
		r1_phase_sum <= 'd0;
	else
		r1_phase_sum <= phase_sum;
end

always @(posedge clk, posedge rst) begin
	if(rst)
		frac_part <= 24'd0;
	else if(is_start_bit)
		frac_part <= 'd0;
	else if (frac_part[i] >= FRAC_THRESHOLD)
		frac_part <= frac_part - FRAC_THRESHOLD + frac_step_len;
	else
		frac_part <= frac_part + frac_step_len;
end

assign frac_carry_bit = (frac_part >= FRAC_THRESHOLD);

always @(posedge clk, posedge rst) begin
	if(rst)
		uart_driv_flag <= 'd0;
	else if(r1_phase_sum[31:24] > phase_sum[31:24])
		uart_driv_flag <= 1'd1;
	else
		uart_driv_flag <= 'd0;
end

endmodule