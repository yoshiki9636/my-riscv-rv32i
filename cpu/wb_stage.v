/*
 * My RISC-V RV32I CPU
 *   CPU Write Back Stage Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module wb_stage(
	input clk,
	input rst_n,

	// from MA
    input cmd_ld_wb,
	input [2:0] ld_code_wb,
	input [31:0] rd_data_wb,
	input [31:0] ld_data_wb,
    // to ID write back, forwarding
	output [31:0] wbk_data_wb,
	// to EX forwarding
	output reg [31:0] wbk_data_wb2,
	// stall
	input stall,
	input rst_pipe

	);

// load

function [7:0] ld_byte_aligner;
input [1:0] adr_ofs;
input [31:0] ld_data_wb;
begin
	case(adr_ofs)
		2'd0: ld_byte_aligner = ld_data_wb[7:0];
		2'd1: ld_byte_aligner = ld_data_wb[15:8];
		2'd2: ld_byte_aligner = ld_data_wb[23:16];
		2'd3: ld_byte_aligner = ld_data_wb[31:24];
		default: ld_byte_aligner = 4'd0;
	endcase
end
endfunction

wire [7:0] ld_byte = ld_byte_aligner( rd_data_wb[1:0], ld_data_wb );
wire [31:0] s_ld_byte = { { 24{ ld_byte[7] }}, ld_byte };
wire [31:0] u_ld_byte = { 24'd0, ld_byte };

function [15:0] ld_half_aligner;
input adr_ofs;
input [31:0] ld_data_wb;
begin
	case(adr_ofs)
		1'd0: ld_half_aligner = ld_data_wb[15:0];
		1'd1: ld_half_aligner = ld_data_wb[31:16];
		default: ld_half_aligner = 32'd0;
	endcase
end
endfunction

wire [15:0] ld_half = ld_half_aligner( rd_data_wb[1], ld_data_wb );
wire [31:0] s_ld_half = { { 16{ ld_half[15] }}, ld_half };
wire [31:0] u_ld_half = { 16'd0, ld_half };

function [31:0] ld_selector;
input [2:0] ld_code_wb;
input [31:0] s_ld_byte;
input [31:0] u_ld_byte;
input [31:0] s_ld_half;
input [31:0] u_ld_half;
input [31:0] ld_data_wb;
begin
	case(ld_code_wb)
		3'b000: ld_selector = s_ld_byte;
		3'b001: ld_selector = s_ld_half;
		3'b010: ld_selector = ld_data_wb;
		3'b100: ld_selector = u_ld_byte;
		3'b101: ld_selector = u_ld_half;
		default: ld_selector = 32'd0;
	endcase
end
endfunction

wire [31:0] ld_data = ld_selector( ld_code_wb,
								   s_ld_byte,
								   u_ld_byte,
								   s_ld_half,
								   u_ld_half,
								   ld_data_wb );
								   
// selector

assign wbk_data_wb = cmd_ld_wb ? ld_data : rd_data_wb;

// for fowarding

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        wbk_data_wb2 <= 32'd0;
	else if (rst_pipe)
        wbk_data_wb2 <= 32'd0;
	else if (~stall)
		wbk_data_wb2 <= wbk_data_wb;
end

endmodule
