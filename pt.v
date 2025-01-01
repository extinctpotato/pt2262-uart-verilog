module cb_gen(
	input clk,
	input rst,
	input [1:0] state,
	output q,
	output done
);
	reg [31:0] zero = 32'b11110000000000001111000000000000;
	reg [31:0] one = 32'b11111111111100001111111111110000;
	reg [31:0] hi_z = 32'b11110000000000001111111111110000;
	reg [31:0] def = 0; 

	reg [4:0] ctr = 0;
	reg [31:0] mux;
	assign q = mux[ctr] && ~rst;
	assign done = (ctr == 5'b00000 && rst == 0);

	always @(posedge clk) begin
		if (rst) begin
			ctr <= 31;
			case (state)
				2'b00 : mux <= zero;
				2'b01 : mux <= one;
				2'b10 : mux <= hi_z;
				default: mux <= def; 
			endcase
		end else
			ctr <= ctr - 1;
	end
endmodule

module sb_gen(
	input clk,
	input rst,
	output q,
	output done
);
	reg [6:0] ctr = 127;
	wire drive_high = (ctr < 4);
	assign q = drive_high;
	assign done = (ctr == 127 && rst == 0);

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
	output q,
	output done
);
	reg [23:0] tmp;
	reg [9:0] txed = 512;
	wire [1:0] codebit = tmp[23:22];
	wire cb_done;
	wire sb_done;
	assign done = (txed == 512); 

	wire q_cb;
	wire q_sb;
	assign q = q_cb || q_sb;

	wire gen_done = cb_done || sb_done;

	always @(posedge clk) begin
		if (ld) begin
			tmp <= ad;
			txed <= 0;
		end else begin
			if (gen_done)
				tmp <= {tmp[21:0], 2'b00};
			if (txed < 512)
				txed <= txed + 1;
		end
	end

	cb_gen c0 (
		.clk(clk),
		.rst(txed == 0 || txed > 384),
		.state(codebit),
		.q(q_cb),
		.done(cb_done)
	);

	sb_gen s0 (
		.clk(clk),
		.rst(txed < 384 || txed > 511),
		.q(q_sb),
		.done(sb_done)
	);
endmodule
