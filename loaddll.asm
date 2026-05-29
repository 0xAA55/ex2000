%include "loaddll.inc"
%include "assets.inc"

%define NOIAT 1

extern _addr_of_Kernel32
extern _addr_of_GetProcAddress
extern _addr_of_LoadLibraryA
extern _hInstance
extern _hHeap

extern _calloc

segment .bss
_addr_of_LoadLibraryA resd 1
_addr_of_Kernel32 resd 1
_addr_of_GetProcAddress resd 1
_hInstance resd 1
_hHeap resd 1
%ifdef _DEBUG
_hDCDesktop resd 1
%endif

segment .rdata
_name_of_LoadLibraryA db "LoadLibraryA", 0

dll_func_group_start KFunc
def_dll_func ExitProcess
def_dll_func GetProcessHeap
def_dll_func HeapAlloc
def_dll_func HeapReAlloc
def_dll_func HeapFree
dll_func_group_end KFunc

dll_func_group_start_without_name KFunc_DelayedLoad
def_dll_func_addr QueryPerformanceFrequency
def_dll_func_addr QueryPerformanceCounter
def_dll_func_addr Sleep
def_dll_func_addr GetTickCount
def_dll_func_addr CreateThread
def_dll_func_addr CloseHandle
def_dll_func_addr WaitForMultipleObjects
def_dll_func_addr VirtualProtect
def_dll_func_addr TlsAlloc
def_dll_func_addr TlsGetValue
def_dll_func_addr TlsSetValue
def_dll_func_addr TlsFree
dll_func_group_end KFunc_DelayedLoad

dll_func_group_start UFunc
def_dll_func MessageBoxA
dll_func_group_end UFunc

dll_func_group_start_without_name UFunc_DelayedLoad
def_dll_func_addr DrawTextA
def_dll_func_addr LoadIconA
def_dll_func_addr LoadCursorA
def_dll_func_addr RegisterClassExA
def_dll_func_addr CreateWindowExA
def_dll_func_addr ShowWindow
def_dll_func_addr UpdateWindow
def_dll_func_addr PeekMessageA
def_dll_func_addr TranslateMessage
def_dll_func_addr DispatchMessageA
def_dll_func_addr PostQuitMessage
def_dll_func_addr DefWindowProcA
def_dll_func_addr GetDC
def_dll_func_addr ReleaseDC
def_dll_func_addr GetWindowRect
def_dll_func_addr GetClientRect
def_dll_func_addr ClientToScreen
def_dll_func_addr GetCursorPos
def_dll_func_addr SetCursorPos
def_dll_func_addr ShowCursor
def_dll_func_addr GetAsyncKeyState
def_dll_func_addr GetForegroundWindow
dll_func_group_end UFunc_DelayedLoad

dll_func_group_start CFunc
def_dll_func strcpy
def_dll_func strcat
def_dll_func strlen
def_dll_func strcmp
def_dll_func printf
def_dll_func_alias vsnprintf, "_vsnprintf"
def_dll_func memset
def_dll_func memcpy
def_dll_func memmove
def_dll_func rand
def_dll_func srand
dll_func_group_end CFunc

segment .rdata
extern _name_of_User32
extern _name_of_GDI32
extern _name_of_MSVCRT
extern _name_of_OpenGL32
_name_of_User32   db "user32.dll", 0
_name_of_GDI32    db "gdi32.dll", 0
_name_of_MSVCRT   db "msvcrt.dll", 0
_name_of_OpenGL32 db "opengl32.dll", 0

segment .bss
extern _addr_of_User32
extern _addr_of_GDI32
extern _addr_of_MSVCRT
extern _addr_of_OpenGL32
_addr_of_User32   resd 1
_addr_of_GDI32    resd 1
_addr_of_MSVCRT   resd 1
_addr_of_OpenGL32 resd 1

DefFunc _InitLoadLibrary
	FrameBegin 1, 0, ebx, esi, edi
	AssignVars Index
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
	mov eax, [edx + 0x20]	; EAX = Offset of Name Table
	add eax, ebx			; EAX = Name Table

	; Get index of GetProcAddress
	xor ecx, ecx
	mov Index, ecx
.loop_get_func:
	inc dword Index
	mov esi, [eax]
	add esi, ebx
	mov edi, .get_proc_address
	mov cl, .get_proc_address_len
	repz cmpsb
	jecxz .found
	add eax, 4
	jmp .loop_get_func
.found:
	mov ecx, Index

	; Get the address of GetProcAddress by the index
	mov esi, [edx + 0x24]    ; ESI = Offset of Index Table
	add esi, ebx             ; ESI = Index Table
	movzx ecx, word [esi + ecx * 2]  ; CX = Index
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
%else
	extern __imp__GetProcAddress@8
	extern __imp__LoadLibraryA@4
	mov eax, [__imp__GetProcAddress@8]
	mov ecx, [__imp__LoadLibraryA@4]
	mov [_addr_of_GetProcAddress], eax
	mov [_addr_of_LoadLibraryA], ecx
	invoke_dll_stdcall LoadLibraryA, .name_of_Kernel32
	mov [_addr_of_Kernel32], eax
%endif

	mov esi, _name_of_User32
	mov edi, _addr_of_User32
	mov ecx, 4
