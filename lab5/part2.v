// KEY0 is resetn, KEY1 is the clock for reg_A
// Operation: set SW to the value desired for A, then store this value in A_reg by
// using KEY1. A is shown on HEX3-2. Then change SW to the value desired for B, which is 
// displayed on HEX1-0. The sum S = A + B is displayed on HEX5-4, and the
// carry out is shown on LEDR0.
module part2 (SW, KEY, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR);
	input [7:0] SW;
	input [1:0] KEY;		// Used for reset and enable for A_reg
	output [0:6] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output [9:0] LEDR;

	wire [7:0] A, B, S;
	wire carry;

	// instantiate module regn (R, Clock, Resetn, Q);
	regn A_reg (SW, KEY[1], KEY[0], A);
	assign B = SW;

	// drive the displays through 7-seg decoders
	hex7seg digit_3 (A[7:4], HEX3);
	hex7seg digit_2 (A[3:0], HEX2);
	hex7seg digit_1 (B[7:4], HEX1);
	hex7seg digit_0 (B[3:0], HEX0);

	assign {carry, S} = A + B;
	hex7seg digit_5 (S[7:4], HEX5);
	hex7seg digit_4 (S[3:0], HEX4);
	assign LEDR[0] = carry;
	assign LEDR[9:1] = 9'b0;
endmodule
			
module regn (R, Clock, Resetn, Q);
	parameter n = 8;
	input [n-1:0] R;
	input Clock, Resetn;
	output [n-1:0] Q;
	reg [n-1:0] Q;	
	
	always @(posedge Clock or negedge Resetn)
		if (Resetn == 0)
			Q <= {n{1'b0}};
		else
			Q <= R;
endmodule
			
module hex7seg (hex, display);
	input [3:0] hex;
	output [0:6] display;

	reg [0:6] display;

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
	always @ (hex)
		case (hex)
			4'h0: display = 7'b0000001;
			4'h1: display = 7'b1001111;
			4'h2: display = 7'b0010010;
			4'h3: display = 7'b0000110;
			4'h4: display = 7'b1001100;
			4'h5: display = 7'b0100100;
			4'h6: display = 7'b0100000;
			4'h7: display = 7'b0001111;
			4'h8: display = 7'b0000000;
			4'h9: display = 7'b0000100;
			4'hA: display = 7'b0001000;
			4'hb: display = 7'b1100000;
			4'hC: display = 7'b0110001;
			4'hd: display = 7'b1000010;
			4'hE: display = 7'b0110000;
			4'hF: display = 7'b0111000;
		endcase
endmodule
