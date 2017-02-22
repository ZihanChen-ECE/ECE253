// inputs:
//	Clk: manual clock
//	D: data input
//
// outputs:
//	Qa: gated D-latch output
//	Qb: positive edge-triggered D flip-flop output
//	Qc: negative edge-triggered D flip-flop output
module part1 (Clk, D, Qa, Qb, Qc);
	input Clk, D;
	output reg Qa, Qb, Qc;
	
	// gated D-latch
	always @( * )
		if (Clk == 1'b1)
			Qa <= D;
	
	// positive-edge triggered D FF
	always @(posedge Clk)
		Qb <= D;
	
	// negative-edge triggered D FF 
	always @(negedge Clk)
		Qc <= D;
endmodule