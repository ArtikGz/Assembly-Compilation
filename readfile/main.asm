bits 64

%define stdout 1

%define __sys_read 0
%define __sys_write 1
%define __sys_open 2
%define __sys_close 3
%define __sys_fstat 5
%define __sys_mmap 9
%define __sys_exit 60

%define fstat_struct_size 112
%define fstat_size_offset 56

%define PROT_READ 1
%define PROT_WRITE 2
%define MAP_PRIVATE 2

section .text
global _start

_start:
	enter 200, 0
	mov rax, __sys_open
	mov rdi, filename
	mov rsi, 0
	mov rdx, 755o
	syscall

	mov [rbp - 200], rax ; file fd

	mov rax, __sys_fstat
	mov rdi, [rbp - 200]
	lea rsi, [rbp - 104]
	syscall

	mov rax, __sys_mmap
	xor rdi, rdi
	mov rsi, [rbp - fstat_struct_size + fstat_size_offset]
	mov rdx, PROT_READ
	mov r10, MAP_PRIVATE
	mov r8, [rbp - 200]
	xor r9, r9
	syscall

	mov rsi, rax
	mov rax, __sys_write
	mov rdi, stdout
	mov rdx, [rbp - fstat_struct_size + fstat_size_offset]
	syscall

	mov rax, __sys_close
	mov rdi, [rbp - 200]
	syscall

	mov rdi, rax
	mov rax, __sys_exit
	syscall


section .data
	filename: db "test.txt"