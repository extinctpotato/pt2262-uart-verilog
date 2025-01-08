`include "pt.v"
`include "verilog-uart/uart/UARTReceiver.v"
`include "verilog-uart/uart/UARTTransmitter.v"

module pt_tb();
	reg clk;
	reg uart_in;
	reg uart_reset = 1;
	reg uart_tx_valid;
	reg [7:0] uart_tx_in;
	reg [7:0] uart_out;
	wire [23:0] ad;
	wire q;
	wire done;
	wire cb_ld;
	wire uart_valid;
	wire uart_tx_out;
	wire uart_tx_ready;
	wire uart_rx_in;
	wire [7:0] uart_rx_out;

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
		.ready(done),
		.out(uart_rx_out),
		.valid(uart_valid)
	);

	pipo_8_to_24 p0(
		.clk(clk),
		.ready(uart_valid),
		.pi(uart_rx_out),
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
