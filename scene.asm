%include "loaddll.inc"
%include "timer.inc"
%include "gl33.inc"

extern _hWnd
extern _hDC

def_dll Dwmapi, "dwmapi.dll"
def_dll_func DwmFlush

import_dll_func Sleep

segment .bss
global _Timer
_Timer resb Timer.size

segment .text
DefFunc _Scene
	FrameBegin 0, 1

	PrepParam 0, _Timer
	call _UpdateTimer

	invoke_dll_stdcall glClearColor, 0, 0, 0, 0
	invoke_dll_stdcall glClear, GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT






	call _SwapBuffers
	FrameEnd
	ret

DefFunc _SwapBuffers
	mov eax, [_addr_of_wglSwapInterval]
	test eax, eax
	jnz .swap_buffers

	invoke_dll_stdcall DwmFlush

.swap_buffers:
	invoke_dll_stdcall wglSwapBuffers, [_hDC]
	ret

DefFunc _SceneInit
	FrameBegin 0, 1

	PrepParam 0, _Timer
	call _InitTimer

	mov eax, [_addr_of_wglSwapInterval]
	test eax, eax
	jz .no_swap_interval

	invoke_dll_stdcall wglSwapInterval, 1
	jmp .load_scene
.no_swap_interval:
	load_dll Dwmapi
	test eax, eax
	jz .no_dwmflush

	load_dll_func Dwmapi, DwmFlush
	test eax, eax
	jz .no_dwmflush
	jmp .load_scene
.no_dwmflush:
	mov dword [_addr_of_DwmFlush], _FakeDwmFlush
.load_scene:






.end:
	FrameEnd
	ret

DefFunc _FakeDwmFlush
	xor eax, eax
	ret
