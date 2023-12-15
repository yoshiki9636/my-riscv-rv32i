/*
 * My RISC-V RV32I CPU
 *   CPU Status Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module cpu_status(
	input clk,
	input rst_n,

	// from control
	input cpu_start,
	input quit_cmd,
	// to CPU
	output stall,
	output stall_1shot,
	output reg stall_dly,
	output reg rst_pipe,
	output reg rst_pipe_id,
	output reg rst_pipe_ex,
	output reg rst_pipe_ma,
	output reg rst_pipe_wb
	);

reg cpu_run_state;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		cpu_run_state <= 1'b0;
	else if (quit_cmd)
		cpu_run_state <= 1'b0;	
	else if (cpu_start)
		cpu_run_state <= 1'b1;
end

//wire cpu_running = cpu_run_state; 

// stall signal : currently controlled by outside

assign stall = ~cpu_run_state;

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        stall_dly <= 1'b1 ;
	else
		stall_dly <= stall;
end

assign stall_1shot = stall & ~stall_dly;

// pipeline reset signal

wire start_reset = cpu_start & ~cpu_run_state;
wire end_reset = quit_cmd & cpu_run_state;


always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
        rst_pipe <= 1'b0 ;
	else
		rst_pipe <= start_reset | end_reset;
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rst_pipe_id <= 1'b0 ;
        rst_pipe_ex <= 1'b0 ;
        rst_pipe_ma <= 1'b0 ;
        rst_pipe_wb <= 1'b0 ;
	end
	else begin
        rst_pipe_id <= rst_pipe;
        rst_pipe_ex <= rst_pipe_id;
        rst_pipe_ma <= rst_pipe_ex;
        rst_pipe_wb <= rst_pipe_ma;
	end
end

endmodule
