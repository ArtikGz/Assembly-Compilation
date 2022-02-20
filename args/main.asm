bits 64

%define __sys_write 1
%define stdout 1

section .text
global _start

_start:
	mov rbx, 1

.start:
	cmp rbx, [rsp]
	jg .end

	mov rdi, [rsp + 8*rbx]
	call strlen

	mov rdx, rax
	mov rax, __sys_write
	mov rdi, stdout
	mov rsi, [rsp + 8*rbx]
	syscall

	mov rax, __sys_write
	mov rdi, stdout
	mov rsi, nl
	mov rdx, 1
	syscall

	inc rbx
	jmp .start

.end:

	mov rax, 60
	mov rdi, 0
	syscall

strlen:
	xor rax, rax

.start:
	cmp [rdi], byte 0
	je .end
	inc rax
	inc rdi
	jmp .start

.end:
	ret

section .data
	nl: db 0xA