section .text
	global		sort

;; struct node {
;     	int val;
;    	struct node* next;
; };

;; finds the next node
find:
	enter	0, 0
	pusha

	mov		ecx, [ebp + 8]	;; n
	mov		edx, [ebp + 12] ;; the address of the struct array
	mov		edi, [ebp + 16] ;; the address of the node whose following node is
							;  being searched
	mov		eax, [edi]		;; the value of the node
	cmp		eax, ecx		;; if the value = n, then there is no greater value
							;  in the array
	je		max_found
	inc		eax				;; the value + 1, which we are seaching for

;; loops through the array until value + 1 is found
lp:
	cmp		eax, [edx]
	je		set_next
	add		edx, 8
	jmp		lp

;; writing the address of value + 1 in the next * of the node that was put on
;  the stack
set_next:
	add		edi, 4
	mov		[edi], edx

max_found:
	popa
	leave
	ret

;; struct node* sort(int n, struct node* node);
; 	The function will link the nodes in the array
;	in ascending order and will return the address
;	of the new found head of the list
; @params:
;	n -> the number of nodes in the array
;	node -> a pointer to the beginning in the array
; @returns:
;	the address of the head of the sorted list
sort:
	enter	0, 0

	mov 	ecx, [ebp + 8]	;; n
	mov		ebx, [ebp + 12]	;; the address of tbe struct array

;; finds the head of the list by finding the address of 1 in the array
find_head:
	cmp		[ebx], dword 1	;; checks if 1 is found
	je		head_found
	add		ebx, 8			;; if not keep searching		
	jmp		find_head

;; puts the address in eax then pushs onto the stack
head_found:
	mov		eax, ebx
	push	eax

;; searches for the address of the next node in the array
search_for_next:
	;; necessary pushes for find
	push	eax
	push	dword [ebp + 12]
	push	dword [ebp + 8]

	;; calls find
	call	find

	;; clears the stack
	add 	esp, 12

	;; puts the address in the next * of the node
	mov		eax, [eax + 4] 

	;; keeps searching
	loop	search_for_next

	;; puts the head in eax
	pop		eax
	leave
	ret
