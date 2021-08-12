/*
 * My RISC-V RV32I CPU
 *   Verilog Simulation Top Module
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2021 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module simtop;

reg clkin;
reg rst_n;
wire rx = 1'b0;
wire tx;
wire [2:0] rgb_led;

fpga_top fpga_top (
        .clkin(clkin),
        .rst_n(rst_n),
		.rx(rx),
        .tx(tx),
        .rgb_led(rgb_led)
	);

initial $readmemh("./test.txt", fpga_top.cpu_top.if_stage.inst_1r1w.ram);

initial clkin = 0;

always #5 clkin <= ~clkin;


initial begin
	force fpga_top.cpu_start = 1'b0;
	rst_n = 1'b1;
#10
	rst_n = 1'b0;
#20
	rst_n = 1'b1;
#10
	force fpga_top.cpu_start = 1'b1;
#10
	force fpga_top.cpu_start = 1'b0;
#500000
	$stop;
end

endmodule
