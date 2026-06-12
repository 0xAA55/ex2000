%include "common.inc"

DefFunc _FloatMapGetMaxValue
	FrameBegin 0, 3, ebx

	mov ebx, Param(0)
	mov eax, [ebx + BitMap.num_floats]
	test eax, eax
	jnz .good
.bad:
	int3
	jmp .bad
.good:
	invoke_cdecl _BatchMax, [ebx + BitMap.data], eax

	FrameEnd
	ret
