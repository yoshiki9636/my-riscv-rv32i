/*
 * My RISC-V RV32I CPU
 *   UART Monitor Top Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module uart_top
	#(parameter DWIDTH = 11)
	(

	input clk,
	input rst_n,
	input rx,
	output tx,

	output [DWIDTH+1:2] d_ram_radr,
	output [DWIDTH+1:2] d_ram_wadr,
	input [31:0] d_ram_rdata,
	output [31:0] d_ram_wdata,
	output d_ram_wen,
	output d_read_sel,
	output [13:2] i_ram_radr,
	output [13:2] i_ram_wadr,
	input [31:0] i_ram_rdata,
	output [31:0] i_ram_wdata,
	output i_ram_wen,
	output i_read_sel,
	input [31:0] pc_data,
	
	output cpu_start,
	output quit_cmd,
	output [31:2] start_adr
	//output tx_fifo_full,
	//output tx_fifo_overrun,
	//output tx_fifo_underrun,
	//output rx_fifo_full,
	//output rx_fifo_overrun,
	//output rx_fifo_underrun,
	//output [3:0] cmd_status,
	//output [2:0] rx_fifo_rcntr,
	//output [7:0] rout,
	//output reg [2:0] rout_en_c,
	//output [2:0] test

	);


wire [31:0] uart_data;
wire [63:0] rdata_snd;
wire [7:0] rout;
wire [7:0] rx_rdata;
wire [7:0] send_char;
wire [7:0] tx_wdata;

wire flushing_wq;
wire inst_address_set;
wire inst_data_en;
wire pgm_end_set;
wire pgm_start_set;
wire pgm_stop;
wire rdata_snd_start;
wire read_end_set;
wire read_start_set;
wire read_stop;
wire rout_en;
wire rx_fifo_dvalid;
wire rx_fifo_full;
wire rx_fifo_overrun;
wire rx_fifo_underrun;
wire rx_rden;
wire send_en;
wire start_step;
wire start_trush;
wire tx_fifo_full;
wire tx_fifo_overrun;
wire tx_fifo_underrun;
wire tx_wten;
wire write_address_set;
wire write_data_en;
wire pc_print;
wire pc_print_sel;

wire dump_running;
wire trush_running;
//wire data_en;
wire crlf_in;
wire [2:0] rx_fifo_rcntr;

/*
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		rout_en_c <= 3'd0;
	else if (crlf_in)
		rout_en_c <= rout_en_c + 3'd1;
end
*/

uart_if uart_if (
	.clk(clk),
	.rst_n(rst_n),
	.rx(rx),
	.tx(tx),
	.rx_rden(rx_rden),
	.rx_rdata(rx_rdata),
	.rx_fifo_full(rx_fifo_full),
	.rx_fifo_dvalid(rx_fifo_dvalid),
	.rx_fifo_overrun(rx_fifo_overrun),
	.rx_fifo_underrun(rx_fifo_underrun),
	.tx_wdata(tx_wdata),
	.tx_wten(tx_wten),
	.tx_fifo_full(tx_fifo_full),
	.tx_fifo_overrun(tx_fifo_overrun),
	.tx_fifo_underrun(tx_fifo_underrun),
	.rx_fifo_rcntrs(rx_fifo_rcntr)
	);

uart_loop uart_loop (
	.clk(clk),
	.rst_n(rst_n),
	.rout(rout),
	.rout_en(rout_en),
	.send_char(send_char),
	.send_en(send_en),
	.rx_rden(rx_rden),
	.rx_rdata(rx_rdata),
	.rx_fifo_full(rx_fifo_full),
	.rx_fifo_dvalid(rx_fifo_dvalid),
	.rx_fifo_overrun(rx_fifo_overrun),
	.rx_fifo_underrun(rx_fifo_underrun),
	.tx_wdata(tx_wdata),
	.tx_wten(tx_wten),
	.tx_fifo_full(tx_fifo_full),
	.tx_fifo_overrun(tx_fifo_overrun),
	.tx_fifo_underrun(tx_fifo_underrun)
	);

uart_rec_char uart_rec_char (
	.clk(clk),
	.rst_n(rst_n),
	.rout(rout),
	.rout_en(rout_en),
	.dump_running(dump_running),
	.trush_running(trush_running),
	.uart_data(uart_data),
	.cpu_start(cpu_start),
	.write_address_set(write_address_set),
	.write_data_en(write_data_en),
	.read_start_set(read_start_set),
	.read_end_set(read_end_set),
	.read_stop(read_stop),
	.start_trush(start_trush),
	.start_step(start_step),
	.quit_cmd(quit_cmd),
	.pgm_start_set(pgm_start_set),
	.pgm_end_set(pgm_end_set),
	.pgm_stop(pgm_stop),
	.inst_address_set(inst_address_set),
	.inst_data_en(inst_data_en),
	.pc_print(pc_print),
	.pc_print_sel(pc_print_sel),
	.crlf_in(crlf_in)
	//.cmd_status(cmd_status),
	//.data_en(data_en),
	//.test(test)
	);
	
uart_send_char uart_send_char (
	.clk(clk),
	.rst_n(rst_n),
	.rdata_snd_start(rdata_snd_start),
	.rdata_snd(rdata_snd),
	.flushing_wq(flushing_wq),
	.send_char(send_char),
	.send_en(send_en),
	.tx_fifo_full(tx_fifo_full),
	.crlf_in(crlf_in)	
	);

uart_logics  #(.DWIDTH(DWIDTH)) uart_logics (
	.clk(clk),
	.rst_n(rst_n),
	.i_ram_radr(i_ram_radr),
	.i_ram_rdata(i_ram_rdata),
	.i_ram_wadr(i_ram_wadr),
	.i_ram_wdata(i_ram_wdata),
	.i_ram_wen(i_ram_wen),
	.i_read_sel(i_read_sel),
	.d_ram_radr(d_ram_radr),
	.d_ram_rdata(d_ram_rdata),
	.d_ram_wadr(d_ram_wadr),
	.d_ram_wdata(d_ram_wdata),
	.d_ram_wen(d_ram_wen),
	.d_read_sel(d_read_sel),
	.uart_data(uart_data),
	.start_adr(start_adr),
	.write_address_set(write_address_set),
	.write_data_en(write_data_en),
	.read_start_set(read_start_set),
	.read_end_set(read_end_set),
	.read_stop(read_stop),
	.rdata_snd_start(rdata_snd_start),
	.rdata_snd(rdata_snd),
	.flushing_wq(flushing_wq),
	.dump_running(dump_running),
	.start_trush(start_trush),
	.trush_running(trush_running),
	.start_step(start_step),
	.pgm_start_set(pgm_start_set),
	.pgm_end_set(pgm_end_set),
	.pgm_stop(pgm_stop),
	.inst_address_set(inst_address_set),
	.pc_print(pc_print),
	.pc_print_sel(pc_print_sel),
	.pc_data(pc_data),
	.inst_data_en(inst_data_en)
	);

endmodule 
