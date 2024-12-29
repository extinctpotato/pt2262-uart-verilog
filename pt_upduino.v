`include "pt.v"

// Taken from https://github.com/vlsicad/clock-divide-by-n
// Will be removed once it is no longer necessary.
module clk_div_n #(
	parameter WIDTH = 7)

	(clk,reset,div_num, clk_out);

	input clk;
	input reset; 
	input [WIDTH-1:0] div_num;
	output clk_out;

	reg [WIDTH-1:0] pos_count, neg_count;
	wire [WIDTH-1:0] r_nxt;

	always @(posedge clk)
		if (reset)
			pos_count <=0;
		else if (pos_count ==div_num-1) pos_count <= 0;
		else pos_count<= pos_count +1;

	always @(negedge clk)
		if (reset)
			neg_count <=0;
		else  if (neg_count ==div_num-1) neg_count <= 0;
		else neg_count<= neg_count +1; 

	assign clk_out = ((pos_count > (div_num>>1)) | (neg_count > (div_num>>1))); 
endmodule

module top(
	output led_r,
	output led_g,
	output led_b
);
	assign led_g = 1;
	//assign led_b = 1;
	
	wire clk_10khz;
	SB_LFOSC u_lfosc (
		.CLKLFPU(1'b1),
		.CLKLFEN(1'b1),
		.CLKLF(clk_10khz)
	);

	wire clk_div;

	clk_div_n clk0 (
		.clk(clk_10khz),
		.reset(1'b0),
		.div_num(256),
		.clk_out(clk_div)
	);

	cb_gen c0 (
		.clk(clk_div),
		.state(1'bz),
		.q(led_r)
	);
endmodule
