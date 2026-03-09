%include "loaddll.inc"
%include "frame.inc"
%define GL_NO_FUNC_IMPORT 1
%include "gl33.inc"

import_dll GDI32
import_dll_func strcpy
import_dll_func strcat
import_dll_func strlen
import_dll_func MessageBoxA

extern _hWnd
extern _hDC

struc PIXELFORMATDESCRIPTOR
	.nSize: resw 1
	.nVersion: resw 1
	.dwFlags: resd 1
	.iPixelType: resb 1
	.cColorBits: resb 1
	.cRedBits: resb 1
	.cRedShift: resb 1
	.cGreenBits: resb 1
	.cGreenShift: resb 1
	.cBlueBits: resb 1
	.cBlueShift: resb 1
	.cAlphaBits: resb 1
	.cAlphaShift: resb 1
	.cAccumBits: resb 1
	.cAccumRedBits: resb 1
	.cAccumGreenBits: resb 1
	.cAccumBlueBits: resb 1
	.cAccumAlphaBits: resb 1
	.cDepthBits: resb 1
	.cStencilBits: resb 1
	.cAuxBuffers: resb 1
	.iLayerType: resb 1
	.bReserved: resb 1
	.dwLayerMask: resd 1
	.dwVisibleMask: resd 1
	.dwDamageMask: resd 1
	.size equ $ - .nSize
endstruc

segment .bss
global _hGLRC
_hGLRC resd 1

global _OpenGL_Vendor
global _OpenGL_Renderer
global _OpenGL_Version
global _OpenGL_Is_ES
global _OpenGL_Ver_Major
global _OpenGL_Ver_Minor
global _OpenGL_Ver_Release
global _FailReason
_OpenGL_Vendor resd 1
_OpenGL_Renderer resd 1
_OpenGL_Version resd 1
_OpenGL_Is_ES resd 1
_OpenGL_Ver_Major resd 1
_OpenGL_Ver_Minor resd 1
_OpenGL_Ver_Release resd 1
_FailReason resd 1
global _OpenGLNullFunctions
_OpenGLNullFunctions resb 4096

%define PFD_DRAW_TO_WINDOW 0x00000004
%define PFD_SUPPORT_OPENGL 0x00000020
%define PFD_DOUBLEBUFFER 0x00000001
%define PFD_TYPE_RGBA 0
%define PFD_MAIN_PLANE 0

segment .rdata
global _PFD
_PFD:
istruc PIXELFORMATDESCRIPTOR
	at .nSize, dw PIXELFORMATDESCRIPTOR.size
	at .nVersion, dw 1
	at .dwFlags, dd PFD_DRAW_TO_WINDOW|PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER
	at .iPixelType, db PFD_TYPE_RGBA
	at .cColorBits, db 32
	at .cRedBits, db 8
	at .cGreenBits, db 8
	at .cBlueBits, db 8
	at .cAlphaBits, db 8
	at .cDepthBits, db 24
	at .cStencilBits, db 8
	at .iLayerType, db PFD_MAIN_PLANE
iend

global _ParseFailText
_ParseFailText db "Unable to parse OpenGL version:", 0xd, 0xa, 0
global _ParseFailBecauseNondigit
global _ParseFailBecauseDotExpected
global _ParseFailBecauseUnknown
_ParseFailBecauseNondigit db 0xd, 0xa, "Unexpected non-digit", 0
_ParseFailBecauseDotExpected db 0xd, 0xa, "Dot '.' expected", 0
_ParseFailBecauseUnknown db 0xd, 0xa, "Unknown error", 0

; The code table to decode the function names
; The order of the strings represents the code
global _DecodeTableStrings
_DecodeTableStrings:
.code_01 db "WindowPos", 0
.code_02 db "Compressed", 0
.code_03 db "Multisample", 0
.code_04 db "FragData", 0
.code_05 db "Location", 0
.code_06 db "Clear", 0
.code_07 db "Renderbuffer", 0
.code_08 db "Enable", 0
.code_09 db "Disable", 0
.code_0a db "Begin", 0
.code_0b db "End", 0
.code_0c db "Instanced", 0
.code_0d db "Range", 0
.code_0e db "Base", 0
.code_0f db "Mask", 0
.code_10 db "Func", 0
.code_11 db "Blend", 0
.code_12 db "Separate", 0
.code_13 db "Data", 0
.code_14 db "Sub", 0
.code_15 db "Copy", 0
.code_16 db "Op", 0
.code_17 db "Object", 0
.code_18 db "Is", 0
.code_19 db "Attach", 0
.code_1a db "TransformFeedback", 0
.code_1b db "Map", 0
.code_1c db "ConditionalRender", 0
.code_1d db "Depth", 0
.code_1e db "Pixel", 0
.code_1f db "Block", 0
.code_20 db "Sync", 0
.code_21 db "Bind", 0
.code_22 db "iv", 0
.code_23 db "Matrix", 0
.code_24 db "Image", 0
.code_25 db "Transpose", 0
.code_26 db "Texture", 0
.code_27 db "fv", 0
.code_28 db "Secondary", 0
.code_29 db "Active", 0
.code_2a db "Vertex", 0
.code_2b db "Tex", 0
.code_2c db "TexCoord", 0
.code_2d db "ing", 0
.code_2e db "Point", 0
.code_2f db "Delete", 0
.code_30 db "Queries", 0
.code_31 db "1", 0
.code_32 db "2", 0
.code_33 db "3", 0
.code_34 db "4", 0
.code_35 db "Color", 0
.code_36 db "6", 0
.code_37 db "Framebuffer", 0
.code_38 db "Gen", 0
.code_39 db "Coord", 0
.code_3a db "Sampler", 0
.code_3b db "ui", 0
.code_3c db "Get", 0
.code_3d db "Uniform", 0
.code_3e db "Query", 0
.code_3f db "Parameter", 0
.code_40 db "Attrib", 0

.code_5b db "Buffer", 0
.code_5c db "Flush", 0
.code_5d db "Element", 0
.code_5e db "Multi", 0
.code_5f db "_", 0
.code_60 db "Pointer", 0

