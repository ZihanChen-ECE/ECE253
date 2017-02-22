// Display digits from 0 to 9 on the 7-segment displays, using the SW
// toggle switches as inputs.
module part1 (SW, LEDR, HEX1, HEX0);
	input [7:0] SW;
	output [7:0] LEDR;	
	output [0:6] HEX1, HEX0;

	assign LEDR = SW;

	// drive the displays through 7-seg decoders
	bcd7seg digit1 (SW[7:4], HEX1);
	bcd7seg digit0 (SW[3:0], HEX0);
	
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
