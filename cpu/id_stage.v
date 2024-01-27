/*
 * My RISC-V RV32I CPU
 *   CPU Instruction Decode Stage Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 * @version		0.2 add part of csr instructions
 */

module id_stage(
	input clk,
	input rst_n,
	// from IF stage
	input [31:0] inst_id,
	input [31:2] pc_id,
	// to EX stage
	output [31:0] rs1_data_ex,
	output [31:0] rs2_data_ex,
	output reg [31:2] pc_ex,

    // control signals
    output reg cmd_lui_ex,
    output reg cmd_auipc_ex,
    output reg [31:12] lui_auipc_imm_ex,
    output reg cmd_ld_ex,
    output reg [11:0] ld_alui_ofs_ex,
    output reg cmd_alui_ex,
    output reg cmd_alui_shamt_ex,
    output reg cmd_alu_ex,
    output reg cmd_alu_add_ex,
    output reg cmd_alu_sub_ex,
    output reg [2:0] alu_code_ex,
    output reg [4:0] alui_shamt_ex,
    output reg cmd_st_ex,
    output reg [11:0] st_ofs_ex,
    output reg cmd_jal_ex,
    output reg [20:1] jal_ofs_ex,
    output reg cmd_jalr_ex,
    output reg [11:0] jalr_ofs_ex,
    output reg cmd_br_ex,
    output reg [12:1] br_ofs_ex,
    output reg cmd_fence_ex,
    output reg cmd_fencei_ex,
    output reg [3:0] fence_succ_ex,
    output reg [3:0] fence_pred_ex,
    output reg cmd_sfence_ex,
    output reg cmd_csr_ex,
    output reg [11:0] csr_ofs_ex,
	output reg [4:0] csr_uimm_ex,
	output reg [2:0] csr_op2_ex,
    output reg cmd_ecall_ex,
    output reg cmd_ebreak_ex,
    output reg cmd_uret_ex,
    output reg cmd_sret_ex,
    output reg cmd_mret_ex,
    output reg cmd_wfi_ex,
	output reg [4:0] rd_adr_ex,
	output reg wbk_rd_reg_ex,
    output reg illegal_ops_ex,
	// from EX
	input jmp_purge_ma,
	// from WB
	input [4:0] rd_adr_wb,
	input wbk_rd_reg_wb,
	input [31:0] wbk_data_wb,
	// to Forwarding
	output [4:0] inst_rs1_id,
	output [4:0] inst_rs2_id,
	output inst_rs1_valid,
	output inst_rs2_valid,
	// stall
	input stall,
	input stall_1shot,
	input stall_dly,
	input stall_ld,
	input stall_ld_ex,
	input rst_pipe

	);

// decoder
// bit slice

wire [1:0]   inst_set = inst_id[1:0];
wire [6:2]   inst_op1 = inst_id[6:2];
wire [11:7]  inst_rd  = inst_id[11:7];
wire [14:12] inst_op2 = inst_id[14:12];
wire [19:15] inst_rs1 = inst_id[19:15];
wire [19:15] inst_uimm = inst_id[19:15];
wire [24:20] inst_rs2 = inst_id[24:20];
wire [26:25] inst_op5 = inst_id[26:25];
wire [31:27] inst_op3 = inst_id[31:27];
wire [31:12] inst_imm_31_12 = inst_id[31:12];
wire [20:1]  inst_ofs_20_1 = { inst_id[31], inst_id[19:12], inst_id[20], inst_id[30:21] };
wire [11:0]  inst_imm_11_0 = inst_id[31:20];
wire [11:0]  inst_ofs_11_0_l = inst_id[31:20];
wire [24:20] inst_shamt = inst_id[24:20];
wire         inst_zero_26 = inst_id[26];
wire [26:25] inst_zero_26_25 = inst_id[26:25];
wire [23:20] inst_succ = inst_id[23:20];
wire [27:24] inst_pred = inst_id[27:24];
wire [31:28] inst_zero_31_28 = inst_id[31:28];
wire [19:15] inst_zero_19_15 = inst_id[19:15];
wire [11:7]  inst_zero_11_7  = inst_id[11:7];
wire [24:20] inst_op4 = inst_id[24:20];
wire [11:0]  inst_ofs_11_0_s = { inst_id[31:25], inst_id[11:7] };
wire [12:1]  inst_ofs_12_1 = { inst_id[31], inst_id[7], inst_id[30:25], inst_id[11:8]};

