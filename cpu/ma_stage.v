/*
 * My RISC-V RV32I CPU
 *   CPU Memory Access Stage Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module ma_stage(
	input clk,
	input rst_n,
	
	// from EX
    input cmd_ld_ma,
    input cmd_st_ma,
	input [4:0] rd_adr_ma,
	input [31:0] rd_data_ex,
	input [31:0] rd_data_ma,
	input wbk_rd_reg_ma,
	input [31:0] st_data_ma,
	input [2:0] ldst_code_ma,
	// to WB
    output reg cmd_ld_wb,
	output reg [2:0] ld_code_wb,
	output reg [4:0] rd_adr_wb,
	output reg [31:0] rd_data_wb,
	output reg wbk_rd_reg_wb,
	output [31:0] ld_data_ma,
	output reg [31:0] ld_data_wb,
	// to Memory
	input [13:2] d_ram_radr,
	output [31:0] d_ram_rdata,
	input [13:2] d_ram_wadr,
	input [31:0] d_ram_wdata,
	input d_ram_wen,
	input d_read_sel,
	// to IO
	output [3:0] st_we_io,
	output [11:2] st_adr_io,
	output [31:0] st_data_io,

	// stall
	input stall,
	input stall_1shot,
	input stall_dly,
	input rst_pipe

	);

// store
// byte aligner
function [31:0] byte_aligner;
input [1:0] adr_ofs;
input [7:0] data_byte;
begin
	case(adr_ofs)
		2'd0: byte_aligner = { 24'd0, data_byte };
		2'd1: byte_aligner = { 16'd0, data_byte, 8'd0 };
		2'd2: byte_aligner = { 8'd0, data_byte, 16'd0 };
		2'd3: byte_aligner = { data_byte, 24'd0 };
		default: byte_aligner = 32'd0;
	endcase
end
endfunction

wire [31:0] st_data_byte = byte_aligner( rd_data_ma[1:0], st_data_ma[7:0] );

function [31:0] half_aligner;
input adr_ofs;
input [15:0] data_byte;
begin
	case(adr_ofs)
		1'b0: half_aligner = { 16'd0, data_byte };
		1'b1: half_aligner = { data_byte, 16'd0 };
		default: half_aligner = 32'd0;
	endcase
end
endfunction

wire [31:0] st_data_half = half_aligner( rd_data_ma[1], st_data_ma[15:0] );

wire [31:0] st_wdata = (ldst_code_ma == 3'b000) ? st_data_byte :
                       (ldst_code_ma == 3'b001) ? st_data_half :
					   (ldst_code_ma == 3'b010) ? st_data_ma : 32'd0;

// byte enable

function [3:0] be_byte_aligner;
input [1:0] adr_ofs;
input cmd_st_ma;
begin
	case(adr_ofs)
		2'd0: be_byte_aligner = { 3'd0, cmd_st_ma };
		2'd1: be_byte_aligner = { 2'd0, cmd_st_ma, 1'd0 };
		2'd2: be_byte_aligner = { 1'd0, cmd_st_ma, 2'd0 };
		2'd3: be_byte_aligner = { cmd_st_ma, 3'd0 };
		default: be_byte_aligner = 4'd0;
	endcase
end
endfunction

wire [3:0] be_byte = be_byte_aligner( rd_data_ma[1:0], cmd_st_ma );

wire [3:0] be_half = rd_data_ma[1] ? { cmd_st_ma, cmd_st_ma, 2'd0 } : { 2'd0, cmd_st_ma, cmd_st_ma };

wire [3:0] st_we = (ldst_code_ma == 3'b000) ? be_byte :
                   (ldst_code_ma == 3'b001) ? be_half :
				   (ldst_code_ma == 3'b010) ? { cmd_st_ma, cmd_st_ma, cmd_st_ma, cmd_st_ma } : 4'd0;

wire [3:0] st_we_mem = st_we & { 4{ (rd_data_ma[31:30] != 2'b11) }};
assign      st_we_io = st_we & { 4{ (rd_data_ma[31:30] == 2'b11) }};
assign st_adr_io = rd_data_ma[11:2];
assign st_data_io = st_wdata;

// load / next stage

// data memory
reg  [31:0] ld_data_roll;
wire sel_data_rd_ma;
wire [13:2] data_radr_ex;
wire [31:0] data_rdata_ma;
wire [13:2] data_wadr_ma;
wire [31:0] data_wdata_ma;
wire [3:0] data_we_ma;

assign data_radr_ex = d_read_sel ? d_ram_radr : rd_data_ex[13:2];
assign data_wadr_ma = d_ram_wen ? d_ram_wadr : rd_data_ma[13:2];
assign data_wdata_ma = d_ram_wen ? d_ram_wdata : st_wdata;
assign data_we_ma = d_ram_wen ? 4'b1111 : st_we_mem;
assign sel_data_rd_ma = cmd_ld_ma; 

data_1r1w data_1r1w (
	.clk(clk),
	.ram_radr(data_radr_ex),
	.ram_rdata(data_rdata_ma),
	.ram_wadr(data_wadr_ma),
	.ram_wdata(data_wdata_ma),
	.ram_wen(data_we_ma)
	);

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        ld_data_roll <= 32'd0;
	else if (rst_pipe)
        ld_data_roll <= 32'd0;
	else if (stall_1shot)
        ld_data_roll <= data_rdata_ma;
end

assign ld_data_ma = stall_dly ? ld_data_roll : data_rdata_ma;
assign d_ram_rdata = data_rdata_ma;

// FF to WB

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
        cmd_ld_wb <= 1'b0;
		ld_code_wb <= 3'd0;
		ld_data_wb <= 32'd0;
		rd_adr_wb <= 5'd0;
		rd_data_wb <= 32'd0;
		wbk_rd_reg_wb <= 1'b0;
	end
	else if (rst_pipe) begin
        cmd_ld_wb <= 1'b0;
		ld_code_wb <= 3'd0;
		ld_data_wb <= 32'd0;
		rd_adr_wb <= 5'd0;
		rd_data_wb <= 32'd0;
		wbk_rd_reg_wb <= 1'b0;
	end
	else if (~stall) begin
        cmd_ld_wb <= cmd_ld_ma;
		ld_code_wb <= ldst_code_ma;
		ld_data_wb <= ld_data_ma;
		rd_adr_wb <= rd_adr_ma;
		rd_data_wb <= rd_data_ma;
		wbk_rd_reg_wb <= wbk_rd_reg_ma;
	end
end

endmodule



