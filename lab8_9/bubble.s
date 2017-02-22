/* This program implements a bubble sort algorithm */
				.text							// executable code follows
				.global	_start
_start:		
				LDR		R4, =LIST		// load the address of the list into R4

				LDR		R10, [R4]		// R10 = number of elements to be sorted

OUTER_LOOP:	MOV		R8, #0			// clear flag that indicates nothing is left to be sorted
				MOV		R9, #1			// loop counter
				ADD		R5, R4, #4		// point to the first data item

SORT_LOOP:	CMP		R9, R10			// reached the end of the list?
				BEQ		END_FOR
				MOV		R0, R5			// pass parameter to SWAP in R0
				BL			SWAP

				ORR		R8, R8, R0		// save the flag returned by SWAP

				ADD		R9, R9, #1
				ADD		R5, R5, #4		// point to next list element
				B			SORT_LOOP

END_FOR:		SUB		R10, R10, #1	// no need to re-sort the last element!
				CMP		R8, #0			// check if any swap was done
				BNE		OUTER_LOOP

				LDR R4, =LIST     //re-read
				LDR R10, [R4]
				ADD R4, R4, #4
				MOV R6, #0
READ_LOOP:      CMP R10, #0
				BEQ END
				LDR R6, [R4]
				ADD R4, R4, #4
				SUB R10, R10, #1
				B READ_LOOP
				
END:			B			END

/* Subroutine to swap list elements
 * Parameter: R0 points to the first element
 * Returns: R0 = 1 if a swap was done, else R0 = 0
 */
SWAP:			MOV		R3, R0
				MOV		R0, #0			// initialize return value to 0

				LDR		R1, [R3]			// get first list element from memory
				LDR		R2, [R3, #4]	// get second list element from memory
				CMP		R1, R2
				BGT		END_SWAP

				STR		R2, [R3]
				STR		R1, [R3, #4]
				MOV		R0, #1			// set return value to 1

END_SWAP:	BX			LR					// return the result

LIST:			.word		10,1400,45,23,5,3,8,17,4,20,33

				.end    
