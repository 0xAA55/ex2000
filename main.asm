%include "loaddll.inc"
%include "assets.inc"
%include "math.inc"
%include "tls.inc"

extern _InitLoadLibrary
extern _InitDelayedLoadFunc
extern _InitGL33
extern _DeInitGL33
extern _Scene
extern _SceneInit
extern _SceneUnload

%macro InstWNDCLASSEX 0
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
%endmacro

%macro InstMSG 0
    .hwnd resd 1
    .message resd 1
    .wParam resd 1
    .lParam resd 1
    .time resd 1
    .pt_x resd 1
    .pt_y resd 1
    .size equ $ - .hwnd
%endmacro

struc WNDCLASSEX
	InstWNDCLASSEX
endstruc

struc MSG
	InstMSG
endstruc

segment .rdata
_ClassName db "EX2000_DemoWindow", 0
_WindowTitle db "EX2000", 0

segment .bss
extern _hWnd
extern _hDC
extern _MSG
_WCEx:
	InstWNDCLASSEX
_ClassAtom resd 1
_hWnd resd 1
_hDC resd 1
_MSG:
	InstMSG

segment .bss
_LastUFunc:

DefFunc _entry
	FrameBegin 0, 2, ebx
	invoke_cdecl _InitLoadLibrary
	invoke_cdecl _AssetsInit
	invoke_cdecl _InitDelayedLoadFunc
	invoke_cdecl _TlsInit
	invoke_cdecl _MathInit
	invoke_cdecl _TlsInvokeCallbacks, TLS_CALLBACK_REASON_ON_INIT
	invoke_cdecl _main
	mov ebx, eax
	invoke_cdecl _TlsInvokeCallbacks, TLS_CALLBACK_REASON_ON_FINI
	invoke_cdecl _MathDeInit
	invoke_cdecl _TlsDeInit
	invoke_cdecl _AssetsDestroy
	invoke_dll_stdcall ExitProcess, ebx
	FrameEnd
	ret

DefFunc _main
	FrameBegin 0, 1

	mov byte[_WCEx.cbSize], WNDCLASSEX.size
	mov dword[_WCEx.lpfnWndProc], _WndProc@16
	mov byte[_WCEx.hbrBackground], 6
	mov dword[_WCEx.lpszClassName], _ClassName

	mov eax, [_hInstance]
	mov [_WCEx.hInstance], eax

	invoke_dll_stdcall LoadIconA, 0, 32512

	mov [_WCEx.hIcon], eax
	mov [_WCEx.hIconSm], eax

	invoke_dll_stdcall LoadCursorA, 0, 32512
	mov [_WCEx.hCursor], eax

	invoke_dll_stdcall RegisterClassExA, _WCEx
	mov [_ClassAtom], eax

	invoke_dll_stdcall CreateWindowExA, \
		0, _ClassName, _WindowTitle, WS_OVERLAPPEDWINDOW, \
		CW_USEDEFAULT, CW_USEDEFAULT, 1024, 768, \
		0, 0, [_hInstance], 0
	mov [_hWnd], eax

	invoke_dll_stdcall ShowWindow, [_hWnd], 1
	invoke_dll_stdcall UpdateWindow, [_hWnd]

	invoke_cdecl _SceneInit
	test eax, eax
	jz .exit

.msgloop:
	invoke_cdecl _DoEvents
	test eax, eax
	jz .exit

	invoke_cdecl _Scene
	test eax, eax
	jz .exit

	jmp .msgloop
.exit:
	xor eax, eax
	FrameEnd
	ret

DefFunc _DoEvents
	FrameBegin 0, 0

	invoke_dll_stdcall PeekMessageA, _MSG, 0, 0, 0, PM_REMOVE
	test eax, eax
	jz .finish

	cmp dword [_MSG.message], WM_QUIT
	je .quit

	invoke_dll_stdcall TranslateMessage, _MSG
	invoke_dll_stdcall DispatchMessageA, _MSG

.finish:
	mov al, 1
	jmp .end
.quit:
	xor eax, eax
.end:
	FrameEnd
	ret

DefFunc _WndProc@16
	FrameBegin 0, 0
	cmp dword Param(1), WM_CREATE
	jnz .other_than_WM_CREATE

	invoke_dll_stdcall GetDC, Param(0)
	mov [_hDC], eax

	invoke_cdecl _InitGL33
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

	invoke_cdecl _SceneUnload
	invoke_cdecl _DeInitGL33

	invoke_dll_stdcall ReleaseDC, [_hWnd], [_hDC]
	invoke_dll_stdcall PostQuitMessage, 0

	xor eax, eax
	jmp .end
.other_than_WM_DESTROY:
	FrameEnd
	jmp [_addr_of_DefWindowProcA]
.end:
	FrameEnd
	ret 16
