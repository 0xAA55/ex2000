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

_SystemInfo:
	InstSYSTEM_INFO

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
def_dll_func_addr GetCurrentProcess
def_dll_func_addr SetProcessInformation
def_dll_func_addr QueryPerformanceFrequency
def_dll_func_addr QueryPerformanceCounter
def_dll_func_addr Sleep
def_dll_func_addr GetTickCount
def_dll_func_addr GetTickCount64
def_dll_func_addr CreateThread
def_dll_func_addr CloseHandle
def_dll_func_addr WaitForSingleObject
def_dll_func_addr WaitForMultipleObjects
def_dll_func_addr VirtualProtect
def_dll_func_addr TlsAlloc
def_dll_func_addr TlsGetValue
def_dll_func_addr TlsSetValue
def_dll_func_addr TlsFree
def_dll_func_addr InterlockedIncrement
def_dll_func_addr InterlockedDecrement
def_dll_func_addr InterlockedExchange
def_dll_func_addr CreateWaitableTimerExW
def_dll_func_addr SetWaitableTimer
def_dll_func_addr GetSystemInfo
dll_func_group_end KFunc_DelayedLoad

dll_func_group_start UFunc
def_dll_func MessageBoxA
dll_func_group_end UFunc

dll_func_group_start_without_name UFunc_DelayedLoad
def_dll_func_addr MessageBoxW
def_dll_func_addr AdjustWindowRect
def_dll_func_addr MoveWindow
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
def_dll_func_addr MonitorFromWindow
def_dll_func_addr GetMonitorInfoW
def_dll_func_addr EnumDisplaySettingsW
dll_func_group_end UFunc_DelayedLoad

dll_func_group_start CFunc
def_dll_func strcpy
def_dll_func strlen
def_dll_func strcmp
def_dll_func printf
def_dll_func memset
def_dll_func memcpy
dll_func_group_end CFunc

dll_func_group_start_without_name CFunc_DelayedLoad
def_dll_func_addr rand
def_dll_func_addr srand
def_dll_func_addr strcat
def_dll_func_addr strchr
def_dll_func_addr strncpy
def_dll_func_addr memcmp
def_dll_func_addr memmove
def_dll_func_addr vsnprintf
def_dll_func_addr fopen
def_dll_func_addr fseek
def_dll_func_addr fscanf
def_dll_func_addr fread
def_dll_func_addr fprintf
def_dll_func_addr fwrite
def_dll_func_addr fclose
def_dll_func_addr remove
dll_func_group_end CFunc_DelayedLoad

dll_func_group_start_without_name GFunc_DelayedLoad
def_dll_func_addr SelectObject
def_dll_func_addr DeleteObject
def_dll_func_addr GetStockObject
def_dll_func_addr GetCurrentObject
def_dll_func_addr ChoosePixelFormat
def_dll_func_addr SetPixelFormat
def_dll_func_addr GetTextMetricsW
def_dll_func_addr GetGlyphOutlineW
def_dll_func_addr GetTextExtentPoint32W
def_dll_func_addr CreateCompatibleDC
def_dll_func_addr CreateDIBSection
def_dll_func_addr DeleteDC
def_dll_func_addr SetBkColor
def_dll_func_addr SetTextColor
def_dll_func_addr SetBkMode
def_dll_func_addr ExtTextOutW
dll_func_group_end GFunc_DelayedLoad

dll_func_group_start_without_name WFunc_DelayedLoad
def_dll_func_addr waveOutBreakLoop
def_dll_func_addr waveOutClose
def_dll_func_addr waveOutGetDevCaps
def_dll_func_addr waveOutGetErrorText
def_dll_func_addr waveOutGetID
def_dll_func_addr waveOutGetNumDevs
def_dll_func_addr waveOutGetPitch
def_dll_func_addr waveOutGetPlaybackRate
def_dll_func_addr waveOutGetPosition
def_dll_func_addr waveOutGetVolume
def_dll_func_addr waveOutMessage
def_dll_func_addr waveOutOpen
def_dll_func_addr waveOutPause
def_dll_func_addr waveOutPrepareHeader
def_dll_func_addr waveOutProc
def_dll_func_addr waveOutReset
def_dll_func_addr waveOutRestart
def_dll_func_addr waveOutSetPitch
def_dll_func_addr waveOutSetPlaybackRate
def_dll_func_addr waveOutSetVolume
def_dll_func_addr waveOutUnprepareHeader
def_dll_func_addr waveOutWrite
dll_func_group_end WFunc_DelayedLoad

