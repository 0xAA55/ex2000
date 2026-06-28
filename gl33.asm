%include "loaddll.inc"
%include "gl33.inc"
%include "assets.inc"

extern _NextString

extern _hWnd
extern _hDC

segment .bss
extern _hGLRC
_hGLRC resd 1

extern _OpenGL_Vendor
extern _OpenGL_Renderer
extern _OpenGL_Version
extern _OpenGL_Is_ES
extern _OpenGL_Ver_Major
extern _OpenGL_Ver_Minor
extern _OpenGL_Ver_Release
extern _FailReason
extern _OpenGLNullFunctions
extern _FailInfoBuffer
extern _FuncNameBuf
_OpenGL_Vendor resd 1
_OpenGL_Renderer resd 1
_OpenGL_Version resd 1
_OpenGL_Is_ES resd 1
_OpenGL_Ver_Major resd 1
_OpenGL_Ver_Minor resd 1
_OpenGL_Ver_Release resd 1
_FailReason resd 1
_OpenGLNullFunctions resd 1
_FailInfoBuffer resd 1
_FuncNameBuf resd 1 ; The buffer to store the decoded function name

segment .rdata
extern _PFD
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

extern _ParseFailText
_ParseFailText db "Unable to parse OpenGL version:", 0xd, 0xa, 0
extern _ParseFailBecauseNondigit
extern _ParseFailBecauseDotExpected
extern _ParseFailBecauseUnknown
_ParseFailBecauseNondigit db 0xd, 0xa, "Unexpected non-digit", 0
_ParseFailBecauseDotExpected db 0xd, 0xa, "Dot '.' expected", 0
_ParseFailBecauseUnknown db 0xd, 0xa, "Unknown error", 0

extern _OpenGL_ES_String
_OpenGL_ES_String db "OpenGL ES "
.size equ $ - _OpenGL_ES_String

_FailedToGet db "Failed to fetch OpenGL function pointers:"
_NewLine db 0xd, 0xa, 0
_TheseFunc db "These functions are unavailable.", 0

def_dll_func_alias wglSwapInterval, "wglSwapIntervalEXT"

dll_func_group_start_without_name WGLFunc
def_dll_func_addr wglGetProcAddress
def_dll_func_addr wglCreateContext
def_dll_func_addr wglDeleteContext
def_dll_func_addr wglMakeCurrent
def_dll_func_addr wglSwapBuffers
def_dll_func_addr glCullFace
def_dll_func_addr glFrontFace
def_dll_func_addr glHint
def_dll_func_addr glLineWidth
def_dll_func_addr glPointSize
def_dll_func_addr glPolygonMode
def_dll_func_addr glScissor
def_dll_func_addr glTexParameterf
def_dll_func_addr glTexParameterfv
def_dll_func_addr glTexParameteri
def_dll_func_addr glTexParameteriv
def_dll_func_addr glTexImage1D
def_dll_func_addr glTexImage2D
def_dll_func_addr glDrawBuffer
def_dll_func_addr glClear
def_dll_func_addr glClearColor
def_dll_func_addr glClearStencil
def_dll_func_addr glClearDepth
def_dll_func_addr glStencilMask
def_dll_func_addr glColorMask
def_dll_func_addr glDepthMask
def_dll_func_addr glDisable
def_dll_func_addr glEnable
def_dll_func_addr glFinish
def_dll_func_addr glFlush
def_dll_func_addr glBlendFunc
def_dll_func_addr glLogicOp
def_dll_func_addr glStencilFunc
def_dll_func_addr glStencilOp
def_dll_func_addr glDepthFunc
def_dll_func_addr glPixelStoref
def_dll_func_addr glPixelStorei
def_dll_func_addr glReadBuffer
def_dll_func_addr glReadPixels
def_dll_func_addr glGetBooleanv
def_dll_func_addr glGetDoublev
def_dll_func_addr glGetError
def_dll_func_addr glGetFloatv
def_dll_func_addr glGetIntegerv
def_dll_func_addr glGetString
def_dll_func_addr glGetTexImage
def_dll_func_addr glGetTexParameterfv
def_dll_func_addr glGetTexParameteriv
def_dll_func_addr glGetTexLevelParameterfv
def_dll_func_addr glGetTexLevelParameteriv
def_dll_func_addr glIsEnabled
def_dll_func_addr glDepthRange
def_dll_func_addr glViewport
dll_func_group_end WGLFunc

