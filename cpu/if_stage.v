/*
 * My RISC-V RV32I CPU
 *   CPU Instruction Fetch Stage Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 * @version		0.2 add ecall
 */

module if_stage(
	input clk,
	input rst_n,
	// to ID stage
	output [31:0] inst_id,
	output reg [31:2] pc_id,
	// from EX stage : jmp/br
	input jmp_condition_ex,
	input [31:2] jmp_adr_ex,
	input ecall_condition_ex,
	input [31:2] csr_mtvec_ex,
	input cmd_mret_ex,
	input [31:2] csr_mepc_ex,
	input cmd_sret_ex,
	input [31:2] csr_sepc_ex,
	input cmd_uret_ex,
    input g_interrupt,
	output post_jump_cmd_cond,
	input g_exception,
	// from monitor
	//output [11:2] inst_radr_if,
	//input [31:0] inst_rdata_id,	
	input [13:2] i_ram_radr,
	output [31:0] i_ram_rdata,
	input [13:2] i_ram_wadr,
	input [31:0] i_ram_wdata,
	input i_ram_wen,
	input i_read_sel,

	// other place
	input cpu_start,
	input [31:2] start_adr,
	input stall,
	input stall_1shot,
	input stall_dly,
	input stall_ld,
	input stall_ld_ex,
	input rst_pipe,
	output [31:0] pc_data
	);

// resources
// PC

reg [31:2] pc_if;
reg post_intr_ecall_exception;
wire intr_ecall_exception = ecall_condition_ex | g_interrupt | g_exception ;
wire jump_cmd_cond = jmp_condition_ex | cmd_mret_ex | cmd_sret_ex | cmd_uret_ex;

wire jmp_cond = intr_ecall_exception | ( jump_cmd_cond & ~post_intr_ecall_exception);
wire [31:2] jmp_adr = intr_ecall_exception ? csr_mtvec_ex :
                      cmd_mret_ex ? csr_mepc_ex :
                      cmd_sret_ex ? csr_sepc_ex : jmp_adr_ex;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		pc_if <= 30'd0;
	else if (cpu_start)
		pc_if <= start_adr;
	else if (stall | stall_ld)
		pc_if <= pc_if;	
	else if (jmp_cond)
		pc_if <= jmp_adr;
	else
		pc_if <= pc_if + 30'd1;
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		pc_id <= 30'd0;
	else
		pc_id <= pc_if;
end

assign pc_data = {pc_if, 2'd0};

// instruction RAM

wire [11:0] inst_radr_if; // input
wire [31:0] inst_rdata_id; // output
wire [13:2] iram_radr;

assign inst_radr_if = pc_if[13:2]; // depend on size of iram
assign iram_radr = i_read_sel ? i_ram_radr : pc_if[13:2] ;
assign i_ram_rdata = inst_rdata_id;

inst_1r1w inst_1r1w (
	.clk(clk),
	.ram_radr(iram_radr),
	.ram_rdata(inst_rdata_id),
	.ram_wadr(i_ram_wadr),
	.ram_wdata(i_ram_wdata),
	.ram_wen(i_ram_wen)
	);

reg [31:0] inst_roll;

always @ (posedge clk or negedge rst_n) begin   
	if (~rst_n)
        inst_roll <= 32'd0;
	else if (rst_pipe)
        inst_roll <= 32'd0;	
	else if (stall_1shot | stall_ld)
        inst_roll <= inst_rdata_id;
end

assign inst_id = (stall_dly | stall_ld_ex) ? inst_roll : inst_rdata_id;

// post interrupt / ecall timing
always @ (posedge clk or negedge rst_n) begin   
	if (~rst_n)
        post_intr_ecall_exception <= 1'b0;
	else
        post_intr_ecall_exception <= intr_ecall_exception;
end

// post cump command condition
reg post_jump_cmd_c;

always @ (posedge clk or negedge rst_n) begin   
	if (~rst_n)
        post_jump_cmd_c <= 1'b0;
	else
        post_jump_cmd_c <= jump_cmd_cond;
end

assign post_jump_cmd_cond = post_jump_cmd_c;


endmodule
