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
	._CreateBitMap resd 1
	._DestroyBitMap resd 1
	._GetBitmapPixelAddress resd 1
	._SampleFloatMap resd 1
	._BatchAdd resd 1
	.num_fps equ ($ - _SCEAT) / 4

segment .rdata
_RelocSCIAT:
	._malloc dd _malloc
	._calloc dd _calloc
	._realloc dd _realloc
	._free dd _free
	._aligned_malloc dd _aligned_malloc
	._aligned_free dd _aligned_free
	._AssetsQuery dd _AssetsQuery
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

DefFunc _CreateBitMap
	jmp [_SCEAT._CreateBitMap]

DefFunc _DestroyBitMap
	jmp [_SCEAT._DestroyBitMap]

DefFunc _GetBitmapPixelAddress
	jmp [_SCEAT._GetBitmapPixelAddress]

DefFunc _SampleFloatMap
	jmp [_SCEAT._SampleFloatMap]