.code_7b db "Array", 0
.code_7c db "Varying", 0
.code_7d db "Draw", 0
.code_7e db "Program", 0
.code_7f db "Stencil", 0
.code_80 db "Shader", 0
.code_81 db "Location", 0
.code_82 db "Integer", 0
.code_83 db "Equation", 0
.code_84 db "Normal", 0
.code_85 db "Fog", 0

%define LAST_CODE 85

; Offsets of the strings
global _DecodeTable
_DecodeTable:
.code_01_40:
	%assign CurCode 0x01
	%rep 0x10 - CurCode
		dw _DecodeTableStrings.code_ %+ 0 %+ %tok(%substr(%hex(CurCode), 3)) - _DecodeTableStrings
		%assign CurCode CurCode + 1
	%endrep
	%assign CurCode 0x10
	%rep (0x40) + 1 - CurCode
		dw _DecodeTableStrings.code_ %+ %tok(%substr(%hex(CurCode), 3)) - _DecodeTableStrings
		%assign CurCode CurCode + 1
	%endrep

.code_5b_60:
	%assign CurCode 0x5b
	%rep (0x60) + 1 - CurCode
		dw _DecodeTableStrings.code_ %+ %tok(%substr(%hex(CurCode), 3)) - _DecodeTableStrings
		%assign CurCode CurCode + 1
	%endrep

.code_7b_ %+ LAST_CODE:
	%assign CurCode 0x7B
	%rep (0x %+ LAST_CODE) + 1 - CurCode
		dw _DecodeTableStrings.code_ %+ %tok(%substr(%hex(CurCode), 3)) - _DecodeTableStrings
		%assign CurCode CurCode + 1
	%endrep
	%undef CurCode

global _OpenGL_ES_String
_OpenGL_ES_String db "OpenGL ES "
.size equ $ - _OpenGL_ES_String

_FailedToGet db "Failed to fetch OpenGL function pointers:"
_NewLine db 0xd, 0xa, 0
_TheseFunc db "These functions are unavailable.", 0

segment .bss
; The buffer to store the decoded function name
global _FuncNameBuf
_FuncNameBuf resb 64

; The buffer to store parse fail info string
global _FailInfoBuffer
_FailInfoBuffer resb 256

segment .text
global _DecodeProcName
_DecodeProcName:
	FrameBegin 3, 0

	StoreVariable 0, esi
	StoreVariable 1, edi

	mov word[_FuncNameBuf], 'gl' ; Add prefix

	mov esi, eax
	mov edi, _FuncNameBuf + 2

.decode_loop:
	xor eax, eax
	lodsb
	test al, al ; Check NUL
	jz .end
	cmp al, 0x40
	jbe .code_01_40 ; Part 1
	cmp al, 0x5B
	jb .movechar ; ABCDEFG...
	cmp al, 0x60
	jbe .code_5b_60 ; Part 2
	cmp al, 0x7B
	jb .movechar ; abcdefg...
	cmp al, 0x %+ LAST_CODE
	jbe .code_7b_ %+ LAST_CODE ; Part 3

.movechar:
	stosb ; No need to decode
	jmp .decode_loop
.code_01_40: ; Part 1
	StoreVariable 2, esi
	dec al ; Start from 1
	movzx esi, word[_DecodeTable.code_01_40 + eax * 2]
	jmp .decode
.code_5b_60: ; Part 2
	StoreVariable 2, esi
	sub al, 0x5B
	movzx esi, word[_DecodeTable.code_5b_60 + eax * 2]
	jmp .decode
.code_7b_ %+ LAST_CODE: ; Part 3
	StoreVariable 2, esi
	sub al, 0x7B
	movzx esi, word[_DecodeTable.code_7b_ %+ LAST_CODE + eax * 2]
.decode:
	add esi, _DecodeTableStrings ; Add up offset
.copy_loop:
	lodsb
	test al, al
	jz .decode_end
	stosb
	jmp .copy_loop
.decode_end:
	LoadVariable esi, 2
	jmp .decode_loop

.end:
	stosb ; Trail 0

	LoadVariable esi, 0
	LoadVariable edi, 1

	FrameEnd
	ret

global _NextString
_NextString:
	lodsb
	test al, al ; Find NUL
	jnz _NextString
	ret

global _CheckOpenGLProcAddress
_CheckOpenGLProcAddress:
	test eax, eax
	jnz .success

	push _OpenGLNullFunctions
	invoke_dll_func strlen
	test eax, eax
	jnz .strcat_fn_name

	push _FailedToGet
	push _OpenGLNullFunctions
	invoke_dll_func strcat

.strcat_fn_name:
	push _FuncNameBuf
	push _OpenGLNullFunctions
	invoke_dll_func strcat

	push _NewLine
	push _OpenGLNullFunctions
	invoke_dll_func strcat

	xor eax, eax
.success:
	ret

global _GetGL32ProcAddress ; Using Kernel32.dll `GetProcAddress`
_GetGL32ProcAddress:
	FrameBegin 0, 0

	call _DecodeProcName

	push _FuncNameBuf
	push [_addr_of_OpenGL32]
	call [_addr_of_GetProcAddress]

	call _CheckOpenGLProcAddress

	FrameEnd
	ret

global _GetGLProcAddress ; Using OpenGL32.dll `wglGetProcAddress`
_GetGLProcAddress:
	FrameBegin 0, 0

	call _DecodeProcName

	push _FuncNameBuf
	invoke_dll_func wglGetProcAddress

	call _CheckOpenGLProcAddress

	FrameEnd
	ret

