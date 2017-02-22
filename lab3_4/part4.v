// one-digit BCD adder S1 S0 = X + Y + Cin
// inputs: SW7-4 = X
//         SW3-0 = Y
//         SW8 = Cin
// outputs: X is displayed on HEX5
// 			Y is displayed on HEX3
// 			S1 S0 is displayed on HEX1 HEX0
module part4 (SW, LEDR, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [8:0] SW;
	output [9:0] LEDR;
	
	output [0:6] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire [3:0] X, Y, S;			// S is the sum output of the adder
	wire Cin;						// carry in
	wire [4:1] C;					// internal carries
	wire [3:0] M;					// used for sums 0 to 15
	wire [3:0] B, S0;				// used for sums 16, 17, 18, 19
	wire z, S1;
	
	assign X = SW[7:4];
	assign Y = SW[3:0];
	assign Cin = SW[8];

	fa bit0 (X[0], Y[0], Cin, S[0], C[1]);
	fa bit1 (X[1], Y[1], C[1], S[1], C[2]);
	fa bit2 (X[2], Y[2], C[2], S[2], C[3]);
	fa bit3 (X[3], Y[3], C[3], S[3], C[4]);
	assign LEDR[4:0] = {C[4], S};
	
	// Display the inputs
	bcd7seg H_5 (X, HEX5);
	assign HEX4 = 7'b1111111;	// display blank

	bcd7seg H_3 (Y, HEX3);
	assign HEX2 = 7'b1111111;	// display blank
	
	// Detect illegal inputs, display on LEDR[9]
	assign LEDR[9] = (X[3] & X[2]) | (X[3] & X[1]) | 
		(Y[3] & Y[2]) | (Y[3] & Y[1]);
	assign LEDR[8:5] = 4'b0;

	// Display the sum
	// module part2 (V, z, M);
	part2 U1 (S, z, M); 
	// S is really a 5-bit # with the carry-out C[4], but part2 handles only 
	// the lower four bit (sums 00-15).  To account for sums 16, 17, 18, 19 the
	// signal B is created to be used instead of M in the cases that C[4] = 1:
	assign B[3] = M[1];
	assign B[2] = ~M[1];
	assign B[1] = ~M[1];
	assign B[0] = M[0];
	mux2to1_4bit U2 (M, B, C[4], S0);

	bcd7seg H_0 (S0, HEX0);
	// HEX1 should display 1 when z is 1 (sums 10-15), and also when C[4] is 1 (sums 16-19)
	assign S1 = z | C[4];
	bcd7seg H_1 ({3'b000, S1}, HEX1);
endmodule
			
module fa (a, b, ci, s, co);
	input a, b, ci;
	output s, co;

	wire a_xor_b;

	assign a_xor_b = a ^ b;
	assign s = a_xor_b ^ ci;
	assign co = (~a_xor_b & b) | (a_xor_b & ci);
endmodule

// bcd-to-decimal converter
module part2 (V, z, M);
	input [3:0] V;
	output z;
	output [3:0] M;

	wire[3:0] A;
	
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
