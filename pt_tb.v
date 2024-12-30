`include "pt.v"

module pt_tb();
	reg clk;
	reg [1:0] state;
	wire q;

	initial begin
		$dumpfile("pt.vcd");
		$dumpvars(0, c0);
		$display("Running testbench for pt module.");
		clk = 0;
		#1 state = 2'b00;
		#64 state = 2'b01;
		#64 state = 2'b10;
		#64 state = 2'b00;
		#128 $finish;
	end

	always begin
		#1 clk = !clk;
	end

	cb_gen c0 (
		.clk(clk),
		.state(state),
		.q(q)
	);
endmodule
