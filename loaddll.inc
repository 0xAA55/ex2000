extern _addr_of_GetProcAddress
extern _addr_of_LoadLibraryA

%macro def_dll 2
	segment .bss
	global _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	segment .rdata
	global _name_of_ %+ %1
	_name_of_ %+ %1 db %2, 0
%endmacro

%macro def_dll_func 2
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

%macro def_dll_func_and_load 3
	def_dll_func %2, %3
	segment .text
	load_dll_func %1, %2
%endmacro
