// Simple module that connects the SW switches to the LEDR lights
module part1 (SW, LEDR);
	input [9:0] SW;				// toggle switches
	output [9:0] LEDR;			// red LEDs

	assign LEDR[9:0] = SW[9:0];
endmodule
