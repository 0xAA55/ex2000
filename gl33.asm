%include "loaddll.inc"
%include "frame.inc"
%include "gl33.inc"

import_dll GDI32
import_dll_func strcpy

extern _hWnd
extern _hDC

segment .bss
global _hGLRC
_hGLRC resd 1

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
.code_0A db "Begin", 0
.code_0B db "End", 0
.code_0C db "Instanced", 0
.code_0D db "Range", 0
.code_0E db "Base", 0
.code_0F db "Mask", 0
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
.code_1A db "TransformFeedback", 0
.code_1B db "Map", 0
.code_1C db "ConditionalRender", 0
.code_1D db "Depth", 0
.code_1E db "Pixel", 0
.code_1F db "Block", 0
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
.code_2A db "Vertex", 0
.code_2B db "Tex", 0
.code_2C db "TexCoord", 0
.code_2D db "ing", 0
.code_2E db "Point", 0
.code_2F db "Delete", 0
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
.code_3A db "Sampler", 0
.code_3B db "ui", 0
.code_3C db "Get", 0
.code_3D db "Uniform", 0
.code_3E db "Query", 0
.code_3F db "Parameter", 0
.code_40 db "Attrib", 0

.code_5B db "Buffer", 0
.code_5C db "Flush", 0
.code_5D db "Element", 0
.code_5E db "Multi", 0
.code_5F db "Shader", 0
.code_60 db "Pointer", 0

.code_7B db "Array", 0
.code_7C db "Varying", 0
.code_7D db "Draw", 0
.code_7E db "Program", 0
.code_7F db "Stencil", 0

global _DecodeTable
_DecodeTable:
.code_01_40:
	dw _DecodeTableStrings.code_01 - _DecodeTableStrings
	dw _DecodeTableStrings.code_02 - _DecodeTableStrings
	dw _DecodeTableStrings.code_03 - _DecodeTableStrings
	dw _DecodeTableStrings.code_04 - _DecodeTableStrings
	dw _DecodeTableStrings.code_05 - _DecodeTableStrings
	dw _DecodeTableStrings.code_06 - _DecodeTableStrings
	dw _DecodeTableStrings.code_07 - _DecodeTableStrings
	dw _DecodeTableStrings.code_08 - _DecodeTableStrings
	dw _DecodeTableStrings.code_09 - _DecodeTableStrings
	dw _DecodeTableStrings.code_0A - _DecodeTableStrings
	dw _DecodeTableStrings.code_0B - _DecodeTableStrings
	dw _DecodeTableStrings.code_0C - _DecodeTableStrings
	dw _DecodeTableStrings.code_0D - _DecodeTableStrings
	dw _DecodeTableStrings.code_0E - _DecodeTableStrings
	dw _DecodeTableStrings.code_0F - _DecodeTableStrings
	dw _DecodeTableStrings.code_10 - _DecodeTableStrings
	dw _DecodeTableStrings.code_11 - _DecodeTableStrings
	dw _DecodeTableStrings.code_12 - _DecodeTableStrings
	dw _DecodeTableStrings.code_13 - _DecodeTableStrings
	dw _DecodeTableStrings.code_14 - _DecodeTableStrings
	dw _DecodeTableStrings.code_15 - _DecodeTableStrings
	dw _DecodeTableStrings.code_16 - _DecodeTableStrings
	dw _DecodeTableStrings.code_17 - _DecodeTableStrings
	dw _DecodeTableStrings.code_18 - _DecodeTableStrings
	dw _DecodeTableStrings.code_19 - _DecodeTableStrings
	dw _DecodeTableStrings.code_1A - _DecodeTableStrings
	dw _DecodeTableStrings.code_1B - _DecodeTableStrings
	dw _DecodeTableStrings.code_1C - _DecodeTableStrings
	dw _DecodeTableStrings.code_1D - _DecodeTableStrings
	dw _DecodeTableStrings.code_1E - _DecodeTableStrings
	dw _DecodeTableStrings.code_1F - _DecodeTableStrings
	dw _DecodeTableStrings.code_20 - _DecodeTableStrings
	dw _DecodeTableStrings.code_21 - _DecodeTableStrings
	dw _DecodeTableStrings.code_22 - _DecodeTableStrings
	dw _DecodeTableStrings.code_23 - _DecodeTableStrings
	dw _DecodeTableStrings.code_24 - _DecodeTableStrings
	dw _DecodeTableStrings.code_25 - _DecodeTableStrings
	dw _DecodeTableStrings.code_26 - _DecodeTableStrings
	dw _DecodeTableStrings.code_27 - _DecodeTableStrings
	dw _DecodeTableStrings.code_28 - _DecodeTableStrings
	dw _DecodeTableStrings.code_29 - _DecodeTableStrings
	dw _DecodeTableStrings.code_2A - _DecodeTableStrings
	dw _DecodeTableStrings.code_2B - _DecodeTableStrings
	dw _DecodeTableStrings.code_2C - _DecodeTableStrings
	dw _DecodeTableStrings.code_2D - _DecodeTableStrings
	dw _DecodeTableStrings.code_2E - _DecodeTableStrings
	dw _DecodeTableStrings.code_2F - _DecodeTableStrings
	dw _DecodeTableStrings.code_30 - _DecodeTableStrings
	dw _DecodeTableStrings.code_31 - _DecodeTableStrings
	dw _DecodeTableStrings.code_32 - _DecodeTableStrings
	dw _DecodeTableStrings.code_33 - _DecodeTableStrings
	dw _DecodeTableStrings.code_34 - _DecodeTableStrings
	dw _DecodeTableStrings.code_35 - _DecodeTableStrings
	dw _DecodeTableStrings.code_36 - _DecodeTableStrings
	dw _DecodeTableStrings.code_37 - _DecodeTableStrings
	dw _DecodeTableStrings.code_38 - _DecodeTableStrings
	dw _DecodeTableStrings.code_39 - _DecodeTableStrings
	dw _DecodeTableStrings.code_3A - _DecodeTableStrings
	dw _DecodeTableStrings.code_3B - _DecodeTableStrings
	dw _DecodeTableStrings.code_3C - _DecodeTableStrings
	dw _DecodeTableStrings.code_3D - _DecodeTableStrings
	dw _DecodeTableStrings.code_3E - _DecodeTableStrings
	dw _DecodeTableStrings.code_3F - _DecodeTableStrings
	dw _DecodeTableStrings.code_40 - _DecodeTableStrings

