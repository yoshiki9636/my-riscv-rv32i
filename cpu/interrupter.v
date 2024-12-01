/*
 * My RISC-V RV32I CPU
 *   CPU Interrupter
 *    Verilog code
 * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
 * @copylight	2023 Yoshiki Kurokawa
 * @license		https://opensource.org/licenses/MIT     MIT license
 * @version		0.1
 */

module interrupter(
	input clk,
	input rst_n,
	// from external
	input interrupt_0,
	// from csr
	input csr_meie,
	output g_interrupt

	);

// making 1 shot from level
reg int_1lat;
reg int_2lat;
reg int_3lat;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		int_1lat <= 1'b0;
		int_2lat <= 1'b0;
		int_3lat <= 1'b0;
    end
	else begin
		int_1lat <= interrupt_0;
		int_2lat <= int_1lat;
		int_3lat <= int_2lat;
	end
end

assign g_interrupt = csr_meie & int_2lat & ~int_3lat;

endmodule
