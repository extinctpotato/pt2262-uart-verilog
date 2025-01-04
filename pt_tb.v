`include "pt.v"

module pt_tb();
	reg clk;
	reg ready = 0;
	reg [7:0] uart_in;
	wire [23:0] ad;
	wire q;
	wire done;
	wire cb_ld;

	initial begin
		$dumpfile("pt.vcd");
		$dumpvars(0, pt, p0);
		$display("Running testbench for pt module.");
		clk = 0;
		#1 uart_in = 8'b10101010;
		#2 ready = 1;
		#2 ready = 0; uart_in = 8'b10101010;
		#2 ready = 1;
		#2 ready = 0; uart_in = 8'b00000001;
		#2 ready = 1;
		#2 ready = 0;
		#2056 $finish;
	end

	always begin
		#1 clk = !clk;
	end

	pipo_8_to_24 p0(
		.clk(clk),
		.ready(ready),
		.pi(uart_in),
		.po(ad),
		.ld(cb_ld)
	);

	pt_enc pt (
		.clk(clk),
		.ld(cb_ld),
		.ad(ad),
		.q(q),
		.done(done)
	);
endmodule