.code_5B_60:
	dw _DecodeTableStrings.code_5B - _DecodeTableStrings
	dw _DecodeTableStrings.code_5C - _DecodeTableStrings
	dw _DecodeTableStrings.code_5D - _DecodeTableStrings
	dw _DecodeTableStrings.code_5E - _DecodeTableStrings
	dw _DecodeTableStrings.code_5F - _DecodeTableStrings
	dw _DecodeTableStrings.code_60 - _DecodeTableStrings

.code_7B_7F:
	dw _DecodeTableStrings.code_7B - _DecodeTableStrings
	dw _DecodeTableStrings.code_7C - _DecodeTableStrings
	dw _DecodeTableStrings.code_7D - _DecodeTableStrings
	dw _DecodeTableStrings.code_7E - _DecodeTableStrings
	dw _DecodeTableStrings.code_7F - _DecodeTableStrings

segment .bss
global _FuncNameBuf
_FuncNameBuf resb 64

segment .text
global _DecodeProcName
_DecodeProcName:
	FrameBegin 3, 0

	StoreVariable 0, esi
	StoreVariable 1, edi

	mov word[_FuncNameBuf], 'gl'

	mov esi, eax
	mov edi, _FuncNameBuf + 2

.decode_loop:
	xor eax, eax
	lodsb
	test al, al
	jz .end
	cmp al, 0x40
	jbe .code_01_40
	cmp al, 0x5B
	jb .movechar
	cmp al, 0x60
	jbe .code_5B_60
	cmp al, 0x7B
	jb .movechar
	cmp al, 0x7F
	jbe .code_7B_7F

.movechar:
	stosb
	jmp .decode_loop
.code_01_40:
	StoreVariable 2, esi
	dec al
	movzx esi, word[_DecodeTable.code_01_40 + eax * 2]
	jmp .decode
.code_5B_60:
	StoreVariable 2, esi
	sub al, 0x5B
	movzx esi, word[_DecodeTable.code_5B_60 + eax * 2]
	jmp .decode
.code_7B_7F:
	StoreVariable 2, esi
	sub al, 0x7B
	movzx esi, word[_DecodeTable.code_7B_7F + eax * 2]
