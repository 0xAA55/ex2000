%include "frame.inc"
%include "loaddll.inc"

extern _InitLoadLibrary
extern _InitGL33
extern _DeInitGL33
extern _Scene
extern _SceneInit

%define WM_CREATE 0x0001
%define WM_DESTROY 0x0002
%define WM_QUIT 0x0012

%define WS_OVERLAPPEDWINDOW (0x00000000 | 0x00C00000 | 0x00080000 | 0x00040000 | 0x00020000 | 0x00010000)

%define CW_USEDEFAULT 0x80000000

%define PM_REMOVE 1

struc WNDCLASSEX
	.cbSize resd 1
	.style resd 1
	.lpfnWndProc resd  1
	.cbClsExtra resd 1
	.cbWndExtra resd 1
	.hInstance resd 1
	.hIcon resd 1
	.hCursor resd 1
	.hbrBackground resd 1
	.lpszMenuName resd 1
	.lpszClassName resd 1
	.hIconSm resd 1
    .size equ $ - .cbSize
endstruc

struc MSG
    .hwnd resd 1
    .message resd 1
    .wParam resd 1
    .lParam resd 1
    .time resd 1
    .pt_x resd 1
    .pt_y resd 1
    .size equ $ - .hwnd
endstruc

segment .rdata
_ClassName db "EX2000_DemoWindow", 0
_WindowTitle db "EX2000", 0

segment .bss
global _hWnd
global _hDC
global _MSG
_WCEx resb WNDCLASSEX.size
_ClassAtom resd 1
_hWnd resd 1
_hDC resd 1
_hHeap resd 1
_MSG resb MSG.size

dll_func_group_start KFunc
def_dll_func_alias strcpy, "lstrcpyA"
def_dll_func_alias strcat, "lstrcatA"
def_dll_func_alias strlen, "lstrlenA"
def_dll_func_alias memset, "RtlFillMemory"
def_dll_func_alias memcpy, "RtlMoveMemory"
def_dll_func ExitProcess
def_dll_func QueryPerformanceFrequency
def_dll_func QueryPerformanceCounter
def_dll_func Sleep
def_dll_func GetProcessHeap
def_dll_func HeapAlloc
def_dll_func HeapReAlloc
def_dll_func HeapFree
def_dll_func HeapLock
def_dll_func HeapUnlock
global _addr_of_memmove
_addr_of_memmove equ _addr_of_memcpy
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
dll_func_group_end UFunc

segment .bss
_LastUFunc:

segment .text
global _start
_start:
	FrameBegin 0, 0
	call _InitLoadLibrary
	def_dll_and_load User32, "user32.dll"
	def_dll_and_load GDI32, "gdi32.dll"

	dll_func_group_load Kernel32, KFunc
	dll_func_group_load User32, UFunc

	invoke_dll_func GetProcessHeap
	mov [_hHeap], eax

	mov dword[_WCEx + WNDCLASSEX.cbSize], WNDCLASSEX.size
	mov dword[_WCEx + WNDCLASSEX.lpfnWndProc], _WndProc@16
	mov dword[_WCEx + WNDCLASSEX.hbrBackground], 6
	mov dword[_WCEx + WNDCLASSEX.lpszClassName], _ClassName

	mov eax, [_hInstance]
	mov [_WCEx + WNDCLASSEX.hInstance], eax

	PrepStdCallParam 0, 32512
	invoke_dll_func LoadIconA
	AfterStdCall

	mov [_WCEx + WNDCLASSEX.hIcon], eax
	mov [_WCEx + WNDCLASSEX.hIconSm], eax

	PrepStdCallParam 0, 32512
	invoke_dll_func LoadCursorA
	AfterStdCall
	mov [_WCEx + WNDCLASSEX.hCursor], eax

	PrepStdCallParam _WCEx
	invoke_dll_func RegisterClassExA
	AfterStdCall
	mov [_ClassAtom], eax

	PrepStdCallParam 0, eax, _WindowTitle, WS_OVERLAPPEDWINDOW, \
		CW_USEDEFAULT, CW_USEDEFAULT, 1024, 768, \
		0, 0, [_hInstance], 0
	invoke_dll_func CreateWindowExA
	AfterStdCall
	mov [_hWnd], eax

	PrepStdCallParam [_hWnd], 1
	invoke_dll_func ShowWindow
	AfterStdCall

	PrepStdCallParam [_hWnd]
	invoke_dll_func UpdateWindow
	AfterStdCall

	call _SceneInit

.msgloop:
	PrepStdCallParam _MSG, 0, 0, 0, PM_REMOVE
	invoke_dll_func PeekMessageA
	AfterStdCall
	test eax, eax
	jnz .proc_message

	call _Scene
	jmp .msgloop
.proc_message:

	cmp dword [_MSG + MSG.message], WM_QUIT
	je .exit

	PrepStdCallParam _MSG
	invoke_dll_func TranslateMessage
	AfterStdCall

	PrepStdCallParam _MSG
	invoke_dll_func DispatchMessageA
	AfterStdCall

	jmp .msgloop

.exit:
	FrameEnd
	PrepStdCallParam 0
	invoke_dll_func ExitProcess
	AfterStdCall
	ret

global _WndProc@16
_WndProc@16:
	FrameBegin 0, 0
	cmp dword Param(1), WM_CREATE
	jnz .other_than_WM_CREATE

	PrepStdCallParam Param(0)
	invoke_dll_func GetDC
	AfterStdCall
	mov [_hDC], eax

	call _InitGL33
	test eax, eax
	jz .fail

	xor eax, eax
	jmp .end
.fail:
	dec eax
	jmp .end
.other_than_WM_CREATE:
	cmp dword Param(1), WM_DESTROY
	jnz .other_than_WM_DESTROY

	call _DeInitGL33

	PrepStdCallParam [_hWnd], [_hDC]
	invoke_dll_func ReleaseDC
	AfterStdCall

	PrepStdCallParam 0
	invoke_dll_func PostQuitMessage
	AfterStdCall

	xor eax, eax
	jmp .end
.other_than_WM_DESTROY:
	FrameEnd
	jmp [_addr_of_DefWindowProcA]
.end:
	FrameEnd
	ret 16

global _malloc
_malloc:
	FrameBegin 0, 0

	PrepStdCallParam [_hHeap], 4, Param(0)
	invoke_dll_func HeapAlloc
	AfterStdCall

	FrameEnd
	ret

global _calloc
_calloc:
	FrameBegin 0, 0

	mov eax, Param(0)
	mul dword Param(1)
	PrepStdCallParam [_hHeap], 8|4, eax
	invoke_dll_func HeapAlloc
	AfterStdCall

	FrameEnd
	ret

global _realloc
_realloc:
	FrameBegin 0, 0

	PrepStdCallParam [_hHeap], 4, Param(0), Param(1)
	invoke_dll_func HeapReAlloc
	AfterStdCall

	FrameEnd
	ret

global _free
_free:
	FrameBegin 0, 0

	PrepStdCallParam [_hHeap], 4, Param(0)
	invoke_dll_func HeapFree
	AfterStdCall

	FrameEnd
	ret
