/*
 * My RISC-V RV32I CPU
 *   CPU Data RAM Module in MA Stage
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

//`define TANG_PRIMER
`define ARTY_A7

module data_1r1w
	#(parameter DRWIDTH = 9)
	(
	input clk,
	input [DRWIDTH-1:0] ram_radr,
	output [31:0] ram_rdata,
	input [DRWIDTH-1:0] ram_wadr,
	input [31:0] ram_wdata,
	input [3:0] ram_wen
	);

// 4x1024 1r1w RAM

`ifdef TANG_PRIMER
reg[7:0] ram0[0:(2**DRWIDTH)-1];
reg[7:0] ram1[0:(2**DRWIDTH)-1];
reg[7:0] ram2[0:(2**DRWIDTH)-1];
reg[7:0] ram3[0:(2**DRWIDTH)-1];
`endif

`ifdef ARTY_A7
(* rw_addr_collision = "yes" *)
(* ram_style = "block" *) reg[7:0] ram0[0:(2**DRWIDTH)-1];
(* rw_addr_collision = "yes" *)
(* ram_style = "block" *) reg[7:0] ram1[0:(2**DRWIDTH)-1];
(* rw_addr_collision = "yes" *)
(* ram_style = "block" *) reg[7:0] ram2[0:(2**DRWIDTH)-1];
(* rw_addr_collision = "yes" *)
(* ram_style = "block" *) reg[7:0] ram3[0:(2**DRWIDTH)-1];
`endif

reg[DRWIDTH-1:0] radr;

always @ (posedge clk) begin
	if (ram_wen[0])
		ram0[ram_wadr] <= ram_wdata[7:0];
	if (ram_wen[1])
		ram1[ram_wadr] <= ram_wdata[15:8];
	if (ram_wen[2])
		ram2[ram_wadr] <= ram_wdata[23:16];
	if (ram_wen[3])
		ram3[ram_wadr] <= ram_wdata[31:24];
	radr <= ram_radr;
end

assign ram_rdata = { ram3[radr], ram2[radr], ram1[radr], ram0[radr] };

endmodule
