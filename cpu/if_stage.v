/*
 * My RISC-V RV32I CPU
 *   CPU Instruction Fetch Stage Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
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
	// from monitor
	//output [11:2] inst_radr_if,
	//input [31:0] inst_rdata_id,	
	input [11:2] i_ram_radr,
	output [31:0] i_ram_rdata,
	input [11:2] i_ram_wadr,
	input [31:0] i_ram_wdata,
	input i_ram_wen,
	input i_read_sel,

	// other place
	input cpu_start,
	input [31:2] start_adr,
	input stall,
	input stall_1shot,
	input stall_dly,
	input rst_pipe
	);

// resources
// PC

reg [31:2] pc_if;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		pc_if <= 30'd0;
	else if (cpu_start)
		pc_if <= start_adr;
	else if (stall)
		pc_if <= pc_if;	
	else if (jmp_condition_ex)
		pc_if <= jmp_adr_ex;
	else
		pc_if <= pc_if + 30'd1;
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		pc_id <= 30'd0;
	else
		pc_id <= pc_if;
end


// instruction RAM

wire [9:0] inst_radr_if; // input
wire [31:0] inst_rdata_id; // output
wire [11:2] iram_radr;

assign inst_radr_if = pc_if[11:2]; // depend on size of iram
assign iram_radr = i_read_sel ? i_ram_radr : pc_if[11:2] ;
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
	else if (stall_1shot)
        inst_roll <= inst_rdata_id;
end

assign inst_id = stall_dly ? inst_roll : inst_rdata_id;


endmodule