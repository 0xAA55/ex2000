%ifndef _LOADDLL_INC_
%define _LOADDLL_INC_ 1

%include "frame.inc"

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
	%ifdef INVOKE_CHECK
		segment .rdata
		%%dllfail db %str(CurFuncName), ": On load dll `", %str(%1), "`: failed", 0

		segment .text
		test eax, eax
		jnz %%success
		extern _addr_of_MessageBoxA
		push 0
		push 0
		push %%dllfail
		push 0
		call [_addr_of_MessageBoxA]
		int3
	%%success:
	%endif
%endmacro

%macro load_dll_func 2
	push _name_of_ %+ %2
	push [_addr_of_ %+ %1]
	call [_addr_of_GetProcAddress]
	mov [_addr_of_ %+ %2], eax
	%ifdef INVOKE_CHECK
		test eax, eax
		jnz %%success
		int3
	%%success:
	%endif
%endmacro

%macro invoke_dll_func 1
	%ifdef INVOKE_CHECK
		mov eax, [_addr_of_ %+ %1]
		test eax, eax
		jnz %%success
		segment .rdata
		%%func_name db %str(CurFuncName), ": On call `", %str(%1), "`: NULL function pointer", 0

		segment .text
		extern _addr_of_MessageBoxA
		push 0
		push 0
		push %%func_name
		push 0
		call [_addr_of_MessageBoxA]
		jmp %%unsuccess
		%%success:
		call [_addr_of_ %+ %1]
		%%unsuccess:
	%else
		call [_addr_of_ %+ %1]
	%endif
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

%macro invoke_stdcall 1-2+
	%if %0 == 1
		call %1
	%else
		PrepStdCallParam %2
		call %1
		AfterStdCall
	%endif
%endmacro

%macro invoke_dll_stdcall 1-2+
	%if %0 == 1
		invoke_dll_func %1
	%else
		PrepStdCallParam %2
		invoke_dll_func %1
		AfterStdCall
	%endif
%endmacro

%macro invoke_cdecl 1-*
	%if %0 == 1
		call %1
	%else
		ResetPassReg
		%rep %0 - 1
			%rotate 1
			%if IsPassReg(%1)
				AddRegAvoidForPass %1
			%endif
		%endrep
		%rotate 1
		%assign CDeclParamIndex 0
		%rep %0 - 1
			%rotate 1
			PrepParam CDeclParamIndex, %1
			%assign CDeclParamIndex CDeclParamIndex + 1
		%endrep
		%rotate 1
		call %1
	%endif
%endmacro

%macro invoke_dll_cdecl 1-*
	%if %0 == 1
		invoke_dll_func %1
	%else
		ResetPassReg
		%rep %0 - 1
			%rotate 1
			%if IsPassReg(%1)
				AddRegAvoidForPass %1
			%endif
		%endrep
		%rotate 1
		%assign CDeclParamIndex 0
		%rep %0 - 1
			%rotate 1
			PrepParam CDeclParamIndex, %1
			%assign CDeclParamIndex CDeclParamIndex + 1
		%endrep
		%rotate 1
		invoke_dll_func %1
	%endif
%endmacro

%macro debug_msg 1-2+
segment .rdata
	%%format db %1, 0

segment .text
	invoke_cdecl _DebugMsg, %%format, %2
%endmacro

%ifndef LOADDLL_ASM
import_dll Kernel32
import_dll_func GetProcAddress
import_dll_func LoadLibraryA
extern _hInstance
extern _LoadFuncGroup
extern _DebugMsg
%endif

%endif
