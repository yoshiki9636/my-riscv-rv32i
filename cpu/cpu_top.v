/*
 * My RISC-V RV32I CPU
 *   CPU Top Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module cpu_top
	#(parameter DWIDTH = 12)
	(

	input clk,
	input rst_n,

	input cpu_start,
	input quit_cmd,
	input [31:2] start_adr,

	input [DWIDTH+1:2] d_ram_radr,
	input [DWIDTH+1:2] d_ram_wadr,
	output [31:0] d_ram_rdata,
	input [31:0] d_ram_wdata,
	input d_ram_wen,
	input d_read_sel,

	input [13:2] i_ram_radr,
	input [13:2] i_ram_wadr,
	output [31:0] i_ram_rdata,
	input [31:0] i_ram_wdata,
	input i_ram_wen,
	input i_read_sel,
	output [31:0] pc_data,

	output dma_io_we,
	output [15:2] dma_io_wadr,
	output [31:0] dma_io_wdata,
	output [15:2] dma_io_radr,
	input [31:0] dma_io_rdata_in,

    output ibus_ren,
    output [19:2] ibus_radr,
    input [15:0] ibus32_rdata,
    output ibus_wen,
    output [19:2] ibus_wadr,
    output [15:0] ibus32_wdata,

	input interrupt_0

	);

`define M_MODE 2'b11
`define S_MODE 2'b01
`define U_MODE 2'b00

wire [11:0] csr_ofs_ex;
wire [11:0] jalr_ofs_ex;
wire [11:0] ld_alui_ofs_ex;
wire [11:0] st_ofs_ex;
wire [12:1] br_ofs_ex;
wire [20:1] jal_ofs_ex;
wire [2:0] alu_code_ex;
wire [2:0] ld_code_wb;
wire [2:0] ldst_code_ma;
wire [31:0] inst_id;
wire [31:0] ld_data_wb;
wire [31:0] rd_data_ma;
wire [31:0] rd_data_wb;
wire [31:0] rs1_data_ex;
wire [31:0] rs2_data_ex;
wire [31:0] st_data_ma;
wire [31:0] wbk_data_wb2;
wire [31:0] wbk_data_wb;
wire [31:12] lui_auipc_imm_ex;
wire [31:2] jmp_adr_ex;
wire [31:2] csr_mtvec_ex;
wire [31:2] pc_ex;
wire [31:2] pc_id;
wire [3:0] fence_pred_ex;
wire [3:0] fence_succ_ex;
wire [4:0] alui_shamt_ex;
wire [4:0] csr_uimm_ex;
wire [2:0] csr_op2_ex;
wire [4:0] inst_rs1_id;
wire [4:0] inst_rs2_id;
wire [4:0] rd_adr_ex;
wire [4:0] rd_adr_ma;
wire [4:0] rd_adr_wb;
wire cmd_alu_add_ex;
wire cmd_alu_ex;
wire cmd_alu_sub_ex;
wire cmd_alui_ex;
wire cmd_alui_shamt_ex;
wire cmd_auipc_ex;
wire cmd_br_ex;
wire cmd_csr_ex;
wire cmd_ebreak_ex;
wire cmd_ecall_ex;
wire cmd_fence_ex;
wire cmd_fencei_ex;
wire cmd_jal_ex;
wire cmd_jalr_ex;
wire cmd_ld_ex;
wire cmd_ld_ma;
wire cmd_ld_wb;
wire cmd_lui_ex;
wire cmd_mret_ex;
wire cmd_sfence_ex;
wire cmd_sret_ex;
wire cmd_st_ex;
wire cmd_st_ma;
wire cmd_uret_ex;
wire cmd_wfi_ex;
wire illegal_ops_ex;
wire g_exception;
wire hit_rs1_idex_ex;
wire hit_rs1_idma_ex;
wire hit_rs1_idwb_ex;
wire hit_rs2_idex_ex;
wire hit_rs2_idma_ex;
wire hit_rs2_idwb_ex;
wire inst_rs1_valid;
wire inst_rs2_valid;
wire jmp_condition_ex;
wire ecall_condition_ex;
wire jmp_purge_ma;
wire nohit_rs1_ex;
wire nohit_rs2_ex;
wire rst_pipe;
wire rst_pipe_id;
wire rst_pipe_ex;
wire rst_pipe_ma;
wire rst_pipe_wb;
wire stall;
wire stall_1shot;
wire stall_dly;
wire stall_ld;
wire stall_ld_ex;
wire wbk_rd_reg_ex;
wire wbk_rd_reg_ma;
wire wbk_rd_reg_wb;

wire [31:2] csr_mepc_ex;
wire [31:2] csr_sepc_ex;
// from somewhere...
wire [1:0] g_interrupt_priv = `M_MODE; // temp
wire [1:0] g_current_priv = `M_MODE; // temp
wire g_interrupt;
wire post_jump_cmd_cond;
wire csr_meie;
wire csr_mtie;
wire csr_msie;
wire dma_we_ma;
wire [15:2] dataram_wadr_ma;
wire [15:0] dataram_wdata_ma;
wire dma_re_ma;
wire [15:2] dataram_radr_ma;
wire [15:0] dataram_rdata_wb;
wire [31:0] dma_io_rdata;

cpu_status cpu_status (
	.clk(clk),
	.rst_n(rst_n),
	.cpu_start(cpu_start),
	.quit_cmd(quit_cmd),
	.stall(stall),
	.stall_1shot(stall_1shot),
	.stall_dly(stall_dly),
	.rst_pipe(rst_pipe),
	.rst_pipe_id(rst_pipe_id),
	.rst_pipe_ex(rst_pipe_ex),
	.rst_pipe_ma(rst_pipe_ma),
	.rst_pipe_wb(rst_pipe_wb)
	);

if_stage if_stage (
	.clk(clk),
	.rst_n(rst_n),
	.inst_id(inst_id),
	.pc_id(pc_id),
	.jmp_condition_ex(jmp_condition_ex),
	.jmp_adr_ex(jmp_adr_ex),
	.ecall_condition_ex(ecall_condition_ex),
	.cmd_mret_ex(cmd_mret_ex),
	.csr_mepc_ex(csr_mepc_ex),
	.cmd_sret_ex(cmd_sret_ex),
	.csr_sepc_ex(csr_sepc_ex),
	.cmd_uret_ex(cmd_uret_ex),
	.csr_mtvec_ex(csr_mtvec_ex),
    .g_interrupt(g_interrupt),
    .post_jump_cmd_cond(post_jump_cmd_cond),
    .g_exception(g_exception),
	.i_ram_radr(i_ram_radr),
	.i_ram_rdata(i_ram_rdata),
	.i_ram_wadr(i_ram_wadr),
	.i_ram_wdata(i_ram_wdata),
	.i_ram_wen(i_ram_wen),
	.i_read_sel(i_read_sel),
	.cpu_start(cpu_start),
	.start_adr(start_adr),
	.stall(stall),
	.stall_1shot(stall_1shot),
	.stall_dly(stall_dly),
	.stall_ld(stall_ld),
	.stall_ld_ex(stall_ld_ex),
	.rst_pipe(rst_pipe),
	.pc_data(pc_data)
	);

id_stage id_stage (
	.clk(clk),
	.rst_n(rst_n),
	.inst_id(inst_id),
	.pc_id(pc_id),
	.rs1_data_ex(rs1_data_ex),
	.rs2_data_ex(rs2_data_ex),
	.pc_ex(pc_ex),
	.cmd_lui_ex(cmd_lui_ex),
	.cmd_auipc_ex(cmd_auipc_ex),
	.lui_auipc_imm_ex(lui_auipc_imm_ex),
	.cmd_ld_ex(cmd_ld_ex),
	.ld_alui_ofs_ex(ld_alui_ofs_ex),
	.cmd_alui_ex(cmd_alui_ex),
	.cmd_alui_shamt_ex(cmd_alui_shamt_ex),
	.cmd_alu_ex(cmd_alu_ex),
	.cmd_alu_add_ex(cmd_alu_add_ex),
	.cmd_alu_sub_ex(cmd_alu_sub_ex),
	.alu_code_ex(alu_code_ex),
	.alui_shamt_ex(alui_shamt_ex),
	.cmd_st_ex(cmd_st_ex),
	.st_ofs_ex(st_ofs_ex),
	.cmd_jal_ex(cmd_jal_ex),
	.jal_ofs_ex(jal_ofs_ex),
	.cmd_jalr_ex(cmd_jalr_ex),
	.jalr_ofs_ex(jalr_ofs_ex),
	.cmd_br_ex(cmd_br_ex),
	.br_ofs_ex(br_ofs_ex),
	.cmd_fence_ex(cmd_fence_ex),
	.cmd_fencei_ex(cmd_fencei_ex),
	.fence_succ_ex(fence_succ_ex),
	.fence_pred_ex(fence_pred_ex),
	.cmd_sfence_ex(cmd_sfence_ex),
	.cmd_csr_ex(cmd_csr_ex),
	.csr_ofs_ex(csr_ofs_ex),
	.csr_uimm_ex(csr_uimm_ex),
	.csr_op2_ex(csr_op2_ex),
	.cmd_ecall_ex(cmd_ecall_ex),
	.cmd_ebreak_ex(cmd_ebreak_ex),
	.cmd_uret_ex(cmd_uret_ex),
	.cmd_sret_ex(cmd_sret_ex),
	.cmd_mret_ex(cmd_mret_ex),
	.cmd_wfi_ex(cmd_wfi_ex),
	.illegal_ops_ex(illegal_ops_ex),
	.rd_adr_ex(rd_adr_ex),
	.wbk_rd_reg_ex(wbk_rd_reg_ex),
	.jmp_purge_ma(jmp_purge_ma),
	.rd_adr_wb(rd_adr_wb),
	.wbk_rd_reg_wb(wbk_rd_reg_wb),
	.wbk_data_wb(wbk_data_wb),
	.inst_rs1_id(inst_rs1_id),
	.inst_rs2_id(inst_rs2_id),
	.inst_rs1_valid(inst_rs1_valid),
	.inst_rs2_valid(inst_rs2_valid),
	.stall(stall),
	.stall_1shot(stall_1shot),
	.stall_dly(stall_dly),
	.stall_ld(stall_ld),
	.stall_ld_ex(stall_ld_ex),
	.rst_pipe(rst_pipe_id)
	);

ex_stage ex_stage (
	.clk(clk),
	.rst_n(rst_n),
	.rs1_data_ex(rs1_data_ex),
	.rs2_data_ex(rs2_data_ex),
	.pc_ex(pc_ex),
	.cmd_lui_ex(cmd_lui_ex),
	.cmd_auipc_ex(cmd_auipc_ex),
	.lui_auipc_imm_ex(lui_auipc_imm_ex),
	.cmd_ld_ex(cmd_ld_ex),
	.ld_alui_ofs_ex(ld_alui_ofs_ex),
	.cmd_alui_ex(cmd_alui_ex),
	.cmd_alui_shamt_ex(cmd_alui_shamt_ex),
	.cmd_alu_ex(cmd_alu_ex),
	.cmd_alu_add_ex(cmd_alu_add_ex),
	.cmd_alu_sub_ex(cmd_alu_sub_ex),
	.alu_code_ex(alu_code_ex),
	.alui_shamt_ex(alui_shamt_ex),
	.cmd_st_ex(cmd_st_ex),
	.st_ofs_ex(st_ofs_ex),
	.cmd_jal_ex(cmd_jal_ex),
	.jal_ofs_ex(jal_ofs_ex),
	.cmd_jalr_ex(cmd_jalr_ex),
	.jalr_ofs_ex(jalr_ofs_ex),
	.cmd_br_ex(cmd_br_ex),
	.br_ofs_ex(br_ofs_ex),
	.cmd_fence_ex(cmd_fence_ex),
	.cmd_fencei_ex(cmd_fencei_ex),
	.fence_succ_ex(fence_succ_ex),
	.fence_pred_ex(fence_pred_ex),
	.cmd_sfence_ex(cmd_sfence_ex),
	.cmd_csr_ex(cmd_csr_ex),
	.csr_ofs_ex(csr_ofs_ex),
	.csr_uimm_ex(csr_uimm_ex),
	.csr_op2_ex(csr_op2_ex),
	.cmd_ecall_ex(cmd_ecall_ex),
	.cmd_ebreak_ex(cmd_ebreak_ex),
	.cmd_uret_ex(cmd_uret_ex),
	.cmd_sret_ex(cmd_sret_ex),
	.cmd_mret_ex(cmd_mret_ex),
	.cmd_wfi_ex(cmd_wfi_ex),
	.illegal_ops_ex(illegal_ops_ex),
	.rd_adr_ex(rd_adr_ex),
	.wbk_rd_reg_ex(wbk_rd_reg_ex),
	.hit_rs1_idex_ex(hit_rs1_idex_ex),
	.hit_rs1_idma_ex(hit_rs1_idma_ex),
	.hit_rs1_idwb_ex(hit_rs1_idwb_ex),
	.nohit_rs1_ex(nohit_rs1_ex),
	.hit_rs2_idex_ex(hit_rs2_idex_ex),
	.hit_rs2_idma_ex(hit_rs2_idma_ex),
	.hit_rs2_idwb_ex(hit_rs2_idwb_ex),
	.nohit_rs2_ex(nohit_rs2_ex),
	.wbk_data_wb(wbk_data_wb),
	.wbk_data_wb2(wbk_data_wb2),
	.cmd_ld_ma(cmd_ld_ma),
	.cmd_st_ma(cmd_st_ma),
	.rd_adr_ma(rd_adr_ma),
	.rd_data_ma(rd_data_ma),
	.wbk_rd_reg_ma(wbk_rd_reg_ma),
	.st_data_ma(st_data_ma),
	.ldst_code_ma(ldst_code_ma),
	.jmp_adr_ex(jmp_adr_ex),
	.jmp_condition_ex(jmp_condition_ex),
	.ecall_condition_ex(ecall_condition_ex),
	.csr_mtvec_ex(csr_mtvec_ex),
	.csr_mepc_ex(csr_mepc_ex),
	.csr_sepc_ex(csr_sepc_ex),
    .g_interrupt(g_interrupt),
    .post_jump_cmd_cond(post_jump_cmd_cond),
    .g_interrupt_priv(g_interrupt_priv),
    .g_current_priv(g_current_priv),
    .g_exception(g_exception),
    .csr_meie(csr_meie),
    .csr_mtie(csr_mtie),
    .csr_msie(csr_msie),
	.jmp_purge_ma(jmp_purge_ma),
	.stall(stall),
	.rst_pipe(rst_pipe_ex)
	);

ma_stage #(.DWIDTH(DWIDTH)) ma_stage (
	.clk(clk),
	.rst_n(rst_n),
	.cmd_ld_ma(cmd_ld_ma),
	.cmd_st_ma(cmd_st_ma),
	.rd_adr_ma(rd_adr_ma),
	.rd_data_ma(rd_data_ma),
	.wbk_rd_reg_ma(wbk_rd_reg_ma),
	.st_data_ma(st_data_ma),
	.ldst_code_ma(ldst_code_ma),
	.cmd_ld_wb(cmd_ld_wb),
	.ld_code_wb(ld_code_wb),
	.rd_adr_wb(rd_adr_wb),
	.rd_data_wb(rd_data_wb),
	.wbk_rd_reg_wb(wbk_rd_reg_wb),
	.ld_data_wb(ld_data_wb),
	.d_ram_radr(d_ram_radr),
	.d_ram_rdata(d_ram_rdata),
	.d_ram_wadr(d_ram_wadr),
	.d_ram_wdata(d_ram_wdata),
	.d_ram_wen(d_ram_wen),
	.d_read_sel(d_read_sel),
	.dma_io_we(dma_io_we),
	.dma_io_wadr(dma_io_wadr),
	.dma_io_wdata(dma_io_wdata),
	.dma_io_radr(dma_io_radr),
	.dma_io_rdata(dma_io_rdata),
	.dma_we_ma(dma_we_ma),
	.dataram_wadr_ma(dataram_wadr_ma),
	.dataram_wdata_ma(dataram_wdata_ma),
	.dma_re_ma(dma_re_ma),
	.dataram_radr_ma(dataram_radr_ma),
	.dataram_rdata_wb(dataram_rdata_wb),
	.stall(stall),
	.stall_1shot(stall_1shot),
	.stall_dly(stall_dly),
	.rst_pipe(rst_pipe)
	);

wb_stage wb_stage (
	.clk(clk),
	.rst_n(rst_n),
	.cmd_ld_wb(cmd_ld_wb),
	.ld_code_wb(ld_code_wb),
	.rd_data_wb(rd_data_wb),
	.ld_data_wb(ld_data_wb),
	.wbk_data_wb(wbk_data_wb),
	.wbk_data_wb2(wbk_data_wb2),
	.stall(stall),
	.rst_pipe(rst_pipe_wb)
	);

forwarding forwarding (
	.clk(clk),
	.rst_n(rst_n),
	.inst_rs1_id(inst_rs1_id),
	.inst_rs1_valid(inst_rs1_valid),
	.inst_rs2_id(inst_rs2_id),
	.inst_rs2_valid(inst_rs2_valid),
	.rd_adr_ex(rd_adr_ex),
	.wbk_rd_reg_ex(wbk_rd_reg_ex),
	.cmd_ld_ex(cmd_ld_ex),
	.rd_adr_ma(rd_adr_ma),
	.wbk_rd_reg_ma(wbk_rd_reg_ma),
	.rd_adr_wb(rd_adr_wb),
	.wbk_rd_reg_wb(wbk_rd_reg_wb),
	.hit_rs1_idex_ex(hit_rs1_idex_ex),
	.hit_rs1_idma_ex(hit_rs1_idma_ex),
	.hit_rs1_idwb_ex(hit_rs1_idwb_ex),
	.nohit_rs1_ex(nohit_rs1_ex),
	.hit_rs2_idex_ex(hit_rs2_idex_ex),
	.hit_rs2_idma_ex(hit_rs2_idma_ex),
	.hit_rs2_idwb_ex(hit_rs2_idwb_ex),
	.nohit_rs2_ex(nohit_rs2_ex),
	.stall_ld(stall_ld),
	.stall_ld_ex(stall_ld_ex),
	.stall(stall),
	.rst_pipe(rst_pipe)
	);

interrupter interrupter (
	.clk(clk),
	.rst_n(rst_n),
	.interrupt_0(interrupt_0),
	.csr_meie(csr_meie),
	.g_interrupt(g_interrupt)
	);

dma #(.DWIDTH(DWIDTH)) dma (
	.clk(clk),
	.rst_n(rst_n),
	.dma_io_we(dma_io_we),
	.dma_io_wadr(dma_io_wadr),
	.dma_io_wdata(dma_io_wdata),
	.dma_io_radr(dma_io_radr),
	.dma_io_rdata_in(dma_io_rdata_in),
	.dma_io_rdata(dma_io_rdata),
	.dma_we_ma(dma_we_ma),
	.dataram_wadr_ma(dataram_wadr_ma),
	.dataram_wdata_ma(dataram_wdata_ma),
	.dma_re_ma(dma_re_ma),
	.dataram_radr_ma(dataram_radr_ma),
	.dataram_rdata_wb(dataram_rdata_wb),
	.ibus_ren(ibus_ren),
	.ibus_radr(ibus_radr),
	.ibus32_rdata(ibus32_rdata),
	.ibus_wen(ibus_wen),
	.ibus_wadr(ibus_wadr),
	.ibus32_wdata(ibus32_wdata),
	.rst_pipe(rst_pipe)
	);

endmodule

