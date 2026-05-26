%include "common.inc"

segment .text
DefFunc _FloatMapGetMaxValue
	FrameBegin 0, 3, ebx

	mov ebx, Param(0)
	mov eax, [ebx + FloatMap.num_pixels]
	mul dword [ebx + FloatMap.dims]
	test eax, eax
	jnz .good
.bad:
	int3
	jmp .bad
.good:
	invoke_cdecl _BatchMax, [ebx + FloatMap.data], eax

	FrameEnd
	ret
