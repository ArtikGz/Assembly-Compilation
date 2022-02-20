bits 64

%define __sys_write 1
%define __sys_exit 60

%define stdout 1

segment .text
global _start

_start:
	mov [args], rsp

	mov rax, [args]
	mov rdi, [rax + 16]
	call getenv

	mov rdi, rax
	call puts

	mov rax, __sys_exit
	mov rdi, 0
	syscall

print_all_env:
	xor rbx, rbx

.next:
	mov rdi, rbx
	call getenv_at_index

	cmp rax, 0
	je .end

	mov rdi, rax
	call puts
	inc rbx
	jmp .next

.end:
	ret

; strlen(char*)
strlen:
	xor rax, rax

.start:
	cmp [rdi + rax], byte 0
	je .end
	inc rax
	jmp .start

.end:
	ret

; find_first_of(char*, char)
find_first_of:
	push rbx
	xor rax, rax

.start:
	mov rbx, [rdi + rax]
	and rbx, 0xff
	cmp rbx, byte 0
	je .fatal_end

	cmp rbx, rsi
	je .end
	inc rax
	jmp .start

.fatal_end:
	mov rax, -1

.end:
	pop rbx
	ret

; bool streq(char*, char*)
; 1 = true
; 0 = false
streq:
	enter 20, 0

	mov [rbp - 8], rdi  ; = first_str
	mov [rbp - 16], rsi ; = second_str

	call strlen
	mov rsi, rax

	mov rdi, [rbp - 16]
	call strlen

	cmp rsi, rax
	jne .nequals

	mov rsi, [rbp - 16]
	mov rdx, rax
	call strneq
	jmp .end

.nequals:
	mov rax, 0

.end:
	leave
	ret

strneq:
	enter 20, 0
	
	mov [rbp - 8], rdi
	mov [rbp - 16], rsi
	mov rax, rdx

.eqstart:
	mov rdi, [rbp - 8]
	mov rsi, [rbp - 16] 

	mov rdi, [rdi + rax]
	mov rsi, [rsi + rax]
	and rdi, 0xff
	and rsi, 0xff
	cmp rdi, rsi
	jne .nequals
	dec rax

	cmp rax, 0
	jle .equals
	jmp .eqstart

.nequals:
	mov rax, 0
	jmp .end

.equals:
	mov rax, 1

.end:
	leave
	ret

; void puts(char*)
puts:
	call strlen
	mov rdx, rax
	mov rsi, rdi
	mov rax, __sys_write
	mov rdi, stdout
	syscall

	mov rax, __sys_write
	mov rdi, stdout
	mov rsi, ln
	mov rdx, 1
	syscall
	ret

getenv:
	enter 10, 0
	push rbx
	push r12
	push r11

	xor rbx, rbx
	mov r12, rdi

.next:
	mov rdi, rbx
	call getenv_at_index

	mov r11, rax

	cmp rax, 0
	je .end

	mov rdi, r11
	mov rsi, '='
	call find_first_of
	mov [rbp - 8], rax
	dec rax

	mov rdi, r12
	mov rsi, r11
	mov rdx, rax
	call strneq
	cmp rax, 1
	je .found

	inc rbx
	jmp .next

.found:	
	mov rax, r11
	add rax, [rbp - 8]
	add rax, 1 ; skip equals

.end:
	pop r11
	pop r12
	pop rbx
	leave
	ret

getenv_at_index:
	mov rsi, [args]

	mov rax, [rsi]
	add rax, rdi
	imul rax, 8
	add rax, 16 ; skip 64bits NULL and last arg

	add rsi, rax
	mov rax, [rsi]
	ret

segment .data
	is: db " is "
	is_len: equ $-is
	ln: db 0xA

	home_env: db "HOME", 0x0

segment .bss
	args: resq 1