global _InitGL33
_InitGL33:
	FrameBegin 3, 0
	StoreVariable 0, esi
	StoreVariable 1, edi

	def_dll_func_and_load GDI32, ChoosePixelFormat
	def_dll_func_and_load GDI32, SetPixelFormat

	def_dll_and_load OpenGL32, "opengl32.dll"

	def_dll_func_and_load OpenGL32, wglGetProcAddress
	def_dll_func_and_load OpenGL32, wglCreateContext
	def_dll_func_and_load OpenGL32, wglDeleteContext
	def_dll_func_and_load OpenGL32, wglMakeCurrent
	def_dll_func_and_load OpenGL32, wglSwapBuffers

	segment .bss ; Store the function pointer list
	global _FirstGL32Func
	_FirstGL32Func:

	segment .rdata ; Store the function name list
	global _FirstNameOfGL32Func
	_FirstNameOfGL32Func:

	%macro def_opengl32_func 2-*
		segment .bss
		global _addr_of_gl %+ %1
		_addr_of_gl %+ %1 resd 1

		segment .rdata
		global _name_of_gl %+ %1
		_name_of_gl %+ %1:

		%rep %0 - 1
			%rotate 1
			db %1
		%endrep
		db 0
	%endmacro

	def_opengl32_func CullFace, "CullFace"
	def_opengl32_func FrontFace, "FrontFace"
	def_opengl32_func Hint, "Hint"
	def_opengl32_func LineWidth, "LineWidth"
	def_opengl32_func PointSize, ".Size"
	def_opengl32_func PolygonMode, "PolygonMode"
	def_opengl32_func Scissor, "Scissor"
	def_opengl32_func TexParameterf, "+?f"
	def_opengl32_func TexParameterfv, "+?", 0x27
	def_opengl32_func TexParameteri, "+?i"
	def_opengl32_func TexParameteriv, "+?", 0x22
	def_opengl32_func TexImage1D, "+$1D"
	def_opengl32_func TexImage2D, "+$2D"
	def_opengl32_func DrawBuffer, "}["
	def_opengl32_func Clear, 0x06
	def_opengl32_func ClearColor, 0x06, "5"
	def_opengl32_func ClearStencil, 0x06, 0x7F
	def_opengl32_func ClearDepth, 0x06, 0x1D
	def_opengl32_func StencilMask, 0x7F, 0x0F
	def_opengl32_func ColorMask, "5", 0x0F
	def_opengl32_func DepthMask, 0x1D, 0x0F
	def_opengl32_func Disable, 0x09
	def_opengl32_func Enable, 0x08
	def_opengl32_func Finish, "Finish"
	def_opengl32_func Flush, 0x5C
	def_opengl32_func BlendFunc, 0x11, 0x10
	def_opengl32_func LogicOp, "Logic", 0x16
	def_opengl32_func StencilFunc, 0x7F, 0x10
	def_opengl32_func StencilOp, 0x7F, 0x16
	def_opengl32_func DepthFunc, 0x1D, 0x10
	def_opengl32_func PixelStoref, 0x1E, "Storef"
	def_opengl32_func PixelStorei, 0x1E, "Storei"
	def_opengl32_func ReadBuffer, "Read["
	def_opengl32_func ReadPixels, "Read", 0x1E, "s"
	def_opengl32_func GetBooleanv, "<Booleanv"
	def_opengl32_func GetDoublev, "<Doublev"
	def_opengl32_func GetError, "<Error"
	def_opengl32_func GetFloatv, "<Floatv"
	def_opengl32_func GetIntegerv, "<", 0x82, "v"
	def_opengl32_func GetString, "<Str-"
	def_opengl32_func GetTexImage, "<+$"
	def_opengl32_func GetTexParameterfv, "<+?", 0x27
	def_opengl32_func GetTexParameteriv, "<+?", 0x22
	def_opengl32_func GetTexLevelParameterfv, "<+Level?", 0x27
	def_opengl32_func GetTexLevelParameteriv, "<+Level?", 0x22
	def_opengl32_func IsEnabled, 0x18, 0x08, "d"
	def_opengl32_func DepthRange, 0x1D, 0x0D
	def_opengl32_func Viewport, "Viewport"

segment .bss
	global _LastGL32Func
	_LastGL32Func:

segment .text
_StartDecodeGL32Functions:
	mov ecx, (_LastGL32Func - _FirstGL32Func) / 4
	mov esi, _FirstNameOfGL32Func
	mov edi, _FirstGL32Func
.loop_init_gl32:
	StoreVariable 2, ecx
	mov eax, esi
	call _GetGL32ProcAddress
	stosd
	call _NextString
	LoadVariable ecx, 2
	loop .loop_init_gl32

	push _PFD
	push [_hDC]
	invoke_dll_func ChoosePixelFormat

	push _PFD
	push eax ; Pixel format
	push [_hDC]
	invoke_dll_func SetPixelFormat

	push [_hDC]
	invoke_dll_func wglCreateContext
	mov [_hGLRC], eax

	push eax
	push [_hDC]
	invoke_dll_func wglMakeCurrent

	push GL_VENDOR
	invoke_dll_func glGetString
	mov [_OpenGL_Vendor], eax
	push GL_RENDERER
	invoke_dll_func glGetString
	mov [_OpenGL_Renderer], eax
	push GL_VERSION
	invoke_dll_func glGetString
	mov [_OpenGL_Version], eax

	mov esi, [_OpenGL_Version]
	mov edi, _OpenGL_ES_String
	mov ecx, _OpenGL_ES_String.size
	repz cmpsb
	jz .is_es
	jmp .parse_version_non_es
.is_es:
	mov dword [_OpenGL_Is_ES], 1
	jmp .parse_version
.isdigit:
	mov dword [_FailReason], _ParseFailBecauseNondigit
	cmp al, '0'
	jb .parse_fail
	cmp al, '9'
	ja .parse_fail
	sub al, '0'
	ret
.parse_fail:
	push _ParseFailText
	push _FailInfoBuffer
	invoke_dll_func strcpy

	push [_OpenGL_Version]
	push _FailInfoBuffer
	invoke_dll_func strcat

	push [_FailReason]
	push _FailInfoBuffer
	invoke_dll_func strcat

	push 0
	push 0
	push _FailInfoBuffer
	push [_hWnd]
	invoke_dll_func MessageBoxA

	xor eax, eax
	jmp _InitGL33_exit
.parse_version_non_es:
	mov esi, [_OpenGL_Version]
	xor eax, eax
