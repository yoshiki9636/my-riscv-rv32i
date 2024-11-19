/*
 * My RISC-V RV32I CPU
 *   FPGA Top Module for Tang Premier
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

//`define TANG_PRIMER
`define ARTY_A7

module fpga_top
	#(parameter DWIDTH = 15)
	(
	input clkin,
	input rst_n,
	input rx,
	output tx,
	input interrupt_0,
	output [2:0] rgb_led,
	output [2:0] rgb_led1,
	output [2:0] rgb_led2,
	output [2:0] rgb_led3

	);

wire [DWIDTH+1:2] d_ram_radr;
wire [DWIDTH+1:2] d_ram_wadr;
wire [31:0] d_ram_rdata;
wire [31:0] d_ram_wdata;
wire d_ram_wen;
wire d_read_sel;

wire [13:2] i_ram_radr;
wire [13:2] i_ram_wadr;
wire [31:0] i_ram_rdata;
wire [31:0] i_ram_wdata;
wire i_ram_wen;
wire i_read_sel;

wire dma_io_we;
wire [15:2] dma_io_wadr;
wire [31:0] dma_io_wdata;
wire [15:2] dma_io_radr;
wire [31:0] dma_io_rdata;
wire [31:0] dma_io_rdata_in = 32'd0;
wire ibus_ren;
wire [19:2] ibus_radr;
wire [15:0] ibus32_rdata = 16'd0;
wire ibus_wen;
wire [19:2] ibus_wadr;
wire [15:0] ibus32_wdata;

wire [31:2] start_adr;
wire cpu_start;
wire quit_cmd;
wire [31:0] pc_data;

wire clk;
wire stdby = 1'b0 ;
// for debug
wire tx_fifo_full;
wire tx_fifo_overrun;
wire tx_fifo_underrun;


`ifdef ARTY_A7
wire locked;
 // Instantiation of the clocking network
 //--------------------------------------
  clk_wiz_0 clknetwork
   (
    // Clock out ports
    .clk_out1           (clk),
    // Status and control signals
    .reset              (~rst_n),
    .locked             (locked),
   // Clock in ports
    .clk_in1            (clkin)
);
`endif

`ifdef TANG_PRIMER
wire clklock;
pll pll (
	.refclk(clkin),
	.reset(~rst_n),
	//.stdby(stdby),
	.extlock(clklock),
	.clk0_out(clk)
	);
`endif

cpu_top #(.DWIDTH(DWIDTH)) cpu_top (
	.clk(clk),
	.rst_n(rst_n),
	.cpu_start(cpu_start),
	.quit_cmd(quit_cmd),
	.start_adr(start_adr),
	.d_ram_radr(d_ram_radr),
	.d_ram_wadr(d_ram_wadr),
	.d_ram_rdata(d_ram_rdata),
	.d_ram_wdata(d_ram_wdata),
	.d_ram_wen(d_ram_wen),
	.d_read_sel(d_read_sel),
	.i_ram_radr(i_ram_radr),
	.i_ram_wadr(i_ram_wadr),
	.i_ram_rdata(i_ram_rdata),
	.i_ram_wdata(i_ram_wdata),
	.i_ram_wen(i_ram_wen),
	.i_read_sel(i_read_sel),
	.pc_data(pc_data),
	.dma_io_we(dma_io_we),
	.dma_io_wadr(dma_io_wadr),
	.dma_io_wdata(dma_io_wdata),
	.dma_io_radr(dma_io_radr),
	.dma_io_rdata_in(dma_io_rdata),
	.ibus_ren(ibus_ren),
	.ibus_radr(ibus_radr),
	.ibus32_rdata(ibus32_rdata),
	.ibus_wen(ibus_wen),
	.ibus_wadr(ibus_wadr),
	.ibus32_wdata(ibus32_wdata),
	.interrupt_0(interrupt_0)
	);

uart_top #(.DWIDTH(DWIDTH)) uart_top (
	.clk(clk),
	.rst_n(rst_n),
	.rx(rx),
	.tx(tx),
	.d_ram_radr(d_ram_radr),
	.d_ram_wadr(d_ram_wadr),
	.d_ram_rdata(d_ram_rdata),
	.d_ram_wdata(d_ram_wdata),
	.d_ram_wen(d_ram_wen),
	.d_read_sel(d_read_sel),
	.i_ram_radr(i_ram_radr),
	.i_ram_wadr(i_ram_wadr),
	.i_ram_rdata(i_ram_rdata),
	.i_ram_wdata(i_ram_wdata),
	.i_ram_wen(i_ram_wen),
	.i_read_sel(i_read_sel),
	.pc_data(pc_data),
	.cpu_start(cpu_start),
	.quit_cmd(quit_cmd),
	.start_adr(start_adr)
	
	);

io_led io_led (
	.clk(clk),
	.rst_n(rst_n),
	.dma_io_we(dma_io_we),
	.dma_io_wadr(dma_io_wadr),
	.dma_io_wdata(dma_io_wdata),
	.dma_io_radr(dma_io_radr),
	.dma_io_rdata_in(dma_io_rdata_in),
	.dma_io_rdata(dma_io_rdata),
	.rgb_led(rgb_led),
	.rgb_led1(rgb_led1),
	.rgb_led2(rgb_led2),
	.rgb_led3(rgb_led3)

	);
endmodule
