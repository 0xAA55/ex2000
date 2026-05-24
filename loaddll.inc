%ifndef _LOADDLL_INC_
%define _LOADDLL_INC_ 1

%include "frame.inc"

%define NULL 0

%macro def_dll 2
	segment .bss
	extern _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	segment .rdata
	extern _name_of_ %+ %1
	_name_of_ %+ %1 db %2, 0
%endmacro

%macro def_dll_func 1
	segment .bss
	extern _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	segment .rdata
	extern _name_of_ %+ %1
	_name_of_ %+ %1 db %str(%1), 0
%endmacro

%macro def_dll_func_alias 2
	segment .bss
	extern _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	segment .rdata
	extern _name_of_ %+ %1
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
	extern _First %+ %1 %+ Addr
	_First %+ %1 %+ Addr:

	segment .rdata
	extern _First %+ %1 %+ Name
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

%macro debug_msg 1-2+
segment .rdata
	%%format db %1, 0

segment .text
	%if %0 >= 2
		invoke_stdcall _DebugMsg, %%format, %2
		add esp, (1 + %count(%2)) * 4
	%else
		invoke_stdcall _DebugMsg, %%format
		add esp, 4
	%endif
%endmacro

%macro debug_printf 1-2+
segment .rdata
	%%format db %1, 0

segment .text
	%if %0 >= 2
		invoke_dll_stdcall printf, %%format, %2
		add esp, (1 + %count(%2)) * 4
	%else
		invoke_dll_stdcall printf, %%format
		add esp, 4
	%endif
%endmacro

%macro debug_show 3-4+
%ifndef _DEBUG
	%error `_DEBUG` not defined.
	%exitmacro
%endif
segment .rdata
	%%format db %3, 0

segment .text
	%if %0 >= 4
		invoke_stdcall _DebugShow, %1, %2, %%format, %4
		add esp, (3 + %count(%4)) * 4
	%else
		invoke_stdcall _DebugShow, %1, %2, %%format
		add esp, 12
	%endif
%endmacro

%macro snprintf 3-4+
segment .rdata
	%%format db %3, 0

segment .text
	%if %0 >= 4
		invoke_cdecl _snprintf, %1, %2, %%format, %4
	%else
		invoke_cdecl _snprintf, %1, %2, %%format
	%endif
%endmacro

import_dll Kernel32
import_dll_func GetProcAddress
import_dll_func LoadLibraryA

extern _hInstance
extern _hDCDesktop

extern _LoadFuncGroup
extern _DebugMsg ;void DebugMsg(const char *format, ...);
%ifdef _DEBUG
	extern _DebugShow ;void DebugShow(int x, int y, const char *format, ...);
	extern _DebugShowV ;void DebugShowV(int x, int y, const char *format, void *ap);
%endif
extern _snprintf
extern _malloc
extern _calloc
extern _realloc
extern _free
extern _aligned_malloc
extern _aligned_free

import_dll_func ExitProcess
import_dll_func QueryPerformanceFrequency
import_dll_func QueryPerformanceCounter
import_dll_func GetProcessHeap
import_dll_func HeapAlloc
import_dll_func HeapReAlloc
import_dll_func HeapFree
import_dll_func HeapLock
import_dll_func HeapUnlock
import_dll_func Sleep
import_dll_func GetTickCount
import_dll_func CreateThread
import_dll_func CloseHandle
import_dll_func WaitForMultipleObjects

import_dll_func MessageBoxA
import_dll_func DrawTextA
import_dll_func LoadIconA
import_dll_func LoadCursorA
import_dll_func RegisterClassExA
import_dll_func CreateWindowExA
import_dll_func ShowWindow
import_dll_func UpdateWindow
import_dll_func PeekMessageA
import_dll_func TranslateMessage
import_dll_func DispatchMessageA
import_dll_func PostQuitMessage
import_dll_func DefWindowProcA
import_dll_func GetDC
import_dll_func ReleaseDC
import_dll_func GetWindowRect
import_dll_func GetClientRect
import_dll_func ClientToScreen
import_dll_func GetCursorPos
import_dll_func SetCursorPos
import_dll_func ShowCursor
import_dll_func GetAsyncKeyState
import_dll_func GetForegroundWindow

import_dll_func strcpy
import_dll_func strcat
import_dll_func strlen
import_dll_func strcmp
import_dll_func printf
import_dll_func vsnprintf
import_dll_func memset
import_dll_func memcpy
import_dll_func memmove
import_dll_func rand
import_dll_func srand

%define DT_TOP                      0x00000000
%define DT_LEFT                     0x00000000
%define DT_CENTER                   0x00000001
%define DT_RIGHT                    0x00000002
%define DT_VCENTER                  0x00000004
%define DT_BOTTOM                   0x00000008
%define DT_WORDBREAK                0x00000010
%define DT_SINGLELINE               0x00000020
%define DT_EXPANDTABS               0x00000040
%define DT_TABSTOP                  0x00000080
%define DT_NOCLIP                   0x00000100
%define DT_EXTERNALLEADING          0x00000200
%define DT_CALCRECT                 0x00000400
%define DT_NOPREFIX                 0x00000800
%define DT_INTERNAL                 0x00001000

%define PAGE_NOACCESS           0x01
%define PAGE_READONLY           0x02
%define PAGE_READWRITE          0x04

%define WM_CREATE 0x0001
%define WM_DESTROY 0x0002
%define WM_QUIT 0x0012

%define WS_OVERLAPPEDWINDOW (0x00000000 | 0x00C00000 | 0x00080000 | 0x00040000 | 0x00020000 | 0x00010000)

%define CW_USEDEFAULT 0x80000000

%define PM_REMOVE 1

%endif
