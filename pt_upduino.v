`include "pt.v"
`include "verilog-uart/uart/UARTReceiver.v"

// Taken from https://www.fpga4fun.com/CrossClockDomain2.html
module Flag_CrossDomain(
	input clkA,
	input FlagIn_clkA,   // this is a one-clock pulse from the clkA domain
	input clkB,
	output FlagOut_clkB   // from which we generate a one-clock pulse in clkB domain
);

	reg FlagToggle_clkA;
	always @(posedge clkA) FlagToggle_clkA <= FlagToggle_clkA ^ FlagIn_clkA;  // when flag is asserted, this signal toggles (clkA domain)

	reg [2:0] SyncA_clkB;
	always @(posedge clkB) SyncA_clkB <= {SyncA_clkB[1:0], FlagToggle_clkA};  // now we cross the clock domains

	assign FlagOut_clkB = (SyncA_clkB[2] ^ SyncA_clkB[1]);  // and create the clkB flag
endmodule

module top(
	input gpio_25,
	output led_r,
	output led_g,
	output led_b,
	output gpio_23
);
	wire clk_10khz;
	SB_LFOSC u_lfosc (
		.CLKLFPU(1'b1),
		.CLKLFEN(1'b1),
		.CLKLF(clk_10khz)
	);

	wire clk_48mhz;
	SB_HFOSC u_hfosc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(clk_48mhz)
	);

	// UART RX
	wire uart_rx_valid;
	wire uart_rx_valid_sync;
	wire uart_rx_error;
	wire uart_rx_overrun;
	wire [7:0] uart_rx_out;
	wire uart_rx_in;
	reg uart_reset = 1;

	// Encoder signals
	wire [23:0] encoder_payload;
	wire encoder_load;
	wire encoder_out;
	wire encoder_done;

	// Physical mappings
	assign gpio_23 = encoder_out;
	assign led_r = ~uart_rx_error;
	assign led_g = encoder_done;
	assign led_b = ~uart_rx_valid_sync;
	assign uart_rx_in = gpio_25;

	reg [1:0] ctr = 0;

	always @(posedge clk_48mhz) begin
		if (ctr < 3)
			ctr <= ctr + 1;
		else
			uart_reset <= 0;
	end

	reg encoder_load_latch2 = 0;
	reg [3:0] encoder_load_ctr = 0;

	always @(posedge clk_10khz) begin
		if (encoder_load) begin
			encoder_load_latch2 <= 1;
			encoder_load_ctr <= 0;
		end else if (encoder_load_latch2) begin
			if (encoder_done) begin
				if (encoder_load_ctr < 6)
					encoder_load_ctr <= encoder_load_ctr + 1;
				else
					encoder_load_latch2 <= 0;
			end
		end
	end

	UARTReceiver #(.CLOCK_RATE(48000000), .BAUD_RATE(9600)) u_rx(
		.clk(clk_48mhz),
		.reset(uart_reset),
		.enable(1'b1),
		.in(uart_rx_in),
		.ready(encoder_done),
		.out(uart_rx_out),
		.valid(uart_rx_valid),
		.error(uart_rx_error),
		.overrun(uart_rx_overrun)
	);

	Flag_CrossDomain fcdc(
		.clkA(clk_48mhz),
		.FlagIn_clkA(uart_rx_valid),
		.clkB(clk_10khz),
		.FlagOut_clkB(uart_rx_valid_sync)
	);

	pipo_8_to_24 p0(
		.clk(clk_10khz),
		.ready(uart_rx_valid_sync),
		.pi(uart_rx_out),
		.po(encoder_payload),
		.ld(encoder_load)
	);

	pt_enc pt (
		.clk(clk_10khz),
		.rst(~encoder_load_latch2),
		.ad(encoder_payload),
		.q(encoder_out),
		.done(encoder_done)
	);
endmodule
