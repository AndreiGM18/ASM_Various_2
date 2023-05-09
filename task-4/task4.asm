section .text
	global cpu_manufact_id
	global features
	global l2_cache_info

;; void cpu_manufact_id(char *id_string);
;
;  reads the manufacturer id string from cpuid and stores it in id_string
cpu_manufact_id:
	enter 	0, 0

	xor		eax, eax				;; eax = 0
	cpuid

	mov		eax, [ebp + 8]			;; id_string

	mov		dword [eax], ebx		;; the first 4 chars in ebx
	mov		dword [eax + 4], edx	;; the next 4 chars in edx
	mov		dword [eax + 8], ecx	;; the last 4 chars in ecx

	leave
	ret

;; void features(int *apic, int *rdrand, int *mpx, int *svm)
;
;  checks whether apic, rdrand and mpx / svm are supported by the CPU
;  MPX should be checked only for Intel CPUs; otherwise, the mpx variable
;  should have the value -1
;  SVM should be checked only for AMD CPUs; otherwise, the svm variable
;  should have the value -1
features:
	enter 	0, 0

apic:
	mov		esi, [ebp + 8]			;; apic
	mov		eax, 01h
	cpuid

	test	edx, 512				;; the 9th bit of edx
	jnz		apic_set
	jmp		apic_not_set

apic_set:
	mov		[esi], dword 1
	jmp		rdrandd

apic_not_set:
	mov		[esi], dword -1

rdrandd:
	mov		esi, [ebp + 12]			;; rdrand
	mov		eax, 01h
	cpuid

	test	ecx, 1073741824			;; the 30th bit of ecx
	jnz		rdrand_set
	jmp		rdrand_not_set

rdrand_set:
	mov		[esi], dword 1
	jmp		mpx

rdrand_not_set:
	mov		[esi], dword -1

mpx:
	mov		esi, [ebp + 16]			;; mpx

	;; checking for INTEL only
	xor		eax, eax
	cpuid
	cmp 	bl, 'A'
	je		is_not_intel

	mov		eax, 07h
	cpuid

	test	ebx, 16384				;; the 14th bit of ebx
	jnz		mpx_set
	jmp		mpx_not_set

is_not_intel:
	mov		[esi], dword -1
	jmp		svm

mpx_set:
	mov		[esi], dword 1
	jmp		svm

mpx_not_set:
	mov		[esi], dword 0

svm:
	mov		esi, [ebp + 20]			;; svm

	;; checking for INTEL only
	xor		eax, eax
	cpuid
	cmp 	bl, 'G'
	je		is_not_amd


	mov		eax, 80000001h
	cpuid

	test	ecx, 4					;; the 2nd bit of ecx
	jnz		svm_set
	jmp		svm_not_set

is_not_amd:
	mov		[esi], dword -1
	jmp		fin

svm_set:
	mov		[esi], dword 1
	jmp		fin

svm_not_set:
	mov		[esi], dword 0

fin:
	leave
	ret

;; void l2_cache_info(int *line_size, int *cache_size)
;
;  reads from cpuid the cache line size, and total cache size for the current
;  cpu, and stores them in the corresponding parameters
l2_cache_info:
	enter 	0, 0

	mov		esi, [ebp + 8]			;; line_size

	mov		eax, 80000006h
	cpuid

	xor		edx, edx				;; resets edx

	mov		dl, cl					;; cl is moved to dl so only cl is in edx

	mov		[esi], edx				;; writes the size at the address

	leave
	ret
