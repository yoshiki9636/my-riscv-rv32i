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
	// to IO
	input [3:0] st_we_io,
	input [11:2] st_adr_io,
	input [31:0] st_data_io,
	output [2:0] rgb_led

	);

reg [2:0] led_value;

// decode :: adr 0x0 : LED values

wire we_led_value = st_we_io[0] & (st_adr_io == 10'd0);


always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        led_value <= 3'd0 ;
	else if ( we_led_value )
		led_value <= st_data_io[2:0];
end

assign rgb_led = led_value;

endmodule
