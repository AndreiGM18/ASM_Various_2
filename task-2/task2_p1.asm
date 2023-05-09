section .text
	global cmmmc

;; int cmmmc(int a, int b)
;
;  calculate least common multiple for 2 numbers, a and b
cmmmc:
	add		ebx, eax	;; a is in eax, now it is also in ebx
	add		ecx, edx	;; b is in edx, now it is also in ecx

;; finds cmmdc
for:
	cmp		ebx, ecx
	jg		great
	je		equal
	jl		low

;; a > b, so a = a - b
great:
	sub		ebx, ecx
	jmp		for

;; a < b, so b = b - a
low:
	sub		ecx, ebx
	jmp		for

;; a = b, so cmmdc is found
equal:
	imul	eax, edx	;; eax = a * b

	xor		edx, edx

	idiv	ebx			; eax = (a * b) / cmmdc(a, b) = cmmmc(a, b)

	ret
