// This is a Morse code encoder circuit. It displays the Morse code for
// letters A to H on LEDR[0]. The letter to be displayed is selected using 
// SW[3..0], using A = 000, B = 001, ..., H = 111.
module part3 (SW, CLOCK_50, KEY, LEDR);
	/******************************************************************/
	/****      PARAMETER DECLARATIONS                              ****/
	/******************************************************************/
	// SW switch patterns, Morse codes, and code lengths are defined below (in the Morse
	// code, 0 = dot, 1 = dash)
	parameter A_SW = 3'b000, A_MORSE = 4'b0010, A_LENGTH = 3'd2; /* .-   */
	parameter B_SW = 3'b001, B_MORSE = 4'b0001, B_LENGTH = 3'd4; /* -... */
	parameter C_SW = 3'b010, C_MORSE = 4'b0101, C_LENGTH = 3'd4; /* -.-. */
	parameter D_SW = 3'b011, D_MORSE = 4'b0001, D_LENGTH = 3'd3; /* -..  */
	parameter E_SW = 3'b100, E_MORSE = 4'b0000, E_LENGTH = 3'd1; /* .    */
	parameter F_SW = 3'b101, F_MORSE = 4'b0100, F_LENGTH = 3'd4; /* ..-. */
	parameter G_SW = 3'b110, G_MORSE = 4'b0011, G_LENGTH = 3'd3; /* --.  */
	parameter H_SW = 3'b111, H_MORSE = 4'b0000, H_LENGTH = 3'd4; /* .... */
	
	parameter	s_WAIT_SEND = 3'b000, s_WAIT_BLANK = 3'b001, s_SEND_DOT = 3'b010, 
			  		s_SEND_DASH_1 = 3'b011, s_SEND_DASH_2 = 3'b100, s_SEND_DASH_3 = 3'b101,
					s_RELEASE_SEND = 3'b110;
				
	/******************************************************************/
	/****      PORT DECLARATIONS                                   ****/
	/******************************************************************/	
	input [2:0] SW;
	input [1:0] KEY;
	input CLOCK_50;
	output [9:0] LEDR;

	/******************************************************************/
	/****      LOCAL WIRE DECLARATIONS                             ****/
	/******************************************************************/
	wire Clock, Resetn, go, half_sec_enable, load_regs, shift_and_count, light_on;
	reg [3:0] morse_code;
	reg [2:0] morse_length;
	reg [3:0] send_data;
	reg [2:0] data_size;
	wire [1:0] pulse_cycle;
	reg [3:0] y_Q, Y_D;

	/******************************************************************/
	/****      IMPLEMENTATION                                      ****/
	/******************************************************************/	
	assign Clock = CLOCK_50;
	assign Resetn = KEY[0];
	assign go = ~KEY[1];

	// FSM State Table
	always @(go, y_Q, send_data, data_size, half_sec_enable)
	begin: state_table
		case (y_Q)
			s_WAIT_SEND:
				if (go) Y_D = s_WAIT_BLANK;
				else Y_D = s_WAIT_SEND;
			s_WAIT_BLANK:	// sync with the half-second pulses
				if (!half_sec_enable)
					Y_D = s_WAIT_BLANK;
				else if (send_data[0] == 1'b0)
						Y_D = s_SEND_DOT;
				else
						Y_D = s_SEND_DASH_1;
			s_SEND_DOT:		// wait here for one half-second period
				if (!half_sec_enable)
					Y_D = s_SEND_DOT;
				else if (data_size == 'd1)	// check if we are done with this letter
						Y_D = s_RELEASE_SEND;
				else
						Y_D = s_WAIT_BLANK;
			s_SEND_DASH_1:	// wait for three half-second periods
				if (!half_sec_enable)
					Y_D = s_SEND_DASH_1;
				else
					Y_D = s_SEND_DASH_2;
			s_SEND_DASH_2:	// wait for two more half-second periods
				if (!half_sec_enable)
					Y_D = s_SEND_DASH_2;
				else
					Y_D = s_SEND_DASH_3;
			s_SEND_DASH_3:	// wait for one more half-second period
				if (!half_sec_enable)
					Y_D = s_SEND_DASH_3;
				else if (data_size == 'd1) // check if we are done with this letter
					Y_D = s_RELEASE_SEND;
				else
					Y_D = s_WAIT_BLANK;
			s_RELEASE_SEND:
				if (~go) Y_D = s_WAIT_SEND;
				else Y_D = s_RELEASE_SEND;
				
			default: Y_D = 3'bxxx;
		endcase
	end // state_table

	// FSM State flip-flops
	always @(posedge Clock)
		if (Resetn  == 1'b0)	// synchronous clear
			y_Q <= s_WAIT_SEND;
		else
			y_Q <= Y_D;
	
	// FSM outputs
	// turn on the Morse code light in the states below
	assign light_on = ( (y_Q == s_SEND_DOT) | (y_Q == s_SEND_DASH_1) |
		(y_Q == s_SEND_DASH_2) | (y_Q == s_SEND_DASH_3) );
	// specify when to load the Morse code into the shift register, and length into the counter
	assign load_regs = (y_Q == s_WAIT_SEND) & go;
	// specify when to shift the Morse code bits and decrement the length counter
	assign shift_and_count = ((y_Q == s_SEND_DOT) | (y_Q == s_SEND_DASH_3)) & half_sec_enable;
	
	/* Create an enable signal that is asserted once every 0.5 of a second. */
	modulo_counter half_sec( .Clock(CLOCK_50), .Resetn(Resetn), .rollover(half_sec_enable) );
		defparam half_sec.n = 25;
		defparam half_sec.k = 25000000;
	
	/* Letter selection */
	always @(*)
	case (SW)
		A_SW:	begin morse_code = A_MORSE; morse_length = A_LENGTH; end
		B_SW:	begin morse_code = B_MORSE; morse_length = B_LENGTH; end
		C_SW:	begin morse_code = C_MORSE; morse_length = C_LENGTH; end
		D_SW:	begin morse_code = D_MORSE; morse_length = D_LENGTH; end
		E_SW:	begin morse_code = E_MORSE; morse_length = E_LENGTH; end
		F_SW:	begin morse_code = F_MORSE; morse_length = F_LENGTH; end
		G_SW:	begin morse_code = G_MORSE; morse_length = G_LENGTH; end
		H_SW:	begin morse_code = H_MORSE; morse_length = H_LENGTH; end
	endcase
	
	/* Store the Morse code to be sent in a shift register, and its length in a counter */
	always@(posedge CLOCK_50)
	begin
		if (~Resetn)
		begin
			send_data <= 'd0;
			data_size <= 'd0;
		end
		else
			if (load_regs)
			begin
				send_data <= morse_code;
				data_size <= morse_length;
			end
			else if (shift_and_count) // shift and decrement when appropriate
			begin
				send_data[2:0] <= send_data[3:1];
				send_data[3] <= 1'b0;
				data_size <= data_size - 1'b1;
			end
	end							

	assign LEDR[0] = light_on;
	assign LEDR[9:1] = 9'b0;
endmodule

module modulo_counter(Clock, Resetn, rollover);
	/******************************************************************/
	/****      PARAMETER DECLARATIONS                              ****/
	/******************************************************************/
	parameter 		n = 4;
	parameter 		k = 16;
	
	/******************************************************************/
	/****      PORT DECLARATIONS                                   ****/
	/******************************************************************/
	input 	Clock, Resetn;
	output	rollover;
	reg	 	[n-1:0]	Q;

	/******************************************************************/
	/****      IMPLEMENTATION                                      ****/
	/******************************************************************/
	always@(posedge Clock)
	begin
		if (!Resetn)
			Q <= 'd0;
		else if (Q == k-1)
			Q <= 'd0;
		else
			Q <= Q + 1'b1;
	end

	assign rollover = (Q == k-1);
endmodule
