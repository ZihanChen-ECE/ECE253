//
// inputs:
// KEY0: manual clock
// SW0: active low reset
// SW1: enable signal for the counter
//
// outputs:
//	HEX0 - HEX1: hex segment displays
module part3 (SW, KEY, HEX1, HEX0);
	input [1:0] SW ;
	input [0:0] KEY ;
	output [0:6] HEX1, HEX0;
	
	wire Clock = KEY[0];
	wire Resetn = SW[0];
	
	// 8-bit counter based on T-flip flops
	wire [7:0] Count;
	wire [7:0] Enable;

	assign Enable[0] = SW[1];
	ToggleFF ff0(Enable[0], Clock, Resetn, Count[0]);
	assign Enable[1] = Count[0] & Enable[0];
	ToggleFF ff1(Enable[1], Clock, Resetn, Count[1]);
	assign Enable[2] = Count[1] & Enable[1];
	ToggleFF ff2(Enable[2], Clock, Resetn, Count[2]);
	assign Enable[3] = Count[2] & Enable[2];
	ToggleFF ff3(Enable[3], Clock, Resetn, Count[3]);
	assign Enable[4] = Count[3] & Enable[3];
	ToggleFF ff4(Enable[4], Clock, Resetn, Count[4]);
	assign Enable[5] = Count[4] & Enable[4];
	ToggleFF ff5(Enable[5], Clock, Resetn, Count[5]);
	assign Enable[6] = Count[5] & Enable[5];
	ToggleFF ff6(Enable[6], Clock, Resetn, Count[6]);
	assign Enable[7] = Count[6] & Enable[6];
	ToggleFF ff7(Enable[7], Clock, Resetn, Count[7]);
	
	// drive the displays
	hex7seg digit1 (Count[7:4], HEX1);
	hex7seg digit0 (Count[3:0], HEX0);
endmodule

module ToggleFF(T, Clock, Resetn, Q);
	input T, Clock, Resetn;
	output reg Q;
	
	always @(posedge Clock)
		if (Resetn  == 1'b0)	// synchronous clear
			Q <= 1'b0;
		else if(T)
			Q <= ~Q;
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
