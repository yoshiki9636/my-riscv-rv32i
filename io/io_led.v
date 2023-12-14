/*
 * My RISC-V RV32I CPU
 *   FPGA LED output Module for Tang Premier
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module io_led(
	input clk,
	input rst_n,
	// from/to IO bus

    input dma_io_we,
    input [15:2] dma_io_wadr,
    input [15:0] dma_io_wdata,
    input [15:2] dma_io_radr,
    input [15:0] dma_io_rdata_in,
    output [15:0] dma_io_rdata,
	output [2:0] rgb_led

	);

reg [2:0] led_value;

// decode :: adr 0x0 : LED values
`define SYS_LED_IO 14'h3F80

wire we_led_value = dma_io_we & (dma_io_wadr == `SYS_LED_IO);
wire re_led_value = (dma_io_radr == `SYS_LED_IO);


always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        led_value <= 3'd0 ;
	else if ( we_led_value )
		led_value <= dma_io_wdata[2:0];
end

assign dma_io_rdata = re_led_value ? { 13'd0, led_value } : dma_io_rdata_in;
assign rgb_led = led_value;

endmodule
