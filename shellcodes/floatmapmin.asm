%include "common.inc"

DefFunc _FloatMapGetMinValue
	FrameBegin ebx
	NameParams %$FloatMap

	mov ebx, %$FloatMap
	mov eax, [ebx + BitMap.num_floats]
	test eax, eax
	jnz .good
.bad:
	int3
	jmp .bad
.good:
	invoke_cdecl _BatchMin, [ebx + BitMap.data], eax

	FrameEnd
	ret
