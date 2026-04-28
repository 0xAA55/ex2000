%include "loaddll.inc"
%include "timer.inc"
%include "gl33.inc"
%include "buffer.inc"
%include "assets.inc"
%include "shader.inc"

extern _hWnd
extern _hDC

def_dll Dwmapi, "dwmapi.dll"
def_dll_func DwmFlush

import_dll_func Sleep

extern _calloc
extern _realloc
extern _free
import_dll_func memcpy
import_dll_func strcpy
import_dll_func strlen
import_dll_func strcat
import_dll_func snprintf

segment .bss
global _Timer
_Timer resb Timer.size
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

;DefFunc _ReallocateStringCat
;	FrameBegin 1, 2
;
;	mov eax, Param(0)
;	test eax, eax
;	jz .new
;	invoke_dll_cdecl strlen, eax
;	mov Variable(0), eax
;	invoke_dll_cdecl strlen, Param(1)
;	add eax, Variable(0)
;	inc eax
;	invoke_cdecl _realloc, Param(0), eax
;	test eax, eax
;	jz .failed
;	mov Variable(0), eax
;	invoke_dll_cdecl strcat, eax, Param(1)
;	mov eax, Variable(0)
;	jmp .end
;.new:
;	invoke_dll_cdecl strlen, Param(1)
;	inc eax
;	invoke_cdecl _calloc, eax, 1
;	test eax, eax
;	jz .failed
;	mov Variable(0), eax
;	invoke_dll_cdecl strcpy, eax, Param(1)
;	mov eax, Variable(0)
;
;	jmp .end
;.failed:
;	invoke_cdecl _free, Param(0)
;	xor eax, eax
;
;.end:
;	FrameEnd
;	ret
;
;segment .rdata
;global _NL
;_NL db 10, 0
;
;segment .text
;DefFunc _SceneDebugGetAttribs
;	FrameBegin 7, 7, esi, edi
;
;	xor eax, eax
;	mov esi, eax
;	lea edi, Variable(0)
;	mov ecx, 7
;	rep stosd
;	invoke_dll_stdcall glGetProgramiv, Param(0), GL_ACTIVE_ATTRIBUTES, &Variable(1)
;	invoke_dll_stdcall glGetProgramiv, Param(0), GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &Variable(2)
;	mov eax, Variable(2)
;	add eax, 64
;	mov Variable(2), eax
;	invoke_cdecl _calloc, eax, 1
;	test eax, eax
;	jz .end
;	mov Variable(3), eax
;	invoke_cdecl _calloc, Variable(2), 1
;	test eax, eax
;	jz .end
;	mov Variable(6), eax
;
;.enum:
;	invoke_dll_stdcall glGetActiveAttrib, Param(0), esi, Variable(2), 0, &Variable(4), &Variable(5), Variable(6)
;	snprintf Variable(3), Variable(2), "%d: %p(%d) %s", esi, Variable(5), Variable(4), Variable(6)
;	invoke_cdecl _ReallocateStringCat, Variable(0), Variable(3)
;	invoke_cdecl _ReallocateStringCat, eax, _NL
;	mov Variable(0), eax
;
;	inc esi
;	cmp esi, Variable(1)
;	jb .enum
;
;	debug_msg "AA: %s", Variable(0)
;
;.end:
;	invoke_cdecl _free, Variable(0)
;	invoke_cdecl _free, Variable(3)
;	invoke_cdecl _free, Variable(6)
;	FrameEnd
;	ret

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

	invoke_dll_stdcall glUseProgram, [_DrawBillboardProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4
	invoke_dll_stdcall glBindVertexArray, 0



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