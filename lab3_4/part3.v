// 4-bit ripple-carry adder
module part3 (SW, LEDR);
	input [8:0] SW;
	output [9:0] LEDR;
	
	wire [3:0] A, B, S;
	wire [4:0] C;		// carries
	
	assign A = SW[7:4];
	assign B = SW[3:0];
	assign C[0] = SW[8];
	fa bit0 (A[0], B[0], C[0], S[0], C[1]);
	fa bit1 (A[1], B[1], C[1], S[1], C[2]);
	fa bit2 (A[2], B[2], C[2], S[2], C[3]);
	fa bit3 (A[3], B[3], C[3], S[3], C[4]);
	
	// Display the inputs
	assign LEDR[4:0] = {C[4], S};
	assign LEDR[9:5] = 5'b0;

endmodule
			
module fa (a, b, ci, s, co);
	input a, b, ci;
	output s, co;

	wire a_xor_b;

	assign a_xor_b = a ^ b;
	assign s = a_xor_b ^ ci;
	assign co = (~a_xor_b & b) | (a_xor_b & ci);
endmodule
