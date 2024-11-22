/*
 * My RISC-V RV32I CPU
 *   FPGA LED output Module for Tang Premier
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2024 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module io_uart_out(
	input clk,
	input rst_n,
	// from/to IO bus

    input dma_io_we,
    input [15:2] dma_io_wadr,
    input [31:0] dma_io_wdata,
    input [15:2] dma_io_radr,
    input dma_io_radr_en,
    input [31:0] dma_io_rdata_in,
    output [31:0] dma_io_rdata,

	output reg [7:0] uart_io_char,
	output reg uart_io_we,
	input uart_io_full

	);

// decode :: adr 0x0 : LED values
`define SYS_UART_OUTC 14'h3F00
`define SYS_UART_FULL 14'h3F01

wire we_uart_char = dma_io_we & (dma_io_wadr == `SYS_UART_OUTC);
wire re_uart_full = dma_io_radr_en & (dma_io_radr == `SYS_UART_FULL);


always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        uart_io_char <= 8'd0 ;
	else if ( we_uart_char )
		uart_io_char <= dma_io_wdata[7:0];
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        uart_io_we <= 1'b0 ;
	else
        uart_io_we <= we_uart_char & ~uart_io_full;
end

reg re_uart_full_dly;

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        re_uart_full_dly <= 1'b0 ;
	else
        re_uart_full_dly <= re_uart_full ;
end

assign dma_io_rdata = re_uart_full_dly ? { 31'd0, uart_io_full } : dma_io_rdata_in;

endmodule
