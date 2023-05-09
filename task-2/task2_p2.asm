section .text
	global par

;; int par(int str_length, char* str)
;
;  checks for balanced brackets in an expression
par:
	;; moves the str_length into ecx
	push 	edx
	pop		ecx

	;; a counter: + 1 for '(', - 1 for ')'
	xor		ebx, ebx

;; loops through the string
lop:
	;; checking the brackets
	cmp		byte [eax], '('
	je		left
	cmp		byte [eax], ')'
	je		right

;; checks if the number of ')' is greater than the number of '(' during the
;  iteration
back:
	cmp		ebx, 0
	jl		false
	inc		eax		;; next character
	loop	lop

	;; checks if the number of brackets is equal
	cmp		ebx, 0
	jnz		false

;; balanced
true:
	push	1
	pop		eax
	jmp		fin		;; jump to the end

;; adding 1 to the counter
left:
	inc		ebx
	jmp		back

;; suntracting 1 from the counter
right:
	dec		ebx
	jmp		back

;; not balanced
false:
	push	0
	pop		eax

fin:
	ret
