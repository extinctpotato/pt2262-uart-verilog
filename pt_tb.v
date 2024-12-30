`include "pt.v"

module pt_tb();
	reg clk;
	reg state;
	wire q;

	initial begin
		$dumpfile("pt.vcd");
		$dumpvars(0, c0);
		$display("Running testbench for pt module.");
		clk = 0;
		#1 state = 1'b0;
		#64 state = 1'b1;
		#64 state = 1'bz;
		#64 state = 1'b0;
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
