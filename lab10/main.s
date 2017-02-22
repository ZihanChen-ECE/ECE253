				.include	"defines.s"
/* 
 * This program demonstrates the use of interrupts using the KEY port and a timer. It
 * 	1. displays a sweeping red light on LEDR, which moves left and right
 * 	2. stops/starts the sweeping motion if KEY3 is pressed
 * Both the timer and KEYs are handled via interrupts
*/
				.text								// executable code follows
				.global	_start
_start:		
				/* Set up stack pointers for IRQ and SVC processor modes */
				MOV		R1, #INT_DISABLE | IRQ_MODE
				MSR		CPSR_c, R1					// change to IRQ mode
				LDR		SP, =0xFFFFFFFC	// set IRQ stack to top of A9 onchip memory
				/* Change to SVC (supervisor) mode with interrupts disabled */
				MOV		R1, #INT_DISABLE | SVC_MODE
				MSR		CPSR, R1						// change to supervisor mode
				LDR		SP, =0x3FFFFFFC			// set SVC stack to top of DDR3 memory

				BL			CONFIG_GIC					// configure the ARM generic interrupt controller
				BL			CONFIG_PRIV_TIMER			// configure the MPCore private timer
				BL			CONFIG_KEYS					// configure the pushbutton KEYs

				/* enable IRQ interrupts in the processor */
				MOV		R1, #INT_ENABLE | SVC_MODE		// IRQ unmasked, MODE = SVC
				MSR		CPSR_c, R1

				LDR		R6, =0xFF200000	// red LED base address
MAIN_LOOP:
				LDR		R4, LEDR_PATTERN		// LEDR pattern; modified by timer ISR
				STR		R4, [R6]					// write to red LEDs

				B 			MAIN_LOOP

/* Configure the MPCore private timer to create interrupts every 1/100 seconds */
CONFIG_PRIV_TIMER:
				LDR		R0, =0xFFFEC600
				LDR		R1, =20000000				// timeout = 1/(200 MHz) x 2x10^7 = 0.1 sec
				STR		R1, [R0]						// write to timer load register
				MOV		R1, #0b111					// set bits: int = 1, mode = 1 (auto), enable = 1
				STR		R1, [R0, #0x8]				// write to timer control register
				MOV		PC, LR
				   
/* Configure the KEYS to generate interrupts */
CONFIG_KEYS:
				// write to the pushbutton port interrupt mask register
				LDR		R0, =0xFF200050			// KEYs base address
				MOV		R1, #0xF						// set interrupt mask bits
				STR		R1, [R0, #0x8]				// interrupt mask register is (base + 8)
				MOV		PC, LR

				.global	LEDR_DIRECTION
LEDR_DIRECTION:
				.word 0									// 0 means left, 1 means right

				.global	LEDR_PATTERN
LEDR_PATTERN:
				.word 0x1
