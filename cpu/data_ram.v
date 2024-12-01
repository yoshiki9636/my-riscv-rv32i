/*
 * My RISC-V RV32I CPU
 *   CPU Data RAM Module in MA Stage
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module data_ram
	#(parameter DWIDTH = 11)
	(
	input clk,
	input rst_n,
	// CPU i/f
	input [DWIDTH-1:0] ram_radr_part,
	output [31:0] ram_rdata,
	input [DWIDTH-1:0] ram_wadr_part,
	input [31:0] ram_wdata,
	input [3:0] ram_wen,
	// DRAM i/f
	input [DWIDTH-3:0] ram_radr_all,
	output [127:0] ram_rdata_all,
	input ram_ren_all,
	input [DWIDTH-3:0] ram_wadr_all,
	input [127:0] ram_wdata_all,
	input ram_wen_all
	);

wire [DWIDTH-3:0] ram_radr = ram_ren_all ? ram_radr_all : ram_radr_part[DWIDTH-1:2];
wire [DWIDTH-3:0] ram_wadr = ram_wen_all ? ram_wadr_all : ram_wadr_part[DWIDTH-1:2];
wire [3:0] ram_wen0 = { 4{ ram_wen_all }} | ram_wen & { 4{ (ram_wadr_part[1:0] == 2'b00) }};
wire [3:0] ram_wen1 = { 4{ ram_wen_all }} | ram_wen & { 4{ (ram_wadr_part[1:0] == 2'b01) }};
wire [3:0] ram_wen2 = { 4{ ram_wen_all }} | ram_wen & { 4{ (ram_wadr_part[1:0] == 2'b10) }};
wire [3:0] ram_wen3 = { 4{ ram_wen_all }} | ram_wen & { 4{ (ram_wadr_part[1:0] == 2'b11) }};
wire [31:0] ram_rdata0;
wire [31:0] ram_rdata1;
wire [31:0] ram_rdata2;
wire [31:0] ram_rdata3;
wire [31:0] ram_wdata0 = ram_wen_all ? ram_wdata_all[31:0] : ram_wdata;
wire [31:0] ram_wdata1 = ram_wen_all ? ram_wdata_all[63:32] : ram_wdata;
wire [31:0] ram_wdata2 = ram_wen_all ? ram_wdata_all[95:64] : ram_wdata;
wire [31:0] ram_wdata3 = ram_wen_all ? ram_wdata_all[127:96] : ram_wdata;

reg [1:0] ram_rd_sel;
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		ram_rd_sel <= 2'd0;
	else
		ram_rd_sel <= ram_radr_part[1:0];
end

assign ram_rdata = (ram_rd_sel == 2'd0) ? ram_rdata0 :
                   (ram_rd_sel == 2'd1) ? ram_rdata1 :
                   (ram_rd_sel == 2'd2) ? ram_rdata2 : ram_rdata3;

assign ram_rdata_all = {ram_rdata3, ram_rdata2, ram_rdata1, ram_rdata0};

data_1r1w #(.DRWIDTH(DWIDTH-2)) ram0 (
	.clk(clk),
	.ram_radr(ram_radr),
	.ram_rdata(ram_rdata0),
	.ram_wadr(ram_wadr),
	.ram_wdata(ram_wdata0),
	.ram_wen(ram_wen0)
	);

data_1r1w #(.DRWIDTH(DWIDTH-2)) ram1 (
	.clk(clk),
	.ram_radr(ram_radr),
	.ram_rdata(ram_rdata1),
	.ram_wadr(ram_wadr),
	.ram_wdata(ram_wdata1),
	.ram_wen(ram_wen1)
	);

data_1r1w #(.DRWIDTH(DWIDTH-2)) ram2 (
	.clk(clk),
	.ram_radr(ram_radr),
	.ram_rdata(ram_rdata2),
	.ram_wadr(ram_wadr),
	.ram_wdata(ram_wdata2),
	.ram_wen(ram_wen2)
	);

data_1r1w #(.DRWIDTH(DWIDTH-2)) ram3 (
	.clk(clk),
	.ram_radr(ram_radr),
	.ram_rdata(ram_rdata3),
	.ram_wadr(ram_wadr),
	.ram_wdata(ram_wdata3),
	.ram_wen(ram_wen3)
	);

endmodule
