module part3(SW, LEDR);

	output [9:0] LEDR;
	input [9:0] SW;

	
	wire m_0, m_1;
	wire [1:0] S, U, V, W, M;
	
	assign S[1:0] = SW[9:8];
	assign U[1:0] = SW[1:0];
	assign V = SW[3:2];
	assign W = SW[5:4];
	
	// 3-to-1 multiplexer for bit 0
	assign m_0 = (~S[0] & U[0]) | (S[0] & V[0]);	
	assign M[0] = (~S[1] & m_0) | (S[1] & W[0]); // 3-to-1 multiplexer output

	// 3-to-1 multiplexer for bit 1
	assign m_1 = (~S[0] & U[1]) | (S[0] & V[1]);	
	assign M[1] = (~S[1] & m_1) | (S[1] & W[1]); // 3-to-1 multiplexer output
	
	
	assign LEDR[1:0] = M;
	assign LEDR[9:2] = 8'b0;

endmodule	
	