segment .rdata
extern _name_of_User32
extern _name_of_GDI32
extern _name_of_MSVCRT
extern _name_of_OpenGL32
extern _name_of_WinMM
_FirstDllName:
_name_of_User32   db "user32.dll", 0
_name_of_GDI32    db "gdi32.dll", 0
_name_of_MSVCRT   db "msvcrt.dll", 0
_name_of_OpenGL32 db "opengl32.dll", 0
_name_of_WinMM    db "winmm.dll", 0

extern _FopenTypeWb
_FopenTypeWb db "wb", 0

segment .bss
extern _addr_of_User32
extern _addr_of_GDI32
extern _addr_of_MSVCRT
extern _addr_of_OpenGL32
extern _addr_of_WinMM
_FirstDllAddr:
_addr_of_User32   resd 1
_addr_of_GDI32    resd 1
_addr_of_MSVCRT   resd 1
_addr_of_OpenGL32 resd 1
_addr_of_WinMM    resd 1
_NumDlls equ ($ - _FirstDllAddr) / 4

DefFunc _InitLoadLibrary
	FrameBegin ebx, esi, edi
	DefVars %$Index
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
	mov %$Index, ecx
.loop_get_func:
	inc dword %$Index
	mov esi, [eax]
	add esi, ebx
	mov edi, .get_proc_address
	mov cl, .get_proc_address_len
	repz cmpsb
	jecxz .found
	add eax, 4
	jmp .loop_get_func
.found:
	mov ecx, %$Index

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
	invoke_stdcall edx, ebx, _name_of_LoadLibraryA ; GetProcAddress
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

	mov esi, _FirstDllName
	mov edi, _FirstDllAddr
	mov ecx, _NumDlls
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

segment .rdata
	.get_proc_address db 'GetProcAddress', 0
	.get_proc_address_len equ $ - .get_proc_address

%ifndef NOIAT
	.name_of_Kernel32 db "kernel32.dll", 0
%endif

DefFunc _LoadFuncGroup
	FrameBegin ebx, esi, edi
	NameParams %$DllBase, %$Count, %$Names, %$Pointers
	mov ebx, %$DllBase
	mov ecx, %$Count
	mov esi, %$Names
	mov edi, %$Pointers
.next_func:
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
	loop .next_func
	FrameEnd
	ret

DefFunc _NextString
	FrameBegin
.next_char:
	lodsb
	test al, al ; Find NUL
	jnz .next_char
	FrameEnd
	ret

DefFunc _NLtoNUL
	FrameBegin esi, edi

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
	FrameBegin esi
	NameParams %$Pointers, %$DllBase, %$AssetPath, %$Count
	DefVars %$SizeOfNames

	invoke_cdecl _AssetsQuery, %$AssetPath, & %$SizeOfNames
	mov esi, eax
	invoke_cdecl _NLtoNUL, esi, %$SizeOfNames
	invoke_cdecl _LoadFuncGroup, %$DllBase, %$Count, esi, %$Pointers

	FrameEnd
	ret

DefFunc _InitDelayedLoadFunc
	FrameBegin ebx
	DefVars %$SizeOfFuncs

	AssetsQuery 'assets\CFUNC', & %$SizeOfFuncs
	mov ebx, eax
	invoke_cdecl _NLtoNUL, ebx, %$SizeOfFuncs
	dll_func_group_load_alter_name MSVCRT, CFunc_DelayedLoad, ebx

	AssetsQuery 'assets\KFUNC', & %$SizeOfFuncs
	mov ebx, eax
	invoke_cdecl _NLtoNUL, ebx, %$SizeOfFuncs
	dll_func_group_load_alter_name Kernel32, KFunc_DelayedLoad, ebx

	AssetsQuery 'assets\UFUNC', & %$SizeOfFuncs
	mov ebx, eax
	invoke_cdecl _NLtoNUL, ebx, %$SizeOfFuncs
	dll_func_group_load_alter_name User32, UFunc_DelayedLoad, ebx

	AssetsQuery 'assets\GFUNC', & %$SizeOfFuncs
	mov ebx, eax
	invoke_cdecl _NLtoNUL, ebx, %$SizeOfFuncs
	dll_func_group_load_alter_name GDI32, GFunc_DelayedLoad, ebx

	AssetsQuery 'assets\WFUNC', & %$SizeOfFuncs
	mov ebx, eax
	invoke_cdecl _NLtoNUL, ebx, %$SizeOfFuncs
	dll_func_group_load_alter_name WinMM, WFunc_DelayedLoad, ebx

	invoke_dll_stdcall GetSystemInfo, _SystemInfo

	FrameEnd
	ret

