`include "pt.v"

module pt_tb();
	reg clk;
	reg [1:0] state;
	reg sb_rst = 1;
	reg cb_ld = 1;
	wire q;
	wire q2;
	wire q3;

	initial begin
		$dumpfile("pt.vcd");
		$dumpvars(0, c0, s0, pt);
		$display("Running testbench for pt module.");
		clk = 0;
		#1 state = 2'b00;
		#1 cb_ld = 0;
		#64 state = 2'b01;
		#64 state = 2'b10;
		#64 state = 2'b00;
		#128 sb_rst = 0; 
		#512 $finish;
	end

	always begin
		#1 clk = !clk;
	end

	cb_gen c0 (
		.clk(clk),
		.state(state),
		.q(q)
	);

	sb_gen s0 (
		.clk(clk),
		.rst(sb_rst),
		.q(q2)
	);

	pt_enc pt (
		.clk(clk),
		.ld(cb_ld),
		.ad(24'b000100000001010101001010),
		.q(q3)
	);
endmodule