dll_func_group_start_without_name GL33Func
def_dll_func_addr glDrawArrays
def_dll_func_addr glDrawElements
def_dll_func_addr glGetPointerv
def_dll_func_addr glPolygonOffset
def_dll_func_addr glCopyTexImage1D
def_dll_func_addr glCopyTexImage2D
def_dll_func_addr glCopyTexSubImage1D
def_dll_func_addr glCopyTexSubImage2D
def_dll_func_addr glTexSubImage1D
def_dll_func_addr glTexSubImage2D
def_dll_func_addr glBindTexture
def_dll_func_addr glDeleteTextures
def_dll_func_addr glGenTextures
def_dll_func_addr glDrawRangeElements
def_dll_func_addr glTexImage3D
def_dll_func_addr glTexSubImage3D
def_dll_func_addr glCopyTexSubImage3D
def_dll_func_addr glActiveTexture
def_dll_func_addr glSampleCoverage
def_dll_func_addr glCompressedTexImage3D
def_dll_func_addr glCompressedTexImage2D
def_dll_func_addr glCompressedTexImage1D
def_dll_func_addr glCompressedTexSubImage3D
def_dll_func_addr glCompressedTexSubImage2D
def_dll_func_addr glCompressedTexSubImage1D
def_dll_func_addr glGetCompressedTexImage
def_dll_func_addr glClientActiveTexture
def_dll_func_addr glMultiTexCoord1d
def_dll_func_addr glMultiTexCoord1dv
def_dll_func_addr glMultiTexCoord1f
def_dll_func_addr glMultiTexCoord1fv
def_dll_func_addr glMultiTexCoord1i
def_dll_func_addr glMultiTexCoord1iv
def_dll_func_addr glMultiTexCoord1s
def_dll_func_addr glMultiTexCoord1sv
def_dll_func_addr glMultiTexCoord2d
def_dll_func_addr glMultiTexCoord2dv
def_dll_func_addr glMultiTexCoord2f
def_dll_func_addr glMultiTexCoord2fv
def_dll_func_addr glMultiTexCoord2i
def_dll_func_addr glMultiTexCoord2iv
def_dll_func_addr glMultiTexCoord2s
def_dll_func_addr glMultiTexCoord2sv
def_dll_func_addr glMultiTexCoord3d
def_dll_func_addr glMultiTexCoord3dv
def_dll_func_addr glMultiTexCoord3f
def_dll_func_addr glMultiTexCoord3fv
def_dll_func_addr glMultiTexCoord3i
def_dll_func_addr glMultiTexCoord3iv
def_dll_func_addr glMultiTexCoord3s
def_dll_func_addr glMultiTexCoord3sv
def_dll_func_addr glMultiTexCoord4d
def_dll_func_addr glMultiTexCoord4dv
def_dll_func_addr glMultiTexCoord4f
def_dll_func_addr glMultiTexCoord4fv
def_dll_func_addr glMultiTexCoord4i
def_dll_func_addr glMultiTexCoord4iv
def_dll_func_addr glMultiTexCoord4s
def_dll_func_addr glMultiTexCoord4sv
def_dll_func_addr glLoadTransposeMatrixf
def_dll_func_addr glLoadTransposeMatrixd
def_dll_func_addr glMultTransposeMatrixf
def_dll_func_addr glMultTransposeMatrixd
def_dll_func_addr glBlendFuncSeparate
def_dll_func_addr glMultiDrawArrays
def_dll_func_addr glMultiDrawElements
def_dll_func_addr glPointParameterf
def_dll_func_addr glPointParameterfv
def_dll_func_addr glPointParameteri
def_dll_func_addr glPointParameteriv
def_dll_func_addr glFogCoordf
def_dll_func_addr glFogCoordfv
def_dll_func_addr glFogCoordd
def_dll_func_addr glFogCoorddv
def_dll_func_addr glFogCoordPointer
def_dll_func_addr glSecondaryColor3b
def_dll_func_addr glSecondaryColor3bv
def_dll_func_addr glSecondaryColor3d
def_dll_func_addr glSecondaryColor3dv
def_dll_func_addr glSecondaryColor3f
def_dll_func_addr glSecondaryColor3fv
def_dll_func_addr glSecondaryColor3i
def_dll_func_addr glSecondaryColor3iv
def_dll_func_addr glSecondaryColor3s
def_dll_func_addr glSecondaryColor3sv
def_dll_func_addr glSecondaryColor3ub
def_dll_func_addr glSecondaryColor3ubv
def_dll_func_addr glSecondaryColor3ui
def_dll_func_addr glSecondaryColor3uiv
def_dll_func_addr glSecondaryColor3us
def_dll_func_addr glSecondaryColor3usv
def_dll_func_addr glSecondaryColorPointer
def_dll_func_addr glWindowPos2d
def_dll_func_addr glWindowPos2dv
def_dll_func_addr glWindowPos2f
def_dll_func_addr glWindowPos2fv
def_dll_func_addr glWindowPos2i
def_dll_func_addr glWindowPos2iv
def_dll_func_addr glWindowPos2s
def_dll_func_addr glWindowPos2sv
def_dll_func_addr glWindowPos3d
def_dll_func_addr glWindowPos3dv
def_dll_func_addr glWindowPos3f
def_dll_func_addr glWindowPos3fv
def_dll_func_addr glWindowPos3i
def_dll_func_addr glWindowPos3iv
def_dll_func_addr glWindowPos3s
def_dll_func_addr glWindowPos3sv
def_dll_func_addr glBlendColor
def_dll_func_addr glBlendEquation
def_dll_func_addr glGenQueries
def_dll_func_addr glDeleteQueries
def_dll_func_addr glIsQuery
def_dll_func_addr glBeginQuery
def_dll_func_addr glEndQuery
def_dll_func_addr glGetQueryiv
def_dll_func_addr glGetQueryObjectiv
def_dll_func_addr glGetQueryObjectuiv
def_dll_func_addr glBindBuffer
def_dll_func_addr glDeleteBuffers
def_dll_func_addr glGenBuffers
def_dll_func_addr glIsBuffer
def_dll_func_addr glBufferData
def_dll_func_addr glBufferSubData
def_dll_func_addr glGetBufferSubData
def_dll_func_addr glMapBuffer
def_dll_func_addr glUnmapBuffer
def_dll_func_addr glGetBufferParameteriv
def_dll_func_addr glGetBufferPointerv
def_dll_func_addr glBlendEquationSeparate
def_dll_func_addr glDrawBuffers
def_dll_func_addr glStencilOpSeparate
def_dll_func_addr glStencilFuncSeparate
def_dll_func_addr glStencilMaskSeparate
def_dll_func_addr glAttachShader
def_dll_func_addr glBindAttribLocation
def_dll_func_addr glCompileShader
def_dll_func_addr glCreateProgram
def_dll_func_addr glCreateShader
def_dll_func_addr glDeleteProgram
def_dll_func_addr glDeleteShader
def_dll_func_addr glDetachShader
def_dll_func_addr glDisableVertexAttribArray
def_dll_func_addr glEnableVertexAttribArray
def_dll_func_addr glGetActiveAttrib
def_dll_func_addr glGetActiveUniform
def_dll_func_addr glGetAttachedShaders
def_dll_func_addr glGetAttribLocation
def_dll_func_addr glGetProgramiv
def_dll_func_addr glGetProgramInfoLog
def_dll_func_addr glGetShaderiv
def_dll_func_addr glGetShaderInfoLog
def_dll_func_addr glGetShaderSource
def_dll_func_addr glGetUniformLocation
def_dll_func_addr glGetUniformfv
def_dll_func_addr glGetUniformiv
def_dll_func_addr glGetVertexAttribdv
def_dll_func_addr glGetVertexAttribfv
def_dll_func_addr glGetVertexAttribiv
def_dll_func_addr glGetVertexAttribPointerv
def_dll_func_addr glIsProgram
def_dll_func_addr glIsShader
def_dll_func_addr glLinkProgram
def_dll_func_addr glShaderSource
def_dll_func_addr glUseProgram
def_dll_func_addr glUniform1f
def_dll_func_addr glUniform2f
def_dll_func_addr glUniform3f
def_dll_func_addr glUniform4f
def_dll_func_addr glUniform1i
def_dll_func_addr glUniform2i
def_dll_func_addr glUniform3i
def_dll_func_addr glUniform4i
def_dll_func_addr glUniform1fv
def_dll_func_addr glUniform2fv
def_dll_func_addr glUniform3fv
def_dll_func_addr glUniform4fv
def_dll_func_addr glUniform1iv
def_dll_func_addr glUniform2iv
def_dll_func_addr glUniform3iv
def_dll_func_addr glUniform4iv
def_dll_func_addr glUniformMatrix2fv
def_dll_func_addr glUniformMatrix3fv
def_dll_func_addr glUniformMatrix4fv
def_dll_func_addr glValidateProgram
def_dll_func_addr glVertexAttrib1d
def_dll_func_addr glVertexAttrib1dv
def_dll_func_addr glVertexAttrib1f
def_dll_func_addr glVertexAttrib1fv
def_dll_func_addr glVertexAttrib1s
def_dll_func_addr glVertexAttrib1sv
def_dll_func_addr glVertexAttrib2d
def_dll_func_addr glVertexAttrib2dv
def_dll_func_addr glVertexAttrib2f
def_dll_func_addr glVertexAttrib2fv
def_dll_func_addr glVertexAttrib2s
def_dll_func_addr glVertexAttrib2sv
def_dll_func_addr glVertexAttrib3d
def_dll_func_addr glVertexAttrib3dv
def_dll_func_addr glVertexAttrib3f
def_dll_func_addr glVertexAttrib3fv
def_dll_func_addr glVertexAttrib3s
def_dll_func_addr glVertexAttrib3sv
def_dll_func_addr glVertexAttrib4Nbv
def_dll_func_addr glVertexAttrib4Niv
def_dll_func_addr glVertexAttrib4Nsv
def_dll_func_addr glVertexAttrib4Nub
def_dll_func_addr glVertexAttrib4Nubv
def_dll_func_addr glVertexAttrib4Nuiv
def_dll_func_addr glVertexAttrib4Nusv
def_dll_func_addr glVertexAttrib4bv
def_dll_func_addr glVertexAttrib4d
def_dll_func_addr glVertexAttrib4dv
def_dll_func_addr glVertexAttrib4f
def_dll_func_addr glVertexAttrib4fv
def_dll_func_addr glVertexAttrib4iv
def_dll_func_addr glVertexAttrib4s
def_dll_func_addr glVertexAttrib4sv
def_dll_func_addr glVertexAttrib4ubv
def_dll_func_addr glVertexAttrib4uiv
def_dll_func_addr glVertexAttrib4usv
def_dll_func_addr glVertexAttribPointer
def_dll_func_addr glUniformMatrix2x3fv
def_dll_func_addr glUniformMatrix3x2fv
def_dll_func_addr glUniformMatrix2x4fv
def_dll_func_addr glUniformMatrix4x2fv
def_dll_func_addr glUniformMatrix3x4fv
def_dll_func_addr glUniformMatrix4x3fv
def_dll_func_addr glColorMaski
def_dll_func_addr glGetBooleani_v
def_dll_func_addr glGetIntegeri_v
def_dll_func_addr glEnablei
def_dll_func_addr glDisablei
def_dll_func_addr glIsEnabledi
def_dll_func_addr glBeginTransformFeedback
def_dll_func_addr glEndTransformFeedback
def_dll_func_addr glBindBufferRange
def_dll_func_addr glBindBufferBase
def_dll_func_addr glTransformFeedbackVaryings
def_dll_func_addr glGetTransformFeedbackVarying
def_dll_func_addr glClampColor
def_dll_func_addr glBeginConditionalRender
def_dll_func_addr glEndConditionalRender
def_dll_func_addr glVertexAttribIPointer
def_dll_func_addr glGetVertexAttribIiv
def_dll_func_addr glGetVertexAttribIuiv
def_dll_func_addr glVertexAttribI1i
def_dll_func_addr glVertexAttribI2i
def_dll_func_addr glVertexAttribI3i
def_dll_func_addr glVertexAttribI4i
def_dll_func_addr glVertexAttribI1ui
def_dll_func_addr glVertexAttribI2ui
def_dll_func_addr glVertexAttribI3ui
def_dll_func_addr glVertexAttribI4ui
def_dll_func_addr glVertexAttribI1iv
def_dll_func_addr glVertexAttribI2iv
def_dll_func_addr glVertexAttribI3iv
def_dll_func_addr glVertexAttribI4iv
def_dll_func_addr glVertexAttribI1uiv
def_dll_func_addr glVertexAttribI2uiv
def_dll_func_addr glVertexAttribI3uiv
def_dll_func_addr glVertexAttribI4uiv
def_dll_func_addr glVertexAttribI4bv
def_dll_func_addr glVertexAttribI4sv
def_dll_func_addr glVertexAttribI4ubv
def_dll_func_addr glVertexAttribI4usv
def_dll_func_addr glGetUniformuiv
def_dll_func_addr glBindFragDataLocation
def_dll_func_addr glGetFragDataLocation
def_dll_func_addr glUniform1ui
def_dll_func_addr glUniform2ui
def_dll_func_addr glUniform3ui
def_dll_func_addr glUniform4ui
def_dll_func_addr glUniform1uiv
def_dll_func_addr glUniform2uiv
def_dll_func_addr glUniform3uiv
def_dll_func_addr glUniform4uiv
def_dll_func_addr glTexParameterIiv
def_dll_func_addr glTexParameterIuiv
def_dll_func_addr glGetTexParameterIiv
def_dll_func_addr glGetTexParameterIuiv
def_dll_func_addr glClearBufferiv
def_dll_func_addr glClearBufferuiv
def_dll_func_addr glClearBufferfv
def_dll_func_addr glClearBufferfi
def_dll_func_addr glGetStringi
def_dll_func_addr glIsRenderbuffer
def_dll_func_addr glBindRenderbuffer
def_dll_func_addr glDeleteRenderbuffers
def_dll_func_addr glGenRenderbuffers
def_dll_func_addr glRenderbufferStorage
def_dll_func_addr glGetRenderbufferParameteriv
def_dll_func_addr glIsFramebuffer
def_dll_func_addr glBindFramebuffer
def_dll_func_addr glDeleteFramebuffers
def_dll_func_addr glGenFramebuffers
def_dll_func_addr glCheckFramebufferStatus
def_dll_func_addr glFramebufferTexture1D
def_dll_func_addr glFramebufferTexture2D
def_dll_func_addr glFramebufferTexture3D
def_dll_func_addr glFramebufferRenderbuffer
def_dll_func_addr glGetFramebufferAttachmentParameteriv
def_dll_func_addr glGenerateMipmap
def_dll_func_addr glBlitFramebuffer
def_dll_func_addr glRenderbufferStorageMultisample
def_dll_func_addr glFramebufferTextureLayer
def_dll_func_addr glMapBufferRange
def_dll_func_addr glFlushMappedBufferRange
def_dll_func_addr glBindVertexArray
def_dll_func_addr glDeleteVertexArrays
def_dll_func_addr glGenVertexArrays
def_dll_func_addr glIsVertexArray
def_dll_func_addr glDrawArraysInstanced
def_dll_func_addr glDrawElementsInstanced
def_dll_func_addr glTexBuffer
def_dll_func_addr glPrimitiveRestartIndex
def_dll_func_addr glCopyBufferSubData
def_dll_func_addr glGetUniformIndices
def_dll_func_addr glGetActiveUniformsiv
def_dll_func_addr glGetActiveUniformName
def_dll_func_addr glGetUniformBlockIndex
def_dll_func_addr glGetActiveUniformBlockiv
def_dll_func_addr glGetActiveUniformBlockName
def_dll_func_addr glUniformBlockBinding
def_dll_func_addr glDrawElementsBaseVertex
def_dll_func_addr glDrawRangeElementsBaseVertex
def_dll_func_addr glDrawElementsInstancedBaseVertex
def_dll_func_addr glMultiDrawElementsBaseVertex
def_dll_func_addr glProvokingVertex
def_dll_func_addr glFenceSync
def_dll_func_addr glIsSync
def_dll_func_addr glDeleteSync
def_dll_func_addr glClientWaitSync
def_dll_func_addr glWaitSync
def_dll_func_addr glGetInteger64v
def_dll_func_addr glGetSynciv
def_dll_func_addr glGetInteger64i_v
def_dll_func_addr glGetBufferParameteri64v
def_dll_func_addr glFramebufferTexture
def_dll_func_addr glTexImage2DMultisample
def_dll_func_addr glTexImage3DMultisample
def_dll_func_addr glGetMultisamplefv
def_dll_func_addr glSampleMaski
def_dll_func_addr glBindFragDataLocationIndexed
def_dll_func_addr glGetFragDataIndex
def_dll_func_addr glGenSamplers
def_dll_func_addr glDeleteSamplers
def_dll_func_addr glIsSampler
def_dll_func_addr glBindSampler
def_dll_func_addr glSamplerParameteri
def_dll_func_addr glSamplerParameteriv
def_dll_func_addr glSamplerParameterf
def_dll_func_addr glSamplerParameterfv
def_dll_func_addr glSamplerParameterIiv
def_dll_func_addr glSamplerParameterIuiv
def_dll_func_addr glGetSamplerParameteriv
def_dll_func_addr glGetSamplerParameterIiv
def_dll_func_addr glGetSamplerParameterfv
def_dll_func_addr glGetSamplerParameterIuiv
def_dll_func_addr glQueryCounter
def_dll_func_addr glGetQueryObjecti64v
def_dll_func_addr glGetQueryObjectui64v
def_dll_func_addr glVertexAttribDivisor
def_dll_func_addr glVertexAttribP1ui
def_dll_func_addr glVertexAttribP1uiv
def_dll_func_addr glVertexAttribP2ui
def_dll_func_addr glVertexAttribP2uiv
def_dll_func_addr glVertexAttribP3ui
def_dll_func_addr glVertexAttribP3uiv
def_dll_func_addr glVertexAttribP4ui
def_dll_func_addr glVertexAttribP4uiv
def_dll_func_addr glVertexP2ui
def_dll_func_addr glVertexP2uiv
def_dll_func_addr glVertexP3ui
def_dll_func_addr glVertexP3uiv
def_dll_func_addr glVertexP4ui
def_dll_func_addr glVertexP4uiv
def_dll_func_addr glTexCoordP1ui
def_dll_func_addr glTexCoordP1uiv
def_dll_func_addr glTexCoordP2ui
def_dll_func_addr glTexCoordP2uiv
def_dll_func_addr glTexCoordP3ui
def_dll_func_addr glTexCoordP3uiv
def_dll_func_addr glTexCoordP4ui
def_dll_func_addr glTexCoordP4uiv
def_dll_func_addr glMultiTexCoordP1ui
def_dll_func_addr glMultiTexCoordP1uiv
def_dll_func_addr glMultiTexCoordP2ui
def_dll_func_addr glMultiTexCoordP2uiv
def_dll_func_addr glMultiTexCoordP3ui
def_dll_func_addr glMultiTexCoordP3uiv
def_dll_func_addr glMultiTexCoordP4ui
def_dll_func_addr glMultiTexCoordP4uiv
def_dll_func_addr glNormalP3ui
def_dll_func_addr glNormalP3uiv
def_dll_func_addr glColorP3ui
def_dll_func_addr glColorP3uiv
def_dll_func_addr glColorP4ui
def_dll_func_addr glColorP4uiv
def_dll_func_addr glSecondaryColorP3ui
def_dll_func_addr glSecondaryColorP3uiv
dll_func_group_end GL33Func