segment .bss
extern _DebugMsgBuffer
_DebugMsgBuffer resd 1

extern _DebugConsoleBuffer
_DebugConsoleBuffer resd 1

_DebugShowRect resd 4

DefFunc _InitDbg
	FrameBegin

	mov eax, [_DebugMsgBuffer]
	test eax, eax
	jnz .dbgmsgbuf_ok
	invoke_cdecl _calloc, _DebugMsgBufferSize + 1, 1
	mov [_DebugMsgBuffer], eax
.dbgmsgbuf_ok:

	mov eax, [_DebugConsoleBuffer]
	test eax, eax
	jnz .dbgconbuf_ok
	invoke_cdecl _calloc, _DebugConsoleBufferSize + 1, 1
	mov [_DebugConsoleBuffer], eax
.dbgconbuf_ok:

%ifdef _DEBUG
	cmp dword[_hDCDesktop], 0
	jnz .hdcdesktop_ok
	invoke_dll_stdcall GetDC, 0
	mov [_hDCDesktop], eax
.hdcdesktop_ok:
%endif
.end:
	FrameEnd
	ret

DefFunc _DeInitDbg
	FrameBegin

%ifdef _DEBUG
	mov eax, [_hDCDesktop]
	test eax, eax
	jz .hdcdesktop_ok
	invoke_dll_stdcall ReleaseDC, eax, 0
.hdcdesktop_ok:
%endif

	invoke_cdecl _free, [_DebugConsoleBuffer]
	invoke_cdecl _free, [_DebugMsgBuffer]

	xor eax, eax
	mov [_DebugMsgBuffer], eax
	mov [_DebugConsoleBuffer], eax
%ifdef _DEBUG
	mov [_hDCDesktop], eax
%endif

	FrameEnd
	ret

DefFunc _DebugMsg
	FrameBegin

	lea eax, Param(1)
	invoke_dll_cdecl vsnprintf, [_DebugMsgBuffer], _DebugMsgBufferSize, Param(0), eax
	invoke_dll_stdcall MessageBoxA, 0, [_DebugMsgBuffer], 0, 0

.end:
	xor eax, eax
	FrameEnd
	ret

%ifdef _DEBUG
DefFunc _DebugShow
	FrameBegin

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
	FrameBegin

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
	FrameBegin

	lea eax, Param(3)
	invoke_dll_cdecl vsnprintf, Param(0), Param(1), Param(2), eax

.end:
	FrameEnd
	ret

DefFunc _malloc
	FrameBegin
	invoke_dll_stdcall HeapAlloc, [_hHeap], 4, Param(0)
	FrameEnd
	ret

DefFunc _calloc
	FrameBegin

	mov eax, Param(0)
	mul dword Param(1)
	invoke_dll_stdcall HeapAlloc, [_hHeap], 8|4, eax

	FrameEnd
	ret

DefFunc _realloc
	FrameBegin
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
	FrameBegin
	invoke_dll_stdcall HeapFree, [_hHeap], 4, Param(0)
	FrameEnd
	ret

DefFunc _aligned_malloc ;void * aligned_malloc(size_t size, int align_bytes);
	FrameBegin

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
	FrameBegin

	mov eax, Param(0)
	test eax, eax
	jz .end

	invoke_cdecl _free, [eax - 4]

.end:
	FrameEnd
	ret

DefFunc _ReleaseComObj
	FrameBegin
	invoke_com Param(0), IUnknown.Release
	FrameEnd
	ret

DefFunc _SafeRelease
	FrameBegin ebx

	mov ebx, Param(0)
	mov eax, [ebx]
	test eax, eax
	jz .end

	invoke_com eax, IUnknown.Release
	mov dword[ebx], 0

.end:
	FrameEnd
	ret
