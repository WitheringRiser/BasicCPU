module register(Q, D, clk, en,clr);
	input [31:0] D;
	input clk, en, clr;
	output [31:0] Q;

	genvar i;
	generate
		for(i=0;i<32;i=i+1) begin: buildDFF
			dffe dff(Q[i], D[i], clk, en, clr);
		end
	endgenerate
endmodule
