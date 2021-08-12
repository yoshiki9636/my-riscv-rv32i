
// Tang Nano UART loop by yoshiki9636

module uart_loop (
    input clk,
    input rst_n,

	// from/to outside
	output [7:0] rout,
	output rout_en,
	input [7:0] send_char,
	input send_en,

	// from rx
	output rx_rden,
	input [7:0] rx_rdata,
	input rx_fifo_full,
	input rx_fifo_dvalid,
	input rx_fifo_overrun,
	input rx_fifo_underrun,
	// to tx
	output [7:0] tx_wdata,
	output tx_wten,
	input tx_fifo_full,
	input tx_fifo_overrun,
	input tx_fifo_underrun

);

// loopback

assign rx_rden = rx_fifo_dvalid;

// rx data latch
reg [7:0] rx_data_l;
reg tx_wten_loop;

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        rx_data_l <= 8'd0 ;
    else if (rx_fifo_dvalid)
        rx_data_l <= rx_rdata ;
end

assign rout = rx_data_l;
assign rout_en = tx_wten_loop;

// tx write enable

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        tx_wten_loop <= 1'b0 ;
    else
        tx_wten_loop <= rx_fifo_dvalid ;
end

assign tx_wten = (tx_wten_loop & ~tx_fifo_full) | send_en;

assign tx_wdata = send_en ? send_char : rx_data_l;


endmodule