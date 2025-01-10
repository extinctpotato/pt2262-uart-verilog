`include "pt.v"
`include "verilog-uart/uart/UARTReceiver.v"

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

	// UART RX
	wire uart_rx_valid;
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
	assign led_r = ~(uart_rx_error || uart_rx_overrun || uart_reset);
	assign led_g = encoder_done;
	assign led_b = ~uart_rx_valid;
	assign uart_rx_in = gpio_25;

	reg [1:0] ctr = 0;

	always @(posedge clk_10khz) begin
		if (ctr < 3)
			ctr <= ctr + 1;
		else
			uart_reset <= 0;
	end

	UARTReceiver #(.CLOCK_RATE(10000), .BAUD_RATE(300)) u_rx(
		.clk(clk_10khz),
		.reset(uart_reset),
		.enable(1'b1),
		.in(uart_rx_in),
		.ready(encoder_done),
		.out(uart_rx_out),
		.valid(uart_rx_valid),
		.error(uart_rx_error),
		.overrun(uart_rx_overrun)
	);

	pipo_8_to_24 p0(
		.clk(clk_10khz),
		.ready(uart_rx_valid),
		.pi(uart_rx_out),
		.po(encoder_payload),
		.ld(encoder_load)
	);

	pt_enc pt (
		.clk(clk_10khz),
		.ld(encoder_load),
		.ad(encoder_payload),
		.q(encoder_out),
		.done(encoder_done)
	);
endmodule
