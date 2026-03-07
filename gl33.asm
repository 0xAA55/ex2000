%include "loaddll.inc"
%include "frame.inc"
%include "gl33.inc"

import_dll GDI32

extern _hDC

%macro def_opengl_func_and_load 1
	segment .bss
	global _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	segment .rdata
	global _name_of_ %+ %1
	_name_of_ %+ %1 db %str(%1), 0

	segment .text
	push _name_of_ %+ %1
	invoke_dll_func wglGetProcAddress
	mov [_addr_of_ %+ %1], eax
%endmacro

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

segment .bss
global _OpenGL_Vendor
global _OpenGL_Renderer
global _OpenGL_Version
global _hGLRC
_OpenGL_Vendor resd 1
_OpenGL_Renderer resd 1
_OpenGL_Version resd 1
_hGLRC resd 1

segment .text
global _InitGL33
_InitGL33:
	FrameBegin 0, 0
	def_dll_and_load OpenGL32, "opengl32.dll"

	def_dll_func_and_load OpenGL32, wglGetProcAddress
	def_dll_func_and_load OpenGL32, wglCreateContext
	def_dll_func_and_load OpenGL32, wglDeleteContext
	def_dll_func_and_load OpenGL32, wglMakeCurrent
	def_dll_func_and_load OpenGL32, wglSwapBuffers

	def_dll_func_and_load OpenGL32, glCullFace
	def_dll_func_and_load OpenGL32, glFrontFace
	def_dll_func_and_load OpenGL32, glHint
	def_dll_func_and_load OpenGL32, glLineWidth
	def_dll_func_and_load OpenGL32, glPointSize
	def_dll_func_and_load OpenGL32, glPolygonMode
	def_dll_func_and_load OpenGL32, glScissor
	def_dll_func_and_load OpenGL32, glTexParameterf
	def_dll_func_and_load OpenGL32, glTexParameterfv
	def_dll_func_and_load OpenGL32, glTexParameteri
	def_dll_func_and_load OpenGL32, glTexParameteriv
	def_dll_func_and_load OpenGL32, glTexImage1D
	def_dll_func_and_load OpenGL32, glTexImage2D
	def_dll_func_and_load OpenGL32, glDrawBuffer
	def_dll_func_and_load OpenGL32, glClear
	def_dll_func_and_load OpenGL32, glClearColor
	def_dll_func_and_load OpenGL32, glClearStencil
	def_dll_func_and_load OpenGL32, glClearDepth
	def_dll_func_and_load OpenGL32, glStencilMask
	def_dll_func_and_load OpenGL32, glColorMask
	def_dll_func_and_load OpenGL32, glDepthMask
	def_dll_func_and_load OpenGL32, glDisable
	def_dll_func_and_load OpenGL32, glEnable
	def_dll_func_and_load OpenGL32, glFinish
	def_dll_func_and_load OpenGL32, glFlush
	def_dll_func_and_load OpenGL32, glBlendFunc
	def_dll_func_and_load OpenGL32, glLogicOp
	def_dll_func_and_load OpenGL32, glStencilFunc
	def_dll_func_and_load OpenGL32, glStencilOp
	def_dll_func_and_load OpenGL32, glDepthFunc
	def_dll_func_and_load OpenGL32, glPixelStoref
	def_dll_func_and_load OpenGL32, glPixelStorei
	def_dll_func_and_load OpenGL32, glReadBuffer
	def_dll_func_and_load OpenGL32, glReadPixels
	def_dll_func_and_load OpenGL32, glGetBooleanv
	def_dll_func_and_load OpenGL32, glGetDoublev
	def_dll_func_and_load OpenGL32, glGetError
	def_dll_func_and_load OpenGL32, glGetFloatv
	def_dll_func_and_load OpenGL32, glGetIntegerv
	def_dll_func_and_load OpenGL32, glGetString
	def_dll_func_and_load OpenGL32, glGetTexImage
	def_dll_func_and_load OpenGL32, glGetTexParameterfv
	def_dll_func_and_load OpenGL32, glGetTexParameteriv
	def_dll_func_and_load OpenGL32, glGetTexLevelParameterfv
	def_dll_func_and_load OpenGL32, glGetTexLevelParameteriv
	def_dll_func_and_load OpenGL32, glIsEnabled
	def_dll_func_and_load OpenGL32, glDepthRange
	def_dll_func_and_load OpenGL32, glViewport

	def_dll_func_and_load GDI32, ChoosePixelFormat
	def_dll_func_and_load GDI32, SetPixelFormat

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

	def_opengl_func_and_load glDrawArrays
	def_opengl_func_and_load glDrawElements
	def_opengl_func_and_load glGetPointerv
	def_opengl_func_and_load glPolygonOffset
	def_opengl_func_and_load glCopyTexImage1D
	def_opengl_func_and_load glCopyTexImage2D
	def_opengl_func_and_load glCopyTexSubImage1D
	def_opengl_func_and_load glCopyTexSubImage2D
	def_opengl_func_and_load glTexSubImage1D
	def_opengl_func_and_load glTexSubImage2D
	def_opengl_func_and_load glBindTexture
	def_opengl_func_and_load glDeleteTextures
	def_opengl_func_and_load glGenTextures

	def_opengl_func_and_load glDrawRangeElements
	def_opengl_func_and_load glTexImage3D
	def_opengl_func_and_load glTexSubImage3D
	def_opengl_func_and_load glCopyTexSubImage3D

	def_opengl_func_and_load glActiveTexture
	def_opengl_func_and_load glSampleCoverage
	def_opengl_func_and_load glCompressedTexImage3D
	def_opengl_func_and_load glCompressedTexImage2D
	def_opengl_func_and_load glCompressedTexImage1D
	def_opengl_func_and_load glCompressedTexSubImage3D
	def_opengl_func_and_load glCompressedTexSubImage2D
	def_opengl_func_and_load glCompressedTexSubImage1D
	def_opengl_func_and_load glGetCompressedTexImage
	def_opengl_func_and_load glClientActiveTexture
	def_opengl_func_and_load glMultiTexCoord1d
	def_opengl_func_and_load glMultiTexCoord1dv
	def_opengl_func_and_load glMultiTexCoord1f
	def_opengl_func_and_load glMultiTexCoord1fv
	def_opengl_func_and_load glMultiTexCoord1i
	def_opengl_func_and_load glMultiTexCoord1iv
	def_opengl_func_and_load glMultiTexCoord1s
	def_opengl_func_and_load glMultiTexCoord1sv
	def_opengl_func_and_load glMultiTexCoord2d
	def_opengl_func_and_load glMultiTexCoord2dv
	def_opengl_func_and_load glMultiTexCoord2f
	def_opengl_func_and_load glMultiTexCoord2fv
	def_opengl_func_and_load glMultiTexCoord2i
	def_opengl_func_and_load glMultiTexCoord2iv
	def_opengl_func_and_load glMultiTexCoord2s
	def_opengl_func_and_load glMultiTexCoord2sv
	def_opengl_func_and_load glMultiTexCoord3d
	def_opengl_func_and_load glMultiTexCoord3dv
	def_opengl_func_and_load glMultiTexCoord3f
	def_opengl_func_and_load glMultiTexCoord3fv
	def_opengl_func_and_load glMultiTexCoord3i
	def_opengl_func_and_load glMultiTexCoord3iv
	def_opengl_func_and_load glMultiTexCoord3s
	def_opengl_func_and_load glMultiTexCoord3sv
	def_opengl_func_and_load glMultiTexCoord4d
	def_opengl_func_and_load glMultiTexCoord4dv
	def_opengl_func_and_load glMultiTexCoord4f
	def_opengl_func_and_load glMultiTexCoord4fv
	def_opengl_func_and_load glMultiTexCoord4i
	def_opengl_func_and_load glMultiTexCoord4iv
	def_opengl_func_and_load glMultiTexCoord4s
	def_opengl_func_and_load glMultiTexCoord4sv
	def_opengl_func_and_load glLoadTransposeMatrixf
	def_opengl_func_and_load glLoadTransposeMatrixd
	def_opengl_func_and_load glMultTransposeMatrixf
	def_opengl_func_and_load glMultTransposeMatrixd

	def_opengl_func_and_load glBlendFuncSeparate
	def_opengl_func_and_load glMultiDrawArrays
	def_opengl_func_and_load glMultiDrawElements
	def_opengl_func_and_load glPointParameterf
	def_opengl_func_and_load glPointParameterfv
	def_opengl_func_and_load glPointParameteri
	def_opengl_func_and_load glPointParameteriv
	def_opengl_func_and_load glFogCoordf
	def_opengl_func_and_load glFogCoordfv
	def_opengl_func_and_load glFogCoordd
	def_opengl_func_and_load glFogCoorddv
	def_opengl_func_and_load glFogCoordPointer
	def_opengl_func_and_load glSecondaryColor3b
	def_opengl_func_and_load glSecondaryColor3bv
	def_opengl_func_and_load glSecondaryColor3d
	def_opengl_func_and_load glSecondaryColor3dv
	def_opengl_func_and_load glSecondaryColor3f
	def_opengl_func_and_load glSecondaryColor3fv
	def_opengl_func_and_load glSecondaryColor3i
	def_opengl_func_and_load glSecondaryColor3iv
	def_opengl_func_and_load glSecondaryColor3s
	def_opengl_func_and_load glSecondaryColor3sv
	def_opengl_func_and_load glSecondaryColor3ub
	def_opengl_func_and_load glSecondaryColor3ubv
	def_opengl_func_and_load glSecondaryColor3ui
	def_opengl_func_and_load glSecondaryColor3uiv
	def_opengl_func_and_load glSecondaryColor3us
	def_opengl_func_and_load glSecondaryColor3usv
	def_opengl_func_and_load glSecondaryColorPointer
	def_opengl_func_and_load glWindowPos2d
	def_opengl_func_and_load glWindowPos2dv
	def_opengl_func_and_load glWindowPos2f
	def_opengl_func_and_load glWindowPos2fv
	def_opengl_func_and_load glWindowPos2i
	def_opengl_func_and_load glWindowPos2iv
	def_opengl_func_and_load glWindowPos2s
	def_opengl_func_and_load glWindowPos2sv
	def_opengl_func_and_load glWindowPos3d
	def_opengl_func_and_load glWindowPos3dv
	def_opengl_func_and_load glWindowPos3f
	def_opengl_func_and_load glWindowPos3fv
	def_opengl_func_and_load glWindowPos3i
	def_opengl_func_and_load glWindowPos3iv
	def_opengl_func_and_load glWindowPos3s
	def_opengl_func_and_load glWindowPos3sv
	def_opengl_func_and_load glBlendColor
	def_opengl_func_and_load glBlendEquation

	def_opengl_func_and_load glGenQueries
	def_opengl_func_and_load glDeleteQueries
	def_opengl_func_and_load glIsQuery
	def_opengl_func_and_load glBeginQuery
	def_opengl_func_and_load glEndQuery
	def_opengl_func_and_load glGetQueryiv
	def_opengl_func_and_load glGetQueryObjectiv
	def_opengl_func_and_load glGetQueryObjectuiv
	def_opengl_func_and_load glBindBuffer
	def_opengl_func_and_load glDeleteBuffers
	def_opengl_func_and_load glGenBuffers
	def_opengl_func_and_load glIsBuffer
	def_opengl_func_and_load glBufferData
	def_opengl_func_and_load glBufferSubData
	def_opengl_func_and_load glGetBufferSubData
	def_opengl_func_and_load glMapBuffer
	def_opengl_func_and_load glUnmapBuffer
	def_opengl_func_and_load glGetBufferParameteriv
	def_opengl_func_and_load glGetBufferPointerv

	def_opengl_func_and_load glBlendEquationSeparate
	def_opengl_func_and_load glDrawBuffers
	def_opengl_func_and_load glStencilOpSeparate
	def_opengl_func_and_load glStencilFuncSeparate
	def_opengl_func_and_load glStencilMaskSeparate
	def_opengl_func_and_load glAttachShader
	def_opengl_func_and_load glBindAttribLocation
	def_opengl_func_and_load glCompileShader
	def_opengl_func_and_load glCreateProgram
	def_opengl_func_and_load glCreateShader
	def_opengl_func_and_load glDeleteProgram
	def_opengl_func_and_load glDeleteShader
	def_opengl_func_and_load glDetachShader
	def_opengl_func_and_load glDisableVertexAttribArray
	def_opengl_func_and_load glEnableVertexAttribArray
	def_opengl_func_and_load glGetActiveAttrib
	def_opengl_func_and_load glGetActiveUniform
	def_opengl_func_and_load glGetAttachedShaders
	def_opengl_func_and_load glGetAttribLocation
	def_opengl_func_and_load glGetProgramiv
	def_opengl_func_and_load glGetProgramInfoLog
	def_opengl_func_and_load glGetShaderiv
	def_opengl_func_and_load glGetShaderInfoLog
	def_opengl_func_and_load glGetShaderSource
	def_opengl_func_and_load glGetUniformLocation
	def_opengl_func_and_load glGetUniformfv
	def_opengl_func_and_load glGetUniformiv
	def_opengl_func_and_load glGetVertexAttribdv
	def_opengl_func_and_load glGetVertexAttribfv
	def_opengl_func_and_load glGetVertexAttribiv
	def_opengl_func_and_load glGetVertexAttribPointerv
	def_opengl_func_and_load glIsProgram
	def_opengl_func_and_load glIsShader
	def_opengl_func_and_load glLinkProgram
	def_opengl_func_and_load glShaderSource
	def_opengl_func_and_load glUseProgram
	def_opengl_func_and_load glUniform1f
	def_opengl_func_and_load glUniform2f
	def_opengl_func_and_load glUniform3f
	def_opengl_func_and_load glUniform4f
	def_opengl_func_and_load glUniform1i
	def_opengl_func_and_load glUniform2i
	def_opengl_func_and_load glUniform3i
	def_opengl_func_and_load glUniform4i
	def_opengl_func_and_load glUniform1fv
	def_opengl_func_and_load glUniform2fv
	def_opengl_func_and_load glUniform3fv
	def_opengl_func_and_load glUniform4fv
	def_opengl_func_and_load glUniform1iv
	def_opengl_func_and_load glUniform2iv
	def_opengl_func_and_load glUniform3iv
	def_opengl_func_and_load glUniform4iv
	def_opengl_func_and_load glUniformMatrix2fv
	def_opengl_func_and_load glUniformMatrix3fv
	def_opengl_func_and_load glUniformMatrix4fv
	def_opengl_func_and_load glValidateProgram
	def_opengl_func_and_load glVertexAttrib1d
	def_opengl_func_and_load glVertexAttrib1dv
	def_opengl_func_and_load glVertexAttrib1f
	def_opengl_func_and_load glVertexAttrib1fv
	def_opengl_func_and_load glVertexAttrib1s
	def_opengl_func_and_load glVertexAttrib1sv
	def_opengl_func_and_load glVertexAttrib2d
	def_opengl_func_and_load glVertexAttrib2dv
	def_opengl_func_and_load glVertexAttrib2f
	def_opengl_func_and_load glVertexAttrib2fv
	def_opengl_func_and_load glVertexAttrib2s
	def_opengl_func_and_load glVertexAttrib2sv
	def_opengl_func_and_load glVertexAttrib3d
	def_opengl_func_and_load glVertexAttrib3dv
	def_opengl_func_and_load glVertexAttrib3f
	def_opengl_func_and_load glVertexAttrib3fv
	def_opengl_func_and_load glVertexAttrib3s
	def_opengl_func_and_load glVertexAttrib3sv
	def_opengl_func_and_load glVertexAttrib4Nbv
	def_opengl_func_and_load glVertexAttrib4Niv
	def_opengl_func_and_load glVertexAttrib4Nsv
	def_opengl_func_and_load glVertexAttrib4Nub
	def_opengl_func_and_load glVertexAttrib4Nubv
	def_opengl_func_and_load glVertexAttrib4Nuiv
	def_opengl_func_and_load glVertexAttrib4Nusv
	def_opengl_func_and_load glVertexAttrib4bv
	def_opengl_func_and_load glVertexAttrib4d
	def_opengl_func_and_load glVertexAttrib4dv
	def_opengl_func_and_load glVertexAttrib4f
	def_opengl_func_and_load glVertexAttrib4fv
	def_opengl_func_and_load glVertexAttrib4iv
	def_opengl_func_and_load glVertexAttrib4s
	def_opengl_func_and_load glVertexAttrib4sv
	def_opengl_func_and_load glVertexAttrib4ubv
	def_opengl_func_and_load glVertexAttrib4uiv
	def_opengl_func_and_load glVertexAttrib4usv
	def_opengl_func_and_load glVertexAttribPointer

	def_opengl_func_and_load glUniformMatrix2x3fv
	def_opengl_func_and_load glUniformMatrix3x2fv
	def_opengl_func_and_load glUniformMatrix2x4fv
	def_opengl_func_and_load glUniformMatrix4x2fv
	def_opengl_func_and_load glUniformMatrix3x4fv
	def_opengl_func_and_load glUniformMatrix4x3fv

	def_opengl_func_and_load glColorMaski
	def_opengl_func_and_load glGetBooleani_v
	def_opengl_func_and_load glGetIntegeri_v
	def_opengl_func_and_load glEnablei
	def_opengl_func_and_load glDisablei
	def_opengl_func_and_load glIsEnabledi
	def_opengl_func_and_load glBeginTransformFeedback
	def_opengl_func_and_load glEndTransformFeedback
	def_opengl_func_and_load glBindBufferRange
	def_opengl_func_and_load glBindBufferBase
	def_opengl_func_and_load glTransformFeedbackVaryings
	def_opengl_func_and_load glGetTransformFeedbackVarying
	def_opengl_func_and_load glClampColor
	def_opengl_func_and_load glBeginConditionalRender
	def_opengl_func_and_load glEndConditionalRender
	def_opengl_func_and_load glVertexAttribIPointer
	def_opengl_func_and_load glGetVertexAttribIiv
	def_opengl_func_and_load glGetVertexAttribIuiv
	def_opengl_func_and_load glVertexAttribI1i
	def_opengl_func_and_load glVertexAttribI2i
	def_opengl_func_and_load glVertexAttribI3i
	def_opengl_func_and_load glVertexAttribI4i
	def_opengl_func_and_load glVertexAttribI1ui
	def_opengl_func_and_load glVertexAttribI2ui
	def_opengl_func_and_load glVertexAttribI3ui
	def_opengl_func_and_load glVertexAttribI4ui
	def_opengl_func_and_load glVertexAttribI1iv
	def_opengl_func_and_load glVertexAttribI2iv
	def_opengl_func_and_load glVertexAttribI3iv
	def_opengl_func_and_load glVertexAttribI4iv
	def_opengl_func_and_load glVertexAttribI1uiv
	def_opengl_func_and_load glVertexAttribI2uiv
	def_opengl_func_and_load glVertexAttribI3uiv
	def_opengl_func_and_load glVertexAttribI4uiv
	def_opengl_func_and_load glVertexAttribI4bv
	def_opengl_func_and_load glVertexAttribI4sv
	def_opengl_func_and_load glVertexAttribI4ubv
	def_opengl_func_and_load glVertexAttribI4usv
	def_opengl_func_and_load glGetUniformuiv
	def_opengl_func_and_load glBindFragDataLocation
	def_opengl_func_and_load glGetFragDataLocation
	def_opengl_func_and_load glUniform1ui
	def_opengl_func_and_load glUniform2ui
	def_opengl_func_and_load glUniform3ui
	def_opengl_func_and_load glUniform4ui
	def_opengl_func_and_load glUniform1uiv
	def_opengl_func_and_load glUniform2uiv
	def_opengl_func_and_load glUniform3uiv
	def_opengl_func_and_load glUniform4uiv
	def_opengl_func_and_load glTexParameterIiv
	def_opengl_func_and_load glTexParameterIuiv
	def_opengl_func_and_load glGetTexParameterIiv
	def_opengl_func_and_load glGetTexParameterIuiv
	def_opengl_func_and_load glClearBufferiv
	def_opengl_func_and_load glClearBufferuiv
	def_opengl_func_and_load glClearBufferfv
	def_opengl_func_and_load glClearBufferfi
	def_opengl_func_and_load glGetStringi
	def_opengl_func_and_load glIsRenderbuffer
	def_opengl_func_and_load glBindRenderbuffer
	def_opengl_func_and_load glDeleteRenderbuffers
	def_opengl_func_and_load glGenRenderbuffers
	def_opengl_func_and_load glRenderbufferStorage
	def_opengl_func_and_load glGetRenderbufferParameteriv
	def_opengl_func_and_load glIsFramebuffer
	def_opengl_func_and_load glBindFramebuffer
	def_opengl_func_and_load glDeleteFramebuffers
	def_opengl_func_and_load glGenFramebuffers
	def_opengl_func_and_load glCheckFramebufferStatus
	def_opengl_func_and_load glFramebufferTexture1D
	def_opengl_func_and_load glFramebufferTexture2D
	def_opengl_func_and_load glFramebufferTexture3D
	def_opengl_func_and_load glFramebufferRenderbuffer
	def_opengl_func_and_load glGetFramebufferAttachmentParameteriv
	def_opengl_func_and_load glGenerateMipmap
	def_opengl_func_and_load glBlitFramebuffer
	def_opengl_func_and_load glRenderbufferStorageMultisample
	def_opengl_func_and_load glFramebufferTextureLayer
	def_opengl_func_and_load glMapBufferRange
	def_opengl_func_and_load glFlushMappedBufferRange
	def_opengl_func_and_load glBindVertexArray
	def_opengl_func_and_load glDeleteVertexArrays
	def_opengl_func_and_load glGenVertexArrays
	def_opengl_func_and_load glIsVertexArray

	def_opengl_func_and_load glDrawArraysInstanced
	def_opengl_func_and_load glDrawElementsInstanced
	def_opengl_func_and_load glTexBuffer
	def_opengl_func_and_load glPrimitiveRestartIndex
	def_opengl_func_and_load glCopyBufferSubData
	def_opengl_func_and_load glGetUniformIndices
	def_opengl_func_and_load glGetActiveUniformsiv
	def_opengl_func_and_load glGetActiveUniformName
	def_opengl_func_and_load glGetUniformBlockIndex
	def_opengl_func_and_load glGetActiveUniformBlockiv
	def_opengl_func_and_load glGetActiveUniformBlockName
	def_opengl_func_and_load glUniformBlockBinding

	def_opengl_func_and_load glDrawElementsBaseVertex
	def_opengl_func_and_load glDrawRangeElementsBaseVertex
	def_opengl_func_and_load glDrawElementsInstancedBaseVertex
	def_opengl_func_and_load glMultiDrawElementsBaseVertex
	def_opengl_func_and_load glProvokingVertex
	def_opengl_func_and_load glFenceSync
	def_opengl_func_and_load glIsSync
	def_opengl_func_and_load glDeleteSync
	def_opengl_func_and_load glClientWaitSync
	def_opengl_func_and_load glWaitSync
	def_opengl_func_and_load glGetInteger64v
	def_opengl_func_and_load glGetSynciv
	def_opengl_func_and_load glGetInteger64i_v
	def_opengl_func_and_load glGetBufferParameteri64v
	def_opengl_func_and_load glFramebufferTexture
	def_opengl_func_and_load glTexImage2DMultisample
	def_opengl_func_and_load glTexImage3DMultisample
	def_opengl_func_and_load glGetMultisamplefv
	def_opengl_func_and_load glSampleMaski

	def_opengl_func_and_load glBindFragDataLocationIndexed
	def_opengl_func_and_load glGetFragDataIndex
	def_opengl_func_and_load glGenSamplers
	def_opengl_func_and_load glDeleteSamplers
	def_opengl_func_and_load glIsSampler
	def_opengl_func_and_load glBindSampler
	def_opengl_func_and_load glSamplerParameteri
	def_opengl_func_and_load glSamplerParameteriv
	def_opengl_func_and_load glSamplerParameterf
	def_opengl_func_and_load glSamplerParameterfv
	def_opengl_func_and_load glSamplerParameterIiv
	def_opengl_func_and_load glSamplerParameterIuiv
	def_opengl_func_and_load glGetSamplerParameteriv
	def_opengl_func_and_load glGetSamplerParameterIiv
	def_opengl_func_and_load glGetSamplerParameterfv
	def_opengl_func_and_load glGetSamplerParameterIuiv
	def_opengl_func_and_load glQueryCounter
	def_opengl_func_and_load glGetQueryObjecti64v
	def_opengl_func_and_load glGetQueryObjectui64v
	def_opengl_func_and_load glVertexAttribDivisor
	def_opengl_func_and_load glVertexAttribP1ui
	def_opengl_func_and_load glVertexAttribP1uiv
	def_opengl_func_and_load glVertexAttribP2ui
	def_opengl_func_and_load glVertexAttribP2uiv
	def_opengl_func_and_load glVertexAttribP3ui
	def_opengl_func_and_load glVertexAttribP3uiv
	def_opengl_func_and_load glVertexAttribP4ui
	def_opengl_func_and_load glVertexAttribP4uiv
	def_opengl_func_and_load glVertexP2ui
	def_opengl_func_and_load glVertexP2uiv
	def_opengl_func_and_load glVertexP3ui
	def_opengl_func_and_load glVertexP3uiv
	def_opengl_func_and_load glVertexP4ui
	def_opengl_func_and_load glVertexP4uiv
	def_opengl_func_and_load glTexCoordP1ui
	def_opengl_func_and_load glTexCoordP1uiv
	def_opengl_func_and_load glTexCoordP2ui
	def_opengl_func_and_load glTexCoordP2uiv
	def_opengl_func_and_load glTexCoordP3ui
	def_opengl_func_and_load glTexCoordP3uiv
	def_opengl_func_and_load glTexCoordP4ui
	def_opengl_func_and_load glTexCoordP4uiv
	def_opengl_func_and_load glMultiTexCoordP1ui
	def_opengl_func_and_load glMultiTexCoordP1uiv
	def_opengl_func_and_load glMultiTexCoordP2ui
	def_opengl_func_and_load glMultiTexCoordP2uiv
	def_opengl_func_and_load glMultiTexCoordP3ui
	def_opengl_func_and_load glMultiTexCoordP3uiv
	def_opengl_func_and_load glMultiTexCoordP4ui
	def_opengl_func_and_load glMultiTexCoordP4uiv
	def_opengl_func_and_load glNormalP3ui
	def_opengl_func_and_load glNormalP3uiv
	def_opengl_func_and_load glColorP3ui
	def_opengl_func_and_load glColorP3uiv
	def_opengl_func_and_load glColorP4ui
	def_opengl_func_and_load glColorP4uiv
	def_opengl_func_and_load glSecondaryColorP3ui
	def_opengl_func_and_load glSecondaryColorP3uiv

.exit:
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
