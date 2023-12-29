`timescale 1ns/1ps
`define CLK_PERIOD 20
module basic_tb;
reg clock, reset;
wire imem_clock, dmem_clock, processor_clock, regfile_clock;
// dut stands for 'design under test'
skeleton dut(
	.clock(clock), 
	.reset(reset), 
	.imem_clock(imem_clock), 
	.dmem_clock(dmem_clock), 
	.processor_clock(processor_clock), 
	.regfile_clock(regfile_clock));

always begin
	#(`CLK_PERIOD/2) clock = ~clock;
end
initial begin
	clock = 0;		// @ 0ns
	reset = 1;
#100					// Give 5 cycles reset signal
	reset = 0;
#2000					// Let it run for 100 cycles (25 processor cycles)
	$stop;			// Stop here so that we can check
end

endmodule