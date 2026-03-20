%ifndef _VECTOR_INC_
%define _VECTOR_INC_ 1

%include "raii.inc"

%macro DefVector 1
	%ifndef VECTOR_OF_ %+ %1
		%define VECTOR_OF_ %+ %1
		struc VectorOf %+ %1
			.pointer resd 1
			.num_items resd 1
			.capacity resd 1
			.size equ $ - .pointer
		endstruc
		DefObject VecOf %+ %1, VectorOf %+ %1.size
	%endif
%endmacro

%macro NewVector 2
	DefVector %2

	PrepParam 0, VectorOf %+ %2.size
	call _malloc

	push eax
	push VectorOf %+ %2.size
	push 0
	push eax
	invoke_dll_func memset
	pop %1
%endif

%macro VecPush 3 ; Addr of vector, type of item, item address
	
%endmacro

%ifndef BUFFER_ASM
	extern _malloc
	extern _realloc
	extern _free
	def_dll_func memset
%endif

%endif
