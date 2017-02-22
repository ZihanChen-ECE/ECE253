//
// inputs:
// clock
// active low reset
// enable signal for the counter
//
// outputs:
//	counter values
module part3_simulation (Clock, Resetn, En, Count);
	input Clock, Resetn, En;
	output [7:0] Count;
	
	// 8-bit counter based on T-flip flops
	wire [7:0] Enable;

	assign Enable[0] = En;
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
