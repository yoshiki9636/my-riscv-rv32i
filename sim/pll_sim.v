/*
 * My RISC-V RV32I CPU
 *   PLL Dummy Module for Verilog Simulation
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module pll(
	input refclk,
	input reset,
	//output stdby,
	output extlock,
	output clk0_out

	);

//assign stdby = 1'b0;
assign extlock = 1'b0;
assign clk0_out = refclk;

endmodule
