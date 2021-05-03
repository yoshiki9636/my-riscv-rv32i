/*
 * My RISC-V RV32I CPU
 *   CPU Data RAM Module in MA Stage
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module data_1r1w(
	input clk,
	input [9:0] ram_radr,
	output [31:0] ram_rdata,
	input [9:0] ram_wadr,
	input [31:0] ram_wdata,
	input [3:0] ram_wen
	);

// 8x256 1r1w RAM

reg[31:0] ram[0:1023];
reg[9:0] radr;

wire ena = |ram_wen;
reg [7:0] d0,d1,d2,d3;

always @(ram_wen or ram_wdata or ram_wadr or ram) begin
	if (ram_wen[0])
		d0 = ram_wdata[7:0];
	else
		d0 = ram[ram_wadr][7:0];
	if (ram_wen[1])
		d1 = ram_wdata[15:8];
	else
		d1 = ram[ram_wadr][15:8];
	if (ram_wen[2])
		d2 = ram_wdata[23:16];
	else
		d2 = ram[ram_wadr][23:16];
	if (ram_wen[3])
		d3 = ram_wdata[31:24];
	else
		d3 = ram[ram_wadr][31:24];
end	

always @ (posedge clk) begin
	if (ena)
		ram[ram_wadr] <= { d3,d2,d1,d0 };
	radr <= ram_radr;
end

assign ram_rdata = ram[radr];

endmodule
