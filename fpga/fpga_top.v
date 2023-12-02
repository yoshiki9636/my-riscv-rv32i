/*
 * My RISC-V RV32I CPU
 *   FPGA Top Module for Tang Premier
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

`define TANG_PRIMER
//`define ARTY_A7

module fpga_top(
	input clkin,
	input rst_n,
	input rx,
	output tx,
	input interrupt_0,
	output [2:0] rgb_led

	);

wire [13:2] d_ram_radr;
wire [13:2] d_ram_wadr;
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

wire [11:2] st_adr_io;
wire [3:0] st_we_io;
wire [31:0] st_data_io;

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

cpu_top cpu_top (
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
	.st_adr_io(st_adr_io),
	.st_data_io(st_data_io),
	.st_we_io(st_we_io),
	.interrupt_0(interrupt_0)
	);

uart_top uart_top (
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
	//.tx_fifo_full(tx_fifo_full),
	//.tx_fifo_overrun(tx_fifo_overrun),
	//.tx_fifo_underrun(tx_fifo_underrun)
	
	);
//wire [2:0] rgb_led_dummy;
//assign rgb_led = { tx_fifo_full, tx_fifo_overrun, tx_fifo_underrun };
//assign rgb_led = { i_ram_wadr[4:2] };

io_led io_led (
	.clk(clk),
	.rst_n(rst_n),
	.st_we_io(st_we_io),
	.st_adr_io(st_adr_io),
	.st_data_io(st_data_io),
	.rgb_led(rgb_led)
	//.rgb_led(rgb_led_dummy)
	);

endmodule