.parse_version:
	lodsb
	call .isdigit
	mov [_OpenGL_Ver_Major], eax
	mov dword [_FailReason], _ParseFailBecauseDotExpected
	lodsb
	cmp al, '.'
	jnz .parse_fail
	lodsb
	call .isdigit
	mov [_OpenGL_Ver_Minor], eax
	lodsb
	cmp al, ' '
	jz .version_parsed
	mov dword [_FailReason], _ParseFailBecauseDotExpected
	cmp al, '.'
	jnz .parse_fail
	lodsb
	call .isdigit
	mov [_OpenGL_Ver_Release], eax

.version_parsed:
	segment .bss  ; Store the function pointer list
	global _FirstGLFunc
	_FirstGLFunc:

	segment .rdata ; Store the function name list
	global _FirstNameOfGLFunc
	_FirstNameOfGLFunc:

	%macro def_opengl_func 2-*
		segment .bss
		global _addr_of_gl %+ %1
		_addr_of_gl %+ %1 resd 1

		segment .rdata
		global _name_of_gl %+ %1
		_name_of_gl %+ %1:
		%rep %0 - 1
			%rotate 1
			db %1
		%endrep
		db 0
	%endmacro

	def_opengl_func DrawArrays, "}{s"
	def_opengl_func DrawElements, "}]s"
	def_opengl_func GetPointerv, "<`v"
	def_opengl_func PolygonOffset, "PolygonOffset"
	def_opengl_func CopyTexImage1D, 0x15, "+$1D"
	def_opengl_func CopyTexImage2D, 0x15, "+$2D"
	def_opengl_func CopyTexSubImage1D, 0x15, "+", 0x14, "$1D"
	def_opengl_func CopyTexSubImage2D, 0x15, "+", 0x14, "$2D"
	def_opengl_func TexSubImage1D, "+", 0x14, "$1D"
	def_opengl_func TexSubImage2D, "+", 0x14, "$2D"
	def_opengl_func BindTexture, "!&"
	def_opengl_func DeleteTextures, "/&s"
	def_opengl_func GenTextures, "8&s"

	def_opengl_func DrawRangeElements, "}", 0x0D, "]s"
	def_opengl_func TexImage3D, "+$3D"
	def_opengl_func TexSubImage3D, "+", 0x14, "$3D"
	def_opengl_func CopyTexSubImage3D, 0x15, "+", 0x14, "$3D"

	def_opengl_func ActiveTexture, ")&"
	def_opengl_func SampleCoverage, "SampleCoverage"
	def_opengl_func CompressedTexImage3D, 0x02, "+$3D"
	def_opengl_func CompressedTexImage2D, 0x02, "+$2D"
	def_opengl_func CompressedTexImage1D, 0x02, "+$1D"
	def_opengl_func CompressedTexSubImage3D, 0x02, "+", 0x14, "$3D"
	def_opengl_func CompressedTexSubImage2D, 0x02, "+", 0x14, "$2D"
	def_opengl_func CompressedTexSubImage1D, 0x02, "+", 0x14, "$1D"
	def_opengl_func GetCompressedTexImage, "<", 0x02, "+$"
	def_opengl_func ClientActiveTexture, "Client)&"
	def_opengl_func MultiTexCoord1d, "^,1d"
	def_opengl_func MultiTexCoord1dv, "^,1dv"
	def_opengl_func MultiTexCoord1f, "^,1f"
	def_opengl_func MultiTexCoord1fv, "^,1", 0x27
	def_opengl_func MultiTexCoord1i, "^,1i"
	def_opengl_func MultiTexCoord1iv, "^,1", 0x22
	def_opengl_func MultiTexCoord1s, "^,1s"
	def_opengl_func MultiTexCoord1sv, "^,1sv"
	def_opengl_func MultiTexCoord2d, "^,2d"
	def_opengl_func MultiTexCoord2dv, "^,2dv"
	def_opengl_func MultiTexCoord2f, "^,2f"
	def_opengl_func MultiTexCoord2fv, "^,2", 0x27
	def_opengl_func MultiTexCoord2i, "^,2i"
	def_opengl_func MultiTexCoord2iv, "^,2", 0x22
	def_opengl_func MultiTexCoord2s, "^,2s"
	def_opengl_func MultiTexCoord2sv, "^,2sv"
	def_opengl_func MultiTexCoord3d, "^,3d"
	def_opengl_func MultiTexCoord3dv, "^,3dv"
	def_opengl_func MultiTexCoord3f, "^,3f"
	def_opengl_func MultiTexCoord3fv, "^,3", 0x27
	def_opengl_func MultiTexCoord3i, "^,3i"
	def_opengl_func MultiTexCoord3iv, "^,3", 0x22
	def_opengl_func MultiTexCoord3s, "^,3s"
	def_opengl_func MultiTexCoord3sv, "^,3sv"
	def_opengl_func MultiTexCoord4d, "^,4d"
	def_opengl_func MultiTexCoord4dv, "^,4dv"
	def_opengl_func MultiTexCoord4f, "^,4f"
	def_opengl_func MultiTexCoord4fv, "^,4", 0x27
	def_opengl_func MultiTexCoord4i, "^,4i"
	def_opengl_func MultiTexCoord4iv, "^,4", 0x22
	def_opengl_func MultiTexCoord4s, "^,4s"
	def_opengl_func MultiTexCoord4sv, "^,4sv"
	def_opengl_func LoadTransposeMatrixf, "Load%#f"
	def_opengl_func LoadTransposeMatrixd, "Load%#d"
	def_opengl_func MultTransposeMatrixf, "Mult%#f"
	def_opengl_func MultTransposeMatrixd, "Mult%#d"

	def_opengl_func BlendFuncSeparate, 0x11, 0x10, 0x12
	def_opengl_func MultiDrawArrays, "^}{s"
	def_opengl_func MultiDrawElements, "^}]s"
	def_opengl_func PointParameterf, ".?f"
	def_opengl_func PointParameterfv, ".?", 0x27
	def_opengl_func PointParameteri, ".?i"
	def_opengl_func PointParameteriv, ".?", 0x22
	def_opengl_func FogCoordf, 0x85, "9f"
	def_opengl_func FogCoordfv, 0x85, "9", 0x27
	def_opengl_func FogCoordd, 0x85, "9d"
	def_opengl_func FogCoorddv, 0x85, "9dv"
	def_opengl_func FogCoordPointer, 0x85, "9`"
	def_opengl_func SecondaryColor3b, "(53b"
	def_opengl_func SecondaryColor3bv, "(53bv"
	def_opengl_func SecondaryColor3d, "(53d"
	def_opengl_func SecondaryColor3dv, "(53dv"
	def_opengl_func SecondaryColor3f, "(53f"
	def_opengl_func SecondaryColor3fv, "(53", 0x27
	def_opengl_func SecondaryColor3i, "(53i"
	def_opengl_func SecondaryColor3iv, "(53", 0x22
	def_opengl_func SecondaryColor3s, "(53s"
	def_opengl_func SecondaryColor3sv, "(53sv"
	def_opengl_func SecondaryColor3ub, "(53ub"
	def_opengl_func SecondaryColor3ubv, "(53ubv"
	def_opengl_func SecondaryColor3ui, "(53;"
	def_opengl_func SecondaryColor3uiv, "(53u", 0x22
	def_opengl_func SecondaryColor3us, "(53us"
	def_opengl_func SecondaryColor3usv, "(53usv"
	def_opengl_func SecondaryColorPointer, "(5`"
	def_opengl_func WindowPos2d, 0x01, "2d"
	def_opengl_func WindowPos2dv, 0x01, "2dv"
	def_opengl_func WindowPos2f, 0x01, "2f"
	def_opengl_func WindowPos2fv, 0x01, "2", 0x27
	def_opengl_func WindowPos2i, 0x01, "2i"
	def_opengl_func WindowPos2iv, 0x01, "2", 0x22
	def_opengl_func WindowPos2s, 0x01, "2s"
	def_opengl_func WindowPos2sv, 0x01, "2sv"
	def_opengl_func WindowPos3d, 0x01, "3d"
	def_opengl_func WindowPos3dv, 0x01, "3dv"
	def_opengl_func WindowPos3f, 0x01, "3f"
	def_opengl_func WindowPos3fv, 0x01, "3", 0x27
	def_opengl_func WindowPos3i, 0x01, "3i"
	def_opengl_func WindowPos3iv, 0x01, "3", 0x22
	def_opengl_func WindowPos3s, 0x01, "3s"
	def_opengl_func WindowPos3sv, 0x01, "3sv"
	def_opengl_func BlendColor, 0x11, "5"
	def_opengl_func BlendEquation, 0x11, 0x83

	def_opengl_func GenQueries, "80"
	def_opengl_func DeleteQueries, "/0"
	def_opengl_func IsQuery, 0x18, ">"
	def_opengl_func BeginQuery, 0x0A, ">"
	def_opengl_func EndQuery, 0x0B, ">"
	def_opengl_func GetQueryiv, "<>", 0x22
	def_opengl_func GetQueryObjectiv, "<>", 0x17, 0x22
	def_opengl_func GetQueryObjectuiv, "<>", 0x17, "u", 0x22
	def_opengl_func BindBuffer, "!["
	def_opengl_func DeleteBuffers, "/[s"
	def_opengl_func GenBuffers, "8[s"
	def_opengl_func IsBuffer, 0x18, "["
	def_opengl_func BufferData, "[", 0x13
	def_opengl_func BufferSubData, "[", 0x14, 0x13
	def_opengl_func GetBufferSubData, "<[", 0x14, 0x13
	def_opengl_func MapBuffer, 0x1B, "["
	def_opengl_func UnmapBuffer, "Unmap["
	def_opengl_func GetBufferParameteriv, "<[?", 0x22
	def_opengl_func GetBufferPointerv, "<[`v"

	def_opengl_func BlendEquationSeparate, 0x11, 0x83, 0x12
	def_opengl_func DrawBuffers, "}[s"
	def_opengl_func StencilOpSeparate, 0x7F, 0x16, 0x12
	def_opengl_func StencilFuncSeparate, 0x7F, 0x10, 0x12
	def_opengl_func StencilMaskSeparate, 0x7F, 0x0F, 0x12
	def_opengl_func AttachShader, 0x19, 0x80
	def_opengl_func BindAttribLocation, "!@", 0x81
	def_opengl_func CompileShader, "Compile", 0x80
	def_opengl_func CreateProgram, "Create~"
	def_opengl_func CreateShader, "Create", 0x80
	def_opengl_func DeleteProgram, "/~"
	def_opengl_func DeleteShader, "/", 0x80
	def_opengl_func DetachShader, "Detach", 0x80
	def_opengl_func DisableVertexAttribArray, 0x09, "*@{"
	def_opengl_func EnableVertexAttribArray, 0x08, "*@{"
	def_opengl_func GetActiveAttrib, "<)@"
	def_opengl_func GetActiveUniform, "<)="
	def_opengl_func GetAttachedShaders, "<", 0x19, "ed", 0x80, "s"
	def_opengl_func GetAttribLocation, "<@", 0x81
	def_opengl_func GetProgramiv, "<~", 0x22
	def_opengl_func GetProgramInfoLog, "<~InfoLog"
	def_opengl_func GetShaderiv, "<", 0x80, 0x22
	def_opengl_func GetShaderInfoLog, "<", 0x80, "InfoLog"
	def_opengl_func GetShaderSource, "<", 0x80, "Source"
	def_opengl_func GetUniformLocation, "<=", 0x81
	def_opengl_func GetUniformfv, "<=", 0x27
	def_opengl_func GetUniformiv, "<=", 0x22
	def_opengl_func GetVertexAttribdv, "<*@dv"
	def_opengl_func GetVertexAttribfv, "<*@", 0x27
	def_opengl_func GetVertexAttribiv, "<*@", 0x22
	def_opengl_func GetVertexAttribPointerv, "<*@`v"
	def_opengl_func IsProgram, 0x18, "~"
	def_opengl_func IsShader, 0x18, 0x80
	def_opengl_func LinkProgram, "Link~"
	def_opengl_func ShaderSource, 0x80, "Source"
	def_opengl_func UseProgram, "Use~"
	def_opengl_func Uniform1f, "=1f"
	def_opengl_func Uniform2f, "=2f"
	def_opengl_func Uniform3f, "=3f"
	def_opengl_func Uniform4f, "=4f"
	def_opengl_func Uniform1i, "=1i"
	def_opengl_func Uniform2i, "=2i"
	def_opengl_func Uniform3i, "=3i"
	def_opengl_func Uniform4i, "=4i"
	def_opengl_func Uniform1fv, "=1", 0x27
	def_opengl_func Uniform2fv, "=2", 0x27
	def_opengl_func Uniform3fv, "=3", 0x27
	def_opengl_func Uniform4fv, "=4", 0x27
	def_opengl_func Uniform1iv, "=1", 0x22
	def_opengl_func Uniform2iv, "=2", 0x22
	def_opengl_func Uniform3iv, "=3", 0x22
	def_opengl_func Uniform4iv, "=4", 0x22
	def_opengl_func UniformMatrix2fv, "=#2", 0x27
	def_opengl_func UniformMatrix3fv, "=#3", 0x27
	def_opengl_func UniformMatrix4fv, "=#4", 0x27
	def_opengl_func ValidateProgram, "Validate~"
	def_opengl_func VertexAttrib1d, "*@1d"
	def_opengl_func VertexAttrib1dv, "*@1dv"
	def_opengl_func VertexAttrib1f, "*@1f"
	def_opengl_func VertexAttrib1fv, "*@1", 0x27
	def_opengl_func VertexAttrib1s, "*@1s"
	def_opengl_func VertexAttrib1sv, "*@1sv"
	def_opengl_func VertexAttrib2d, "*@2d"
	def_opengl_func VertexAttrib2dv, "*@2dv"
	def_opengl_func VertexAttrib2f, "*@2f"
	def_opengl_func VertexAttrib2fv, "*@2", 0x27
	def_opengl_func VertexAttrib2s, "*@2s"
	def_opengl_func VertexAttrib2sv, "*@2sv"
	def_opengl_func VertexAttrib3d, "*@3d"
	def_opengl_func VertexAttrib3dv, "*@3dv"
	def_opengl_func VertexAttrib3f, "*@3f"
	def_opengl_func VertexAttrib3fv, "*@3", 0x27
	def_opengl_func VertexAttrib3s, "*@3s"
	def_opengl_func VertexAttrib3sv, "*@3sv"
	def_opengl_func VertexAttrib4Nbv, "*@4Nbv"
	def_opengl_func VertexAttrib4Niv, "*@4N", 0x22
	def_opengl_func VertexAttrib4Nsv, "*@4Nsv"
	def_opengl_func VertexAttrib4Nub, "*@4Nub"
	def_opengl_func VertexAttrib4Nubv, "*@4Nubv"
	def_opengl_func VertexAttrib4Nuiv, "*@4Nu", 0x22
	def_opengl_func VertexAttrib4Nusv, "*@4Nusv"
	def_opengl_func VertexAttrib4bv, "*@4bv"
	def_opengl_func VertexAttrib4d, "*@4d"
	def_opengl_func VertexAttrib4dv, "*@4dv"
	def_opengl_func VertexAttrib4f, "*@4f"
	def_opengl_func VertexAttrib4fv, "*@4", 0x27
	def_opengl_func VertexAttrib4iv, "*@4", 0x22
	def_opengl_func VertexAttrib4s, "*@4s"
	def_opengl_func VertexAttrib4sv, "*@4sv"
	def_opengl_func VertexAttrib4ubv, "*@4ubv"
	def_opengl_func VertexAttrib4uiv, "*@4u", 0x22
	def_opengl_func VertexAttrib4usv, "*@4usv"
	def_opengl_func VertexAttribPointer, "*@`"

	def_opengl_func UniformMatrix2x3fv, "=#2x3", 0x27
	def_opengl_func UniformMatrix3x2fv, "=#3x2", 0x27
	def_opengl_func UniformMatrix2x4fv, "=#2x4", 0x27
	def_opengl_func UniformMatrix4x2fv, "=#4x2", 0x27
	def_opengl_func UniformMatrix3x4fv, "=#3x4", 0x27
	def_opengl_func UniformMatrix4x3fv, "=#4x3", 0x27

	def_opengl_func ColorMaski, "5", 0x0F, "i"
	def_opengl_func GetBooleani_v, "<Booleani_v"
	def_opengl_func GetIntegeri_v, "<", 0x82, "i_v"
	def_opengl_func Enablei, 0x08, "i"
	def_opengl_func Disablei, 0x09, "i"
	def_opengl_func IsEnabledi, 0x18, 0x08, "di"
	def_opengl_func BeginTransformFeedback, 0x0A, 0x1A
	def_opengl_func EndTransformFeedback, 0x0B, 0x1A
	def_opengl_func BindBufferRange, "![", 0x0D
	def_opengl_func BindBufferBase, "![", 0x0E
	def_opengl_func TransformFeedbackVaryings, 0x1A, "|s"
	def_opengl_func GetTransformFeedbackVarying, "<", 0x1A, "|"
	def_opengl_func ClampColor, "Clamp5"
	def_opengl_func BeginConditionalRender, 0x0A, 0x1C
	def_opengl_func EndConditionalRender, 0x0B, 0x1C
	def_opengl_func VertexAttribIPointer, "*@I`"
	def_opengl_func GetVertexAttribIiv, "<*@I", 0x22
	def_opengl_func GetVertexAttribIuiv, "<*@Iu", 0x22
	def_opengl_func VertexAttribI1i, "*@I1i"
	def_opengl_func VertexAttribI2i, "*@I2i"
	def_opengl_func VertexAttribI3i, "*@I3i"
	def_opengl_func VertexAttribI4i, "*@I4i"
	def_opengl_func VertexAttribI1ui, "*@I1;"
	def_opengl_func VertexAttribI2ui, "*@I2;"
	def_opengl_func VertexAttribI3ui, "*@I3;"
	def_opengl_func VertexAttribI4ui, "*@I4;"
	def_opengl_func VertexAttribI1iv, "*@I1", 0x22
	def_opengl_func VertexAttribI2iv, "*@I2", 0x22
	def_opengl_func VertexAttribI3iv, "*@I3", 0x22
	def_opengl_func VertexAttribI4iv, "*@I4", 0x22
	def_opengl_func VertexAttribI1uiv, "*@I1u", 0x22
	def_opengl_func VertexAttribI2uiv, "*@I2u", 0x22
	def_opengl_func VertexAttribI3uiv, "*@I3u", 0x22
	def_opengl_func VertexAttribI4uiv, "*@I4u", 0x22
	def_opengl_func VertexAttribI4bv, "*@I4bv"
	def_opengl_func VertexAttribI4sv, "*@I4sv"
	def_opengl_func VertexAttribI4ubv, "*@I4ubv"
	def_opengl_func VertexAttribI4usv, "*@I4usv"
	def_opengl_func GetUniformuiv, "<=u", 0x22
	def_opengl_func BindFragDataLocation, "!", 0x04, 0x81
	def_opengl_func GetFragDataLocation, "<", 0x04, 0x81
	def_opengl_func Uniform1ui, "=1;"
	def_opengl_func Uniform2ui, "=2;"
	def_opengl_func Uniform3ui, "=3;"
	def_opengl_func Uniform4ui, "=4;"
	def_opengl_func Uniform1uiv, "=1u", 0x22
	def_opengl_func Uniform2uiv, "=2u", 0x22
	def_opengl_func Uniform3uiv, "=3u", 0x22
	def_opengl_func Uniform4uiv, "=4u", 0x22
	def_opengl_func TexParameterIiv, "+?I", 0x22
	def_opengl_func TexParameterIuiv, "+?Iu", 0x22
	def_opengl_func GetTexParameterIiv, "<+?I", 0x22
	def_opengl_func GetTexParameterIuiv, "<+?Iu", 0x22
	def_opengl_func ClearBufferiv, 0x06, "[", 0x22
	def_opengl_func ClearBufferuiv, 0x06, "[u", 0x22
	def_opengl_func ClearBufferfv, 0x06, "[", 0x27
	def_opengl_func ClearBufferfi, 0x06, "[fi"
	def_opengl_func GetStringi, "<Str-i"
	def_opengl_func IsRenderbuffer, 0x18, 0x07
	def_opengl_func BindRenderbuffer, "!", 0x07
	def_opengl_func DeleteRenderbuffers, "/", 0x07, "s"
	def_opengl_func GenRenderbuffers, "8", 0x07, "s"
	def_opengl_func RenderbufferStorage, 0x07, "Storage"
	def_opengl_func GetRenderbufferParameteriv, "<", 0x07, "?", 0x22
	def_opengl_func IsFramebuffer, 0x18, "7"
	def_opengl_func BindFramebuffer, "!7"
	def_opengl_func DeleteFramebuffers, "/7s"
	def_opengl_func GenFramebuffers, "87s"
	def_opengl_func CheckFramebufferStatus, "Check7Status"
	def_opengl_func FramebufferTexture1D, "7&1D"
	def_opengl_func FramebufferTexture2D, "7&2D"
	def_opengl_func FramebufferTexture3D, "7&3D"
	def_opengl_func FramebufferRenderbuffer, "7", 0x07
	def_opengl_func GetFramebufferAttachmentParameteriv, "<7", 0x19, "ment?", 0x22
	def_opengl_func GenerateMipmap, "8erateMipmap"
	def_opengl_func BlitFramebuffer, "Blit7"
	def_opengl_func RenderbufferStorageMultisample, 0x07, "Storage", 0x03
	def_opengl_func FramebufferTextureLayer, "7&Layer"
	def_opengl_func MapBufferRange, 0x1B, "[", 0x0D
	def_opengl_func FlushMappedBufferRange, 0x5C, 0x1B, "ped[", 0x0D
	def_opengl_func BindVertexArray, "!*{"
	def_opengl_func DeleteVertexArrays, "/*{s"
	def_opengl_func GenVertexArrays, "8*{s"
	def_opengl_func IsVertexArray, 0x18, "*{"

	def_opengl_func DrawArraysInstanced, "}{s", 0x0C
	def_opengl_func DrawElementsInstanced, "}]s", 0x0C
	def_opengl_func TexBuffer, "+["
	def_opengl_func PrimitiveRestartIndex, "Primit", 0x22, "eRestartIndex"
	def_opengl_func CopyBufferSubData, 0x15, "[", 0x14, 0x13
	def_opengl_func GetUniformIndices, "<=Indices"
	def_opengl_func GetActiveUniformsiv, "<)=s", 0x22
	def_opengl_func GetActiveUniformName, "<)=Name"
	def_opengl_func GetUniformBlockIndex, "<=", 0x1F, "Index"
	def_opengl_func GetActiveUniformBlockiv, "<)=", 0x1F, 0x22
	def_opengl_func GetActiveUniformBlockName, "<)=", 0x1F, "Name"
	def_opengl_func UniformBlockBinding, "=", 0x1F, "!-"

	def_opengl_func DrawElementsBaseVertex, "}]s", 0x0E, "*"
	def_opengl_func DrawRangeElementsBaseVertex, "}", 0x0D, "]s", 0x0E, "*"
	def_opengl_func DrawElementsInstancedBaseVertex, "}]s", 0x0C, 0x0E, "*"
	def_opengl_func MultiDrawElementsBaseVertex, "^}]s", 0x0E, "*"
	def_opengl_func ProvokingVertex, "Provok-*"
	def_opengl_func FenceSync, "Fence", 0x20
	def_opengl_func IsSync, 0x18, 0x20
	def_opengl_func DeleteSync, "/", 0x20
	def_opengl_func ClientWaitSync, "ClientWait", 0x20
	def_opengl_func WaitSync, "Wait", 0x20
	def_opengl_func GetInteger64v, "<", 0x82, "64v"
	def_opengl_func GetSynciv, "<", 0x20, 0x22
	def_opengl_func GetInteger64i_v, "<", 0x82, "64i_v"
	def_opengl_func GetBufferParameteri64v, "<[?i64v"
	def_opengl_func FramebufferTexture, "7&"
	def_opengl_func TexImage2DMultisample, "+$2D", 0x03
	def_opengl_func TexImage3DMultisample, "+$3D", 0x03
	def_opengl_func GetMultisamplefv, "<", 0x03, 0x27
	def_opengl_func SampleMaski, "Sample", 0x0F, "i"

	def_opengl_func BindFragDataLocationIndexed, "!", 0x04, 0x81, "Indexed"
	def_opengl_func GetFragDataIndex, "<", 0x04, "Index"
	def_opengl_func GenSamplers, "8:s"
	def_opengl_func DeleteSamplers, "/:s"
	def_opengl_func IsSampler, 0x18, ":"
	def_opengl_func BindSampler, "!:"
	def_opengl_func SamplerParameteri, ":?i"
	def_opengl_func SamplerParameteriv, ":?", 0x22
	def_opengl_func SamplerParameterf, ":?f"
	def_opengl_func SamplerParameterfv, ":?", 0x27
	def_opengl_func SamplerParameterIiv, ":?I", 0x22
	def_opengl_func SamplerParameterIuiv, ":?Iu", 0x22
	def_opengl_func GetSamplerParameteriv, "<:?", 0x22
	def_opengl_func GetSamplerParameterIiv, "<:?I", 0x22
	def_opengl_func GetSamplerParameterfv, "<:?", 0x27
	def_opengl_func GetSamplerParameterIuiv, "<:?Iu", 0x22
	def_opengl_func QueryCounter, ">Counter"
	def_opengl_func GetQueryObjecti64v, "<>", 0x17, "i64v"
	def_opengl_func GetQueryObjectui64v, "<>", 0x17, ";64v"
	def_opengl_func VertexAttribDivisor, "*@D", 0x22, "isor"
	def_opengl_func VertexAttribP1ui, "*@P1;"
	def_opengl_func VertexAttribP1uiv, "*@P1u", 0x22
	def_opengl_func VertexAttribP2ui, "*@P2;"
	def_opengl_func VertexAttribP2uiv, "*@P2u", 0x22
	def_opengl_func VertexAttribP3ui, "*@P3;"
	def_opengl_func VertexAttribP3uiv, "*@P3u", 0x22
	def_opengl_func VertexAttribP4ui, "*@P4;"
	def_opengl_func VertexAttribP4uiv, "*@P4u", 0x22
	def_opengl_func VertexP2ui, "*P2;"
	def_opengl_func VertexP2uiv, "*P2u", 0x22
	def_opengl_func VertexP3ui, "*P3;"
	def_opengl_func VertexP3uiv, "*P3u", 0x22
	def_opengl_func VertexP4ui, "*P4;"
	def_opengl_func VertexP4uiv, "*P4u", 0x22
	def_opengl_func TexCoordP1ui, ",P1;"
	def_opengl_func TexCoordP1uiv, ",P1u", 0x22
	def_opengl_func TexCoordP2ui, ",P2;"
	def_opengl_func TexCoordP2uiv, ",P2u", 0x22
	def_opengl_func TexCoordP3ui, ",P3;"
	def_opengl_func TexCoordP3uiv, ",P3u", 0x22
	def_opengl_func TexCoordP4ui, ",P4;"
	def_opengl_func TexCoordP4uiv, ",P4u", 0x22
	def_opengl_func MultiTexCoordP1ui, "^,P1;"
	def_opengl_func MultiTexCoordP1uiv, "^,P1u", 0x22
	def_opengl_func MultiTexCoordP2ui, "^,P2;"
	def_opengl_func MultiTexCoordP2uiv, "^,P2u", 0x22
	def_opengl_func MultiTexCoordP3ui, "^,P3;"
	def_opengl_func MultiTexCoordP3uiv, "^,P3u", 0x22
	def_opengl_func MultiTexCoordP4ui, "^,P4;"
	def_opengl_func MultiTexCoordP4uiv, "^,P4u", 0x22
	def_opengl_func NormalP3ui, 0x84, "P3;"
	def_opengl_func NormalP3uiv, 0x84, "P3u", 0x22
	def_opengl_func ColorP3ui, "5P3;"
	def_opengl_func ColorP3uiv, "5P3u", 0x22
	def_opengl_func ColorP4ui, "5P4;"
	def_opengl_func ColorP4uiv, "5P4u", 0x22
	def_opengl_func SecondaryColorP3ui, "(5P3;"
	def_opengl_func SecondaryColorP3uiv, "(5P3u", 0x22

	segment .bss
	global _LastGLFunc
	_LastGLFunc:

	segment .text
_StartDecodeGLFunctions:
	mov ecx, (_LastGLFunc - _FirstGLFunc) / 4
	mov esi, _FirstNameOfGLFunc
	mov edi, _FirstGLFunc
.loop_init_gl:
	StoreVariable 2, ecx
	mov eax, esi
	call _GetGLProcAddress
	stosd
	call _NextString
	LoadVariable ecx, 2
	loop .loop_init_gl

	push _OpenGLNullFunctions
	invoke_dll_func strlen
	test eax, eax
	jz .end

	push _TheseFunc
	push _OpenGLNullFunctions
	invoke_dll_func strcat

	push 0
	push 0
	push _OpenGLNullFunctions
	push [_hWnd]
	invoke_dll_func MessageBoxA

.end:
	mov eax, 1

_InitGL33_exit:
	LoadVariable esi, 0
	LoadVariable edi, 1
	FrameEnd
	ret

global _DeInitGL33
_DeInitGL33:
	FrameBegin 0, 0
	push 0
	push 0
	invoke_dll_func wglMakeCurrent

	push [_hGLRC]
	invoke_dll_func wglDeleteContext

	mov dword[_hGLRC], 0
	FrameEnd
	ret
