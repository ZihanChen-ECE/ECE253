// Implements a circuit that can display 3-letter words on the six 
// 7-segment displays. The character selected for each display is chosen by
// a multiplexer, and these multiplexers are connected to the characters
// in a way that allows a word to be rotated across the displays from
// right-to-left as the multiplexer select lines are changed through the
// sequence 000, 001, ..., 101, 000, etc. Using the four characters d,
// E, 1, and "blank" the displays can show any 3-letter word using 
// these letters, such as "dE1 ", as follows:
//
// SW  987		Displayed characters
//     000		   dE1
//     001		  dE1
//     010		 dE1
//     011		dE1
//     100		E1   d
//     101		1   dE
//
// inputs: SW9-7 provide the multiplexer select lines
//         SW5-0 provide three different codes used to select characters
// outputs: LEDR shows the states of the switches
//          HEX5 - HEX0 displays the characters
module part6 (SW, LEDR, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [9:0] SW;				// toggle switches
	output [9:0] LEDR;			// red LEDs
	output [0:6] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;	// 7-seg displays

	wire [2:0] Ch_Sel; // mux select lines
	wire [1:0] Ch1, Ch2, Ch3, Blank;
	wire [1:0] H5_Ch, H4_Ch, H3_Ch, H2_Ch, H1_Ch, H0_Ch;

	assign LEDR = SW;
	assign Ch_Sel = SW[9:7];
	assign Ch1 = SW[5:4];
	assign Ch2 = SW[3:2];
	assign Ch3 = SW[1:0];
	assign Blank = 2'b11; // used to blank a 7-seg display (see module char_7seg)

	// instantiate module mux_2bit_6to1 (S, U, V, W, X, Y, Z, M) to
	// create the multiplexer for each hex display
	
	mux_2bit_6to1 M5 (Ch_Sel, Blank, Blank, Blank, Ch1, Ch2, Ch3, H5_Ch);
	mux_2bit_6to1 M4 (Ch_Sel, Blank, Blank, Ch1, Ch2, Ch3, Blank, H4_Ch);
	mux_2bit_6to1 M3 (Ch_Sel, Blank, Ch1, Ch2, Ch3, Blank, Blank, H3_Ch);
	mux_2bit_6to1 M2 (Ch_Sel, Ch1, Ch2, Ch3, Blank, Blank, Blank, H2_Ch);
	mux_2bit_6to1 M1 (Ch_Sel, Ch2, Ch3, Blank, Blank, Blank, Ch1, H1_Ch);
	mux_2bit_6to1 M0 (Ch_Sel, Ch3, Blank, Blank, Blank, Ch1, Ch2, H0_Ch);

	// iinstantiate module char_7seg (C, Display) to drive the hex displays
	char_7seg H5 (H5_Ch, HEX5);
	char_7seg H4 (H4_Ch, HEX4);
	char_7seg H3 (H3_Ch, HEX3);
	char_7seg H2 (H2_Ch, HEX2);
	char_7seg H1 (H1_Ch, HEX1);
	char_7seg H0 (H0_Ch, HEX0);
endmodule

// implements a 2-bit wide 6-to-1 multiplexer
module mux_2bit_6to1 (S, U, V, W, X, Y, Z, M);
	input [2:0] S;
	input [1:0] U, V, W, X, Y, Z;
	output [1:0] M;
	wire [1:4] m_0, m_1;	// four intermediate multiplexers in the mux tree for each bit

	// 6-to-1 multiplexer for bit 0
	assign m_0[1] = (~S[0] & U[0]) | (S[0] & V[0]);
	assign m_0[2] = (~S[0] & W[0]) | (S[0] & X[0]);
	assign m_0[3] = (~S[0] & Y[0]) | (S[0] & Z[0]);
	assign m_0[4] = (~S[1] & m_0[1]) | (S[1] & m_0[2]);
	
	assign M[0] = (~S[2] & m_0[4]) | (S[2] & m_0[3]);

	// 6-to-1 multiplexer for bit 1
	assign m_1[1] = (~S[0] & U[1]) | (S[0] & V[1]);
	assign m_1[2] = (~S[0] & W[1]) | (S[0] & X[1]);
	assign m_1[3] = (~S[0] & Y[1]) | (S[0] & Z[1]);
	assign m_1[4] = (~S[1] & m_1[1]) | (S[1] & m_1[2]);
	
	assign M[1] = (~S[2] & m_1[4]) | (S[2] & m_1[3]);

endmodule	

// Converts 3-bit input code on C2-0 into 7-bit code that produces
// a character on a 7-segment display. The conversion is defined by:
// 	 C 1 0	Char
// 	----------------
//	   0 0 	'd'
// 	   0 1	'E'
// 	   1 0 	'1'
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

