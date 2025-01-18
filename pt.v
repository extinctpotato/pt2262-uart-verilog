module cb_gen(
	input clk,
	input rst,
	input [1:0] state,
	output q,
	output done
);
	reg [4:0] ctr = 0;
	reg [31:0] mux;
	assign q = mux[ctr] && ~rst;

	always @(posedge clk) begin
		case (state)
			2'b00 : mux <= 32'b11110000000000001111000000000000; 
			2'b01 : mux <= 32'b11111111111100001111111111110000;
			2'b10 : mux <= 32'b11110000000000001111111111110000;
			default: mux <= 32'b10000000000000000000000000000000;
		endcase

		if (rst) begin
			ctr <= 31;
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
	input rst,
	input [23:0] ad,
	output q,
	output done
);
	reg [23:0] tmp;
	reg [9:0] txed = 511;
	wire [1:0] codebit = tmp[23:22];
	assign done = (txed == 511); 

	wire q_cb;
	wire q_sb;
	assign q = q_cb || q_sb;

	wire load_next_cb = (txed[4:0] == 0 && txed[9:5] > 0 && txed < 384);

	always @(posedge clk) begin
		if (rst) begin
			txed <= 511;
		end else begin
			if (txed == 511) begin
				tmp <= ad;
				txed <= 0;
			end else
				txed <= txed + 1;

			if (load_next_cb)
				tmp <= {tmp[21:0], 2'b00};
		end
	end

	cb_gen c0 (
		.clk(clk),
		.rst(txed == 511 || txed > 383 || rst),
		.state(codebit),
		.q(q_cb)
	);

	sb_gen s0 (
		.clk(clk),
		.rst(txed < 383 || txed > 510),
		.q(q_sb)
	);
endmodule

module pipo_8_to_24(
	input clk,
	input ready,
	input [7:0] pi, 
	output reg [23:0] po,
	output reg ld
);
	reg [1:0] ctr = 0;
	reg ready_once = 0;

	always @(posedge clk) begin
		if (ctr == 3) begin
			ctr <= 0;
			ld <= 1;
		end else begin
			if (ready) begin
				if (~ready_once) begin
					po <= {po[15:0], pi};
					ctr <= ctr + 1;
					ready_once <= 1;
				end
			end else
				ready_once <= 0;
			ld <= 0;
		end
	end
endmodule
