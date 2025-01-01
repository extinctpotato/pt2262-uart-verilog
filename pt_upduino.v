`include "pt.v"

module top(
	output led_r,
	output led_g,
	output led_b,
	output gpio_23
);
	assign led_g = 1;
	assign led_r = 1;
	reg cb_ld = 1;

	wire clk_10khz;
	SB_LFOSC u_lfosc (
		.CLKLFPU(1'b1),
		.CLKLFEN(1'b1),
		.CLKLF(clk_10khz)
	);

	wire out;
	wire done;
	assign gpio_23 = out;
	assign led_b = done;

	always @(posedge clk_10khz) begin
		if (done)
			cb_ld = 1;
		else
			cb_ld = 0;
	end

	pt_enc pt (
		.clk(clk_10khz),
		.ld(cb_ld),
		.ad(24'b101010101010101000000001),
		.q(out),
		.done(done)
	);
endmodule