.loop_load_dll:
	push ecx
	invoke_dll_stdcall LoadLibraryA, esi
	stosd
	call _NextString
	pop ecx
	loop .loop_load_dll

	dll_func_group_load Kernel32, KFunc
	dll_func_group_load User32, UFunc
	dll_func_group_load MSVCRT, CFunc

	invoke_dll_stdcall GetProcessHeap
	mov [_hHeap], eax

	FrameEnd
	ret
	%undef Index

segment .rdata
	.get_proc_address db 'GetProcAddress', 0
	.get_proc_address_len equ $ - .get_proc_address

%ifndef NOIAT
	.name_of_Kernel32 db "kernel32.dll", 0
%endif

DefFunc _LoadFuncGroup
	push ecx
	invoke_dll_stdcall GetProcAddress, ebx, esi
%ifdef INVOKE_CHECK
	extern _addr_of_MessageBoxA
	test eax, eax
	jnz .success
	invoke_dll_stdcall MessageBoxA, 0, esi, 0, 0
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

DefFunc _NLtoNUL
	FrameBegin 0, 0, esi, edi

	mov esi, Param(0)
	mov ecx, Param(1)
	mov edi, esi
	xor edx, edx
.proc:
	lodsb
	cmp al, `\n`
	cmovz eax, edx
	stosb
	loop .proc

	FrameEnd
	ret

; void LoadFuncsFromAssets(void *output, void *dll_base, const char *asset_path, size_t count)
DefFunc _LoadFuncsFromAssets
	FrameBegin 1, 2, ebx, esi, edi
	AssignVars SizeOfNames

	mov edi, Param(0)
	mov ebx, Param(1)
	invoke_cdecl _AssetsQuery, Param(2), &SizeOfNames
	mov esi, eax
	invoke_cdecl _NLtoNUL, esi, SizeOfNames

	mov ecx, Param(3)
	call _LoadFuncGroup

	FrameEnd
	ret
	%undef SizeOfNames

DefFunc _InitDelayedLoadFunc
	FrameBegin 1, 2, ebx
	AssignVars SizeOfFuncs

	AssetsQuery 'assets\KFUNC', &SizeOfFuncs
	mov ebx, eax
	invoke_cdecl _NLtoNUL, ebx, SizeOfFuncs
	dll_func_group_load_alter_name Kernel32, KFunc_DelayedLoad, ebx

	AssetsQuery 'assets\UFUNC', &SizeOfFuncs
	mov ebx, eax
	invoke_cdecl _NLtoNUL, ebx, SizeOfFuncs
	dll_func_group_load_alter_name User32, UFunc_DelayedLoad, ebx

	FrameEnd
	ret

segment .bss
extern _DebugMsgBuffer
_DebugMsgBuffer resd 1
_DebugMsgBufferSize equ 4096
_DebugShowRect resd 4

DefFunc _InitDbg
	FrameBegin 0, 2
	mov eax, [_DebugMsgBuffer]
	test eax, eax
	jnz .end
	invoke_cdecl _calloc, _DebugMsgBufferSize, 1
	mov [_DebugMsgBuffer], eax
%ifdef _DEBUG
	cmp dword[_hDCDesktop], 0
	jnz .end
	invoke_dll_stdcall GetDC, 0
	mov [_hDCDesktop], eax
%endif
.end:
	FrameEnd
	ret

DefFunc _DebugMsg
	FrameBegin 0, 4
	call _InitDbg

	lea eax, Param(1)
	invoke_dll_cdecl vsnprintf, [_DebugMsgBuffer], _DebugMsgBufferSize, Param(0), eax
	invoke_dll_stdcall MessageBoxA, 0, [_DebugMsgBuffer], 0, 0

.end:
	xor eax, eax
	FrameEnd
	ret

%ifdef _DEBUG
DefFunc _DebugShow
	FrameBegin 0, 4
	call _InitDbg

	movq xmm0, Param(0)
	movq [_DebugShowRect], xmm0
	mov eax, 1024
	movd xmm1, eax
	pshufd xmm1, xmm1, 0
	paddd xmm0, xmm1
	movq [_DebugShowRect + 8], xmm0

	invoke_dll_cdecl vsnprintf, [_DebugMsgBuffer], _DebugMsgBufferSize, Param(2), &Param(3)
	invoke_dll_stdcall DrawTextA, [_hDCDesktop], [_DebugMsgBuffer], eax, _DebugShowRect, DT_EXPANDTABS | DT_NOPREFIX | DT_LEFT | DT_NOCLIP | DT_TOP

.end:
	xor eax, eax
	FrameEnd
	ret

DefFunc _DebugShowV
	FrameBegin 0, 4
	call _InitDbg

	movq xmm0, Param(0)
	movq [_DebugShowRect], xmm0
	mov eax, 1024
	movd xmm1, eax
	pshufd xmm1, xmm1, 0
	paddd xmm0, xmm1
	movq [_DebugShowRect + 8], xmm0

	invoke_dll_cdecl vsnprintf, [_DebugMsgBuffer], _DebugMsgBufferSize, Param(2), Param(3)
	invoke_dll_stdcall DrawTextA, [_hDCDesktop], [_DebugMsgBuffer], eax, _DebugShowRect, DT_EXPANDTABS | DT_NOPREFIX | DT_LEFT | DT_NOCLIP | DT_TOP

.end:
	xor eax, eax
	FrameEnd
	ret
%endif

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
	jae .good
.bad:
	int3
	jmp .bad
.good:
	mov eax, Param(0)
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
