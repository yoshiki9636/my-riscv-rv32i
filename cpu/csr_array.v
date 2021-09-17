/*
 * My RISC-V RV32I CPU
 *   Control and Status Register Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module csr_array(
	input clk,
	input rst_n,

	// from ID
    input cmd_csr_ex,
    input [11:0] csr_ofs_ex,
	input [4:0] csr_uimm_ex,
	input [2:0] csr_op2_ex,
	input [31:0] rs1_sel,
	output [31:0] csr_rd_data,
	output [31:2] csr_mtvec_ex,
    input cmd_ecall_ex,
	input [31:2] pc_ex,
	input stall
	);

// csr address definition

`define CSR_MSTATUS_ADR 12'h300
`define CSR_MTVEC_ADR 12'h305
`define CSR_MEPC_ADR 12'h341
`define CSR_MCAUSE_ADR 12'h342

// op2 decode
wire immidiate = csr_op2_ex[2];
wire cmd_rw = (csr_op2_ex[1:0] == 2'b01);
wire cmd_rs = (csr_op2_ex[1:0] == 2'b10);
wire cmd_rc = (csr_op2_ex[1:0] == 2'b11);

// address decode

wire adr_mstatus = (csr_ofs_ex == `CSR_MSTATUS_ADR);
wire adr_mtvec = (csr_ofs_ex == `CSR_MTVEC_ADR);
wire adr_mepc = (csr_ofs_ex == `CSR_MEPC_ADR);
wire adr_mcause = (csr_ofs_ex == `CSR_MCAUSE_ADR);

// read data selector
reg [31:0] csr_mstatus;
reg [31:0] csr_mtvec;
reg [31:0] csr_mepc;
reg [31:0] csr_mcause;

wire [31:0] csr_rsel = adr_mstatus ? csr_mstatus :
                       adr_mtvec ? csr_mtvec :
                       adr_mepc ? csr_mepc :
                       adr_mcause ? csr_mcause : 32'd0;

assign csr_rd_data = csr_rsel;

// wirte data selector 
wire [31:0] wdata_rw = immidiate ? { 27'd0, csr_uimm_ex } : rs1_sel;
wire [31:0] wdata_rs = wdata_rw | csr_rsel ;
wire [31:0] wdata_rc = (~wdata_rw) & csr_rsel ;
wire [31:0] wdata_all = cmd_rw ? wdata_rw :
                        cmd_rs ? wdata_rs :
						cmd_rc ? wdata_rc : 32'd0;

// csr registers
// mstatus
// [5] MBE machine level big endian -> little endian: fixed 0
// [4] SBE superviser level big endian -> little endian: fixed 0
always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
		csr_mstatus <= 32'd0;
	end
	else if ((~stall)&(cmd_csr_ex)&(adr_mstatus)) begin
		csr_mstatus <= { wdata_all[31:6], 2'b00, wdata_all[3:0] };
	end
end

// mtvec
always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
		csr_mtvec <= 32'd0;
	end
	else if ((~stall)&(cmd_csr_ex)&(adr_mtvec)) begin
		csr_mtvec <= wdata_all;
	end
end

assign csr_mtvec_ex = csr_mtvec[31:2];

// mepc
// capture PC when ecall occured
always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
		csr_mepc <= 32'd0;
	end
	else if (cmd_ecall_ex) begin
		csr_mepc <= { pc_ex, 2'b00 };
	end
	else if ((~stall)&(cmd_csr_ex)&(adr_mepc)) begin
		csr_mepc <= wdata_all;
	end
end

// mcause
// conditions
wire interrupt_bit = 1'b0; // currently no interrupt
wire [30:0] mcause_code = 31'd11;  // just impliment Machine mode Ecall
wire mcause_write = cmd_ecall_ex;

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
		csr_mcause <= 32'd0;
	end
	else if (mcause_write) begin
		csr_mcause <= { interrupt_bit, mcause_code };
	end
	else if ((~stall)&(cmd_csr_ex)&(adr_mcause)) begin
		csr_mcause <= wdata_all;
	end
end




endmodule
