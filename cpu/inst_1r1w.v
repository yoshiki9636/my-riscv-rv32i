/*
 * My RISC-V RV32I CPU
 *   CPU Instruction RAM Module in IF Stage
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

//`define TANG_PRIMER
`define ARTY_A7

module inst_1r1w 
	#(parameter IWIDTH = 12)
	(
	input clk,
	input [IWIDTH-1:0] ram_radr,
	output [31:0] ram_rdata,
	input [IWIDTH-1:0] ram_wadr,
	input [31:0] ram_wdata,
	input ram_wen
	);

// 4x1024 1r1w RAM

`ifdef TANG_PRIMER
reg[31:0] ram[0:(2**IWIDTH)-1];
`endif

`ifdef ARTY_A7
(* rw_addr_collision = "yes" *)
(* ram_style = "block" *) reg[31:0] ram[0:(2**IWIDTH)-1];
`endif
reg[IWIDTH-1:0] radr;

always @ (posedge clk) begin
	if (ram_wen)
		ram[ram_wadr] <= ram_wdata;
	radr <= ram_radr;
end

assign ram_rdata = ram[radr];

endmodule
