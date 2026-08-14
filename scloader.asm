%include "loaddll.inc"
%include "avlbst.inc"
%include "assets.inc"
%include "pool.inc"
%include "shader.inc"
%include "math.inc"
%include "tls.inc"

%macro DefImp 1
.%1 resb 5
%endmacro

%macro DefExp 1
.%1 resd 1
%endmacro

%include "shellcode.inc"

struc SCHead
.imports:
	InstImpFull

.exports:
	InstExp

.last_ptr:
	.size equ $ - SCHead
endstruc

segment .bss
extern _ShellOldProtect
_ShellOldProtect resd 1

extern _ShellcodeBase
_ShellcodeBase resd 1

extern _ShellcodeSize
_ShellcodeSize resd 1

extern _WGLFuncWritePos
_WGLFuncWritePos resd 1

extern _FirstDelayLoadFunc
extern _NumDelayLoadFuncs

extern _FirstImmeLoadFunc
extern _NumImmeLoadFuncs

extern _FirstGLFunc
extern _NumGLFuncs

%unmacro DefImp 1
%unmacro DefExp 1

%macro DefExp 1
	.%1 resd 1
%endmacro

%macro DefImp 1
	.%1 dd %1
%endmacro

extern _ShellcodeEAT
_ShellcodeEAT:
	InstExp
	.num_fps equ ($ - _ShellcodeEAT) / 4

segment .rdata
_RelocShellcodeIAT:
	InstImp
	.num_fps equ ($ - _RelocShellcodeIAT) / 4

DefFunc _GetNumProcessors
	FrameBegin
	mov eax, [_SystemInfo + SYSTEM_INFO.dwNumberOfProcessors]
	FrameEnd
	ret

DefFunc _CheckSSE3
	FrameBegin
	mov eax, [_HaveSSE3]
	FrameEnd
	ret

DefFunc _CheckSSE41
	FrameBegin
	mov eax, [_HaveSSE41]
	FrameEnd
	ret

DefFunc _GetDebugConsoleBuffer
	FrameBegin
	mov eax, [_DebugConsoleBuffer]
	FrameEnd
	ret

DefFunc _GetDebugMsgBuffer
	FrameBegin
	mov eax, [_DebugMsgBuffer]
	FrameEnd
	ret

DefFunc _LoadShellcode
	FrameBegin ebx, esi, edi

	AssetsQuery `shellcode.bin`, _ShellcodeSize
	mov ebx, eax
	mov [_ShellcodeBase], eax

	mov ecx, _RelocShellcodeIAT.num_fps
	mov esi, _RelocShellcodeIAT
	lea edi, [ebx + SCHead.imports + 1]
	lea edx, [edi + 4]
.setup_iat:
	lodsd
	sub eax, edx
	stosd
	inc edi
	add edx, 5
	dec ecx
	jnz .setup_iat

	mov esi, _FirstImmeLoadFunc
	mov ecx, _NumImmeLoadFuncs
	call .setup_iat_delay_load_api

	mov esi, _FirstDelayLoadFunc
	mov ecx, _NumDelayLoadFuncs
	call .setup_iat_delay_load_api

	mov [_WGLFuncWritePos], edi

	lea esi, [ebx + SCHead.exports]
	mov edi, _ShellcodeEAT
	mov ecx, _ShellcodeEAT.num_fps
.setup_eat:
	lodsd
	add eax, ebx
	stosd
	dec ecx
	jnz .setup_eat

	invoke_dll_stdcall VirtualProtect, ebx, [_ShellcodeSize], PAGE_EXECUTE_READWRITE, _ShellOldProtect
	invoke_cdecl _ShellcodeInit
	mov eax, ebx
	FrameEnd
	ret
.setup_iat_delay_load_api:
	lodsd
	test eax, eax
	jz .nullptr
	jmp .after_get_offset
.nullptr:
	dec eax
.after_get_offset:
	sub eax, edx
	stosd
	inc edi
	add edx, 5
	dec ecx
	jnz .setup_iat_delay_load_api
	ret

DefFunc _ImportOpenGLFuncsToShellcode
	FrameBegin ebx, esi, edi
	DefVars %$OldProtect

	mov ecx, _NumGLFuncs
	mov esi, _FirstGLFunc
	mov edi, [_WGLFuncWritePos]
	lea edx, [edi + 4]
.loop_import:
	lodsd
	test eax, eax
	jz .nullptr
	jmp .after_get_offset
.nullptr:
	mov eax, .bad
.after_get_offset:
	sub eax, edx
	stosd
	inc edi
	add edx, 5
	dec ecx
	jnz .loop_import

	FrameEnd
	ret
.bad:
	int3
	jmp .bad

DefFunc _UnloadShellcode
	FrameBegin
	DefVars %$OldProtect

	invoke_dll_stdcall VirtualProtect, [_ShellcodeBase], [_ShellcodeSize], [_ShellOldProtect], & %$OldProtect
	xor eax, eax
	mov [_ShellcodeBase], eax
	mov [_ShellcodeSize], eax

	FrameEnd
	ret

%macro RedirCall 1
	DefFunc %1
	jmp [_ShellcodeEAT.%1]
%endmacro

%unmacro DefExp 1
%define DefExp RedirCall

InstExp
