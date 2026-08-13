%include "common.inc"

DefFunc _VectorLength
	FrameBegin
	NameParams %$Out, %$V, %$Dim

	xor eax, eax
	movd xmm0, eax

	mov eax, %$V
	mov ecx, %$Dim
	mov edx, %$Out

.loop_components:
	movss xmm1, [eax + (ecx - 1) * 4]
	mulss xmm1, xmm1
	addss xmm0, xmm1
	dec ecx
	jnz .loop_components

	sqrtss xmm0, xmm0
	movss [edx], xmm0

	FrameEnd
	ret
