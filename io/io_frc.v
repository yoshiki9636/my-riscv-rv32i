/*
 * My RISC-V RV32I CPU
 *   Free Run Counter Module for Timer
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2025 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module io_frc(
	input clk,
	input rst_n,
	// from/to IO bus

    input dma_io_we,
    input [15:2] dma_io_wadr,
    input [31:0] dma_io_wdata,
    input [15:2] dma_io_radr,
    input dma_io_radr_en,
    input [31:0] dma_io_rdata_in,
    output [31:0] dma_io_rdata,

	// from/to Execution/CSR
	input csr_mtie,
	output reg frc_cntr_val_leq,
	output interrupt_clear

	);

`define SYS_FRC_VALLO 14'h3E00
`define SYS_FRC_VALHI 14'h3E01
`define SYS_FRC_CMPLO 14'h3E02
`define SYS_FRC_CMPHI 14'h3E03
`define SYS_FRC_CNTRL 14'h3E04
// temporary for interrupt clear
`define SYS_INT_CLEAR 14'h3E80

wire we_frc_vallo = dma_io_we      & (dma_io_wadr == `SYS_FRC_VALLO);
wire re_frc_vallo = dma_io_radr_en & (dma_io_wadr == `SYS_FRC_VALLO);

wire we_frc_valhi = dma_io_we      & (dma_io_wadr == `SYS_FRC_VALHI);
wire re_frc_valhi = dma_io_radr_en & (dma_io_wadr == `SYS_FRC_VALHI);

wire we_frc_cmplo = dma_io_we      & (dma_io_wadr == `SYS_FRC_CMPLO);
wire re_frc_cmplo = dma_io_radr_en & (dma_io_wadr == `SYS_FRC_CMPLO);

wire we_frc_cmphi = dma_io_we      & (dma_io_wadr == `SYS_FRC_CMPHI);
wire re_frc_cmphi = dma_io_radr_en & (dma_io_wadr == `SYS_FRC_CMPHI);

wire we_frc_cntrl = dma_io_we      & (dma_io_wadr == `SYS_FRC_CNTRL);
wire re_frc_cntrl = dma_io_radr_en & (dma_io_wadr == `SYS_FRC_CNTRL);

wire we_frc_clear = dma_io_we      & (dma_io_wadr == `SYS_INT_CLEAR);

wire run_cntr;
wire frc_cntr_rst;

reg [39:0] frc_cntr_val;

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        frc_cntr_val <= 40'd0 ;
	else if (frc_cntr_rst)
        frc_cntr_val <= 40'd0 ;
	else if (we_frc_vallo)
        frc_cntr_val <= { frc_cntr_val[39:32], dma_io_wdata };
	else if (we_frc_valhi)
        frc_cntr_val <= { dma_io_wdata[7:0], frc_cntr_val[31:0] };
	else if (run_cntr)
		frc_cntr_val <= frc_cntr_val + 40'd1;
end

reg [39:0] frc_cmp_val;

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        frc_cmp_val <= 40'd0 ;
	else if (we_frc_cmplo)
        frc_cmp_val <= { frc_cmp_val[39:32], dma_io_wdata };
	else if (we_frc_cmphi)
        frc_cmp_val <= { dma_io_wdata[7:0], frc_cmp_val[31:0] };
end

reg frc_cntrl_val;

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        frc_cntrl_val <= 1'd0 ;
	else if (we_frc_cntrl)
        frc_cntrl_val <= dma_io_wdata[0];
end

assign run_cntr = frc_cntrl_val;
assign frc_cntr_rst = we_frc_cntrl & dma_io_wdata[1];

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        frc_cntr_val_leq <= 1'd0 ;
	else if (we_frc_cntrl & dma_io_wdata[2])
        frc_cntr_val_leq <= 1'd0 ;
	else if ((frc_cntr_val <= frc_cmp_val) & run_cntr & csr_mtie)
        frc_cntr_val_leq <= 1'd1 ;
end

// for interrupt
assign interrupt_clear = we_frc_clear;

endmodule
