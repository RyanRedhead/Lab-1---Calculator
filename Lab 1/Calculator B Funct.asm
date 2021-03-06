;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section

myProgram:	.byte	0x22, 0x11, 0x22, 0x22, 0x33, 0x33, 0x08, 0x44, 0x08, 0x22, 0x09, 0x44, 0xff, 0x11, 0xff, 0x44, 0xcc, 0x33, 0x02, 0x33, 0x00, 0x44, 0x33, 0x33, 0x08, 0x55

			.data
myResults:	.space	20

ADD_OP:		.equ	0x11
SUB_OP:		.equ	0x22
MUL_OP:		.equ	0x33
CLR_OP:		.equ	0x44
END_OP:		.equ	0x55
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
		mov.w 	#0xC000, 	r5					;myProgram starts at 0xC000
		mov.w 	#0x0200, 	r6					;readying RAM to be written to
		mov.w	#0x0000,	r10					;this is the register that will hold the final value
		mov.b 	0(r5), 		r7					;moves first part of myProgram into r7 then every third value
		inc r5									;moves RAM and address of myProgram to next value to store/load respectively
Inputs
		mov.b	0(r5), 		r8					;next value loaded into next register
		inc		r5
		mov.b 	0(r5),		r9					;same as comments above
		inc 	r5								;three values are loaded into 3 registers to be manipulated
		cmp		#ADD_OP,	r8
		jeq 	Addition
		cmp		#SUB_OP,	r8
		jeq 	Subtraction
		cmp		#MUL_OP,	r8
		jeq		Multiply
		cmp		#CLR_OP,	r8
		jeq		Clear
		cmp		#END_OP,	r8
		jeq 	End

Addition
		add		r7,		r9
		mov.w		r9,		r10
		mov.w		r10, 		r7
		jmp		ErrorCheck

Subtraction
		sub		r9,		r7
		mov.w		r7,		r10
		mov.w		r10,		r7
		jmp ErrorCheck

Multiply

		cm		 #0x0000	r7
		jz EndMultiply
		cmp 		#0x0000, 	r9
		jz EndMultiply1
		rra		r9
		jnc		MultiplyMore
		add		r9, 		r7
		jmp Multiply

MultiplyMore
		rla		r7
		jmp		Multiply

EndMultiply
		mov.w		r7,		r10
		mov.w		r10,		r7
		jmp ErrorCheck


EndMultiply1
		mov.w 		r9,		r10
		mov.w 		r10,		r7
		jmp ErrorCheck

Clear
		mov.w 		#0x0000, 	r10
		mov.w		r9,		r7
		jmp ErrorCheck

ErrorCheck

		cmp 		#0x0000,	r10
		jl		Lower
		cmp		#256,		r10
		jhs		Higher
		mov.b		r10,		0(r6)
		inc		r6
		jmp Inputs

Lower
		mov.w 		#0x0000,	r10
		jmp ErrorCheck

Higher
		mov.w		#0x00FF,	r10
		jmp ErrorCheck

End jmp End
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
