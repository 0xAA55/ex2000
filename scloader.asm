%include "loaddll.inc"
%include "shellcode.inc"
%include "assets.inc"

segment .bss
extern _ShellOldProtect
_ShellOldProtect resd 1

extern _ShellcodeBase
_ShellcodeBase resd 1

extern _ShellcodeSize
_ShellcodeSize resd 1

extern _FirstDelayLoadFunc
extern _NumDelayLoadFunc

extern _SCEAT
_SCEAT:
	.CreateBitMap resd 1
	.DestroyBitMap resd 1
	.GetBitmapPixelAddress resd 1
	.SampleFloatMap resd 1
	.num_fps equ ($ - _SCEAT) / 4

segment .rdata
_RelocSCIAT:
	.malloc dd _malloc
	.calloc dd _calloc
	.realloc dd _realloc
	.free dd _free
	.aligned_malloc dd _aligned_malloc
	.aligned_free dd _aligned_free
	.AssetsQuery dd _AssetsQuery
	.num_fps equ ($ - _RelocSCIAT) / 4

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
	sub eax, edx
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

DefFunc _CreateBitMap
	jmp [_SCEAT.CreateBitMap]

DefFunc _DestroyBitMap
	jmp [_SCEAT.DestroyBitMap]

DefFunc _GetBitmapPixelAddress
	jmp [_SCEAT.GetBitmapPixelAddress]

DefFunc _SampleFloatMap
	jmp [_SCEAT.SampleFloatMap]

