`include "pt.v"
`include "verilog-uart/uart/UARTReceiver.v"
`include "verilog-uart/uart/UARTTransmitter.v"

module pt_tb();
	reg clk;
	reg uart_reset = 1;

	// UART RX
	wire uart_rx_valid;
	wire [7:0] uart_rx_out;
	wire uart_rx_in;

	// UART TX
	wire uart_tx_ready;
	reg uart_tx_valid;
	reg [7:0] uart_tx_in;

	// Encoder signals
	wire [23:0] encoder_payload;
	wire encoder_load;
	wire encoder_out;
	wire encoder_done;

	initial begin
		$dumpfile("pt.vcd");
		$dumpvars(0, pt, p0, u_rx, u_tx);
		$display("Running testbench for pt module.");
		clk = 0;
		#2 uart_reset = 0;
		#99 uart_tx_in = 8'b10101010;
		#2 uart_tx_valid = 1;
		#2 uart_tx_valid = 0;
		#1102 uart_tx_in = 8'b00000001;
		#2 uart_tx_valid = 1;
		#2 uart_tx_valid = 0;
		#1102 uart_tx_in = 8'b10101010;
		#2 uart_tx_valid = 1;
		#2 uart_tx_valid = 0;
		#2056 $finish;
	end

	always begin
		#1 clk = !clk;
	end

	UARTTransmitter #(.CLOCK_RATE(10000), .BAUD_RATE(300)) u_tx(
		.clk(clk),
		.reset(uart_reset),
		.enable(1'b1),
		.valid(uart_tx_valid),
		.in(uart_tx_in),
		.out(uart_rx_in),
		.ready(uart_tx_ready)
	);

	UARTReceiver #(.CLOCK_RATE(10000), .BAUD_RATE(300)) u_rx(
		.clk(clk),
		.reset(uart_reset),
		.enable(1'b1),
		.in(uart_rx_in),
		.ready(encoder_done),
		.out(uart_rx_out),
		.valid(uart_rx_valid)
	);

	pipo_8_to_24 p0(
		.clk(clk),
		.ready(uart_rx_valid),
		.pi(uart_rx_out),
		.po(encoder_payload),
		.ld(encoder_load)
	);

	pt_enc pt (
		.clk(clk),
		.ld(encoder_load),
		.ad(encoder_payload),
		.q(encoder_out),
		.done(encoder_done)
	);
endmodule
