TITLE Random Num Generator and Sorter    (program5.asm)

; Author: Shannon Jeffers
; Course / Project ID      CS 271 Program 5      Date: 2/20/2017
; Description: This program fills an array with randomly generated numbers
; displays the array, sorts the array and then displays it again.. along with
; it's median. 

INCLUDE Irvine32.inc

MIN = 10
MAX = 200
LO = 100
HI = 999

.data

progTitle	BYTE	"Random Num Generator and Sorter by Shannon Jeffers", 0
instruct	BYTE	"Enter a number between 10 and 200. The program will "
			BYTE	"generate an array of that many random numbers.", 0
instruct2	BYTE	"It will then display and sort the numbers and give the median.", 0
getInput	BYTE	"Please enter a number between 10 and 200: ", 0
ooRange		BYTE	"That number is out of range!", 0
unsorted	BYTE	"The unsorted numbers: ", 0
sorted		BYTE	"The sorted numbers: ", 0
med			BYTE	"The Median is: ", 0
bye			BYTE	"Thank you for using my program!", 0
spaces		BYTE	"   ", 0
request		DWORD	?
myArr		DWORD	MAX DUP(?)

.code
main PROC

	; seed for randomrange
	call	Randomize

	;passes progTitle and the instructs to introduction
	push	OFFSET progTitle
	push	OFFSET instruct
	push	OFFSET instruct2
	call	introduction

	;passes getInput, ooRange and request(by reference) to getData
	push	OFFSET getInput
	push	OFFSET ooRange
	push	OFFSET request
	call	getData

	; passes request and the offsert of myArray to fillArray
	push	request
	push	OFFSET myArr
	call	fillArray

	;passes request, the offset of myArr and the prompts for spaces
	;and unsorted to displayList
	push	request
	push	OFFSET myArr
	push	OFFSET spaces
	push	OFFSET unsorted
	call	displayList

	;passes the offset of myArr and request to sortList
	push OFFSET myArr
	push request
	call sortList

	;passes offset myArr, request and med to printMedian
	push	OFFSET myArr
	push	request
	push	OFFSET med
	call	printMedian

	;passes request, spaces, sorted and myArr to displayList
	push	request
	push	OFFSET myArr
	push	OFFSET spaces
	push	OFFSET sorted
	call	displayList

	;passes the bye to farewell
	push	OFFSET bye
	call	farewell



	exit	; exit to operating system
main ENDP


;------------------------------------------------------------------------------------
;Description: prints the program title and instructions
;Recieves: offset progTitle on the stack
;		   offset instruct on the stack
;		   offset instruct2 on the stack
;Returns: none
;Modifies: edx
;------------------------------------------------------------------------------------

introduction PROC
	
	push	ebp
	mov		ebp, esp

	;prints the program title and programmer name
	mov		edx, [ebp + 16]			;offset of progTitle
	call	WriteString
	call	CrLf
	call	CrLf

	;prints the program instructions
	mov		edx, [ebp + 12]			;offset of instruct
	call	WriteString
	call	CrLf
	mov		edx, [ebp + 8]			;offset of instruct2
	call	WriteString
	call	CrLf
	call	CrLf
	pop		ebp
	ret		12	;cleans up the stack

introduction ENDP


;------------------------------------------------------------------------------------
;Description: gets the data from the user, validates it, reprompts if needed
;Recieves: offset getOutput on the stack
;		   offset ooRange on the stack
;		   offset request on the stack
;Returns: users number in request
;Modifies: edx, ebx, eax
;------------------------------------------------------------------------------------

getData PROC
	push	ebp
	mov		ebp, esp

	; prints the prompt to input values, get user data and checks it
	prompt:
		mov		edx, [ebp + 16]			;offset of getInput
		call	WriteString
		call	ReadDec
		call	CrLf
		cmp		eax, MIN
		jb		error
		cmp		eax, MAX
		ja		error
		mov		ebx, [ebp + 8]			;offset of request
		mov		[ebx], eax
		jmp		leaveProc
	
	; prints a error message and jumps back to prompt
	error:
		mov		edx, [ebp + 12]			;offset of ooRange
		call	WriteString
		call	CrLf
		jmp		prompt

	leaveProc:
		call	CrLf
		pop		ebp
		ret		12	;cleans up the stack

getData ENDP


;------------------------------------------------------------------------------------
;Description: fills the aray with randomly generated numbers between the given range
;Recieves: offset myArr on the stack
;		   request on the stack
;Returns: the array filled in (numbers added in place)
;Modifies: ecx, edi, eax
;------------------------------------------------------------------------------------

fillArray PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp + 12]				;request by value
	mov		edi, [ebp + 8]				;offset of myArr

	;gets the random numbers and adds them to the array
	start:
		mov		eax, HI
		sub		eax, LO
		inc		eax
		call	RandomRange
		add		eax, LO
		mov		[edi], eax
		add		edi, 4
		loop	start

	pop		ebp
	ret		8

