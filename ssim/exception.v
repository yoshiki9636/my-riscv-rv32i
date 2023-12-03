/*
 * My RISC-V RV32I CPU
 *   CPU Interrupter
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2023 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module exception(
	input clk,
	input rst_n,
	// from external
	input illegal_ops_ex,
	// from csr
	output g_exception

	);

// currntly supporting just illegal operations
assign g_exception = illegal_ops_ex;

endmodule
