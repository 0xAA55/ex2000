%include "loaddll.inc"
%include "shellcode.inc"
%include "assets.inc"
%include "pool.inc"

segment .bss
extern _ShellOldProtect
_ShellOldProtect resd 1

extern _ShellcodeBase
_ShellcodeBase resd 1

extern _ShellcodeSize
_ShellcodeSize resd 1

extern _FirstDelayLoadFunc
extern _NumDelayLoadFunc

%macro DefImpSC 1
	.%1 resd 1
%endmacro

%macro DefExpSC 1
	.%1 dd %1
%endmacro

extern _SCEAT
_SCEAT:
	DefImpSC _CreateBitMap
	DefImpSC _DestroyBitMap
	DefImpSC _GetBitmapPixelAddress
	DefImpSC _SampleFloatMap
	DefImpSC _BatchAdd
	DefImpSC _BatchBias
	DefImpSC _BatchCurve
	DefImpSC _BatchMax
	DefImpSC _BatchMin
	DefImpSC _FloatMapNextMip
	DefImpSC _ConeMapGen
	DefImpSC _VectorMultMatrix
	DefImpSC _MatrixMultiply
	DefImpSC _MatrixMultiplyTo
	DefImpSC _MatrixProjection
	DefImpSC _MatrixRotationEuler
	DefImpSC _MatrixTranspose
	DefImpSC _FloatMapApplyGain
	.num_fps equ ($ - _SCEAT) / 4

segment .rdata
_RelocSCIAT:
	DefExpSC _malloc
	DefExpSC _calloc
	DefExpSC _realloc
	DefExpSC _free
	DefExpSC _aligned_malloc
	DefExpSC _aligned_free
	DefExpSC _AssetsQuery
	DefExpSC _PoolRun
	DefExpSC _GetNumProcessors
	.num_fps equ ($ - _RelocSCIAT) / 4

DefFunc _GetNumProcessors
	FrameBegin
	mov eax, [_SystemInfo + SYSTEM_INFO.dwNumberOfProcessors]
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
RedirCall _MatrixTranspose
RedirCall _FloatMapApplyGain
