%define LOADDLL_ASM 1
%include "loaddll.inc"

global _addr_of_Kernel32
global _addr_of_GetProcAddress
global _addr_of_LoadLibraryA
global _hInstance

extern _calloc
extern _hWnd
import_dll_func MessageBoxA
import_dll_func vsnprintf

segment .bss
_addr_of_LoadLibraryA resd 1
_addr_of_Kernel32 resd 1
_addr_of_GetProcAddress resd 1
_hInstance resd 1

segment .rdata
_name_of_LoadLibraryA db "LoadLibraryA", 0

segment .text
DefFunc _InitLoadLibrary
	mov eax, [fs:0x30]		; EAX = &PEB
	mov eax, [eax + 0x0C]	; EAX = &(PEB->Ldr)
	mov eax, [eax + 0x14]	; EAX = PEB->Ldr.InMemOrder.Flink (Current EXE)
	mov ebx, [eax + 0x10]
	mov [_hInstance], ebx
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

	; Get index of GetProcAddress
	xor ecx, ecx
	.loop_get_func:
	inc ecx
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
	mov cx, [esi + ecx * 2]  ; CX = Index
	dec ecx
	mov esi, [edx + 0x1c]    ; ESI = Offset of Address Table
	add esi, ebx             ; ESI = Address Table
	mov edx, [esi + ecx * 4] ; EDX = Pointer
	add edx, ebx             ; EDX = GetProcAddress
	mov [_addr_of_GetProcAddress], edx

	; Then call it to get the address of
	push _name_of_LoadLibraryA
	push ebx	; Base offset of kernel32
	call edx	; GetProcAddress
	mov [_addr_of_LoadLibraryA], eax
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
global _DebugMsgBuffer
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
	invoke_dll_stdcall MessageBoxA, [_hWnd], [_DebugMsgBuffer], 0, 0

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
