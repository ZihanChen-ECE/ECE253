// Implements a circuit that can display different 3-letter words on three 7-segment
// displays. The character selected for each display is chosen by
// a multiplexer, and these multiplexers are connected to the characters
// in a way that allows a word to be rotated across the displays from
// right-to-left as the multiplexer select lines are changed through the
// sequence 00, 01, 10, 00, etc. Using the three characters d,
// E, 1, the displays can scroll any 3-letter word using these letters, such 
// as "dE1", as follows:
//
// SW  9  8    Displayed characters
//     0  0    dE1
//     0  1    E1d
//     1  0    1dE
//
// inputs: SW9-8 provide the multiplexer select lines
//         SW5-0 provide three 2-bit codes used to select characters
// outputs: LEDR shows the states of the switches
//          HEX2 - HEX0 displays the characters
module part5 (SW, LEDR, HEX2, HEX1, HEX0);
	input [9:0] SW;				// toggle switches
	output [9:0] LEDR;			// red LEDs
	output [0:6] HEX2, HEX1, HEX0;	// 7-seg displays

	assign LEDR = SW;

	wire [1:0] Ch_Sel, Ch1, Ch2, Ch3;
	wire [1:0] H2_Ch, H1_Ch, H0_Ch;
	assign Ch_Sel = SW[9:8];
	assign Ch1 = SW[5:4];
	assign Ch2 = SW[3:2];
	assign Ch3 = SW[1:0];	

	// instantiate module mux_2bit_3to1 (S, U, V, W, M);
	mux_2bit_3to1 M2 (Ch_Sel, Ch1, Ch2, Ch3, H2_Ch);
	mux_2bit_3to1 M1 (Ch_Sel, Ch2, Ch3, Ch1, H1_Ch);
	mux_2bit_3to1 M0 (Ch_Sel, Ch3, Ch1, Ch2, H0_Ch);
	

	// instantiate module char_7seg (C, Display);
	char_7seg H2 (H2_Ch, HEX2);
	char_7seg H1 (H1_Ch, HEX1);
	char_7seg H0 (H0_Ch, HEX0);
endmodule

// Implements a 2-bit wide 3-to-1 multiplexer
module mux_2bit_3to1 (S, U, V, W, M);
	input [1:0] S, U, V, W;
	output [1:0] M;
	wire  m_0, m_1;	// intermediate multiplexers

	// 3-to-1 multiplexer for bit 0
	assign m_0 = (~S[0] & U[0]) | (S[0] & V[0]);	
	assign M[0] = (~S[1] & m_0) | (S[1] & W[0]); // 3-to-1 multiplexer output

	// 3-to-1 multiplexer for bit 1
	assign m_1 = (~S[0] & U[1]) | (S[0] & V[1]);	
	assign M[1] = (~S[1] & m_1) | (S[1] & W[1]); // 3-to-1 multiplexer output
	
	
endmodule	

// Converts 2-bit input code on C1-0 into 7-bit code that produces
// a character on a 7-segment display. The conversion is defined by:
// 	 C 1 0	Char
// 	----------------
// 	   0 0	'd'
// 	   0 1	'E'
// 	   1 0	'1'
// 	   1 1	' ' Blank
//
//    
//
module char_7seg (C, Display);
	input [1:0] C;		// input code
	output [0:6] Display;	// output 7-seg code

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
	// the following equations describe display functions in cannonical SOP form
	assign Display[0] = ~(~C[1] & C[0]); 
	assign Display[1] = C[0];
	assign Display[2] = C[0];
	assign Display[3] = C[1];
	assign Display[4] = C[1];
	assign Display[5] = ~(~C[1] & C[0]); 
	assign Display[6] = C[1];
endmodule