DefFunc _isdigit_al
	mov dword [_FailReason], _ParseFailBecauseNondigit
	cmp al, '0'
	jb .parse_fail
	cmp al, '9'
	ja .parse_fail
	jmp .end
.parse_fail:
	xor eax, eax
.end:
	ret

DefFunc _CheckOpenGLProcAddress
	FrameBegin 0

	mov eax, Param(0)
	test eax, eax
	jnz .success

	invoke_dll_cdecl strlen, [_OpenGLNullFunctions]
	test eax, eax
	jnz .strcat_fn_name

	invoke_dll_cdecl strcat, [_OpenGLNullFunctions], _FailedToGet

.strcat_fn_name:
	invoke_dll_cdecl strcat, [_OpenGLNullFunctions], [_FuncNameBuf]
	invoke_dll_cdecl strcat, [_OpenGLNullFunctions], _NewLine

	xor eax, eax
.success:
	FrameEnd
	ret

DefFunc _GetGLProcAddress ; Using OpenGL32.dll `wglGetProcAddress`
	FrameBegin 0
	invoke_dll_cdecl strcpy, [_FuncNameBuf], Param(0)
	invoke_dll_stdcall wglGetProcAddress, [_FuncNameBuf]
	invoke_cdecl _CheckOpenGLProcAddress, eax
	FrameEnd
	ret

