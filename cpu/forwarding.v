/*
 * My RISC-V RV32I CPU
 *   CPU Forwarding Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module forwarding(
	input clk,
	input rst_n,
	// id and valid from stages
	input [4:0] inst_rs1_id,
	input inst_rs1_valid,
	input [4:0] inst_rs2_id,
	input inst_rs2_valid,
	input [4:0] rd_adr_ex,
	input wbk_rd_reg_ex,
    input cmd_ld_ex,
	input [4:0] rd_adr_ma,
	input wbk_rd_reg_ma,
	input [4:0] rd_adr_wb,
	input wbk_rd_reg_wb,
	
	output reg hit_rs1_ldex_ex,
	output reg hit_rs1_idex_ex,
	output reg hit_rs1_idma_ex,
	output reg hit_rs1_idwb_ex,
	output reg nohit_rs1_ex,
	output reg hit_rs2_ldex_ex,
	output reg hit_rs2_idex_ex,
	output reg hit_rs2_idma_ex,
	output reg hit_rs2_idwb_ex,
	output reg nohit_rs2_ex,
	// stall
	input stall,
	input rst_pipe

	);

// comparetor

wire hit_rs1_ldex = (inst_rs1_id == rd_adr_ex) & inst_rs1_valid & wbk_rd_reg_ex &  cmd_ld_ex;
wire hit_rs1_idex = (inst_rs1_id == rd_adr_ex) & inst_rs1_valid & wbk_rd_reg_ex & ~cmd_ld_ex;
wire hit_rs1_idma = (inst_rs1_id == rd_adr_ma) & inst_rs1_valid & wbk_rd_reg_ma;
wire hit_rs1_idwb = (inst_rs1_id == rd_adr_wb) & inst_rs1_valid & wbk_rd_reg_wb;
wire nohit_rs1 = ~( hit_rs1_ldex | hit_rs1_idex | hit_rs1_idma | hit_rs1_idwb);

wire hit_rs2_ldex = (inst_rs2_id == rd_adr_ex) & inst_rs2_valid & wbk_rd_reg_ex &  cmd_ld_ex;
wire hit_rs2_idex = (inst_rs2_id == rd_adr_ex) & inst_rs2_valid & wbk_rd_reg_ex & ~cmd_ld_ex;
wire hit_rs2_idma = (inst_rs2_id == rd_adr_ma) & inst_rs2_valid & wbk_rd_reg_ma;
wire hit_rs2_idwb = (inst_rs2_id == rd_adr_wb) & inst_rs2_valid & wbk_rd_reg_wb;
wire nohit_rs2 = ~( hit_rs2_ldex | hit_rs2_idex | hit_rs2_idma | hit_rs2_idwb);

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		hit_rs1_ldex_ex <= 1'b0;
		hit_rs1_idex_ex <= 1'b0;
		hit_rs1_idma_ex <= 1'b0;
		hit_rs1_idwb_ex <= 1'b0;
		nohit_rs1_ex <= 1'b0;
		hit_rs2_ldex_ex <= 1'b0;
		hit_rs2_idex_ex <= 1'b0;
		hit_rs2_idma_ex <= 1'b0;
		hit_rs2_idwb_ex <= 1'b0;
		nohit_rs2_ex <= 1'b0;
	end
	else if (rst_pipe) begin
		hit_rs1_ldex_ex <= 1'b0;
		hit_rs1_idex_ex <= 1'b0;
		hit_rs1_idma_ex <= 1'b0;
		hit_rs1_idwb_ex <= 1'b0;
		nohit_rs1_ex <= 1'b0;
		hit_rs2_ldex_ex <= 1'b0;
		hit_rs2_idex_ex <= 1'b0;
		hit_rs2_idma_ex <= 1'b0;
		hit_rs2_idwb_ex <= 1'b0;
		nohit_rs2_ex <= 1'b0;
	end
	else if (~stall) begin
		hit_rs1_ldex_ex <= hit_rs1_ldex;
		hit_rs1_idex_ex <= hit_rs1_idex;
		hit_rs1_idma_ex <= hit_rs1_idma;
		hit_rs1_idwb_ex <= hit_rs1_idwb;
		nohit_rs1_ex <= nohit_rs1;
		hit_rs2_ldex_ex <= hit_rs2_ldex;
		hit_rs2_idex_ex <= hit_rs2_idex;
		hit_rs2_idma_ex <= hit_rs2_idma;
		hit_rs2_idwb_ex <= hit_rs2_idwb;
		nohit_rs2_ex <= nohit_rs2;
	end
end

endmodule
