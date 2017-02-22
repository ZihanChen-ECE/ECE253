/***************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine checks which KEY has been pressed.  If KEY3 it stops/starts the timer.
****************************************************************************************/
					.global	KEY_ISR
KEY_ISR: 		LDR		R0, =0xFF200050		// base address of KEYs parallel port
					LDR		R1, [R0, #0xC]			// read edge capture register
					STR		R1, [R0, #0xC]			// clear the interrupt

CHK_KEY3:		TST		R1, #0b1000				// KEY 3 pressed?
					BEQ		END_KEY_ISR

					LDR		R0, =0xFFFEC600		// timer base address
					LDR		R1, [R0, #0x8]			// read timer control register
					EOR		R1, R1, #1				// toggle the enable bit
					STR		R1, [R0, #0x8]			// write to the timer control register

END_KEY_ISR:	MOV	PC, LR
					.end
	