.decode:
	add esi, _DecodeTableStrings
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
	test al, al
	jnz _NextString
	ret

global _GetGL32ProcAddress
_GetGL32ProcAddress:
	FrameBegin 0, 0

	call _DecodeProcName

	push _FuncNameBuf
	push [_addr_of_OpenGL32]
	call [_addr_of_GetProcAddress]

	FrameEnd
	ret

global _GetGLProcAddress
_GetGLProcAddress:
	FrameBegin 0, 0

	call _DecodeProcName

	push _FuncNameBuf
	invoke_dll_func wglGetProcAddress

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

	segment .bss
	global _FirstGL32Func
	_FirstGL32Func:

	segment .rdata
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

	def_opengl32_func CullFace
	def_opengl32_func FrontFace
	def_opengl32_func Hint
	def_opengl32_func LineWidth
	def_opengl32_func PointSize
	def_opengl32_func PolygonMode
	def_opengl32_func Scissor
	def_opengl32_func TexParameterf
	def_opengl32_func TexParameterfv
	def_opengl32_func TexParameteri
	def_opengl32_func TexParameteriv
	def_opengl32_func TexImage1D
	def_opengl32_func TexImage2D
	def_opengl32_func DrawBuffer
	def_opengl32_func Clear
	def_opengl32_func ClearColor
	def_opengl32_func ClearStencil
	def_opengl32_func ClearDepth
	def_opengl32_func StencilMask
	def_opengl32_func ColorMask
	def_opengl32_func DepthMask
	def_opengl32_func Disable
	def_opengl32_func Enable
	def_opengl32_func Finish
	def_opengl32_func Flush
	def_opengl32_func BlendFunc
	def_opengl32_func LogicOp
	def_opengl32_func StencilFunc
	def_opengl32_func StencilOp
	def_opengl32_func DepthFunc
	def_opengl32_func PixelStoref
	def_opengl32_func PixelStorei
	def_opengl32_func ReadBuffer
	def_opengl32_func ReadPixels
	def_opengl32_func GetBooleanv
	def_opengl32_func GetDoublev
	def_opengl32_func GetError
	def_opengl32_func GetFloatv
	def_opengl32_func GetIntegerv
	def_opengl32_func GetString
	def_opengl32_func GetTexImage
	def_opengl32_func GetTexParameterfv
	def_opengl32_func GetTexParameteriv
	def_opengl32_func GetTexLevelParameterfv
	def_opengl32_func GetTexLevelParameteriv
	def_opengl32_func IsEnabled
	def_opengl32_func DepthRange
	def_opengl32_func Viewport

	segment .bss
	global _LastGL32Func
	_LastGL32Func:

	segment .namelist
	global _LastNameOfGL32Func
	_LastNameOfGL32Func:

	segment .text
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

	segment .bss
	global _OpenGL_Vendor
	global _OpenGL_Renderer
	global _OpenGL_Version
	_OpenGL_Vendor resd 1
	_OpenGL_Renderer resd 1
	_OpenGL_Version resd 1

	segment .text

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

	segment .bss
	global _FirstGLFunc
	_FirstGLFunc:

	segment .rdata
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

	def_opengl_func DrawArrays
	def_opengl_func DrawElements
	def_opengl_func GetPointerv
	def_opengl_func PolygonOffset
	def_opengl_func CopyTexImage1D
	def_opengl_func CopyTexImage2D
	def_opengl_func CopyTexSubImage1D
	def_opengl_func CopyTexSubImage2D
	def_opengl_func TexSubImage1D
	def_opengl_func TexSubImage2D
	def_opengl_func BindTexture
	def_opengl_func DeleteTextures
	def_opengl_func GenTextures

	def_opengl_func DrawRangeElements
	def_opengl_func TexImage3D
	def_opengl_func TexSubImage3D
	def_opengl_func CopyTexSubImage3D

	def_opengl_func ActiveTexture
	def_opengl_func SampleCoverage
	def_opengl_func CompressedTexImage3D
	def_opengl_func CompressedTexImage2D
	def_opengl_func CompressedTexImage1D
	def_opengl_func CompressedTexSubImage3D
	def_opengl_func CompressedTexSubImage2D
	def_opengl_func CompressedTexSubImage1D
	def_opengl_func GetCompressedTexImage
	def_opengl_func ClientActiveTexture
	def_opengl_func MultiTexCoord1d
	def_opengl_func MultiTexCoord1dv
	def_opengl_func MultiTexCoord1f
	def_opengl_func MultiTexCoord1fv
	def_opengl_func MultiTexCoord1i
	def_opengl_func MultiTexCoord1iv
	def_opengl_func MultiTexCoord1s
	def_opengl_func MultiTexCoord1sv
	def_opengl_func MultiTexCoord2d
	def_opengl_func MultiTexCoord2dv
	def_opengl_func MultiTexCoord2f
	def_opengl_func MultiTexCoord2fv
	def_opengl_func MultiTexCoord2i
	def_opengl_func MultiTexCoord2iv
	def_opengl_func MultiTexCoord2s
	def_opengl_func MultiTexCoord2sv
	def_opengl_func MultiTexCoord3d
	def_opengl_func MultiTexCoord3dv
	def_opengl_func MultiTexCoord3f
	def_opengl_func MultiTexCoord3fv
	def_opengl_func MultiTexCoord3i
	def_opengl_func MultiTexCoord3iv
	def_opengl_func MultiTexCoord3s
	def_opengl_func MultiTexCoord3sv
	def_opengl_func MultiTexCoord4d
	def_opengl_func MultiTexCoord4dv
	def_opengl_func MultiTexCoord4f
	def_opengl_func MultiTexCoord4fv
	def_opengl_func MultiTexCoord4i
	def_opengl_func MultiTexCoord4iv
	def_opengl_func MultiTexCoord4s
	def_opengl_func MultiTexCoord4sv
	def_opengl_func LoadTransposeMatrixf
	def_opengl_func LoadTransposeMatrixd
	def_opengl_func MultTransposeMatrixf
	def_opengl_func MultTransposeMatrixd

	def_opengl_func BlendFuncSeparate
	def_opengl_func MultiDrawArrays
	def_opengl_func MultiDrawElements
	def_opengl_func PointParameterf
	def_opengl_func PointParameterfv
	def_opengl_func PointParameteri
	def_opengl_func PointParameteriv
	def_opengl_func FogCoordf
	def_opengl_func FogCoordfv
	def_opengl_func FogCoordd
	def_opengl_func FogCoorddv
	def_opengl_func FogCoordPointer
	def_opengl_func SecondaryColor3b
	def_opengl_func SecondaryColor3bv
	def_opengl_func SecondaryColor3d
	def_opengl_func SecondaryColor3dv
	def_opengl_func SecondaryColor3f
	def_opengl_func SecondaryColor3fv
	def_opengl_func SecondaryColor3i
	def_opengl_func SecondaryColor3iv
	def_opengl_func SecondaryColor3s
	def_opengl_func SecondaryColor3sv
	def_opengl_func SecondaryColor3ub
	def_opengl_func SecondaryColor3ubv
	def_opengl_func SecondaryColor3ui
	def_opengl_func SecondaryColor3uiv
	def_opengl_func SecondaryColor3us
	def_opengl_func SecondaryColor3usv
	def_opengl_func SecondaryColorPointer
	def_opengl_func WindowPos2d
	def_opengl_func WindowPos2dv
	def_opengl_func WindowPos2f
	def_opengl_func WindowPos2fv
	def_opengl_func WindowPos2i
	def_opengl_func WindowPos2iv
	def_opengl_func WindowPos2s
	def_opengl_func WindowPos2sv
	def_opengl_func WindowPos3d
	def_opengl_func WindowPos3dv
	def_opengl_func WindowPos3f
	def_opengl_func WindowPos3fv
	def_opengl_func WindowPos3i
	def_opengl_func WindowPos3iv
	def_opengl_func WindowPos3s
	def_opengl_func WindowPos3sv
	def_opengl_func BlendColor
	def_opengl_func BlendEquation

	def_opengl_func GenQueries
	def_opengl_func DeleteQueries
	def_opengl_func IsQuery
	def_opengl_func BeginQuery
	def_opengl_func EndQuery
	def_opengl_func GetQueryiv
	def_opengl_func GetQueryObjectiv
	def_opengl_func GetQueryObjectuiv
	def_opengl_func BindBuffer
	def_opengl_func DeleteBuffers
	def_opengl_func GenBuffers
	def_opengl_func IsBuffer
	def_opengl_func BufferData
	def_opengl_func BufferSubData
	def_opengl_func GetBufferSubData
	def_opengl_func MapBuffer
	def_opengl_func UnmapBuffer
	def_opengl_func GetBufferParameteriv
	def_opengl_func GetBufferPointerv

	def_opengl_func BlendEquationSeparate
	def_opengl_func DrawBuffers
	def_opengl_func StencilOpSeparate
	def_opengl_func StencilFuncSeparate
	def_opengl_func StencilMaskSeparate
	def_opengl_func AttachShader
	def_opengl_func BindAttribLocation
	def_opengl_func CompileShader
	def_opengl_func CreateProgram
	def_opengl_func CreateShader
	def_opengl_func DeleteProgram
	def_opengl_func DeleteShader
	def_opengl_func DetachShader
	def_opengl_func DisableVertexAttribArray
	def_opengl_func EnableVertexAttribArray
	def_opengl_func GetActiveAttrib
	def_opengl_func GetActiveUniform
	def_opengl_func GetAttachedShaders
	def_opengl_func GetAttribLocation
	def_opengl_func GetProgramiv
	def_opengl_func GetProgramInfoLog
	def_opengl_func GetShaderiv
	def_opengl_func GetShaderInfoLog
	def_opengl_func GetShaderSource
	def_opengl_func GetUniformLocation
	def_opengl_func GetUniformfv
	def_opengl_func GetUniformiv
	def_opengl_func GetVertexAttribdv
	def_opengl_func GetVertexAttribfv
	def_opengl_func GetVertexAttribiv
	def_opengl_func GetVertexAttribPointerv
	def_opengl_func IsProgram
	def_opengl_func IsShader
	def_opengl_func LinkProgram
	def_opengl_func ShaderSource
	def_opengl_func UseProgram
	def_opengl_func Uniform1f
	def_opengl_func Uniform2f
	def_opengl_func Uniform3f
	def_opengl_func Uniform4f
	def_opengl_func Uniform1i
	def_opengl_func Uniform2i
	def_opengl_func Uniform3i
	def_opengl_func Uniform4i
	def_opengl_func Uniform1fv
	def_opengl_func Uniform2fv
	def_opengl_func Uniform3fv
	def_opengl_func Uniform4fv
	def_opengl_func Uniform1iv
	def_opengl_func Uniform2iv
	def_opengl_func Uniform3iv
	def_opengl_func Uniform4iv
	def_opengl_func UniformMatrix2fv
	def_opengl_func UniformMatrix3fv
	def_opengl_func UniformMatrix4fv
	def_opengl_func ValidateProgram
	def_opengl_func VertexAttrib1d
	def_opengl_func VertexAttrib1dv
	def_opengl_func VertexAttrib1f
	def_opengl_func VertexAttrib1fv
	def_opengl_func VertexAttrib1s
	def_opengl_func VertexAttrib1sv
	def_opengl_func VertexAttrib2d
	def_opengl_func VertexAttrib2dv
	def_opengl_func VertexAttrib2f
	def_opengl_func VertexAttrib2fv
	def_opengl_func VertexAttrib2s
	def_opengl_func VertexAttrib2sv
	def_opengl_func VertexAttrib3d
	def_opengl_func VertexAttrib3dv
	def_opengl_func VertexAttrib3f
	def_opengl_func VertexAttrib3fv
	def_opengl_func VertexAttrib3s
	def_opengl_func VertexAttrib3sv
	def_opengl_func VertexAttrib4Nbv
	def_opengl_func VertexAttrib4Niv
	def_opengl_func VertexAttrib4Nsv
	def_opengl_func VertexAttrib4Nub
	def_opengl_func VertexAttrib4Nubv
	def_opengl_func VertexAttrib4Nuiv
	def_opengl_func VertexAttrib4Nusv
	def_opengl_func VertexAttrib4bv
	def_opengl_func VertexAttrib4d
	def_opengl_func VertexAttrib4dv
	def_opengl_func VertexAttrib4f
	def_opengl_func VertexAttrib4fv
	def_opengl_func VertexAttrib4iv
	def_opengl_func VertexAttrib4s
	def_opengl_func VertexAttrib4sv
	def_opengl_func VertexAttrib4ubv
	def_opengl_func VertexAttrib4uiv
	def_opengl_func VertexAttrib4usv
	def_opengl_func VertexAttribPointer

	def_opengl_func UniformMatrix2x3fv
	def_opengl_func UniformMatrix3x2fv
	def_opengl_func UniformMatrix2x4fv
	def_opengl_func UniformMatrix4x2fv
	def_opengl_func UniformMatrix3x4fv
	def_opengl_func UniformMatrix4x3fv

	def_opengl_func ColorMaski
	def_opengl_func GetBooleani_v
	def_opengl_func GetIntegeri_v
	def_opengl_func Enablei
	def_opengl_func Disablei
	def_opengl_func IsEnabledi
	def_opengl_func BeginTransformFeedback
	def_opengl_func EndTransformFeedback
	def_opengl_func BindBufferRange
	def_opengl_func BindBufferBase
	def_opengl_func TransformFeedbackVaryings
	def_opengl_func GetTransformFeedbackVarying
	def_opengl_func ClampColor
	def_opengl_func BeginConditionalRender
	def_opengl_func EndConditionalRender
	def_opengl_func VertexAttribIPointer
	def_opengl_func GetVertexAttribIiv
	def_opengl_func GetVertexAttribIuiv
	def_opengl_func VertexAttribI1i
	def_opengl_func VertexAttribI2i
	def_opengl_func VertexAttribI3i
	def_opengl_func VertexAttribI4i
	def_opengl_func VertexAttribI1ui
	def_opengl_func VertexAttribI2ui
	def_opengl_func VertexAttribI3ui
	def_opengl_func VertexAttribI4ui
	def_opengl_func VertexAttribI1iv
	def_opengl_func VertexAttribI2iv
	def_opengl_func VertexAttribI3iv
	def_opengl_func VertexAttribI4iv
	def_opengl_func VertexAttribI1uiv
	def_opengl_func VertexAttribI2uiv
	def_opengl_func VertexAttribI3uiv
	def_opengl_func VertexAttribI4uiv
	def_opengl_func VertexAttribI4bv
	def_opengl_func VertexAttribI4sv
	def_opengl_func VertexAttribI4ubv
	def_opengl_func VertexAttribI4usv
	def_opengl_func GetUniformuiv
	def_opengl_func BindFragDataLocation
	def_opengl_func GetFragDataLocation
	def_opengl_func Uniform1ui
	def_opengl_func Uniform2ui
	def_opengl_func Uniform3ui
	def_opengl_func Uniform4ui
	def_opengl_func Uniform1uiv
	def_opengl_func Uniform2uiv
	def_opengl_func Uniform3uiv
	def_opengl_func Uniform4uiv
	def_opengl_func TexParameterIiv
	def_opengl_func TexParameterIuiv
	def_opengl_func GetTexParameterIiv
	def_opengl_func GetTexParameterIuiv
	def_opengl_func ClearBufferiv
	def_opengl_func ClearBufferuiv
	def_opengl_func ClearBufferfv
	def_opengl_func ClearBufferfi
	def_opengl_func GetStringi
	def_opengl_func IsRenderbuffer
	def_opengl_func BindRenderbuffer
	def_opengl_func DeleteRenderbuffers
	def_opengl_func GenRenderbuffers
	def_opengl_func RenderbufferStorage
	def_opengl_func GetRenderbufferParameteriv
	def_opengl_func IsFramebuffer
	def_opengl_func BindFramebuffer
	def_opengl_func DeleteFramebuffers
	def_opengl_func GenFramebuffers
	def_opengl_func CheckFramebufferStatus
	def_opengl_func FramebufferTexture1D
	def_opengl_func FramebufferTexture2D
	def_opengl_func FramebufferTexture3D
	def_opengl_func FramebufferRenderbuffer
	def_opengl_func GetFramebufferAttachmentParameteriv
	def_opengl_func GenerateMipmap
	def_opengl_func BlitFramebuffer
	def_opengl_func RenderbufferStorageMultisample
	def_opengl_func FramebufferTextureLayer
	def_opengl_func MapBufferRange
	def_opengl_func FlushMappedBufferRange
	def_opengl_func BindVertexArray
	def_opengl_func DeleteVertexArrays
	def_opengl_func GenVertexArrays
	def_opengl_func IsVertexArray

	def_opengl_func DrawArraysInstanced
	def_opengl_func DrawElementsInstanced
	def_opengl_func TexBuffer
	def_opengl_func PrimitiveRestartIndex
	def_opengl_func CopyBufferSubData
	def_opengl_func GetUniformIndices
	def_opengl_func GetActiveUniformsiv
	def_opengl_func GetActiveUniformName
	def_opengl_func GetUniformBlockIndex
	def_opengl_func GetActiveUniformBlockiv
	def_opengl_func GetActiveUniformBlockName
	def_opengl_func UniformBlockBinding

	def_opengl_func DrawElementsBaseVertex
	def_opengl_func DrawRangeElementsBaseVertex
	def_opengl_func DrawElementsInstancedBaseVertex
	def_opengl_func MultiDrawElementsBaseVertex
	def_opengl_func ProvokingVertex
	def_opengl_func FenceSync
	def_opengl_func IsSync
	def_opengl_func DeleteSync
	def_opengl_func ClientWaitSync
	def_opengl_func WaitSync
	def_opengl_func GetInteger64v
	def_opengl_func GetSynciv
	def_opengl_func GetInteger64i_v
	def_opengl_func GetBufferParameteri64v
	def_opengl_func FramebufferTexture
	def_opengl_func TexImage2DMultisample
	def_opengl_func TexImage3DMultisample
	def_opengl_func GetMultisamplefv
	def_opengl_func SampleMaski

	def_opengl_func BindFragDataLocationIndexed
	def_opengl_func GetFragDataIndex
	def_opengl_func GenSamplers
	def_opengl_func DeleteSamplers
	def_opengl_func IsSampler
	def_opengl_func BindSampler
	def_opengl_func SamplerParameteri
	def_opengl_func SamplerParameteriv
	def_opengl_func SamplerParameterf
	def_opengl_func SamplerParameterfv
	def_opengl_func SamplerParameterIiv
	def_opengl_func SamplerParameterIuiv
	def_opengl_func GetSamplerParameteriv
	def_opengl_func GetSamplerParameterIiv
	def_opengl_func GetSamplerParameterfv
	def_opengl_func GetSamplerParameterIuiv
	def_opengl_func QueryCounter
	def_opengl_func GetQueryObjecti64v
	def_opengl_func GetQueryObjectui64v
	def_opengl_func VertexAttribDivisor
	def_opengl_func VertexAttribP1ui
	def_opengl_func VertexAttribP1uiv
	def_opengl_func VertexAttribP2ui
	def_opengl_func VertexAttribP2uiv
	def_opengl_func VertexAttribP3ui
	def_opengl_func VertexAttribP3uiv
	def_opengl_func VertexAttribP4ui
	def_opengl_func VertexAttribP4uiv
	def_opengl_func VertexP2ui
	def_opengl_func VertexP2uiv
	def_opengl_func VertexP3ui
	def_opengl_func VertexP3uiv
	def_opengl_func VertexP4ui
	def_opengl_func VertexP4uiv
	def_opengl_func TexCoordP1ui
	def_opengl_func TexCoordP1uiv
	def_opengl_func TexCoordP2ui
	def_opengl_func TexCoordP2uiv
	def_opengl_func TexCoordP3ui
	def_opengl_func TexCoordP3uiv
	def_opengl_func TexCoordP4ui
	def_opengl_func TexCoordP4uiv
	def_opengl_func MultiTexCoordP1ui
	def_opengl_func MultiTexCoordP1uiv
	def_opengl_func MultiTexCoordP2ui
	def_opengl_func MultiTexCoordP2uiv
	def_opengl_func MultiTexCoordP3ui
	def_opengl_func MultiTexCoordP3uiv
	def_opengl_func MultiTexCoordP4ui
	def_opengl_func MultiTexCoordP4uiv
	def_opengl_func NormalP3ui
	def_opengl_func NormalP3uiv
	def_opengl_func ColorP3ui
	def_opengl_func ColorP3uiv
	def_opengl_func ColorP4ui
	def_opengl_func ColorP4uiv
	def_opengl_func SecondaryColorP3ui
	def_opengl_func SecondaryColorP3uiv

	segment .bss
	global _LastGLFunc
	_LastGLFunc:

	segment .namelist
	global _LastNameOfGLFunc
	_LastNameOfGLFunc:

	segment .text
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

.exit:
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
