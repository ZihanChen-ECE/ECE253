				.include "address_map_arm.s"
				.extern	LEDR_DIRECTION
				.extern	LEDR_PATTERN

/*****************************************************************************
 * Interval Timer - Interrupt Service Routine                                
 *   Must write to the Interval Timer to clear it. 
 *                                                                          
 * Shifts the pattern being displayed on the LEDR
 * 
******************************************************************************/
				.global PRIV_TIMER_ISR
PRIV_TIMER_ISR:	
				LDR		R0, =MPCORE_PRIV_TIMER	// base address of timer
				MOV		R1, #1
				STR		R1, [R0, #0xC]				// write 1 to F bit to reset it
															// and clear the interrupt

/* Rotate the LEDR bits either to the left or right. Reverses direction when hitting 
	position 9 on the left, or position 0 on the right */
SWEEP:		LDR		R0, =LEDR_DIRECTION	// put shifting direction into R2
				LDR		R2, [R0]
				LDR		R1, =LEDR_PATTERN		// put LEDR pattern into R3
				LDR		R3, [R1]
				CMP		R2, #0
				BNE		SHIFTR					// shift direction 0 is left
SHIFTL:
				TST		R3, #0b1000000000
				BNE		L_R
				LSL		R3, #1
				B			DONE_SWEEP

L_R:			MOV		R2, #1					// change direction to right
SHIFTR:
				TST		R3, #0b0000000001
				BNE		R_L
				LSR		R3, #1
				B			DONE_SWEEP

R_L:			MOV		R2, #0
				B			SHIFTL

DONE_SWEEP:
				STR		R2, [R0]					// put shifting direction back into memory
				STR		R3, [R1]					// put LEDR pattern back onto stack
	
END_TIMER_ISR:
				MOV		PC, LR
