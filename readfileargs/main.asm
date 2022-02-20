bits 64

%define __sys_write 1
%define __sys_exit 60

%define stdout 1

section .text
global _start

_start:
	mov [args_ptr], rsp
	mov rax, [args_ptr]
	cmp [rax], byte 2
	jne .err_arguments

	jmp .end


.err_arguments:
	call print_usage
	mov rax, __sys_exit
	mov rdi, 1
	syscall

.end:
	mov rax, __sys_exit
	mov rdi, 0
	syscall

print_usage:
	mov rax, __sys_write
	mov rdi, stdout
	mov rsi, usage_first_part
	mov rdx, usage_first_part_len
	syscall

	mov rdi, [args_ptr]
	add rdi, 8
	mov rdi, [rsi]
	call strlen

	mov rdx, rax
	mov rsi, rdi
	mov rax, __sys_write
	mov rdi, stdout
	syscall

	mov rax, __sys_write
	mov rdi, stdout
	mov rsi, usage_second_part
	mov rdx, usage_second_part_len
	syscall
	ret

strlen:
	xor rax, rax

.start:
	cmp [rdi], byte 0
	je .end
	inc rax
	inc rdi
	jmp .start

.end:
	sub rdi, rax
	ret

section .data
	usage_first_part: db "Usage: "
	usage_first_part_len: equ $-usage_first_part
	usage_second_part: db " <filename>", 0xA
	usage_second_part_len: equ $-usage_second_part

section .bss
	args_ptr: resq 1