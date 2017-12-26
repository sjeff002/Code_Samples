TITLE Fibonacci Generator     (program2.asm)

; Author: Shannon Jeffers
; Course / Project ID   271 Program 2       Date: 1/16/2017
; Description: Demonstrates the use of loops and jump statements to generate fibonnaci numbers

INCLUDE Irvine32.inc

UPPER = 46
LOWER = 1

.data

myName		BYTE	"Shannon Jeffers", 0
pTitle		BYTE	"Fibonacci Generator", 0
userName	BYTE	50 DUP(0)
nameSize	DWORD	?
prompt1		BYTE	"What is your name? ", 0
sayHi		BYTE	"Hello, ", 0
prompt2		BYTE	"How many Fibonacci terms would you like to see?", 0
prompt3		BYTE	"Please enter a number between 1 and 46: ", 0
ooRange		BYTE	"Out of Range! The number must be between 1 and 46!", 0
spaces		BYTE	"     ", 0
userNum		DWORD	?
fib			DWORD	1
temp		DWORD	0
count		DWORD	0
bye			BYTE	"Thanks for playing! Bye, ", 0

.code
main PROC

	; Introduction of programmer and user greeting
	mov edx, OFFSET myName ;move offset of myName to be printed
	call WriteString
	call CrLf
	mov edx, OFFSET pTitle ;move offset of title of prog to be printed
	call WriteString
	call CrLf
	call CrLf

	mov edx, OFFSET prompt1 ;asks for user name
	call WriteString
	mov edx, OFFSET userName
	mov ecx, 49
	call ReadString
	mov nameSize, eax

	mov edx, OFFSET sayHi ;says hi to the user
	call WriteString
	mov edx, OFFSET userName
	call WriteString
	call CrLf
	call CrLf

	mov edx, OFFSET prompt2 ;gives the use insructions
	call WriteString
	call CrLf
	mov edx, OFFSET prompt3
	call WriteString

;get input from user and ensure proper range
getInput:
	call ReadDec
	mov userNum, eax
	cmp eax, LOWER
	jl error
	cmp eax, UPPER
	jg error
	jmp continue

;error message to indicate the range was not right
error:
	mov edx, OFFSET ooRange ;gives a warning of the number is out of range
	call WriteString
	call CrLf
	jmp getInput

;sets up for the loop to calculate fib number
continue:
	mov eax, fib
	mov ecx, userNum

;Loop that calculates the fibonacci number of the user entered number
Fibloop:
	cmp ecx, userNum
	je firstNum
	add eax, temp
	mov ebx, fib
	mov temp, ebx
	mov fib, eax
	call WriteDec
	mov edx, OFFSET spaces ;prints the spaces after numbers
	call WriteString
	mov ebx, count
	inc ebx
	mov count, ebx
	cmp ebx, 5
	je printNewLine
	loop Fibloop ; goes back to top of the loop
	jmp exitprog


firstNum: ;handles the first 1 in the series
	call WriteDec
	mov edx, OFFSET spaces ;prints the spaces after numbers
	call WriteString
	mov ebx, count
	inc ebx
	mov count, ebx
	cmp userNum, 1
	je exitprog
	loop FibLoop

;prints a new line after every 5 fibonacci numbers
printNewLine:
	call CrLf
	mov ebx, 0
	mov count, ebx
	loop Fibloop


;says goodbye
exitprog:
	call CrLf
	call CrLf
	mov edx, OFFSET bye ; says goodbye to the user
	call WriteString
	mov edx, OFFSET userName
	call WriteString
	call CrLf

	exit	; exit to operating system
main ENDP


END main
