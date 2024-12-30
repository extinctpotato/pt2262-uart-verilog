module cb_gen(
	input clk,
	input [1:0] state,
	output q
);
	reg [31:0] zero = 32'b11110000000000001111000000000000;
	reg [31:0] one = 32'b11111111111100001111111111110000;
	reg [31:0] hi_z = 32'b11110000000000001111111111110000;

	reg [4:0] ctr = 0;
	reg [31:0] mux;
	assign q = mux[ctr];

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
