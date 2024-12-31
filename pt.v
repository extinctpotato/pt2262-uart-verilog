module cb_gen(
	input clk,
	input [1:0] state,
	output q,
	output done
);
	reg [31:0] zero = 32'b11110000000000001111000000000000;
	reg [31:0] one = 32'b11111111111100001111111111110000;
	reg [31:0] hi_z = 32'b11110000000000001111111111110000;

	reg [4:0] ctr = 0;
	reg [31:0] mux;
	assign q = mux[ctr];
	assign done = (ctr == 5'b00000);

	always @(state) begin
		case (state)
			2'b00 : mux <= zero;
			2'b01 : mux <= one;
			2'b10 : mux <= hi_z;
		endcase
	end

	always @(posedge clk)
		ctr <= ctr - 1;
endmodule

module sb_gen(
	input clk,
	input rst,
	output q
);
	reg [6:0] ctr = 127;
	wire drive_high = (ctr < 5);
	assign q = drive_high;

	always @(posedge clk)
	begin
		if (rst)
			ctr <= 127;
		else
			ctr <= ctr + 1;
	end
endmodule

module pt_enc(
	input clk,
	input ld,
	input [23:0] ad,
	output q
);
	reg [23:0] tmp = 0;
	reg [1:0] codebit = 0;
	wire cb_done;

	always @(posedge clk) begin
		if (ld)
			tmp <= ad;
		else
			codebit <= tmp[23:22];
	end

	always @(negedge clk) begin
		if (cb_done)
			tmp <= {tmp[21:0], 2'b00};
	end

	cb_gen c0 (
		.clk(clk),
		.state(codebit),
		.q(q),
		.done(cb_done)
	);
endmodule