fillArray ENDP


;------------------------------------------------------------------------------------
;Description: display a title and the contents of the array
;Recieves: request on the stack
;		   offset myArr on the stack
;		   offset spaces on the stack
;		   offset unsorted on the stack
;Returns: none
;Modifies: edx, esi, ecx, eax
;------------------------------------------------------------------------------------

displayList PROC
	push	ebp
	mov		ebp, esp
	sub		esp, 4
	mov		DWORD PTR [ebp -4], 0			;used to count number elements printed
	mov		ecx, [ebp + 20]					;request by value
	mov		esi, [ebp + 16]					;offset of myArr
	mov		edx, [ebp + 8]					;title of the list being printed
	call	WriteString		
	call	CrLf

	;prints the contents of the array controlled by a loop
	print:
		mov		eax, [esi]
		call	WriteDec
		mov		edx, [ebp + 12]				;offset of spaces
		call	WriteString
		inc		DWORD PTR [ebp - 4];
		add		esi, 4
		cmp		DWORD PTR [ebp - 4], 10
		je		printNL
		loop	print
		jmp		leaveHere
		
	;prints a new line when necessary 
	printNL:
		mov		DWORD PTR [ebp -4], 0
		call	CrLF
		loop	print

	leaveHere:
		call	CrLf
		call	CrLf
		mov		esp, ebp
		pop		ebp
		ret		16

displayList ENDP


;------------------------------------------------------------------------------------
;Description: sorts the list in decending order. This is a modified version of the 
;			  bubble sort from the textbook.
;Recieves: offset myArr on the stack
;		   request on the stack
;Returns: the array sorted(sorts in place)
;Modifies: edx, esi, ecx, eax, edi
;------------------------------------------------------------------------------------

sortList PROC

	push	ebp
	mov		ebp, esp

	mov		ecx, [ebp + 8]					;request by value
	dec		ecx

	;sets up the outer loop
	sort:
		push	ecx
		mov		esi, [ebp + 12]				;offset myArr
	
	;compares each element, moves smaller elements to the end
	sortInner:
		mov		eax,[esi]
		cmp		[esi + 4], eax
		jb		checkNext
		push	esi
		mov		edi, esi
		add		edi, 4
		push	edi
		call	swap
		
	checkNext:
		add		esi, 4
		loop	sortInner

		pop		ecx
		loop	sort

		pop		ebp
		ret		8

sortList ENDP


;------------------------------------------------------------------------------------
;Description: exchanges the values in the array elements passed in.
;Recieves: 2 elements of the array to be swapped(by reference) the stack
;Returns: the elements are swapped in place
;Modifies: edx, eax, ebx
;------------------------------------------------------------------------------------

swap PROC

	push	ebp
	mov		ebp, esp
	
	; swaps the elements in the array locations being used
	mov		ebx, [ebp + 12]
	mov		eax, [ebx]
	mov		edx, [ebp + 8]
	xchg	eax, [edx]
	mov		[ebx], eax
	mov		[ebp + 12], ebx
	
	pop		ebp
	ret		8

swap ENDP	


;------------------------------------------------------------------------------------
;Description: finds and prints the median value in the array
;Recieves: offset myArr on the stack
;		   request on the stack
;		   offset med on the stack
;Returns: none
;Modifies: edx, esi, ebx, eax
;------------------------------------------------------------------------------------

printMedian PROC
	push	ebp
	mov		ebp, esp
	
	; checks if request is even or odd
	mov		esi, [ebp + 16]					;offset myArr
	mov		eax, [ebp + 12]					;request by value
	mov		edx, 0
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	jne		oddNum

	;adds the 2 middle numbers and divides by 2 to get mode
	mov		ecx, [esi + 4*eax]
	dec		eax
	mov		ebx, [esi + 4*eax]
	add		ecx, ebx
	mov		eax, ecx
	mov		ebx, 2
	mov		edx, 0
	cdq
	div		ebx
	cmp		edx, 0							;checks if there is a remainder
	je		printThis
	inc		eax								;if there was it equals .5 so round up
	jmp		printThis

	;gets the value directly from the array of the middle element
	oddNum:
		mov		ebx, eax
		mov		eax, [esi + 4*ebx]

	;prints either the middle element or the mode of the 2.
	printThis:
		mov		edx, [ebp + 8]				;med by reference
		call	WriteString
		call	WriteDec
		call	CrLf
		call	CrLf
		pop		ebp
		ret		12

printMedian ENDP


;------------------------------------------------------------------------------------
;Description: prints a farewell message
;Recieves: offset bye on the stack
;Returns: none
;Modifies: edx
;------------------------------------------------------------------------------------

farewell PROC

	push	ebp
	mov		ebp, esp
	mov		edx, [ebp + 8]					;offset bye
	call	WriteString
	call	CrLf
	call	CrLf
	pop		ebp
	ret		4

farewell ENDP 

END main
