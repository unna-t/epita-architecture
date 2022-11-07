				org		$4
Vector_001		dc.l 	Main

				org		$500
Main			move.l 	#String1,a0
				jsr		Getnum
				illegal
				
				clr.l	d1
Getnum			movem.l	a1/a2,-(a7)
				move.l	a0,a1/a2
				jsr		NextOp
				move.b	(a2), d1
				move.b	#0, (a2)
				jsr		Convert
	
NextOp 			; If the character is null (end of string),
				; the string does not contain any operators.
				; A0 points to the null character. Branch to \quit.
				tst.b 	(a2)
				beq 	\quit
				; Compare successively the character to the 4 operators.
				; If the character is an operator, branch to \quit.
				; (A0 holds the address of the operator.)
				cmpi.b 	#'+',(a2)
				beq 	\quit
				cmpi.b 	#'-',(a2)
				beq 	\quit
				cmpi.b 	#'*',(a2)
				beq 	quit
				cmpi.b 	#'/',(a2)
				beq 	\quit
				; Go on with the next character.
				addq.l 	#1,a2
				bra 	NextOp
				
\quit 			; Return from subroutine.
				rts
							
Convert 		; If the string is empty,
				; return false (error).
				tst.b 	(a0)
				beq 	\false
				; (At this stage, the string is not empty.)
				; If a character error occurs,
				; return false (error).
				jsr 	IsCharError
				beq 	\false
				; (At this stage, the string is not empty
				; and contains only digits.)
				; If the integer value of the string is higher than 32,767,
				; return false (error).
				jsr 	IsMaxError
				beq 	\false
				; The string is valid. We can convert it
				; and return true (no error).
				jsr 	Atoui
\true 			; Return Z = 1 (no error).
				ori.b 	#%00000100,ccr
				rts
\false 			; Return Z = 0 (error).
				andi.b 	#%11111011,ccr
				rts
IsCharError		; Save registers on the stack.
				movem.l	d0/a0,-(a7)
				\loop ; Load a character of the string into D0 and increment A0.
				; If the character is null, return false (no error).
				move.b 	(a0)+,d0
				beq 	\false
				; Compare the character to the '0' character.
				; If it is lower, return true (it is not a digit).
				cmpi.b 	#'0',d0
				blo 	\true
				; Compare the character to the '9' character.
				; If it is lower or equal, branch to \loop (it is a digit).
				; If it is higher, return true (it is not a digit).
				cmpi.b 	#'9',d0
				
				bls 	\loop
\true 			; Return Z = 1 (error).
				; (The BRA instruction does not modify Z.)
				ori.b 	#%00000100,ccr
				bra 	\quit
				
\false 			; Return Z = 0 (no error).
				andi.b #%11111011,ccr
				
\quit 			; Restore registers from the stack and return from subroutine.
				; (The MOVEM and RTS instructions do not modify Z.)
				movem.l	(a7)+,d0/a0
				rts
				
IsMaxError 		; Save registers on the stack.
				movem.l	d0/a0,-(a7)
				; Get the length of the string (in D0).
				jsr StrLen
				; If the length is longer than 5 characters, return true (error).
				; If the length is shorter than 5 characters, return false (no error).
				cmpi.l	#5,d0
				bhi		\true
				blo 	\false
				; If the length is equal to 5 characters:
				; Successive comparisons with '3', '2', '7', '6' and '7'.
				; If longer, return true (error).
				; If shorter, return false (no error).
				; If equal, compare to the next character.
				cmpi.b 	#'3',(a0)+
				bhi 	\true
				blo 	\false
				cmpi.b 	#'2',(a0)+
				bhi 	\true
				blo 	\false
				cmpi.b 	#'7',(a0)+
				bhi 	\true
				blo 	\false
				cmpi.b 	#'6',(a0)+
				bhi 	\true
				blo 	\false
				cmpi.b 	#'7',(a0)
				bhi 	\true
				
\false 			; Return Z = 0 (no error).
				; (The BRA instruction does not modify Z.)
				andi.b 	#%11111011,ccr
				bra 	\quit
				
\true 			; Return Z = 1 (error).
				ori.b 	#%00000100,ccr
				
\quit 			; Restore registers from the stack and return from subroutine.
				; (The MOVEM and RTS instructions do not modify Z.)
				movem.l (a7)+,d0/a0
				rts


Atoui 			; Save registers on the stack.
				movem.l	d1/a0,-(a7)
				; Initialize the output variable to 0.
				clr.l	 d0
				; Initialize the conversion variable to 0.
				clr.l 	d1
\loop 			; Copy the current character into D1.
				; Then A0 points to the next character (postincrement mode).
				move.b 	(a0)+,d1
				; If the copied character is null,
				; branch to \quit (end of string).
				beq 	\quit
				; Otherwise, the character is converted into an integer.
				subi.b 	#'0',d1
				; Shift the output variable to the left (x10),
				; and add the integer value.
				mulu.w 	#10,d0
				add.l 	d1,d0
				; Next character.
				bra 	\loop
\quit 			; Restore registers from the stack and return from subroutine.
				movem.l	(a7)+,d1/a0
				rts
				
String1			dc.b	"104+9*2-3",  0	
