%include "loaddll.inc"
%include "timer.inc"
%include "gl33.inc"
%include "buffer.inc"

extern _hWnd
extern _hDC

def_dll Dwmapi, "dwmapi.dll"
def_dll_func DwmFlush

import_dll_func Sleep

segment .bss
global _Timer
_Timer resb Timer.size
global _DrawBillboardProgram
_DrawBillboardProgram resd 1
global _BoxVerticesBuffer
_BoxVerticesBuffer resd 1
global _BoxIndicesBuffer
_BoxIndicesBuffer resd 1

segment .rdata
global _BoxVertices
_BoxVertices:
	db -1, -1,  1
	db  1, -1,  1
	db -1,  1,  1
	db  1,  1,  1
	db -1, -1, -1
	db  1, -1, -1
	db -1,  1, -1
	db  1,  1, -1
.num equ $ - _BoxVertices

global _BoxIndices
_BoxIndices:
	; Top
	db 2, 6, 7
	db 2, 3, 7

	; Bottom
	db 0, 4, 5
	db 0, 1, 5

	; Left
	db 0, 2, 6
	db 0, 4, 6

	; Right
	db 1, 3, 7
	db 1, 5, 7

	; Front
	db 0, 2, 3
	db 0, 1, 3

	; Back
	db 4, 6, 7
	db 4, 5, 7
.num equ $ - _BoxIndices

%macro SceneLoadShaderProgram 4
segment .rdata
%%VSAssetsPath db %2, 0
%%GSAssetsPath db %3, 0
%%FSAssetsPath db %4, 0

segment .text
invoke_cdecl _SceneLoadShaderProgram, %1, %%VSAssetsPath, %%GSAssetsPath, %%FSAssetsPath
%endmacro

segment .text
; void SceneLoadShaderProgram(_out_ GLuint *program, _in_ char *VertexShaderAssetPath, _in_ char *GeometryShaderAssetPath, _in_ char *FragmentShaderAssetPath);
DefFunc _SceneLoadShaderProgram
	FrameBegin 3, 3, esi

	mov esi, Param(0)
	invoke_cdecl _AssetsQuery, Param(1), 0
	mov Variable(0), eax
	invoke_cdecl _AssetsQuery, Param(2), 0
	mov Variable(1), eax
	invoke_cdecl _AssetsQuery, Param(3), 0
	mov Variable(2), eax

	invoke_cdecl _ProgramCreate, Variable(0), Variable(1), Variable(2)
	mov [esi], eax

	FrameEnd
	ret

;int SceneInit();
DefFunc _SceneInit
	FrameBegin 0, 6

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

	SceneLoadShaderProgram _DrawBillboardProgram, "assets\shaders\skybill.vsh", 0, "assets\shaders\skybill.fsh"

	InitBuffer _BillboardVerticesBuffer, GL_ARRAY_BUFFER, GL_STATIC_DRAW, 1, _BillBoardVertices.num, _BillBoardVertices
	InitBuffer _BoxVerticesBuffer, GL_ARRAY_BUFFER, GL_STATIC_DRAW, 1, _BoxVertices.num, _BoxVertices
	InitBuffer _BoxIndicesBuffer, GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW, 1, _BoxIndices.num, _BoxIndices

.end:
	mov eax, 1
	FrameEnd
	ret

DefFunc _FakeDwmFlush
	xor eax, eax
	ret

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