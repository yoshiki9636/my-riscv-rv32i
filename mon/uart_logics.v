/*
 * My RISC-V RV32I CPU
 *   UART Monitor Logic Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module uart_logics
	#(parameter DWIDTH = 11)
	(
	input clk,
	input rst_n,
	output [13:2] i_ram_radr,
	input [31:0] i_ram_rdata,
	output [DWIDTH+1:2] i_ram_wadr,
	output [31:0] i_ram_wdata,
	output i_ram_wen,
	output i_read_sel,
	output [DWIDTH+1:2] d_ram_radr,
	input [31:0] d_ram_rdata,
	output [DWIDTH+1:2] d_ram_wadr,
	output [31:0] d_ram_wdata,
	output d_ram_wen,
	output d_read_sel,
	// from controller
	input [31:0] uart_data,
	//input cpu_start,
	output [31:2] start_adr,
	//input quit_cmd,
	input write_address_set,
	input write_data_en,
	input read_start_set,
	input read_end_set,
	input read_stop,
	output rdata_snd_start,
	output [63:0] rdata_snd,
	input flushing_wq,
	output dump_running,
	input start_trush,
	output trush_running,
	input start_step,
	input pgm_start_set,
	input pgm_end_set,
	input pgm_stop,
	input inst_address_set,
	input pc_print,
	input pc_print_sel,
	input [31:0] pc_data,
	input inst_data_en

	);


// CPU running state
assign start_adr = uart_data[31:2];

/*
reg cpu_run_state;
reg step_reserve;
reg cupst_snd_wait;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		cpu_run_state <= 1'b0;
	else if (quit_cmd)
		cpu_run_state <= 1'b0;	
	else if (cpu_start)
		cpu_run_state <= 1'b1;
end

assign cpu_running = cpu_run_state; //& ~(rdata_snd_wait | cupst_snd_wait);

wire step_idle_nodump = s00_idle & ~dump_cpu;
wire step_start_cond = step_idle_nodump & ~(rdata_snd_wait | cupst_snd_wait);

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		step_reserve <= 1'b0;
	else if (step_start_cond)
		step_reserve <= 1'b0;	
	else if (~step_idle_nodump & start_step)
		step_reserve <= 1'b1;
end

wire step_run = step_start_cond & (step_reserve | start_step);
// sequencer start signal
assign run = cpu_running | step_run;
*/

// iram write address 
reg [31:2] cmd_wadr_cntr;
wire [DWIDTH+1:2] trush_adr;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		cmd_wadr_cntr <= 30'd0;
	else if (write_address_set | inst_address_set)
		cmd_wadr_cntr <= uart_data[31:2];
	else if (write_data_en | inst_data_en)
		cmd_wadr_cntr <= cmd_wadr_cntr + 30'd1;
end

assign i_ram_wadr = trush_running ? trush_adr[DWIDTH+1:2] : cmd_wadr_cntr[DWIDTH+1:2];
assign i_ram_wdata = trush_running ? 32'd0 : uart_data;
assign i_ram_wen = inst_data_en | trush_running;
assign d_ram_wadr =  trush_running ? trush_adr : cmd_wadr_cntr[DWIDTH+1:2];
assign d_ram_wdata = i_ram_wdata;
assign d_ram_wen = write_data_en | trush_running;

// i/d ram read address
reg [31:2] cmd_read_end;
reg [32:2] cmd_read_adr;

