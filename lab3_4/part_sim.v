// bcd-to-decimal converter
module part_sim (SW, HEX1, HEX0);
	input [3:0] SW;
	output [0:6] HEX1, HEX0;

	wire[3:0] V, M;
	wire[3:0] A;
	wire z;
	
	assign V = SW;

	// comparator circuit for V > 9
	assign z = (V[3] & V[2]) | (V[3] & V[1]);

	// Circuit A: when V > 9, this circuit allows the digit d0 to display the
	// values 0 - 5 (for the numbers V = 10 to V = 15). Note that V3 = 1 for all of these 
	// values, and V3 isn't needed in circuit A. The circuit implements the truth table
	//
	// V2 V1 V0 | A2 A1 A0
	// -------------------
	// 0  1  0  | 0  0  0  (V = 1010 -> 0)
	// 0  1  1  | 0  0  1  (V = 1011 -> 1)
	// 1  0  0  | 0  1  0  (V = 1100 -> 2)
	// 1  0  1  | 0  1  1  (V = 1101 -> 3)
	// 1  1  0  | 1  0  0  (V = 1110 -> 4)
	// 1  1  1  | 1  0  1  (V = 1111 -> 5)
	assign A[3] = 1'b0;
	assign A[2] = V[2] & V[1];
	assign A[1] = V[2] & ~V[1];
	assign A[0] = (V[1] & V[0]) | (V[2] & V[0]);

	// multiplexers
	mux2to1_4bit U1 (V, A, z, M);
	
	bcd7seg U2 (M, HEX0);
	bcd7seg U3 ({3'b0, z}, HEX1);
endmodule
			
// Implements a 4-bit wide 2-to-1 multiplexer.
module mux2to1_4bit (X, Y, s, M);
	input [3:0] X, Y;	
	input s;
	output [3:0] M;

	assign M[0] = (~s & X[0]) | (s & Y[0]);
	assign M[1] = (~s & X[1]) | (s & Y[1]);
	assign M[2] = (~s & X[2]) | (s & Y[2]);
	assign M[3] = (~s & X[3]) | (s & Y[3]);
endmodule

module bcd7seg (B, H);
	input [3:0] B;
	output [0:6] H;

	wire [0:6] H;

	/*
	 *       0  
	 *      ---  
	 *     |   |
	 *    5|   |1
	 *     | 6 |
	 *      ---  
	 *     |   |
	 *    4|   |2
	 *     |   |
	 *      ---  
	 *       3  
	 */
	// B  H
	// ----------
	// 0  0000001;
	// 1  1001111;
	// 2  0010010;
	// 3  0000110;
	// 4  1001100;
	// 5  0100100;
	// 6  0100000;
	// 7  0001111;
	// 8  0000000;
	// 9  0000100;
	assign H[0] = (~B[3] & B[2] & ~B[1] & ~B[0]) | (~B[3] & ~B[2] & ~B[1] & B[0]);
	assign H[1] = (B[2] & ~B[1] & B[0]) | (B[2] & B[1] & ~B[0]);
	assign H[2] = (~B[2] & B[1] & ~B[0]);
	assign H[3] = (~B[3] & ~B[2] & ~B[1] & B[0]) | (~B[3] & B[2] & ~B[1] & ~B[0]) | 
		(~B[3] & B[2] & B[1] & B[0]);
	assign H[4] = (~B[1] & B[0]) | (~B[3] & B[0]) | (~B[3] & B[2] & ~B[1]);
	assign H[5] = (B[1] & B[0]) | (~B[2] & B[1]) | (~B[3] & ~B[2] & B[0]);
	assign H[6] = (B[2] & B[1] & B[0]) | (~B[3] & ~B[2] & ~B[1]);
endmodule