// decode opecode and zero

wire dc_notc = (inst_set == 2'b11);
wire dc_zero_26 = (inst_zero_26 == 1'b0);
wire dc_zero_26_25 = (inst_zero_26_25 == 2'd0);
wire dc_zero_31_28 = (inst_zero_31_28 == 4'd0);
wire dc_zero_19_15 = (inst_zero_19_15 == 5'd0);
wire dc_zero_11_7  = (inst_zero_11_7  == 5'd0);

wire dc_pred = (inst_pred == 4'd0);
wire dc_succ = (inst_succ == 4'd0);

//op1

function [10:0] op1_decoder;
input [4:0] inst_op1;
begin
	case(inst_op1)
		5'b01101: op1_decoder = 11'b000_0000_0001;
		5'b00101: op1_decoder = 11'b000_0000_0010;
		5'b11011: op1_decoder = 11'b000_0000_0100;
		5'b00100: op1_decoder = 11'b000_0000_1000;
		5'b11100: op1_decoder = 11'b000_0001_0000;
		5'b00000: op1_decoder = 11'b000_0010_0000;
		5'b01100: op1_decoder = 11'b000_0100_0000;
		5'b00011: op1_decoder = 11'b000_1000_0000;
		5'b11000: op1_decoder = 11'b001_0000_0000;
		5'b01000: op1_decoder = 11'b010_0000_0000;
		5'b11001: op1_decoder = 11'b100_0000_0000;
		default : op1_decoder = 11'b00_0000_0000;
	endcase
end
endfunction

wire [10:0] dc_op1 = op1_decoder( inst_op1 );

wire dc_op1_01101 = dc_op1[0];
wire dc_op1_00101 = dc_op1[1];
wire dc_op1_11011 = dc_op1[2];
wire dc_op1_00100 = dc_op1[3];
wire dc_op1_11100 = dc_op1[4];
wire dc_op1_00000 = dc_op1[5];
wire dc_op1_01100 = dc_op1[6];
wire dc_op1_00011 = dc_op1[7];
wire dc_op1_11000 = dc_op1[8];
wire dc_op1_01000 = dc_op1[9];
wire dc_op1_11001 = dc_op1[10];

// op2

function [7:0] op2_decoder;
input [2:0] inst_op2;
begin
	case(inst_op2)
		3'b000: op2_decoder = 8'b0000_0001;
		3'b001: op2_decoder = 8'b0000_0010;
		3'b010: op2_decoder = 8'b0000_0100;
		3'b011: op2_decoder = 8'b0000_1000;
		3'b100: op2_decoder = 8'b0001_0000;
		3'b101: op2_decoder = 8'b0010_0000;
		3'b110: op2_decoder = 8'b0100_0000;
		3'b111: op2_decoder = 8'b1000_0000;
		default: op2_decoder = 8'b0000_0000;
	endcase
end
endfunction

wire [7:0] dc_op2 = op2_decoder( inst_op2 );

wire dc_op2_000 = dc_op2[0];
wire dc_op2_001 = dc_op2[1];
wire dc_op2_010 = dc_op2[2];
wire dc_op2_011 = dc_op2[3];
wire dc_op2_100 = dc_op2[4];
wire dc_op2_101 = dc_op2[5];
wire dc_op2_110 = dc_op2[6];
wire dc_op2_111 = dc_op2[7];

// op3

function [3:0] op3_decoder;
input [4:0] inst_op3;
begin
	case(inst_op3)
		5'b00000: op3_decoder = 4'b0001;
		5'b01000: op3_decoder = 4'b0010;
		5'b00010: op3_decoder = 4'b0100;
		5'b00110: op3_decoder = 4'b1000;
		default : op3_decoder = 4'b0000;
	endcase
end
endfunction

wire [3:0] dc_op3 = op3_decoder( inst_op3 );

wire dc_op3_00000 = dc_op3[0];
wire dc_op3_01000 = dc_op3[1];
wire dc_op3_00010 = dc_op3[2];
wire dc_op3_00110 = dc_op3[3];

// op4
function [3:0] op4_decoder;
input [4:0] inst_op4;
begin
	case(inst_op4)
		5'b00000: op4_decoder = 4'b0001;
		5'b00001: op4_decoder = 4'b0010;
		5'b00010: op4_decoder = 4'b0100;
		5'b00101: op4_decoder = 4'b1000;
		default : op4_decoder = 4'b0000;
	endcase
end
endfunction

wire [3:0] dc_op4 = op4_decoder( inst_op4 );

wire dc_op4_00000 = dc_op4[0];
wire dc_op4_00001 = dc_op4[1];
wire dc_op4_00010 = dc_op4[2];
wire dc_op4_00101 = dc_op4[3];

// op5

wire dc_op5_01 = (inst_op5 == 2'b01);

// microcode signals

// load, auipc
wire cmd_lui_id = dc_op1_01101 & dc_notc;
wire cmd_auipc_id = dc_op1_00101 & dc_notc;
wire [31:12] lui_auipc_imm_id = inst_imm_31_12;

wire cmd_ld_id = dc_op1_00000 & dc_notc;
//wire [2:0] ld_bw_id = inst_op2;
wire [11:0] ld_ofs_id = inst_ofs_11_0_l;

// ALU immediate, rs2
wire cmd_alui_id = dc_op1_00100 & dc_notc & ~( dc_op2_001 | dc_op2_101 );
wire cmd_alui_shamt_id = dc_op1_00100 & dc_notc & dc_zero_26 & ( dc_op2_001 | dc_op2_101 );
wire cmd_alu_id = dc_op1_01100 & dc_notc & dc_zero_26_25;
wire cmd_alu_add_id = dc_op3_00000;
wire cmd_alu_sub_id = dc_op3_01000;

wire [2:0] alu_code_id = inst_op2;

wire [11:0] alui_imm_id = inst_imm_11_0;
wire [4:0] alui_shamt_id = inst_shamt;

// store
wire cmd_st_id = dc_op1_01000 & dc_notc & ~jmp_purge_ma;
wire [11:0] st_ofs_id = inst_ofs_11_0_s;

// jump jal jalr branch
wire cmd_jal_id = dc_op1_11011 & dc_notc & ~jmp_purge_ma;
wire [20:1] jal_ofs_id = inst_ofs_20_1;

wire cmd_jalr_id = dc_op1_11001 & dc_op2_000 & dc_notc & ~jmp_purge_ma;
wire [11:0] jalr_ofs_id = inst_ofs_11_0_l;

wire cmd_br_id = dc_op1_11000 & dc_notc & ~jmp_purge_ma;
wire [12:1] br_ofs_id = inst_ofs_12_1;

// fence
wire cmd_fence_id = dc_op1_00011 & dc_op2_000 & dc_notc & dc_zero_31_28 & dc_zero_19_15 & dc_zero_11_7;
wire cmd_fencei_id = dc_op1_00011 & dc_op2_001 & dc_notc & dc_zero_31_28 & dc_pred & dc_succ & dc_zero_19_15 & dc_zero_11_7;
wire [3:0] fence_succ_id = inst_succ;
wire [3:0] fence_pred_id = inst_pred;

// sfence
wire cmd_sfence_id = dc_op1_11100 & dc_op2_000 & dc_notc & dc_op3_00010 & dc_op5_01;

// csr
wire cmd_csr_id = dc_op1_11100 & ~dc_op2_000 & dc_notc;
wire [11:0] csr_ofs_id = inst_ofs_11_0_l;
wire [4:0] csr_uimm_id = inst_uimm;
// need to see dc_op2_001 - dc_op2_111
wire [2:0] csr_op2_id = inst_op2;

// ecall
wire cmd_ec_id  = dc_op1_11100 &  dc_op2_000 & dc_notc & dc_zero_26_25 & dc_zero_19_15 & dc_zero_11_7;
wire cmd_ecall_id  = cmd_ec_id & dc_op3_00000 & dc_op4_00000;
wire cmd_ebreak_id = cmd_ec_id & dc_op3_00000 & dc_op4_00001;
wire cmd_uret_id   = cmd_ec_id & dc_op3_00000 & dc_op4_00010;
wire cmd_sret_id   = cmd_ec_id & dc_op3_00010 & dc_op4_00010;
wire cmd_mret_id   = cmd_ec_id & dc_op3_00110 & dc_op4_00010;
wire cmd_wfi_id    = cmd_ec_id & dc_op3_00010 & dc_op4_00101;

// nop command
wire cmd_nop = (inst_id == 32'h0000_0013);
// all command except nop
wire cmd_all_except_nop =
	cmd_lui_id | cmd_auipc_id | cmd_ld_id | cmd_alui_id | cmd_alui_shamt_id
	| cmd_alu_id | cmd_alu_add_id | cmd_alu_sub_id | cmd_st_id | cmd_jal_id
	| cmd_jalr_id | cmd_br_id | cmd_fence_id | cmd_fencei_id | cmd_sfence_id
	| cmd_csr_id | cmd_ec_id | cmd_ecall_id | cmd_ebreak_id | cmd_uret_id  
	| cmd_sret_id | cmd_mret_id | cmd_wfi_id;

wire illegal_ops_id = ~(cmd_nop | cmd_all_except_nop) & ~jmp_purge_ma;

// destination register number
wire [4:0] rd_adr_id = inst_rd;

// destination register write back signal

wire wbk_rd_reg_id = ~(cmd_st_id | cmd_br_id) & dc_notc & ~jmp_purge_ma;

// for forwarding

assign inst_rs1_id = inst_rs1;
assign inst_rs2_id = inst_rs2;

assign inst_rs1_valid = cmd_alui_id | cmd_alui_shamt_id | cmd_alu_id | cmd_csr_id |
                        cmd_sfence_id | cmd_ld_id | cmd_st_id | cmd_jalr_id | cmd_br_id;

assign inst_rs2_valid = cmd_alu_id | cmd_st_id | cmd_br_id;

// zero register

wire rs1_zero = ( inst_rs1 == 5'd0);
wire rs2_zero = ( inst_rs2 == 5'd0);
reg rs1_zero_ex;
reg rs2_zero_ex;

always @ (posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
        rs1_zero_ex <= 1'b1;
        rs2_zero_ex <= 1'b1;
	end
	else if (rst_pipe) begin
        rs1_zero_ex <= 1'b1;
        rs2_zero_ex <= 1'b1;
	end
	else if (~stall) begin
		rs1_zero_ex <= rs1_zero;
		rs2_zero_ex <= rs2_zero;
	end
end

wire [31:0] ram_data1;
wire [31:0] ram_data2;


// register file

rf_2r1w rf_2r1w (
	.clk(clk),
	.ram_radr1(inst_rs1),
	.ram_rdata1(ram_data1),
	.ram_radr2(inst_rs2),
	.ram_rdata2(ram_data2),
	.ram_wadr(rd_adr_wb),
	.ram_wdata(wbk_data_wb),
	.ram_wen(wbk_rd_reg_wb)
	);

// roll back
wire [31:0] rs1_data_st = ram_data1 & { 32{ ~rs1_zero_ex }};
wire [31:0] rs2_data_st = ram_data2 & { 32{ ~rs2_zero_ex }};

reg [31:0] rs1_data_roll;
reg [31:0] rs2_data_roll;

always @ (posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
        rs1_data_roll <= 32'd0;
        rs2_data_roll <= 32'd0;
	end
	else if (rst_pipe) begin
        rs1_data_roll <= 32'd0;
        rs2_data_roll <= 32'd0;
	end
	else if (stall_1shot | stall_ld) begin
        rs1_data_roll <= rs1_data_st;
        rs2_data_roll <= rs2_data_st;
	end
end

assign rs1_data_ex = (stall_dly | stall_ld_ex) ? rs1_data_roll : rs1_data_st;
assign rs2_data_ex = (stall_dly | stall_ld_ex) ? rs2_data_roll : rs2_data_st;

// FF to EX stage

always @ (posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
        cmd_lui_ex <= 1'b0;
        cmd_auipc_ex <= 1'b0;
        lui_auipc_imm_ex <= 20'd0;
        cmd_ld_ex <= 1'b0;
        //ld_bw_ex <= 3'd0;
        ld_alui_ofs_ex <= 12'd0;
        cmd_alui_ex <= 1'b0;
        cmd_alui_shamt_ex <= 1'b0;
        cmd_alu_ex <= 1'b0;
        cmd_alu_add_ex <= 1'b0;
        cmd_alu_sub_ex <= 1'b0;
        alu_code_ex <= 3'd0;
        //alui_imm_ex <= 12'd0;
        alui_shamt_ex <= 5'd0;
        cmd_st_ex <= 1'b0;
        st_ofs_ex <= 12'd0;
        cmd_jal_ex <= 1'b0;
        jal_ofs_ex <= 20'b0;
        cmd_jalr_ex <= 1'b0;
        jalr_ofs_ex <= 12'd0;
        cmd_br_ex <= 1'b0;
        br_ofs_ex <= 12'd0;
        cmd_fence_ex <= 1'b0;
        cmd_fencei_ex <= 1'b0;
        fence_succ_ex <= 5'd0;
        fence_pred_ex <= 5'd0;
        cmd_sfence_ex <= 1'b0;
        cmd_csr_ex <= 1'b0;
        csr_ofs_ex <= 12'd0;
		csr_uimm_ex <= 5'd0;
		csr_op2_ex <= 3'd0;
        cmd_ecall_ex <= 1'b0;
        cmd_ebreak_ex <= 1'b0;
        cmd_uret_ex <= 1'b0;
        cmd_sret_ex <= 1'b0;
        cmd_mret_ex <= 1'b0;
        cmd_wfi_ex <= 1'b0;
		illegal_ops_ex <= 1'b0;
		rd_adr_ex <= 5'd0;
		wbk_rd_reg_ex <= 1'b0;
		pc_ex <= 30'd0;
     end
	else if (rst_pipe) begin
        cmd_lui_ex <= 1'b0;
        cmd_auipc_ex <= 1'b0;
        lui_auipc_imm_ex <= 20'd0;
        cmd_ld_ex <= 1'b0;
        //ld_bw_ex <= 3'd0;
        ld_alui_ofs_ex <= 12'd0;
        cmd_alui_ex <= 1'b0;
        cmd_alui_shamt_ex <= 1'b0;
        cmd_alu_ex <= 1'b0;
        cmd_alu_add_ex <= 1'b0;
        cmd_alu_sub_ex <= 1'b0;
        alu_code_ex <= 3'd0;
        //alui_imm_ex <= 12'd0;
        alui_shamt_ex <= 5'd0;
        cmd_st_ex <= 1'b0;
        st_ofs_ex <= 12'd0;
        cmd_jal_ex <= 1'b0;
        jal_ofs_ex <= 20'b0;
        cmd_jalr_ex <= 1'b0;
        jalr_ofs_ex <= 12'd0;
        cmd_br_ex <= 1'b0;
        br_ofs_ex <= 12'd0;
        cmd_fence_ex <= 1'b0;
        cmd_fencei_ex <= 1'b0;
        fence_succ_ex <= 5'd0;
        fence_pred_ex <= 5'd0;
        cmd_sfence_ex <= 1'b0;
        cmd_csr_ex <= 1'b0;
        csr_ofs_ex <= 12'd0;
		csr_uimm_ex <= 5'd0;
		csr_op2_ex <= 3'd0;
        cmd_ecall_ex <= 1'b0;
        cmd_ebreak_ex <= 1'b0;
        cmd_uret_ex <= 1'b0;
        cmd_sret_ex <= 1'b0;
        cmd_mret_ex <= 1'b0;
        cmd_wfi_ex <= 1'b0;
		illegal_ops_ex <= 1'b0;
		rd_adr_ex <= 5'd0;
		wbk_rd_reg_ex <= 1'b0;
		pc_ex <= 30'd0;
     end
     else if (~stall) begin
        cmd_lui_ex <= cmd_lui_id & ~stall_ld;
        cmd_auipc_ex <= cmd_auipc_id & ~stall_ld;
        lui_auipc_imm_ex <= lui_auipc_imm_id;
        cmd_ld_ex <= cmd_ld_id & ~stall_ld;
        //ld_bw_ex <= ld_bw_id;
        ld_alui_ofs_ex <= ld_ofs_id;
        cmd_alui_ex <= cmd_alui_id & ~stall_ld;
        cmd_alui_shamt_ex <= cmd_alui_shamt_id & ~stall_ld;
        cmd_alu_ex <= cmd_alu_id & ~stall_ld;
        cmd_alu_add_ex <= cmd_alu_add_id & ~stall_ld;
        cmd_alu_sub_ex <= cmd_alu_sub_id & ~stall_ld;
        alu_code_ex <= alu_code_id;
        //alui_imm_ex <= alui_imm_id;
        alui_shamt_ex <= alui_shamt_id;
        cmd_st_ex <= cmd_st_id & ~stall_ld;
        st_ofs_ex <= st_ofs_id;
        cmd_jal_ex <= cmd_jal_id & ~stall_ld;
        jal_ofs_ex <= jal_ofs_id;
        cmd_jalr_ex <= cmd_jalr_id & ~stall_ld;
        jalr_ofs_ex <= jalr_ofs_id;
        cmd_br_ex <= cmd_br_id & ~stall_ld;
        br_ofs_ex <= br_ofs_id;
        cmd_fence_ex <= cmd_fence_id & ~stall_ld;
        cmd_fencei_ex <= cmd_fencei_id & ~stall_ld;
        fence_succ_ex <= fence_succ_id;
        fence_pred_ex <= fence_pred_id;
        cmd_sfence_ex <= cmd_sfence_id & ~stall_ld;
        cmd_csr_ex <= cmd_csr_id & ~stall_ld;
        csr_ofs_ex <= csr_ofs_id;
		csr_uimm_ex <= csr_uimm_id;
		csr_op2_ex <= csr_op2_id;
        cmd_ecall_ex <= cmd_ecall_id & ~stall_ld;
        cmd_ebreak_ex <= cmd_ebreak_id & ~stall_ld;
        cmd_uret_ex <= cmd_uret_id & ~stall_ld;
        cmd_sret_ex <= cmd_sret_id & ~stall_ld;
        cmd_mret_ex <= cmd_mret_id & ~stall_ld;
        cmd_wfi_ex <= cmd_wfi_id & ~stall_ld;
		illegal_ops_ex <= illegal_ops_id & ~stall_ld;
		rd_adr_ex <= rd_adr_id;
		wbk_rd_reg_ex <= wbk_rd_reg_id;
		pc_ex <= pc_id;
    end
end

endmodule