DefFunc _InitGL33
	FrameBegin 2, esi, edi
	AssignVars EcxHome, AssetLength

	LoadFuncsFromAssets _FirstWGLFuncAddr, [_addr_of_OpenGL32], 'assets\WGLFUNC', (_LastWGLFuncAddr - _FirstWGLFuncAddr) / 4

	invoke_cdecl _malloc, 4096
	mov [_OpenGLNullFunctions], eax
	mov [eax], 0

	invoke_cdecl _malloc, 1024
	mov [_FailInfoBuffer], eax
	mov [eax], 0

	invoke_cdecl _malloc, 1024
	mov [_FuncNameBuf], eax
	mov [eax], 0

	invoke_dll_stdcall wglGetProcAddress, _name_of_wglSwapInterval
	mov [_addr_of_wglSwapInterval], eax

	invoke_dll_stdcall ChoosePixelFormat, [_hDC], _PFD
	invoke_dll_stdcall SetPixelFormat, [_hDC], eax, _PFD
	invoke_dll_stdcall wglCreateContext, [_hDC]
	mov [_hGLRC], eax

	invoke_dll_stdcall wglMakeCurrent, [_hDC], eax
	invoke_dll_stdcall glGetString, GL_VENDOR
	mov [_OpenGL_Vendor], eax
	invoke_dll_stdcall glGetString, GL_RENDERER
	mov [_OpenGL_Renderer], eax
	invoke_dll_stdcall glGetString, GL_VERSION
	mov [_OpenGL_Version], eax

	mov esi, [_OpenGL_Version]
	mov edi, _OpenGL_ES_String
	mov ecx, _OpenGL_ES_String.size
	repz cmpsb
	jnz .parse_version_non_es
	mov dword [_OpenGL_Is_ES], 1
	jmp .parse_version
