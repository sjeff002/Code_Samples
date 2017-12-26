TITLE Composite Number Printer     (program4.asm)

; Author: Shannon Jeffers
; Course / Project ID   CS 271 Program4       Date: 2/5/2017
; Description:

INCLUDE Irvine32.inc

UPPER = 400
LOWER = 1

.data
myName		BYTE	"programmed by Shannon Jeffers", 0
spaces		BYTE	"   ", 0
progtitle	BYTE	"Composite Number Printer ", 0
instruct	BYTE	"Enter a number 1-400 and I will print that many composite numbers for you.", 0
prompt		BYTE	"Enter a number 1-400: ", 0
errormsg	BYTE	"Out of Range! The number must be between 1 and 400 (incusive!).", 0
parting		BYTE	"Thank you for using my program!", 0
adios		BYTE	"Adios, Au revoir, Bon voyage, Chio! Or well you know, Goodbye!", 0
divisor		DWORD	2
nextNum		DWORD	4
sqrtNum		DWORD	?
userNum		DWORD	?
printCount	DWORD	0



.code
main PROC ;makes calls to other procs

	call	introduction
	call	getUserData
	call	showComposites
	call	farewell

	exit	; exit to operating system
main ENDP


;-------------------------------------------------------------------------------
;Description: prints the programmer name, title of the program and instructions
;Reveives: progTitle, myName, and instruct are globals.
;Returns: None
;precondition: called from main
;postcondition: intro is displayed on screen
;modified registers: edx
;-------------------------------------------------------------------------------

introduction PROC ;handles introduction for program

	;prints the program title and programmer name
	mov		edx, OFFSET progTitle
	call	WriteString
	mov		edx, OFFSET myName
	call	WriteString
	call	CrLf
	call	CrLF

	;prints the instructions for the program
	mov		edx, OFFSET instruct
	call	WriteString
	call	CrLf

	ret ;return to caller(main)
introduction ENDP


;-------------------------------------------------------------------------------
;Description: gets user number calls validate to validate
;Reveives: prompt, userNum are globals
;Returns: stores a number in userNum
;precondition: called from main
;postcondition: userNum contains user entered number
;modified registers: edx, eax
;-------------------------------------------------------------------------------

getUserData PROC

	;gets user input
	getInput:
		mov		edx, OFFSET prompt	;prompt to enter a number
		call	WriteString
		call	ReadDec
		mov		userNum, eax
		call	validate
		call	CrLf
		call	CrLf
		ret		;reuturn to caller(main)

getUserData ENDP




;-------------------------------------------------------------------------------
;Description: checks to see if user number is in range. If not displayes error
;- message and repromopts user.
;Reveives: prompt, userNum, errormsg are globals. LOWER and UPPER constants.
;Returns: stores a number in userNum
;precondition: called getuserdata, must contain a number is userNum
;postcondition: userNum contains a validated user entered number
;modified registers: edx, eax
;-------------------------------------------------------------------------------

validate PROC

	valid:
		mov		eax, userNum
		cmp		eax, LOWER	;checks if number is too low
		jl		error
		cmp		eax, UPPER	;checks if number is too high
		jg		error
		jmp		leaveProc


	;error message to indicate the range was not right and reprompt
	error:
		mov		edx, OFFSET errormsg	;gives a warning of the number is out of range
		call	WriteString
		call	CrLf
		mov		edx, OFFSET prompt	;prompt to enter a number
		call	WriteString
		call	ReadDec
		mov		userNum, eax
		jmp		valid

	leaveProc:
		ret

validate ENDP


;-------------------------------------------------------------------------------
;Description: calls isCompoiste, prints the composites, spaces and new lines.
;Reveives: nextNum, userNum, printCount, divisor are globals
;Returns: printCount number chances, next num is increased, divisor set back to 2
;precondition: called from main
;postCondition: all composites user requested printed to the screen
;modified registerS: eax, ecx, edx
;-------------------------------------------------------------------------------

showComposites PROC

	;sets up the loop
	mov		ecx, userNum

	showThem:
		call	isComposite

		mov		eax, nextNum
		call	WriteDec
		mov		edx, OFFSET spaces	;print spaces between composites
		call	WriteString
		inc		printCount
		inc		nextNum
		mov		divisor, 2
		cmp		printCount, 10		;check if 10 has been printed
		je		printNewLine
		loop	showThem 
		jmp		finished

	;prints a new line if 10 composites have been printed
	printNewLine:
		call	CrLF
		mov		printCount, 0
		loop	showThem
	
	
	finished:
		call	CrLf
		ret				;returns to caller(main)
showComposites ENDP




;-------------------------------------------------------------------------------
;Description: locates a composite by finding a numbers square root and dividing
;- until its sqrt is smaller than the divisor, or the remainder is 0.
;Reveives: nexNum, sqrtNum, divisor are globals
;Returns: divisor, sqrtNum and nextNum get changed.
;precondition: called from showComposites, nextNum needs to be greater than 0
;postCondition: a number is determined to be a compoiste and it returns to show
;modified registerS: eax, edx
;-------------------------------------------------------------------------------

isComposite PROC

	;finds square root to eliminate need to check all divisors 
	getSqrt:
		fild	nextNum
		fsqrt
		fisttp	sqrtNum		;stores square root(truncated) in memory

	;checks square root against the divisor
	checkNumber:
		mov		eax, sqrtNum
		cmp		divisor, eax
		jle		nextStep	;divisor is less than or equal to number
		jmp		getNextNum	;sqrt of number is less than divisor

	;divides current number by divisor
	nextStep:
		mov		eax, nextNum
		mov		edx, 0
		div		divisor
		cmp		edx, 0
		je		exitIsComposite ;if there is no remainder, it is composite we exit
		jmp		nextDivisor	;else, get next divisor

	;reset divisor, increment number
	getNextNum:
		inc		nextNum
		mov		divisor, 2
		jmp		getSqrt		

	;increments divisor
	nextDivisor:
		inc		divisor
		jmp		checkNumber
	
	exitIsComposite:
		ret

isComposite ENDP




;-------------------------------------------------------------------------------
;Description: prints a farewell message
;Reveives: parting, adios are globals
;Returns: None
;precondition: called from main
;postcondition: farewell message is displayed
;modified registers: edx
;-------------------------------------------------------------------------------
farewell PROC
	
	;prints goodbye message
	call	CrLf
	mov		edx, OFFSET parting
	call	WriteString
	call	CrLf
	mov		edx, OFFSET adios
	call	WriteString
	call	CrLf
	ret

farewell ENDP

END main
