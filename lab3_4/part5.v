// implements a bcd adder S1 S0 = A + B
// inputs: SW7-4 = A
//         SW3-0 = B
//         SW8   = Cin
// outputs: A is displayed on HEX5
//          B is displayed on HEX3
//          S1 S0 is displayed on HEX1 HEX0
module part5 (SW, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input [8:0] SW;
	output [0:6] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	wire[3:0] A, B;
	wire Cin;
	
	wire [4:0] S0;
	wire S1;
		
	reg C1;

	wire [4:0] T0;			// used for bcd addition
	reg [4:0] Z0;			// used for bcd addition

	assign A = SW[7:4];
	assign B = SW[3:0];
	assign Cin = SW[8];
	
	// Add two bcd digits. Result is five bits: C1,S0
	assign T0 = {1'b0,A} + {1'b0,B} + Cin;
	always @ (T0)
	begin
		if (T0 > 5'd9)
		begin
			Z0 = 5'd10;		// need to subtract 10 to get least-significant digit
			C1 = 1'b1;		// most-significant digit is 1
		end
		else
		begin
			Z0 = 5'd0;		// we don't need to subtract anything when sum <= 9
			C1 = 1'b0;		// most-significant digit is 0
		end
	end

	assign S0 = T0 - Z0;	// subtract either 10 or 0
	assign S1 = C1;
	
	// drive the displays through 7-seg decoders
	bcd7seg digit3 (A, HEX5);
	bcd7seg digit2 (B, HEX3);
	bcd7seg digit1 ({3'b000,S1}, HEX1);
	bcd7seg digit0 (S0[3:0], HEX0);

	assign HEX4 = 7'b1111111; //  blank
	assign HEX2 = 7'b1111111; //  blank
	
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
			default: display = 7'b1111111;
		endcase
endmodule
	
