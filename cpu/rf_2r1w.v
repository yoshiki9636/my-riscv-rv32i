/*
 * My RISC-V RV32I CPU
 *   CPU Register File RAM Module in ID Stage
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

//`define TANG_PRIMER
`define ARTY_A7

module rf_2r1w(
	input clk,
	input [4:0] ram_radr1,
	output [31:0] ram_rdata1,
	input [4:0] ram_radr2,
	output [31:0] ram_rdata2,
	input [4:0] ram_wadr,
	input [31:0] ram_wdata,
	input ram_wen
	);

// 4x32 1r1w RAM

`ifdef TANG_PRIMER
reg[31:0] ram[0:31];
`endif
`ifdef ARTY_A7
(* rw_addr_collision = "yes" *)
(* ram_style = "block" *) reg[31:0] ram[0:31];
`endif
reg[4:0] radr1;
reg[4:0] radr2;

always @ (posedge clk) begin
	if (ram_wen)
		ram[ram_wadr] <= ram_wdata;
	radr1 <= ram_radr1;
	radr2 <= ram_radr2;
end

assign ram_rdata1 = ram[radr1];
assign ram_rdata2 = ram[radr2];

endmodule