wire dump_end;
wire radr_cntup;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		cmd_read_adr <= 31'd0;
	else if (read_start_set | pgm_start_set)
		cmd_read_adr <= { 1'b0, uart_data[31:2] };
	else if (radr_cntup)
		cmd_read_adr <= cmd_read_adr + 31'd1;
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		cmd_read_end <= 30'd0;
	else if (read_end_set | pgm_end_set)
		cmd_read_end <= uart_data[31:2];
end

assign dump_end =(cmd_read_adr >= {1'b0, cmd_read_end});

assign i_ram_radr = cmd_read_adr[13:2];
assign d_ram_radr = cmd_read_adr[DWIDTH+1:2];


`define D_IDLE 2'd0
`define D_RED1 2'd1
`define D_RED2 2'd2
`define D_WAIT 2'd3
reg [2:0] status_dump;
wire [2:0] next_status_dump;

/*
reg i_ram_ofs;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		i_ram_ofs <= 1'b0;
	else if (status_dump == `D_RED2)
		i_ram_ofs <= ~i_ram_ofs;
end

wire i_ram_ofs_end = (i_ram_ofs == 1'b1);
*/

function [2:0] dump_status;
input [2:0] status_dump;
input read_end_set;
input pgm_end_set;
input read_stop;
input pgm_stop;
input flushing_wq;
input dump_end;
input pc_print;
input pc_print_sel;
begin
	case(status_dump)
		`D_IDLE :
			if (read_end_set | pgm_end_set)
				dump_status = `D_RED1;
			else if (pc_print)
				dump_status = `D_WAIT;
			else
				dump_status = `D_IDLE;
		`D_RED1 :
			if (read_stop | pgm_stop)
				dump_status = `D_IDLE;
			else
				dump_status = `D_RED2;
		`D_RED2 :
			if (read_stop | pgm_stop)
				dump_status = `D_IDLE;
			else
				dump_status = `D_WAIT;
		`D_WAIT :
			if (read_stop | pgm_stop)
				dump_status = `D_IDLE;
			else if (flushing_wq & pc_print_sel)
				dump_status = `D_IDLE;
			else if (flushing_wq & dump_end)
				dump_status = `D_IDLE;
			else if (flushing_wq & ~dump_end)
				dump_status = `D_RED1;
			else
				dump_status = `D_WAIT;
		default : dump_status = `D_IDLE;
	endcase
end
endfunction

assign next_status_dump = dump_status(
							status_dump,
							read_end_set,
							pgm_end_set,
							read_stop,
							pgm_stop,
							flushing_wq,
							dump_end,
							pc_print,
							pc_print_sel
							);

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		status_dump <= 3'd0;
	else
		status_dump <= next_status_dump;
end

assign radr_cntup = (status_dump == `D_RED1)|(status_dump == `D_RED2);
assign dump_running = (status_dump != `D_IDLE);
wire rdata_snd_wait = (status_dump == `D_WAIT);

reg i_ram_sel;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		i_ram_sel <= 1'b0;
	else if ( read_end_set )
		i_ram_sel <= 1'b0;
	else if ( pgm_end_set )
		i_ram_sel <= 1'b1;
end

wire en0_data = radr_cntup & (status_dump == `D_RED2);
//wire en1_data = radr_cntup & (i_ram_ofs == 3'd2);
//wire en2_data = radr_cntup & (i_ram_ofs == 3'd3);

assign i_read_sel = dump_running &  i_ram_sel;
assign d_read_sel = dump_running & ~i_ram_sel;

reg en1_data;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		en1_data <= 1'b0;
	else
		en1_data <= en0_data;
end

reg [31:0] data_0;
reg [31:0] data_1;
//reg [7:0] data_2;
//reg [7:0] data_3;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		data_0 <= 32'd0;
	else if (en0_data)
		data_0 <= i_ram_sel ? i_ram_rdata : d_ram_rdata;
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		data_1 <= 32'd0;
	else if (en1_data)
		data_1 <= i_ram_sel ? i_ram_rdata : d_ram_rdata;
end

/*
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		data_2 <= 8'd0;
	else if (en2_data)
		data_2 <= i_ram_sel ? i_ram_rdata : d_ram_rdata;
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		data_3 <= 8'd0;
	else if (en3_data)
		data_3 <= i_ram_sel ? i_ram_rdata : d_ram_rdata;
end
*/

assign rdata_snd = pc_print_sel ? { 32'd0, pc_data} : { data_1, data_0 };

// trashing memory data
reg [DWIDTH+2:2] trash_cntr;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		trash_cntr <= { DWIDTH+1{ 1'b0 }};
	else if (start_trush)
		trash_cntr <= { 1'b1, { DWIDTH{ 1'b0 }}};
	else if (trash_cntr[DWIDTH+2])
		trash_cntr <= trash_cntr + 1;
end

assign trush_adr = trash_cntr[DWIDTH+1:2];
assign trush_running = trash_cntr[DWIDTH+2];


// send CPU status to UART i/f
/*
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		cupst_snd_wait <= 1'b0;
	else if (flushing_wq)
		cupst_snd_wait <= 1'b0;
	else if (s04_wtbk)
		cupst_snd_wait <= 1'b1;
end

reg cpust_snd_wait_dly;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		cpust_snd_wait_dly <= 1'b0;
	else
		cpust_snd_wait_dly <= cupst_snd_wait;
end

assign cpust_start = cupst_snd_wait & ~cpust_snd_wait_dly;
*/

reg rdata_snd_wait_dly;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		rdata_snd_wait_dly <= 1'b0;
	else
		rdata_snd_wait_dly <= rdata_snd_wait;
end

assign rdata_snd_start = (rdata_snd_wait & ~rdata_snd_wait_dly) | pc_print;


endmodule
