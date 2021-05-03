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
	input [9:0] ram_radr,
	output [31:0] ram_rdata,
	input [9:0] ram_wadr,
	input [31:0] ram_wdata,
	input ram_wen
	);

// 8x256 1r1w RAM

reg[31:0] ram[0:1023];
reg[9:0] radr;

//initial $readmemh("./test.txt", ram);

always @ (posedge clk) begin
	if (ram_wen)
		ram[ram_wadr] <= ram_wdata;
	radr <= ram_radr;
end

assign ram_rdata = ram[radr];

endmodule