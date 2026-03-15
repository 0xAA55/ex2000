%include "loaddll.inc"
%include "frame.inc"
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
global _Scene
_Scene:
	FrameBegin 0, 1

	PrepParam 0, _Timer
	call _UpdateTimer

	push 0
	push 0
	push 0
	push 0
	invoke_dll_func glClearColor

	push GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
	invoke_dll_func glClear






	call _SwapBuffers
	FrameEnd
	ret

global _SwapBuffers
_SwapBuffers:
	mov eax, [_addr_of_wglSwapInterval]
	test eax, eax
	jnz .swap_buffers

	invoke_dll_func DwmFlush

.swap_buffers:
	push [_hDC]
	invoke_dll_func wglSwapBuffers
	ret

global _SceneInit
_SceneInit:
	FrameBegin 0, 1

	PrepParam 0, _Timer
	call _InitTimer

	mov eax, [_addr_of_wglSwapInterval]
	test eax, eax
	jz .no_swap_interval

	push 1
	invoke_dll_func wglSwapInterval
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

global _FakeDwmFlush
_FakeDwmFlush:
	xor eax, eax
	ret
