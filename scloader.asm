%include "loaddll.inc"
%include "assets.inc"
%include "pool.inc"
%include "shader.inc"
%include "math.inc"

%macro DefImp 1
.%1 resb 5
%endmacro

%macro DefExp 1
.%1 resd 1
%endmacro

%include "shellcode.inc"

struc SCHead
.imports:
	InstImp
	%include 'scfuncs.tmp'

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

extern _FirstDelayLoadFunc
extern _NumDelayLoadFunc

%unmacro DefImp 1
%unmacro DefExp 1

%macro DefExp 1
	.%1 resd 1
%endmacro

%macro DefImp 1
	.%1 dd %1
%endmacro

extern _SCEAT
_SCEAT:
	InstExp
	.num_fps equ ($ - _SCEAT) / 4

segment .rdata
_RelocSCIAT:
	InstImp
	.num_fps equ ($ - _RelocSCIAT) / 4

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

DefFunc _LoadShellcode
	FrameBegin ebx, esi, edi

	AssetsQuery `shellcode.bin`, _ShellcodeSize
	mov ebx, eax
	mov [_ShellcodeBase], eax

	mov ecx, _RelocSCIAT.num_fps
	mov esi, _RelocSCIAT
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

	mov esi, _FirstDelayLoadFunc
	mov ecx, _NumDelayLoadFunc
.setup_iat_delay_load_api:
	lodsd
	test eax, eax
	jz .nullptr
	sub eax, edx
	jmp .after_get_offset
.nullptr:
	dec eax
.after_get_offset:
	stosd
	inc edi
	add edx, 5
	dec ecx
	jnz .setup_iat_delay_load_api

	lea esi, [ebx + SCHead.exports]
	mov edi, _SCEAT
	mov ecx, _SCEAT.num_fps
.setup_eat:
	lodsd
	add eax, ebx
	stosd
	dec ecx
	jnz .setup_eat

	invoke_dll_stdcall VirtualProtect, ebx, [_ShellcodeSize], PAGE_EXECUTE_READWRITE, _ShellOldProtect
	mov eax, ebx
	FrameEnd
	ret

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
	jmp [_SCEAT.%1]
%endmacro

RedirCall _CreateBitMap
RedirCall _DuplicateBitMap
RedirCall _DestroyBitMap
RedirCall _GetBitmapPixelAddress
RedirCall _SampleFloatMap
RedirCall _BatchAdd
RedirCall _BatchBias
RedirCall _BatchCurve
RedirCall _BatchMax
RedirCall _BatchMin
RedirCall _FloatMapNextMip
RedirCall _ConeMapGen
RedirCall _VectorMultMatrix
RedirCall _MatrixMultiply
RedirCall _MatrixMultiplyTo
RedirCall _MatrixProjection
RedirCall _MatrixRotationEuler
RedirCall _MatrixEulerTranslated
RedirCall _MatrixViewEuler
RedirCall _MatrixTranspose
RedirCall _FloatMapApplyGain
RedirCall _CreateSeedVector
RedirCall _CreatePerlinMap2D
RedirCall _ConvertPerlinMapToAltitude
RedirCall _GenPerlinAltitude
RedirCall _AccumulateFloatMap
RedirCall _GenMultiLayerPerlinAltitude
RedirCall _FloatMapCurve
RedirCall _FloatMapGetMinValue
RedirCall _FloatMapGetMaxValue
RedirCall _VectorCross
RedirCall _VectorDot
RedirCall _VectorLength
RedirCall _VectorNormal
RedirCall _RaymarchTerrainAltitude
