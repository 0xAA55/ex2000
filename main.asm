%include "loaddll.inc"
%include "assets.inc"
%include "math.inc"
%include "tls.inc"
%include "vblank.inc"

extern _InitLoadLibrary
extern _InitDelayedLoadFunc
extern _InitGL33
extern _DeInitGL33
extern _Scene
extern _SceneInit
extern _SceneUnload

%define DESIRED_WIDTH 1920
%define DESIRED_HEIGHT 1080

segment .rdata
_ClassName db "EX2000_DemoWindow", 0
_WindowTitle db "EX2000", 0

segment .bss
extern _WCEx
_WCEx:
	InstWNDCLASSEX

extern _ClassAtom
_ClassAtom resd 1

extern _hWnd
_hWnd resd 1

extern _hDC
_hDC resd 1

extern _MSG
_MSG:
	InstMSG

DefFunc _entry
	FrameBegin ebx
	invoke_cdecl _InitLoadLibrary
	invoke_cdecl _AssetsInit
	invoke_cdecl _InitDelayedLoadFunc
	invoke_cdecl _TlsInit
	invoke_cdecl _MathInit
	invoke_cdecl _TlsInvokeCallbacks, TLS_CALLBACK_REASON_ON_INIT
	invoke_cdecl _InitDbg
	invoke_cdecl _main
	mov ebx, eax
	invoke_cdecl _DeInitDbg
	invoke_cdecl _TlsInvokeCallbacks, TLS_CALLBACK_REASON_ON_FINI
	invoke_cdecl _MathDeInit
	invoke_cdecl _TlsDeInit
	invoke_cdecl _AssetsDestroy
	invoke_dll_stdcall ExitProcess, ebx
	FrameEnd
	ret

DefFunc _main
	FrameBegin

	DefVars %$TR_L, %$TR_T, %$TR_R, %$TR_B
	DefVars %$WinW, %$WinH
	DefSizedVar %$MonitorInfoW, MONITORINFOW.size

	xor eax, eax
	mov ecx, %$Frame_NumLocals
	lea edi, Variable(0)
	rep stosd

	mov word %$WinW, DESIRED_WIDTH
	mov word %$WinH, DESIRED_HEIGHT

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
		CW_USEDEFAULT, CW_USEDEFAULT, DESIRED_WIDTH, DESIRED_HEIGHT, \
		0, 0, [_hInstance], 0
	mov [_hWnd], eax

	mov byte[%$MonitorInfoW_Addr + MONITORINFOW.cbSize], MONITORINFOW.size
	invoke_dll_stdcall MonitorFromWindow, [_hWnd], MONITOR_DEFAULTTONEAREST
	invoke_dll_stdcall GetMonitorInfoW, eax, &%$MonitorInfoW
	movq xmm0, [%$MonitorInfoW_Addr + MONITORINFOW.rcMonitor_x]
	movq xmm1, [%$MonitorInfoW_Addr + MONITORINFOW.rcMonitor_r]
	movq xmm2, xmm1
	movq xmm3, %$WinW
	paddd xmm1, xmm0
	psubd xmm2, xmm0
	psrad xmm1, 1
	pminsw xmm2, xmm3
	movq %$WinW, xmm2
	movq xmm3, xmm2
	psrad xmm2, 1
	psubd xmm1, xmm2
	movq %$TR_L, xmm1
	paddd xmm1, xmm3
	movq %$TR_R, xmm1
	invoke_dll_stdcall AdjustWindowRect, & %$TR_L, WS_OVERLAPPEDWINDOW, 0
	invoke_dll_stdcall MoveWindow, [_hWnd], %$TR_L, %$TR_T, %$WinW, %$WinH, 0

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
	FrameBegin

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
	FrameBegin
	mov eax, Param(1)
	cmp eax, WM_CREATE
	jnz .other_than_WM_CREATE

	invoke_dll_stdcall GetDC, Param(0)
	mov [_hDC], eax

	invoke_dll_stdcall GetStockObject, SYSTEM_FIXED_FONT
	invoke_dll_stdcall SelectObject, [_hDC], eax
	invoke_dll_stdcall DeleteObject, eax

	invoke_cdecl _InitGL33
	test eax, eax
	jz .fail

	xor eax, eax
	jmp .end
.fail:
	dec eax
	jmp .end
.other_than_WM_CREATE:
	cmp eax, WM_DESTROY
	jnz .other_than_WM_DESTROY

	invoke_cdecl _SceneUnload
	invoke_cdecl _DeInitGL33

	invoke_dll_stdcall ReleaseDC, [_hWnd], [_hDC]
	invoke_dll_stdcall PostQuitMessage, 0

	xor eax, eax
	jmp .end
.other_than_WM_DESTROY:
	cmp eax, WM_DISPLAYCHANGE
	jnz .other_than_WM_DISPLAYCHANGE

	invoke_cdecl _VBlankReInit

	xor eax, eax
	jmp .end
.other_than_WM_DISPLAYCHANGE:
	invoke_dll_stdcall DefWindowProcA, Param(0), Param(1), Param(2), Param(3)
.end:
	FrameEnd
	ret 16
