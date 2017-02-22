/* 
 * This program demonstrates the use of polled I/O using the KEY and timer ports. It
 * 	1. displays a sweeping red light on LEDR, which moves left and right
 * 	2. stops/starts the sweeping motion if KEY3 is pressed
*/
	
				.text								// executable code follows
				.global	_start
_start:		LDR		R6, =0xFF200000	// red LED base address
				LDR		R7, =0xFF200050	// pushbutton KEY base address
				LDR		R8, =0xFFFEC600	// base address of MPCore private timer
				MOV		R9, #0				// R9 holds shift direction; 0 means LEFT
				MOV		R10, #1				// initial pattern for LEDR
				MOV		R11, #1				// used to stop/restart the sweeping motion

				LDR		R0, =20000000		// timeout = 1/(200 MHz) x 2x10^7 = 0.1 sec
				STR		R0, [R8]				// write to timer load register
				MOV		R0, #0b011			// set bits: mode = 1 (auto), enable = 1
				STR		R0, [R8, #0x8]		// write to control register, to start timer

DO_DISPLAY: STR		R10, [R6]			// write to red LEDs
				LDR		R1, [R7, #0xC]		// load KEY edge-capture register
				CMP		R1, #0
				BEQ		NO_BUTTON
				/* check to see if KEY3 was pressed */
				STR		R1, [R7, #0xC]		// clear edge-capture register

CHECK:		TST		R1, #0b1000
				BEQ		NO_BUTTON
KEY3:			EOR		R11, #1				// toggle stop/go flag

NO_BUTTON:	CMP		R11, #0
				BEQ		DELAY					// don't change LEDR if stopped

				MOV		R0, R9				// pass shifting direction to subroutine
				MOV		R1, R10				// pass LEDR pattern to subroutine
				BL			SWEEP					// shift the displayed pattern left or right

				MOV		R9, R0				// update shift direction using return value
				MOV		R10, R1				// update LEDR pattern using return value

DELAY:		LDR		R0, [R8, #0xC]		// read timer status
				CMP		R0, #0
				BEQ		DELAY
				STR		R0, [R8, #0xC]		// reset timer flag bit

				B	 		DO_DISPLAY

/* Subroutine to rotate a string of bits either to the left or right. It reverses 
 * direction when hitting position 9 on the left, or position 0 on the right. 
 * Input and output:
 *		R0: shifting direction
 *		R1: pattern
*/
SWEEP:		CMP		R0, #0
				BNE		SHIFTR 				// shift direction 0 is left
SHIFTL:		AND		R2, R1, #0b1000000000
				CMP		R2, #0
				BNE		L_R
				LSL		R1, #1
				B			DONE_SWEEP

L_R:			MOV		R0, #1				// change direction to right
SHIFTR:		AND		R2, R1, #0b0000000001
				CMP		R2, #0
				BNE		R_L
				LSR		R1, #1
				B			DONE_SWEEP

R_L:			MOV		R0, #0				// change direction to left
				B			SHIFTL

DONE_SWEEP:	BX			LR

				.end
