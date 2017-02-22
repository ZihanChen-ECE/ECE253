// uses a 1-digit bcd counter enabled at 1Hz
module part5 (CLOCK_50, HEX0);
	input CLOCK_50;
	output [0:6] HEX0;

	wire [3:0] bcd;
	parameter m = 25;
	reg [m-1:0] slow_count;

	reg[3:0] digit_flipper;

	// Create a 1Hz 4-bit counter

	// A large counter to produce a 1 second (approx) enable from the 50 MHz Clock
	always @(posedge CLOCK_50)
		slow_count <= slow_count + 1'b1;

	// four-bit counter that uses a slow enable for selecting digit
	always @ (posedge CLOCK_50)
		if (slow_count == 0)
			if (digit_flipper == 4'h9)
				digit_flipper <= 4'h0;
	 		else
				digit_flipper <= digit_flipper + 1'b1;
				
	assign bcd = digit_flipper;
	// drive the display through a 7-seg decoder
	bcd7seg digit_0 (bcd, HEX0);
	
endmodule

module bcd7seg (bcd, display);
	input [3:0] bcd;
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
	always @ (bcd)
		case (bcd)
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
			default: display = 7'bx;
		endcase
endmodule
