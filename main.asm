%include "frame.inc"
%include "loaddll.inc"

extern _InitLoadLibrary
extern _InitGL33
extern _DeInitGL33

%define WM_CREATE 0x0001
%define WM_DESTROY 0x0002
%define WM_QUIT 0x0012

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
_MSG resb MSG.size

segment .text
global _start
_start:
	FrameBegin 0, 0
	call _InitLoadLibrary

	def_dll_func_and_load Kernel32, ExitProcess

	def_dll_and_load User32, "user32.dll"
	def_dll_func_and_load User32, LoadIconA
	def_dll_func_and_load User32, LoadCursorA
	def_dll_func_and_load User32, RegisterClassExA
	def_dll_func_and_load User32, CreateWindowExA
	def_dll_func_and_load User32, ShowWindow
	def_dll_func_and_load User32, UpdateWindow
	def_dll_func_and_load User32, PeekMessageA
	def_dll_func_and_load User32, TranslateMessage
	def_dll_func_and_load User32, DispatchMessageA
	def_dll_func_and_load User32, PostQuitMessage
	def_dll_func_and_load User32, DefWindowProcA
	def_dll_func_and_load User32, GetDC
	def_dll_func_and_load User32, ReleaseDC

	def_dll_and_load GDI32, "gdi32.dll"

	mov dword[_WCEx + WNDCLASSEX.cbSize], WNDCLASSEX.size
	mov dword[_WCEx + WNDCLASSEX.lpfnWndProc], _WndProc@16
	mov dword[_WCEx + WNDCLASSEX.hbrBackground], 6
	mov dword[_WCEx + WNDCLASSEX.lpszClassName], _ClassName

	mov eax, [_hInstance]
	mov [_WCEx + WNDCLASSEX.hInstance], eax

	push 32512
	push 0
	invoke_dll_func LoadIconA
	mov [_WCEx + WNDCLASSEX.hIcon], eax
	mov [_WCEx + WNDCLASSEX.hIconSm], eax

	push 32512
	push 0
	invoke_dll_func LoadCursorA
	mov [_WCEx + WNDCLASSEX.hCursor], eax

	push _WCEx
	invoke_dll_func RegisterClassExA
	mov [_ClassAtom], eax

	push 0
	push [_hInstance]
	push 0
	push 0
	push 768
	push 1024
	push 0x80000000 ; CW_USEDEFAULT
	push 0x80000000 ; CW_USEDEFAULT
	push (0x00000000 | 0x00C00000 | 0x00080000 | 0x00040000 | 0x00020000 | 0x00010000) ; WS_OVERLAPPEDWINDOW
	push _WindowTitle
	push eax
	push 0
	invoke_dll_func CreateWindowExA
	mov [_hWnd], eax

	push 1
	push [_hWnd]
	invoke_dll_func ShowWindow

	push [_hWnd]
	invoke_dll_func UpdateWindow

.msgloop:
	push 1
	push 0
	push 0
	push 0
	push _MSG
	invoke_dll_func PeekMessageA

	cmp dword [_MSG + MSG.message], WM_QUIT
	je .exit

	push _MSG
	invoke_dll_func TranslateMessage

	push _MSG
	invoke_dll_func DispatchMessageA

	jmp .msgloop

.exit:
	FrameEnd
	push 0
	invoke_dll_func ExitProcess
	ret

global _WndProc@16
_WndProc@16:
	FrameBegin 0, 0
	cmp dword Param(1), WM_CREATE
	jnz .other_than_WM_CREATE

	push Param(0)
	invoke_dll_func GetDC
	mov [_hDC], eax

	call _InitGL33

	xor eax, eax
	jmp .end
.other_than_WM_CREATE:
	cmp dword Param(1), WM_DESTROY
	jnz .other_than_WM_DESTROY

	call _DeInitGL33

	push [_hDC]
	push [_hWnd]
	invoke_dll_func ReleaseDC

	push 0
	invoke_dll_func PostQuitMessage

	xor eax, eax
	jmp .end
.other_than_WM_DESTROY:
	FrameEnd
	jmp [_addr_of_DefWindowProcA]
.end:
	FrameEnd
	ret 16
