module part2 (SW, LEDR);
	input [9:0] SW;				// slide switches
	output [9:0] LEDR;			// red LEDs

	wire s;
	wire [3:0] X, Y, M;
	

	assign X = SW[3:0];
	assign Y = SW[7:4];
	assign s = SW[9];

	assign M[0] = (~s & X[0]) | (s & Y[0]);
	assign M[1] = (~s & X[1]) | (s & Y[1]);
	assign M[2] = (~s & X[2]) | (s & Y[2]);
	assign M[3] = (~s & X[3]) | (s & Y[3]);
	
	assign LEDR[9] = s;
	assign LEDR[8:4] = 5'b0;
	assign LEDR[3:0] = M;
endmodule
