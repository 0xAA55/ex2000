%include "loaddll.inc"

%define NOIAT 1

extern _addr_of_Kernel32
extern _addr_of_GetProcAddress
extern _addr_of_LoadLibraryA
extern _hInstance
extern _hHeap

extern _calloc

import_dll_func MessageBoxA
import_dll_func vsnprintf

segment .bss
_addr_of_LoadLibraryA resd 1
_addr_of_Kernel32 resd 1
_addr_of_GetProcAddress resd 1
_hInstance resd 1
_hHeap resd 1

segment .rdata
_name_of_LoadLibraryA db "LoadLibraryA", 0

dll_func_group_start KFunc
def_dll_func ExitProcess
def_dll_func QueryPerformanceFrequency
def_dll_func QueryPerformanceCounter
def_dll_func GetProcessHeap
def_dll_func HeapAlloc
def_dll_func HeapReAlloc
def_dll_func HeapFree
def_dll_func HeapLock
def_dll_func HeapUnlock
def_dll_func Sleep
def_dll_func GetTickCount
def_dll_func CreateThread
def_dll_func CloseHandle
def_dll_func WaitForMultipleObjects
dll_func_group_end KFunc

dll_func_group_start UFunc
def_dll_func MessageBoxA
def_dll_func LoadIconA
def_dll_func LoadCursorA
def_dll_func RegisterClassExA
def_dll_func CreateWindowExA
def_dll_func ShowWindow
def_dll_func UpdateWindow
def_dll_func PeekMessageA
def_dll_func TranslateMessage
def_dll_func DispatchMessageA
def_dll_func PostQuitMessage
def_dll_func DefWindowProcA
def_dll_func GetDC
def_dll_func ReleaseDC
def_dll_func GetWindowRect
def_dll_func GetClientRect
def_dll_func GetCursorPos
def_dll_func SetCursorPos
def_dll_func ShowCursor
def_dll_func GetAsyncKeyState
def_dll_func GetForegroundWindow
dll_func_group_end UFunc

dll_func_group_start CFunc
def_dll_func strcpy
def_dll_func strcat
def_dll_func strlen
def_dll_func strcmp
def_dll_func_alias vsnprintf, "_vsnprintf"
def_dll_func memset
def_dll_func memcpy
def_dll_func memmove
def_dll_func rand
def_dll_func srand
dll_func_group_end CFunc

segment .text
DefFunc _InitLoadLibrary
	FrameBegin 0, 0, ebx, esi, edi
	mov eax, [fs:0x30]		; EAX = &PEB
	mov eax, [eax + 0x0C]	; EAX = &(PEB->Ldr)
	mov eax, [eax + 0x14]	; EAX = PEB->Ldr.InMemOrder.Flink (Current EXE)
	mov ebx, [eax + 0x10]
	mov [_hInstance], ebx
%ifdef NOIAT
	mov eax, [eax]			; EAX = Flink(ntdll.dll)
	mov eax, [eax]			; EAX = Flink(kernel32.dll)

	mov ebx, [eax + 0x10]
	mov [_addr_of_Kernel32], ebx

	; Find out EAT
	mov edx, [ebx + 0x3c]	; EDX = DOS->e_lfanew
	add edx, ebx			; EDX = PE
	mov edx, [edx + 0x78]	; EDX = Offset of EAT
	add edx, ebx			; EDX = EAT
	mov esi, [edx + 0x20]	; ESI = Offset of Name Table
	add esi, ebx			; ESI = Name Table
	mov ecx, [esi - 0x8]

	; Get index of GetProcAddress
	xor edi, edi
.loop_get_func:
	inc edi
	lodsd
	add eax, ebx
	cmp dword [eax], 'GetP'
	jnz .loop_get_func
	cmp dword [eax + 4], 'rocA'
	jnz .loop_get_func
	cmp dword [eax + 8], 'ddre'
	jnz .loop_get_func
	cmp word [eax + 12], 'ss'
	jnz .loop_get_func

	; Get the address of GetProcAddress by the index
	mov esi, [edx + 0x24]    ; ESI = Offset of Index Table
	add esi, ebx             ; ESI = Index Table
	mov di, [esi + edi * 2]  ; CX = Index
	dec edi
	mov esi, [edx + 0x1c]    ; ESI = Offset of Address Table
	add esi, ebx             ; ESI = Address Table
	mov edx, [esi + edi * 4] ; EDX = Pointer
	add edx, ebx             ; EDX = GetProcAddress
	mov [_addr_of_GetProcAddress], edx

	; Then call it to get the address of
	push _name_of_LoadLibraryA
	push ebx	; Base offset of kernel32
	call edx	; GetProcAddress
	mov [_addr_of_LoadLibraryA], eax
