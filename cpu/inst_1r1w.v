/*
 * My RISC-V RV32I CPU
 *   CPU Instruction RAM Module in IF Stage
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module inst_1r1w(
	input clk,
	input [11:0] ram_radr,
	output [31:0] ram_rdata,
	input [11:0] ram_wadr,
	input [31:0] ram_wdata,
	input ram_wen
	);

// 4x1024 1r1w RAM

reg[31:0] ram[0:4095];
reg[11:0] radr;

always @ (posedge clk) begin
	if (ram_wen)
		ram[ram_wadr] <= ram_wdata;
	radr <= ram_radr;
end

assign ram_rdata = ram[radr];

endmodule