.parse_fail:
	invoke_dll_cdecl strcpy, [_FailInfoBuffer], _ParseFailText
	invoke_dll_cdecl strcat, [_FailInfoBuffer], [_OpenGL_Version]
	invoke_dll_cdecl strcat, [_FailInfoBuffer], [_FailReason]
	invoke_dll_stdcall MessageBoxA, [_hWnd], [_FailInfoBuffer], 0, 0

	xor eax, eax
	jmp .exit
.parse_version_non_es:
	mov esi, [_OpenGL_Version]
	xor eax, eax
.parse_version:
	lodsb
	call _isdigit_al
	test eax, eax
	jz .parse_fail
	sub al, '0'
	mov [_OpenGL_Ver_Major], eax
	mov dword [_FailReason], _ParseFailBecauseDotExpected
	lodsb
	cmp al, '.'
	jnz .parse_fail
	lodsb
	call _isdigit_al
	test eax, eax
	jz .parse_fail
	sub al, '0'
	mov [_OpenGL_Ver_Minor], eax
	lodsb
	cmp al, ' '
	jz .version_parsed
	mov dword [_FailReason], _ParseFailBecauseDotExpected
	cmp al, '.'
	jnz .parse_fail
	lodsb
	call _isdigit_al
	test eax, eax
	jz .parse_fail
	sub al, '0'
	mov [_OpenGL_Ver_Release], eax

