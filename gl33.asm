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

segment .bss
extern _FirstGLFunc
_FirstGLFunc:
dll_func_group_start_without_name WGLFunc
%include "wglfuncs.tmp"
dll_func_group_end WGLFunc

dll_func_group_start_without_name GL33Func
%include "gl33funcs.tmp"
dll_func_group_end GL33Func

segment .bss
extern _NumGLFuncs
_NumGLFuncs equ ($ - _FirstGLFunc) / 4

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
	FrameBegin
	NameParams %$FuncPtr

	mov eax, %$FuncPtr
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
	FrameBegin
	NameParams %$FuncName
	invoke_dll_cdecl strcpy, [_FuncNameBuf], %$FuncName
	invoke_dll_stdcall GetProcAddress, [_addr_of_OpenGL32], [_FuncNameBuf]
	test eax, eax
	jnz .end
	invoke_dll_stdcall wglGetProcAddress, [_FuncNameBuf]
	invoke_cdecl _CheckOpenGLProcAddress, eax
.end:
	FrameEnd
	ret

DefFunc _InitGL33
	FrameBegin esi, edi
	DefVars %$RegHome, %$AssetLength

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
	AssetsQuery 'assets\GL33FUNC', &%$AssetLength
	mov esi, eax
	invoke_cdecl _NLtoNUL, eax, %$AssetLength
	mov ecx, (_LastGL33FuncAddr - _FirstGL33FuncAddr) / 4
	mov edi, _FirstGL33FuncAddr
.loop_init_gl:
	mov %$RegHome, ecx
	invoke_cdecl _GetGLProcAddress, esi
	stosd
	call _NextString
	mov ecx, %$RegHome
	loop .loop_init_gl

	invoke_dll_cdecl strlen, [_OpenGLNullFunctions]
	test eax, eax
	jz .end

	invoke_dll_cdecl strcat, [_OpenGLNullFunctions], _TheseFunc
	invoke_dll_stdcall MessageBoxA, [_hWnd], [_OpenGLNullFunctions], 0, 0

.end:
	xor eax, eax
	inc eax

.exit:
	mov %$RegHome, eax
	invoke_cdecl _free, [_OpenGLNullFunctions]
	invoke_cdecl _free, [_FailInfoBuffer]
	invoke_cdecl _free, [_FuncNameBuf]
	xor eax, eax
	mov [_OpenGLNullFunctions], eax
	mov eax, %$RegHome
	FrameEnd
	ret

DefFunc _DeInitGL33
	FrameBegin

	xor eax, eax
	invoke_dll_stdcall wglMakeCurrent, eax, eax
	invoke_dll_stdcall wglDeleteContext, [_hGLRC]
	xor eax, eax
	mov dword[_hGLRC], eax
	FrameEnd
	ret
