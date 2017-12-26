TITLE Combination Tester    (program6B.asm)

; Author: Shannon Jeffers
; Course / Project ID     CS 271 Program 6      Date: 2/27/2017
; Description: Program that drills the user on combination problems that are randomly generated.

INCLUDE Irvine32.inc

WriteMyString MACRO string
	push	edx
	mov		edx, string
	call	WriteString
	pop		edx
ENDM

NLOW = 3
NHIGH = 12
RLOW = 1

.data

titleName	BYTE	"Welcome to the Combination Tester by Shannon Jeffers", 0
instruct	BYTE	"The number of items r and size of set n are randomly generated.", 0
instruct2	BYTE	"Just provide your answer and I will tell you the correct answer.", 0
set			BYTE	"Number of elements in the set: ",0
elements	BYTE	"Number of elements to choose from the set: ", 0
prompt		BYTE	"Please enter your answer: ", 0
errormsg	BYTE	"That was not an integer. Try again: ", 0
right		BYTE	"The right answer was ", 0
yours		BYTE	" and you answered ", 0
correct		BYTE	"You were spot on! Good work!", 0
wrong		BYTE	"Not quite right. Keep practicing!", 0
again		BYTE	"Would you like to play again? y/n: ", 0
error2		BYTE	"Invalid response. ", 0
adios		BYTE	"Thanks for playing! Goodbye!", 0
userInput	BYTE	11 DUP(0)
n			DWORD	?
r			DWORD	?
result		DWORD	?
answer		DWORD	?


.code
main PROC

	call	Randomize

	
	push	OFFSET titleName
	push	OFFSET instruct
	push	OFFSET instruct2
	call	introduction

	;start of the combination excersize program
	play:
		push	OFFSET set
		push	OFFSET elements
		push	OFFSET n
		push	OFFSET r
		call	showProblem


		push	OFFSET userInput
		push	OFFSET answer
		push	OFFSET prompt
		push	OFFSET errormsg
		call	getData


		push	n
		push	r
		push	OFFSET result
		call	combinations

		push	OFFSET right
		push	OFFSET yours
		push	OFFSET correct
		push	OFFSET wrong
		push	result
		push	answer
		call	showResults

	;prompt to see if user wants to run drill again
	promptAgain:
		WriteMyString	OFFSET again
		call	ReadChar
		call	CrLf
		cmp		al, 'y'
		je		play
		cmp		al, 'Y'
		je		play
		cmp		al, 'n'
		je		quit
		cmp		al, 'N'
		je		quit
		
		WriteMyString	OFFSET error2
		jmp		promptAgain

	quit:
		push	OFFSET adios
		call	farewell


	exit	; exit to operating system
main ENDP


;------------------------------------------------------------------------------------
;Description: prints the program title and instructions
;Recieves: offset titleName on the stack
;		   offset instruct on the stack
;		   offset instruct2 on the stack
;Returns: none
;Modifies: none
;------------------------------------------------------------------------------------

introduction PROC
	push	ebp
	mov		ebp, esp

	;prints program title, programmer name and instructions
	WriteMyString	[ebp + 16]				;offset titleName
	call			CrLf
	call			CrLf
	WriteMyString	[ebp + 12]				;offset instruct
	call			CrLf
	WriteMyString	[ebp + 8]				;offset instruct 2
	call			CrLf


	pop ebp
	ret 12

introduction ENDP


;------------------------------------------------------------------------------------
;Description:randomly generates size of set and number of elements to be chosen from 
; the set.
;Recieves: offset set on the stack
;		   offset elements on the stack
;		   offset n on the stack
;		   offset r on the stack
;Returns: none
;Modifies: eax, edx
;------------------------------------------------------------------------------------

showProblem PROC
	push	eax
	push	edx
	push	ebp
	mov		ebp, esp

	call CrLf
	WriteMyString	[ebp + 28]				;offset set

	;finds a random number in the rante [3-12]
	mov		eax, NHIGH
	sub		eax, NLOW
	inc		eax
	call	RandomRange
	add		eax, NLOW
	mov		edx, [ebp + 20]					;offset of n, for set
	mov		[edx], eax
	call	WriteDec
	call	CrLf

	WriteMyString	[ebp + 24]				;offset elements

	;generates a random r between 1 and n from above
	call	RandomRange
	add		eax, RLOW
	mov		edx, [ebp + 16]					;offset of r, number of elements chosen
	mov		[edx], eax
	call	WriteDec
	call	CrLf
	call	CrLf

	pop		ebp
	pop		edx
	pop		eax
	ret		16

showProblem ENDP
	

;------------------------------------------------------------------------------------
;Description: gets and verifies users answer. verifies by ensuring it is a number
;Recieves: offset userInput on the stack
;		   offset answer on the stack
;		   offset prompt on the stack
;		   offset errormsg on the stack
;Returns: none
;Modifies: eax, ebx, ecx, esi, edi
;------------------------------------------------------------------------------------

