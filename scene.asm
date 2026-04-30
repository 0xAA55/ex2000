%include "loaddll.inc"
%include "timer.inc"
%include "gl33.inc"
%include "buffer.inc"
%include "assets.inc"
%include "shader.inc"
%include "matrix.inc"

extern _hWnd
extern _hDC

def_dll Dwmapi, "dwmapi.dll"
def_dll_func DwmFlush

import_dll_func Sleep
import_dll_func GetCursorPos
import_dll_func SetCursorPos
import_dll_func ShowCursor
import_dll_func GetWindowRect
import_dll_func GetClientRect
import_dll_func GetAsyncKeyState

extern _calloc
extern _realloc
extern _free
import_dll_func memcpy
import_dll_func strcpy
import_dll_func strlen
import_dll_func strcat
import_dll_func snprintf

segment .bss
alignb 16
global _CameraMatrix
_CameraMatrix resb Matrix.size
global _CameraYaw
_CameraYaw resd 1
global _CameraPitch
_CameraPitch resd 1
global _BillboardProgramLocations
_BillboardProgramLocations:
.CameraMatrix resd 1
.Aspect resd 1
global _Timer
_Timer resb Timer.size
global _ClientRect
_ClientRect:
.l resd 1
.t resd 1
.r resd 1
.b resd 1
global _WindowRect
_WindowRect:
.l resd 1
.t resd 1
.r resd 1
.b resd 1
global _WindowCenter
_WindowCenter:
.x resd 1
.y resd 1
global _CursorPos
_CursorPos:
.x resd 1
.y resd 1
global _Aspect
_Aspect resd 1
global _BillboardVerticesBuffer
_BillboardVerticesBuffer resb GlBuffer.size
global _DrawBillboardVAO
_DrawBillboardVAO resd 1
global _DrawBillboardProgram
_DrawBillboardProgram resd 1
global _BoxVerticesBuffer
_BoxVerticesBuffer resb GlBuffer.size
global _BoxIndicesBuffer
_BoxIndicesBuffer resb GlBuffer.size

segment .rdata
global _BillBoardVertices
_BillBoardVertices:
	db 0, 0
	db 1, 0
	db 0, 1
	db 1, 1
.num equ $ - _BillBoardVertices

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

global _name_ofu_CameraMatrix
_name_ofu_CameraMatrix db "camera", 0
global _name_ofu_Aspect
_name_ofu_Aspect db "aspect", 0
global _point_001
_point_001 dd 0x3a83126f

%macro SceneLoadShaderProgram 4
segment .rdata
%%VSAssetsPath db %2, 0
%%GSAssetsPath db %3, 0
%%FSAssetsPath db %4, 0

segment .text
invoke_cdecl _SceneLoadShaderProgram, %1, %%VSAssetsPath, %%GSAssetsPath, %%FSAssetsPath
%endmacro

%macro GetAttribLocation 2
segment .rdata
%%AttribName db %2, 0

segment .text
invoke_dll_stdcall glGetAttribLocation, %1, %%AttribName
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
	FrameBegin 1, 6

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

	invoke_cdecl _InitBuffer, _BillboardVerticesBuffer, GL_ARRAY_BUFFER, GL_STATIC_DRAW, 2, _BillBoardVertices.num / 2, _BillBoardVertices
	invoke_cdecl _InitBuffer, _BoxVerticesBuffer, GL_ARRAY_BUFFER, GL_STATIC_DRAW, 2, _BoxVertices.num / 2, _BoxVertices
	invoke_cdecl _InitBuffer, _BoxIndicesBuffer, GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW, 2, _BoxIndices.num / 2, _BoxIndices

	invoke_dll_stdcall glGenVertexArrays, 1, _DrawBillboardVAO
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_BillboardVerticesBuffer + GlBuffer.gl_buffer]
	GetAttribLocation [_DrawBillboardProgram], "position"
	mov Variable(0), eax
	invoke_dll_stdcall glEnableVertexAttribArray, Variable(0)
	invoke_dll_stdcall glVertexAttribPointer, Variable(0), 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, 0
	invoke_dll_stdcall glBindVertexArray, 0
	invoke_dll_stdcall glGetUniformLocation, [_DrawBillboardProgram], _name_ofu_CameraMatrix
	mov [_BillboardProgramLocations.CameraMatrix], eax
	invoke_dll_stdcall glGetUniformLocation, [_DrawBillboardProgram], _name_ofu_Aspect
	mov [_BillboardProgramLocations.Aspect], eax

.end:
	mov eax, 1
	FrameEnd
	ret

DefFunc _FakeDwmFlush
	xor eax, eax
	ret

DefFunc _Scene
	FrameBegin 0, 4

	invoke_cdecl _UpdateTimer, _Timer

	invoke_dll_stdcall GetAsyncKeyState, 0x1B
	test eax, eax
	jnz .quit

	invoke_dll_stdcall GetClientRect, [_hWnd], _ClientRect
	invoke_dll_stdcall GetWindowRect, [_hWnd], _WindowRect
	invoke_dll_stdcall GetCursorPos, _CursorPos
	invoke_dll_stdcall glViewport, [_ClientRect.l], [_ClientRect.t], [_ClientRect.r], [_ClientRect.b]

	mov eax, [_WindowRect.r]
	mov edx, [_WindowRect.b]
	add eax, [_WindowRect.l]
	add edx, [_WindowRect.t]
	shr eax, 1
	shr edx, 1
	mov [_WindowCenter.x], eax
	mov [_WindowCenter.y], edx

	fild dword [_CursorPos.x]
	fisub dword [_WindowCenter.x]
	fmul dword [_point_001]
	fchs
	fadd dword [_CameraYaw]
	fstp dword [_CameraYaw]

	fild dword [_CursorPos.y]
	fisub dword [_WindowCenter.y]
	fmul dword [_point_001]
	fchs
	fadd dword [_CameraPitch]
	fstp dword [_CameraPitch]

	invoke_dll_stdcall SetCursorPos, [_WindowCenter.x], [_WindowCenter.y]

	fild dword [_ClientRect.r]
	fidiv dword [_ClientRect.b]
	fstp dword [_Aspect]

	invoke_dll_stdcall glClearColor, 0, 0, 0, 0
	invoke_dll_stdcall glClear, GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT

	invoke_cdecl _MatrixRotationEuler, _CameraMatrix, [_CameraYaw], [_CameraPitch], 0

	invoke_dll_stdcall glUseProgram, [_DrawBillboardProgram]
	invoke_dll_stdcall glUniformMatrix4fv, [_BillboardProgramLocations.CameraMatrix], 1, 0, _CameraMatrix
	invoke_dll_stdcall glUniform1f, [_BillboardProgramLocations.Aspect], [_Aspect]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4
	invoke_dll_stdcall glBindVertexArray, 0
	invoke_dll_stdcall glUseProgram, 0

	invoke_cdecl _SwapBuffers
	xor eax, eax
	inc eax
	jmp .end
.quit:
	xor eax, eax

.end:
	FrameEnd
	ret

DefFunc _SwapBuffers
	FrameBegin 0, 0
	mov eax, [_addr_of_wglSwapInterval]
	test eax, eax
	jnz .swap_buffers

	invoke_dll_stdcall DwmFlush

.swap_buffers:
	invoke_dll_stdcall wglSwapBuffers, [_hDC]
	FrameEnd
	ret