.version_parsed:
	AssetsQuery 'assets\GL33FUNC', &AssetLength
	mov esi, eax
	invoke_cdecl _NLtoNUL, eax, AssetLength
	mov ecx, (_LastGL33FuncAddr - _FirstGL33FuncAddr) / 4
	mov edi, _FirstGL33FuncAddr
.loop_init_gl:
	mov EcxHome, ecx
	invoke_cdecl _GetGLProcAddress, esi
	stosd
	call _NextString
	mov ecx, EcxHome
	loop .loop_init_gl

	invoke_dll_cdecl strlen, [_OpenGLNullFunctions]
	test eax, eax
	jz .end

	invoke_dll_cdecl strcat, [_OpenGLNullFunctions], _TheseFunc
	invoke_dll_stdcall MessageBoxA, [_hWnd], [_OpenGLNullFunctions], 0, 0

.end:
	mov eax, 1

.exit:
	mov Variable(0), eax
	invoke_cdecl _free, [_OpenGLNullFunctions]
	invoke_cdecl _free, [_FailInfoBuffer]
	invoke_cdecl _free, [_FuncNameBuf]
	xor eax, eax
	mov [_OpenGLNullFunctions], eax
	mov eax, Variable(0)
	FrameEnd
	ret

DefFunc _DeInitGL33
	FrameBegin 0

	xor eax, eax
	invoke_dll_stdcall wglMakeCurrent, eax, eax
	invoke_dll_stdcall wglDeleteContext, [_hGLRC]
	xor eax, eax
	mov dword[_hGLRC], eax
	FrameEnd
	ret