getData PROC
	
	push	eax
	push	ebx
	push	ecx
	push	esi
	push	edx
	push	ebp
	mov		ebp, esp


	;gets input from user as a string
	start:
		WriteMyString	[ebp + 32]				;offset of prompt

		mov		edx, [ebp + 40]					;offset userInput
		mov		ecx, 10
		call	ReadString
		call	CrLf

		;sets up registers for use
		mov		esi, [ebp + 40]
		mov		ecx, 10
		mov		ebx, 0
		mov		eax, 0
		cld

	;loads byte into register al
	load:
		lodsb
		cmp		al, 0
		je		endOfString

		cmp		al, 48							;ensures al is >= 0
		jb		notNum
		cmp		al, 57							;ensures al is <= 9
		ja		notNum

		sub		al, 48							;get the integer value
		xchg	eax, ebx
		mul		ecx								;determines digit place
		jc		notNum							;technically is a num, just too big
		jmp		num

	;if the input was not a numner, try again
	notNum:
		WriteMyString	[ebp + 28]				;offset of errormsg		
		jmp		start

	;if it is a number, set it up to get the next number
	num:
		add		eax, ebx
		xchg	eax, ebx	;ensures number is in proper position
		jmp		load

	endOfString:
		mov		eax, [ebp + 36]					;offset of answer
		mov		[eax], ebx
		pop		ebp
		pop		edx
		pop		esi
		pop		ecx
		pop		ebx
		pop		eax
		ret		16

getData ENDP


;------------------------------------------------------------------------------------
;Description: calculates the correct combination answer, calls factorial 
;Recieves: n on the stack
;		   r on the stack
;		   offset result on the stack
;Returns: none
;Modifies: eax, ecx, ebx, edx
;------------------------------------------------------------------------------------

combinations PROC
	push	eax
	push	ecx
	push	ebx
	push	edx
	push	ebp
	mov		ebp, esp

	;gets the factorial value for n
	push	[ebp + 32]						;push n on the stack
	call	factorial
	mov		ecx, eax						;ecx contains n!

	;gets the factorial value for r
	push	[ebp + 28]						;push r on the stack
	call	factorial
	mov		ebx, eax						;ebx contains r!

	;gets factorial value for (n-r)
	mov		eax, [ebp + 32]
	mov		edx, [ebp + 28]
	sub		eax, edx
	push	eax
	call	factorial
	
	mul		ebx
	mov		ebx, eax						;bottom r!(n-r)!


	mov		eax, ecx
	div		ebx

	mov		edx, [ebp + 24]
	mov		[edx], eax

	pop		ebp
	pop		edx
	pop		ebx
	pop		ecx
	pop		eax
	ret		12

combinations ENDP


;------------------------------------------------------------------------------------
;Description: calculates the factorial value **modified from version in the textnook**
;Recieves: number to get factorial for on the stack
;Returns: factorial answer in eax
;Modifies: ebx, eax
;------------------------------------------------------------------------------------

factorial PROC
	push	ebx
	push	ebp
	mov		ebp, esp

	;checks base case
	mov		eax, [ebp + 12]					;value to be factorialed
	cmp		eax, 0
	ja		nextFact
	mov		eax, 1
	jmp		leaveproc

	;calls factorial recursively on next smaller number
	nextFact:
		dec		eax
		push	eax
		call	factorial

		mov		ebx, [ebp + 12]
		mul		ebx

	leaveProc:
		pop		ebp
		pop		ebx
		ret		4

factorial	ENDP


;------------------------------------------------------------------------------------
;Description: Shows the result and answers if the user got the problem right
;Recieves: offset right on the stack
;		   offset yours on the stack
;		   offset correct on the stack
;		   offset wrong on the stack
;		   result on the stack
;		   answers on the stack
;Returns: none
;Modifies: eax
;------------------------------------------------------------------------------------

showResults PROC

	push	eax
	push	ebp
	mov		ebp, esp

	;tells user correct answer and entered answer
	WriteMyString	[ebp + 32]					;offset right
	mov		eax, [ebp + 16]						;result value
	call	WriteDec
	WriteMyString	[ebp + 28]					;offset yours
	mov		eax, [ebp + 12]						;answer value
	call	WriteDec
	call	CrLf

	;sees if user was right, prints correct message if so
	cmp		eax, [ebp + 16]
	jne		needsWork
	WriteMyString	[ebp + 24]					;offset correct
	jmp		outOfHere

	;prints user wrong message
	needsWork:
		WriteMyString	[ebp + 20]				;offset of wrong

	outOfHere:
		call	CrLf
		call	CrLf
		pop		ebp
		pop		eax
		ret		24

showResults ENDP


;------------------------------------------------------------------------------------
;Description: prints a farewell message to the screen
;Recieves: offset adios on the stack
;Returns: none
;Modifies: none
;------------------------------------------------------------------------------------

farewell PROC
	push	ebp
	mov		ebp, esp


	;prints goodbye message
	call	CrLf
	call	CrLf
	WriteMyString [ebp + 8]
	call CrLf
	call CrLf

	pop ebp
	ret 4

farewell ENDP

END main
