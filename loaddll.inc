extern _addr_of_Kernel32
extern _addr_of_GetProcAddress
extern _addr_of_LoadLibraryA
extern _hInstance
%ifndef HAVE_LOADFUNCGROUP
extern _LoadFuncGroup
%define HAVE_LOADFUNCGROUP 1
%endif

%macro def_dll 2
	segment .bss
	global _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	segment .rdata
	global _name_of_ %+ %1
	_name_of_ %+ %1 db %2, 0
%endmacro

%macro def_dll_func 1
	segment .bss
	global _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	segment .rdata
	global _name_of_ %+ %1
	_name_of_ %+ %1 db %str(%1), 0
%endmacro

%macro def_dll_func_alias 2
	segment .bss
	global _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	segment .rdata
	global _name_of_ %+ %1
	_name_of_ %+ %1 db %2, 0
%endmacro

%macro load_dll 1
	push _name_of_ %+ %1
	call [_addr_of_LoadLibraryA]
	mov [_addr_of_ %+ %1], eax
%endmacro

%macro load_dll_func 2
	push _name_of_ %+ %2
	push [_addr_of_ %+ %1]
	call [_addr_of_GetProcAddress]
	mov [_addr_of_ %+ %2], eax
%endmacro

%macro invoke_dll_func 1
	call [_addr_of_ %+ %1]
%endmacro

%macro def_dll_and_load 2
	def_dll %1, %2
	segment .text
	load_dll %1
%endmacro

%macro def_dll_func_and_load 2
	def_dll_func %2
	segment .text
	load_dll_func %1, %2
%endmacro

%macro def_dll_func_and_load_alias 3
	def_dll_func_alias %2, %3
	segment .text
	load_dll_func %1, %2
%endmacro

%macro import_dll 1
	extern _addr_of_ %+ %1
%endmacro

%macro import_dll_func 1
	extern _addr_of_ %+ %1
%endmacro

%macro dll_func_group_start 1
	segment .bss
	global _First %+ %1 %+ Addr
	_First %+ %1 %+ Addr:

	segment .rdata
	global _First %+ %1 %+ Name
	_First %+ %1 %+ Name:
%endmacro

%macro dll_func_group_end 1
	segment .bss
	_Last %+ %1 %+ Addr:
%endmacro

%macro dll_func_group_load 2
	mov esi, _First %+ %2 %+ Name
	mov edi, _First %+ %2 %+ Addr
	mov ecx, (_Last %+ %2 %+ Addr - _First %+ %2 %+ Addr) / 4
	mov ebx, [_addr_of_ %+ %1]
	call _LoadFuncGroup
%endmacro
