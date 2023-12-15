/*
 * My RISC-V RV32I CPU
 *   UART Interface Module for Monitor
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module uart_if(
	input clk,
	input rst_n,
	input rx,
	output tx,
	input rx_rden,
	output [7:0] rx_rdata,
	output rx_fifo_full,
	output rx_fifo_dvalid,
	output rx_fifo_overrun,
	output rx_fifo_underrun,

	input [7:0] tx_wdata,
	input tx_wten,
	output tx_fifo_full,
	output tx_fifo_overrun,
	output tx_fifo_underrun,
	output [2:0] rx_fifo_rcntrs

	);
	
// clk:90MHz, 9600bps
//`define TERM 9375
//`define HARF 4688
//`define TERM 8854
//`define HARF 4427
// clk:80MHz, 9600bps
//`define TERM 8333
//`define HARF 4166
// clk:75MHz, 9600bps
`define TERM 7812
`define HARF 3906

// clk:50MHz, 9600bps
//`define TERM 5208
//`define HARF 2604
// clk:48MHz, 9600bps
//`define TERM 5000
//`define HARF 2500
// clk:36MHz, 9600bps
//`define TERM 3750
//`define HARF 1875
// clk:24MHz, 9600bps
//`define TERM 2500
//`define HARF 1250
// for test
//`define TERM 20
//`define HARF 10

// rx input double FF
reg rx1;
reg rx2;
reg s0;
reg s1;
reg s2;
reg s3;
reg s4;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		rx1 <= 1'b1;
		rx2 <= 1'b1;
		s0 <= 1'b1;
		s1 <= 1'b1;
		s2 <= 1'b1;
		s3 <= 1'b1;
		s4 <= 1'b1;
	end
	else begin
		rx1 <= rx;
		rx2 <= rx1;
		s0 <= rx2;
		s1 <= s0;
		s2 <= s1;
		s3 <= s2;
		s4 <= s3;
	end
end

// neg edge check

wire edge_rx = ~rx2 & s0;

// sampler
`define RX_IDLE 4'd0
`define RX_STAR 4'd1
`define RX_BIT0 4'd2
`define RX_BIT1 4'd3
`define RX_BIT2 4'd4
`define RX_BIT3 4'd5
`define RX_BIT4 4'd6
`define RX_BIT5 4'd7
`define RX_BIT6 4'd8
`define RX_BIT7 4'd9
`define RX_STOP 4'd10

wire sample_trg;
reg [3:0] rx_state;

wire [2:0] bit_cnt = {2'd0, s0} +  {2'd0, s1} +  {2'd0, s2} +  {2'd0, s3} +  {2'd0, s4}; 

wire bit_data = (bit_cnt >= 3'd3);

wire start_ok = ~bit_data & sample_trg & (rx_state == `RX_STAR);
wire start_ng =  bit_data & sample_trg & (rx_state == `RX_STAR);
wire end_ok   =  bit_data & sample_trg & (rx_state == `RX_STOP);
wire end_ng   = ~bit_data & sample_trg & (rx_state == `RX_STOP);
wire get_bit =  sample_trg & (rx_state != `RX_STOP) & sample_trg & (rx_state != `RX_STOP);

wire start_trg = edge_rx & (rx_state == `RX_IDLE);

// sample trigger

reg [15:0] sample_cntr;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		sample_cntr <= 16'd0;
	else if (start_trg)
		sample_cntr <= `HARF;
	else if (start_ok | get_bit)
		sample_cntr <= `TERM;
	else if (sample_cntr == 16'd0)
		sample_cntr <= 16'd0;
	else
		sample_cntr <= sample_cntr - 16'd1;
end

assign sample_trg = (sample_cntr == 16'd1);


// rx state machine

function [3:0] rx_state_machine;
input [3:0] rx_state;
input edge_rx;
input start_ok;
input start_ng;
input get_bit;
input end_ok;
input end_ng;
begin
	case(rx_state)
		`RX_IDLE: if (edge_rx) rx_state_machine = `RX_STAR;
				  else rx_state_machine = `RX_IDLE;
		`RX_STAR: if (start_ok)  rx_state_machine = `RX_BIT0;
		          else if (start_ng) rx_state_machine = `RX_IDLE;
				  else rx_state_machine = `RX_STAR;
		`RX_BIT0: if (get_bit) rx_state_machine = `RX_BIT1;
				  else  rx_state_machine = `RX_BIT0;
		`RX_BIT1: if (get_bit) rx_state_machine = `RX_BIT2;
				  else  rx_state_machine = `RX_BIT1;
		`RX_BIT2: if (get_bit) rx_state_machine = `RX_BIT3;
				  else  rx_state_machine = `RX_BIT2;
		`RX_BIT3: if (get_bit) rx_state_machine = `RX_BIT4;
				  else  rx_state_machine = `RX_BIT3;
		`RX_BIT4: if (get_bit) rx_state_machine = `RX_BIT5;
				  else  rx_state_machine = `RX_BIT4;
		`RX_BIT5: if (get_bit) rx_state_machine = `RX_BIT6;
				  else  rx_state_machine = `RX_BIT5;
		`RX_BIT6: if (get_bit) rx_state_machine = `RX_BIT7;
				  else  rx_state_machine = `RX_BIT6;
		`RX_BIT7: if (get_bit) rx_state_machine = `RX_STOP;
				  else  rx_state_machine = `RX_BIT7;
		`RX_STOP: if (end_ok)  rx_state_machine = `RX_IDLE;
		          else if (end_ng) rx_state_machine = `RX_IDLE;
				  else rx_state_machine = `RX_STOP;
		default : rx_state_machine = `RX_IDLE;
	endcase
end
endfunction

wire [3:0] next_rx_state = rx_state_machine( rx_state,
											 edge_rx,
											 start_ok,
											 start_ng,
											 get_bit,
											 end_ok,
											 end_ng);

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		rx_state <= 4'd0;
	else
		rx_state <= next_rx_state;
end

// byte sampler
reg [7:0] byte_data;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		byte_data <= 8'd0;
	else if (start_ok)
		byte_data <= 8'd0;
	else if (get_bit)
		//byte_data <= { byte_data[6:0], bit_data } ;
		byte_data <= { bit_data, byte_data[7:1] } ;
end

// rx FIFO 
reg [2:0] rx_fifo_wcntr;
reg [2:0] rx_fifo_rcntr;
reg [3:0] rx_fifo_dcntr;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		rx_fifo_wcntr <= 3'd0;
	else if (end_ok)
		rx_fifo_wcntr <= rx_fifo_wcntr + 3'd1;
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		rx_fifo_rcntr <= 3'd0;
	else if (rx_rden)
		rx_fifo_rcntr <= rx_fifo_rcntr + 3'd1;
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		rx_fifo_dcntr <= 4'd0;
	else if (end_ok & rx_rden)
		rx_fifo_dcntr <= rx_fifo_dcntr;		
	else if (end_ok)
		rx_fifo_dcntr <= rx_fifo_dcntr + 4'd1;
	else if (rx_rden)
		rx_fifo_dcntr <= rx_fifo_dcntr - 4'd1;
end

assign rx_fifo_full = (rx_fifo_dcntr == 4'd8);
assign rx_fifo_dvalid = ~(rx_fifo_dcntr == 4'd0);
assign rx_fifo_overrun = rx_fifo_full & end_ok;
assign rx_fifo_underrun = ~rx_fifo_dvalid & rx_rden;
assign rx_fifo_rcntrs = rx_fifo_rcntr;

// rx FIFO RAM

uart_1r1w rx_fifo (
	.clk(clk),
	.ram_radr(rx_fifo_rcntr),
	.ram_rdata(rx_rdata),
	.ram_wadr(rx_fifo_wcntr),
	.ram_wdata(byte_data),
	.ram_wen(end_ok)
	);

// tx

// tx FIFO 
reg [2:0] tx_fifo_wcntr;
reg [2:0] tx_fifo_rcntr;
reg [3:0] tx_fifo_dcntr;
wire tx_rden;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_fifo_wcntr <= 3'd0;
	else if (tx_wten)
		tx_fifo_wcntr <= tx_fifo_wcntr + 3'd1;
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_fifo_rcntr <= 3'd0;
	else if (tx_rden)
		tx_fifo_rcntr <= tx_fifo_rcntr + 3'd1;
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_fifo_dcntr <= 4'd0;
	else if (tx_wten & tx_rden)
		tx_fifo_dcntr <= tx_fifo_dcntr;		
	else if (tx_wten)
		tx_fifo_dcntr <= tx_fifo_dcntr + 4'd1;
	else if (tx_rden)
		tx_fifo_dcntr <= tx_fifo_dcntr - 4'd1;
end

assign tx_fifo_full = (tx_fifo_dcntr == 4'd8);
wire   tx_fifo_dvalid = ~(tx_fifo_dcntr == 4'd0);
assign tx_fifo_overrun = tx_fifo_full & tx_wten;
assign tx_fifo_underrun = ~tx_fifo_dvalid & tx_rden;

// tx FIFO RAM
wire [7:0] tx_rdata;

 uart_1r1w tx_fifo(
	.clk(clk),
	.ram_radr(tx_fifo_rcntr),
	.ram_rdata(tx_rdata),
	.ram_wadr(tx_fifo_wcntr),
	.ram_wdata(tx_wdata),
	.ram_wen(tx_wten)
	);

// 
`define TX_IDLE 1'b0
`define TX_CNTR 1'b1

reg [3:0] tx_out_cntr;
wire tx_cycle_end;
reg tx_state;

wire tx_cntr_start = tx_fifo_dvalid & (tx_state == `TX_IDLE);

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_out_cntr <= 4'd0;
	else if (tx_cntr_start)
		tx_out_cntr <= 4'd10;
	else if (tx_out_cntr == 4'd0)
		tx_out_cntr <= 4'd0;
	else if (tx_cycle_end)
		tx_out_cntr <= tx_out_cntr - 4'd1;
end

reg [15:0] tx_cycle_cntr;
wire tx_cntr_next;

wire tx_start_cycle = tx_cntr_start | tx_cntr_next;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_cycle_cntr <= 16'd0;
	else if (tx_start_cycle)
		tx_cycle_cntr <= `TERM;
	else if (tx_cycle_cntr == 16'd0)
		tx_cycle_cntr <= 16'd0;
	else
		tx_cycle_cntr <= tx_cycle_cntr - 16'd1;
end

assign tx_cycle_end = (tx_cycle_cntr == 16'd1);

assign tx_cntr_next = tx_cycle_end & (tx_out_cntr != 4'd0);
wire tx_cntr_finish = tx_cycle_end & (tx_out_cntr == 4'd0);

assign tx_rden = tx_cntr_finish;

// splitter

function tx_state_machine;
input tx_state;
input tx_fifo_dvalid;
input tx_cntr_finish;
begin
	case(tx_state)
		`TX_IDLE: if (tx_fifo_dvalid) tx_state_machine = `TX_CNTR;
				  else tx_state_machine = `TX_IDLE;
		`TX_CNTR: if (tx_cntr_finish) tx_state_machine = `TX_IDLE;
				  else tx_state_machine = `TX_CNTR;
		default : tx_state_machine = `TX_IDLE;
	endcase
end
endfunction

wire next_tx_state = tx_state_machine( tx_state, tx_fifo_dvalid, tx_cntr_finish);

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_state <= `TX_IDLE;
	else
		tx_state <= next_tx_state;
end

reg [9:0] tx_out_data;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_out_data <= 9'd1;
	else if (tx_cntr_start)
		tx_out_data <= { 1'b1, tx_rdata, 1'b0 };
	else if (tx_cntr_next)
		tx_out_data <= { 1'b1, tx_out_data[9:1] };
end

assign tx = tx_out_data[0] | (tx_state == `TX_IDLE);


endmodule
