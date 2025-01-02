`include "pt.v"

module pt_tb();
	reg clk;
	reg cb_ld = 1;
	wire q;
	wire done;

	always @(posedge clk) begin
		if (done)
			cb_ld = 1;
		else
			cb_ld = 0;
	end

	initial begin
		$dumpfile("pt.vcd");
		$dumpvars(0, pt);
		$display("Running testbench for pt module.");
		clk = 0;
		#2056 $finish;
	end

	always begin
		#1 clk = !clk;
	end

	pt_enc pt (
		.clk(clk),
		.ld(cb_ld),
		.ad(24'b101010101010101000000001),
		.q(q),
		.done(done)
	);
endmodule
