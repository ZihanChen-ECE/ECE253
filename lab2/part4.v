module part4(SW, LEDR, HEX0);
	input [1:0] SW;
	output [9:0] LEDR;
	output [0:6] HEX0;
	
	wire [1:0] C;
	
	assign LEDR[1:0] = SW;
	assign LEDR[9:2] = 8'b0;
	
	assign C = SW;
	
	assign HEX0[0] = ~(~C[1] & C[0]); 
	assign HEX0[1] = C[0];
	assign HEX0[2] = C[0];
	assign HEX0[3] = C[1];
	assign HEX0[4] = C[1];
	assign HEX0[5] = ~(~C[1] & C[0]); 
	assign HEX0[6] = C[1];
	

endmodule 