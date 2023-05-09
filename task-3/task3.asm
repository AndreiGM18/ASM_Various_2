global get_words
global compare_func
global sort

extern qsort
extern strlen
extern strcmp

section .text

;; the compare function for 2 strings, used in qsort
compare_func:
    enter   0, 0
 
    ;; pushes
    push    ebx
    push    esi
    push    edi
 
    mov     esi, [ebp + 8]  ;; address of the first string
    mov     edi, [ebp + 12] ;; address of the second string

    ;; calculates strlen for the first sting 
    push    dword [esi]
    call    strlen
    add     esp, 4
 
    ;; pushes the len of the first string onto the stack
    push    eax

    ;; calculates strlen for the second sting 
    push    dword [edi]
    call    strlen
    add     esp, 4
 
    mov     ebx, eax        ;; ebx = the second string's len
    pop     eax             ;; eax = the first string's len

;; compares the two lens
    cmp     eax, ebx
    jl      ret_1st_str
    cmp     eax, ebx
    jg      ret_2nd_str
 
    ;; they are equal, so strcmp is called instead (result saved in eax)
    push    dword [edi]
    push    dword [esi]
    call    strcmp
    add     esp, 8
 
    ;; pops
    pop     edi
    pop     esi
    pop     ebx
 
    leave
    ret
 
;; set eax to -1, first string < second string
ret_1st_str:
    mov     eax, -1
    jmp     finale

;; set eax to 1, first string > second string
ret_2nd_str:
    mov     eax, 1
 
finale:
    ;; pops
    pop     edi
    pop     esi
    pop     ebx
 
    leave
    ret

;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru soratrea cuvintelor 
;  dupa lungime si apoi lexicografix
sort:
    enter   0, 0

    ;; pushing the necessary parameters for qsort
    push    compare_func
    push    dword [ebp + 16]
    push    dword [ebp + 12]
    push    dword [ebp + 8]

    call    qsort

    add     esp, 16         ;; reseting the stack

    leave
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    enter   0, 0

    mov     eax, [ebp + 8]  ;; the address of the string
    mov     ebx, [ebp + 12] ;; the address of the word array

    mov     [ebx], eax      ;; the first word
    inc     eax             ;; next char in the string
    add     ebx, 4          ;; next word address

;; loops through the string
lop:
    ;; end of the string
    cmp     byte [eax], 0
    jz      fin

    ;; delims
    cmp     byte [eax], ` `
    je      write_space
    cmp     byte [eax], `.`
    je      write
    cmp     byte [eax], `,`
    je      write
    cmp     byte [eax], `\n`
    je      write_space

    ;; next string
    inc     eax
    jmp     lop

;; "Ana are" or "Ana\nare" -> "Ana", "are" (delim is 1 char)
write_space:    
    ;; delim is deleted
    mov     byte [eax], 0

    ;; the next word is found 1 char over
    inc     eax

    ;; if we reached NULL, the string has ended
    cmp     byte [eax], 0
    jz      fin

    ;; puts the word in the word array
    mov     [ebx], eax
    add     ebx, 4
    jmp     lop

;; "Ana, are" or "Ana. are" -> "Ana", "are" (delim is 2 chars)
write:
    ;; delim is deleted
    mov     byte [eax], 0

    ;; the next word is found 2 chars over
    add     eax, 2

    ;; may encounter "Ana... are", in which case jumps 2 chars again
    cmp     byte [eax], `.`
    jne     cont
    add     eax, 2

cont:
    ;; if we reached NULL, the string has ended
    cmp     byte [eax], 0
    jz      fin

    ;; puts the word in the word array
    mov     [ebx], eax
    add     ebx, 4
    jmp     lop

fin:
    leave
    ret
