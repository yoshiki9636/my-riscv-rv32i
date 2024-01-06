/*
 * My RISC-V RV32I CPU
 *   Tiny DMA Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2023 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module dma
	#(parameter DWIDTH = 12)
	(
	input clk,
	input rst_n,

	// from io_rw block
	input dma_io_we,
	input [15:2] dma_io_wadr,
	input [31:0] dma_io_wdata,
	input [15:2] dma_io_radr,
	input [31:0] dma_io_rdata_in,
	output [31:0] dma_io_rdata,
	// from/to MA
	output dma_we_ma,
	output [15:2] dataram_wadr_ma,
	output [15:0] dataram_wdata_ma,
	output dma_re_ma,
	output [15:2] dataram_radr_ma,
	input [15:0] dataram_rdata_wb,
	// form/to io bus part
    output ibus_ren,
    output [19:2] ibus_radr,
    input [15:0] ibus32_rdata,
    output ibus_wen,
    output [19:2] ibus_wadr,
    output reg [15:0] ibus32_wdata,

	// reset pipe
	input rst_pipe

	);

// address register
`define SYS_DMA_START 14'h3FF0
`define SYS_DMA_IOSTR 14'h3FF1
`define SYS_DMA_MESTR 14'h3FF2
`define SYS_DMA_DCNTR 14'h3FF3

// read decoder
wire status_re_pre = (dma_io_radr == `SYS_DMA_START);
wire io_start_adr_re_pre = (dma_io_radr == `SYS_DMA_IOSTR);
wire mem_start_adr_re_pre = (dma_io_radr == `SYS_DMA_MESTR);
wire dcntr_re_pre = (dma_io_radr == `SYS_DMA_DCNTR);

reg status_re;
reg io_start_adr_re;
reg mem_start_adr_re;
reg dcntr_re;

reg read_run;
reg write_run;
reg [19:2] io_start_adr;
reg [DWIDTH+1:2] mem_start_adr;
reg [DWIDTH:0] dcntr;
reg [DWIDTH:0] btb_cntr;

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
        status_re <= 1'b0;
        io_start_adr_re <= 1'b0;
        mem_start_adr_re <= 1'b0;
        dcntr_re <= 1'b0;
	end
	else begin
        status_re <= status_re_pre;
        io_start_adr_re <= io_start_adr_re_pre;
        mem_start_adr_re <= mem_start_adr_re_pre;
        dcntr_re <= dcntr_re_pre;
	end
end

assign dma_io_rdata = status_re ? { 16'd0, 14'd0, write_run, read_run } :
					  io_start_adr_re ? { 10'd0, io_start_adr, 2'b00 } :
					  mem_start_adr_re ? { { 30-DWIDTH{1'b0}}, mem_start_adr, 2'b00 } :
					  dcntr_re ? {  { 31-DWIDTH{1'b0}}, dcntr } : dma_io_rdata_in;

// write decoder
// inhibit to write 2'b11 to start regster 
wire read_start_we  = dma_io_we & (dma_io_wadr == `SYS_DMA_START) & ~dma_io_wdata[1] &  dma_io_wdata[0];
wire write_start_we = dma_io_we & (dma_io_wadr == `SYS_DMA_START) &  dma_io_wdata[1] & ~dma_io_wdata[0];
wire io_start_adr_we  = dma_io_we & (dma_io_wadr == `SYS_DMA_IOSTR);
wire mem_start_adr_we  = dma_io_we & (dma_io_wadr == `SYS_DMA_MESTR);
wire dcntr_we  = dma_io_we & (dma_io_wadr == `SYS_DMA_DCNTR);

// registers

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        io_start_adr <= 18'd0;
	else if (rst_pipe)
        io_start_adr <= 18'd0;
	else if (io_start_adr_we)
        io_start_adr <= dma_io_wdata[19:2];
end	

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        mem_start_adr <= { DWIDTH{ 1'b0 }};
	else if (rst_pipe)
        mem_start_adr <= { DWIDTH{ 1'b0 }};
	else if (mem_start_adr_we)
        mem_start_adr <= dma_io_wdata[DWIDTH+1:2];
end

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        dcntr <= { DWIDTH+1{ 1'b0 }};
	else if (rst_pipe)
        dcntr <= { DWIDTH+1{ 1'b0 }};
	else if (dcntr_we)
		dcntr <= dma_io_wdata[DWIDTH:0];
end

// mem -> io read counter
reg read_run_l1;
reg read_run_l2;
//reg read_run_l3;
//reg read_run_l4;

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        read_run <= 1'b0;
	else if (rst_pipe)
        read_run <= 1'b0;
	else if (read_start_we)
        read_run <= 1'b1;
	else if (btb_cntr == { DWIDTH+1{ 1'b0 }})
        read_run <= 1'b0;
end

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
        read_run_l1 <= 1'b0;
        read_run_l2 <= 1'b0;
        //read_run_l3 <= 1'b0;
        //read_run_l4 <= 1'b0;
	end
	else if (rst_pipe) begin
        read_run_l1 <= 1'b0;
        read_run_l2 <= 1'b0;
        //read_run_l3 <= 1'b0;
        //read_run_l4 <= 1'b0;
	end
	else begin
        read_run_l1 <= read_run;
        read_run_l2 <= read_run_l1;
        //read_run_l3 <= read_run_l2;
        //read_run_l4 <= read_run_l3;
	end
end

// io -> mem wirte counter
reg write_run_l1;
reg write_run_l2;

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        write_run <= 1'b0;
	else if (rst_pipe)
        write_run <= 1'b0;
	else if (write_start_we)
        write_run <= 1'b1;
	else if (btb_cntr == { DWIDTH+1{ 1'b0 }})
        write_run <= 1'b0;
end

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n) begin
        write_run_l1 <= 1'b0;
        write_run_l2 <= 1'b0;
	end
	else if (rst_pipe) begin
        write_run_l1 <= 1'b0;
        write_run_l2 <= 1'b0;
	end
	else begin
        write_run_l1 <= write_run;
        write_run_l2 <= write_run_l1;
	end
end

// beck to back access counter

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        btb_cntr <= { DWIDTH+1{ 1'b0 }};
	else if (rst_pipe)
        btb_cntr <= { DWIDTH+1{ 1'b0 }};
	else if (read_start_we | write_start_we)
        btb_cntr <= dcntr;
	else if (btb_cntr == { DWIDTH+1{ 1'b0 }})
        btb_cntr <= { DWIDTH+1{ 1'b0 }};
	else if (read_run | write_run)
		btb_cntr <= btb_cntr - { {DWIDTH{ 1'b0 }}, 1'b1};
end

// mem -> io
// mem destination address counter
reg [DWIDTH-1:0] mem_r_adr;
always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        mem_r_adr <= { DWIDTH{ 1'b0 }};
	else if (write_start_we)
        mem_r_adr <= mem_start_adr;
	else if (write_run)
        mem_r_adr <= mem_r_adr + { {DWIDTH-1{ 1'b0 }}, 1'b1};
end

// io destination address counter
reg [19:2] io_w_adr;
always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        io_w_adr <= 18'd0;
	else if (write_start_we)
        io_w_adr <= io_start_adr;
	else if (write_run_l2)
        io_w_adr <= io_w_adr + 18'd1;
end


// io -> mem
// io source address counter
reg [19:2] io_r_adr;
always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        io_r_adr <= 18'd0;
	else if (read_start_we)
        io_r_adr <= io_start_adr;
	else if (read_run)
        io_r_adr <= io_r_adr + 18'd1;
end

// mem destination address counter
reg [DWIDTH-1:0] mem_w_adr;
always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        mem_w_adr <= { DWIDTH{ 1'b0 }};
	else if (read_start_we)
        mem_w_adr <= mem_start_adr;
	else if (read_run_l2)
        mem_w_adr <= mem_w_adr + { {DWIDTH-1{ 1'b0 }}, 1'b1};
end


// io bus signals
assign ibus_ren = read_run;
assign ibus_wadr = io_w_adr;
assign ibus_wen = write_run_l2;
assign ibus_radr = io_r_adr;

always @ ( posedge clk or negedge rst_n) begin   
	if (~rst_n)
        ibus32_wdata <= 16'd0;
	else
        ibus32_wdata <= dataram_rdata_wb[15:0];
end
assign dataram_wdata_ma = ibus32_rdata;

assign dma_we_ma = read_run_l2;
assign dma_re_ma = write_run;

assign dataram_wadr_ma = { 2'd0, mem_w_adr };
assign dataram_radr_ma = { 2'd0, mem_r_adr };

endmodule
