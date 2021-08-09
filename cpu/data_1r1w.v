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

reg[7:0] ram0[0:1023];
reg[7:0] ram1[0:1023];
reg[7:0] ram2[0:1023];
reg[7:0] ram3[0:1023];
reg[9:0] radr;

always @ (posedge clk) begin
	if (en[0])
		ram0[ram_wadr] <= ram_wdata[7:0];
	if (en[1])
		ram1[ram_wadr] <= ram_wdata[15:8];
	if (en[2])
		ram2[ram_wadr] <= ram_wdata[23:16];
	if (en[3])
		ram3[ram_wadr] <= ram_wdata[31:24];
	radr <= ram_radr;
end

assign ram_rdata = { ram3[radr], ram2[radr], ram1[radr], ram0[radr] };

endmodule