%else
segment .rdata
.name_of_Kernel32 db "kernel32.dll", 0
segment .text
	extern __imp__GetProcAddress@8
	extern __imp__LoadLibraryA@4
	mov eax, [__imp__GetProcAddress@8]
	mov ecx, [__imp__LoadLibraryA@4]
	mov [_addr_of_GetProcAddress], eax
	mov [_addr_of_LoadLibraryA], ecx
	invoke_dll_stdcall LoadLibraryA, .name_of_Kernel32
	mov [_addr_of_Kernel32], eax
%endif

	def_dll_and_load User32, "user32.dll"
	def_dll_and_load GDI32, "gdi32.dll"
	def_dll_and_load MSVCRT, "msvcrt.dll"

	dll_func_group_load Kernel32, KFunc
	dll_func_group_load User32, UFunc
	dll_func_group_load MSVCRT, CFunc

	invoke_dll_stdcall GetProcessHeap
	mov [_hHeap], eax

	FrameEnd
	ret

DefFunc _LoadFuncGroup
	push ecx
	push esi
	push ebx
	call [_addr_of_GetProcAddress]
%ifdef INVOKE_CHECK
	extern _addr_of_MessageBoxA
	test eax, eax
	jnz .success
	push 0
	push 0
	push esi
	push 0
	call [_addr_of_MessageBoxA]
	xor eax, eax
.success:
%endif
	stosd
	call _NextString
	pop ecx
	loop _LoadFuncGroup
	ret

DefFunc _NextString
	lodsb
	test al, al ; Find NUL
	jnz _NextString
	ret

segment .bss
extern _DebugMsgBuffer
_DebugMsgBuffer resd 1
_DebugMsgBufferSize equ 4096

segment .text
DefFunc _DebugMsg
	FrameBegin 0, 4

	mov eax, [_DebugMsgBuffer]
	test eax, eax
	jnz .proceed_printf
	invoke_cdecl _calloc, _DebugMsgBufferSize, 1
	mov [_DebugMsgBuffer], eax
	test eax, eax
	jz .end
.proceed_printf:

	lea eax, Param(1)
	invoke_dll_cdecl vsnprintf, [_DebugMsgBuffer], _DebugMsgBufferSize, Param(0), eax
	invoke_dll_stdcall MessageBoxA, 0, [_DebugMsgBuffer], 0, 0

.end:
	xor eax, eax
	FrameEnd
	ret

DefFunc _snprintf
	FrameBegin 0, 4

	lea eax, Param(3)
	invoke_dll_cdecl vsnprintf, Param(0), Param(1), Param(2), eax

.end:
	FrameEnd
	ret

DefFunc _malloc
	FrameBegin 0, 0
	invoke_dll_stdcall HeapAlloc, [_hHeap], 4, Param(0)
	FrameEnd
	ret

DefFunc _calloc
	FrameBegin 0, 0

	mov eax, Param(0)
	mul dword Param(1)
	invoke_dll_stdcall HeapAlloc, [_hHeap], 8|4, eax

	FrameEnd
	ret

DefFunc _realloc
	FrameBegin 0, 0
	mov eax, Param(0)
	test eax, eax
	jz .ptr_is_null
	invoke_dll_stdcall HeapReAlloc, [_hHeap], 4, Param(0), Param(1)
	jmp .end
.ptr_is_null:
	invoke_dll_stdcall HeapAlloc, [_hHeap], 4, Param(1)
.end:
	FrameEnd
	ret

DefFunc _free
	FrameBegin 0, 0
	invoke_dll_stdcall HeapFree, [_hHeap], 4, Param(0)
	FrameEnd
	ret

DefFunc _aligned_malloc ;void * aligned_malloc(size_t size, int align_bytes);
	FrameBegin 0, 1

	mov eax, Param(1)
	cmp eax, 8
	jae .proceed
	mov al, 8
	mov Param(1), eax

.proceed:
	mov eax, Param(0)
	test eax, eax
	jnz .good
.bad:
	int3
	jmp .bad
.good:
	add eax, Param(1)
	invoke_cdecl _malloc, eax

	mov edx, eax
	mov ecx, Param(1)
	add eax, ecx
	neg ecx
	and eax, ecx
	mov [eax - 4], edx

	FrameEnd
	ret

DefFunc _aligned_free
	FrameBegin 0, 1

	mov eax, Param(0)
	test eax, eax
	jz .end

	invoke_cdecl _free, [eax - 4]

.end:
	FrameEnd
	ret
