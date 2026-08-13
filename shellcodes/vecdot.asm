%include "common.inc"

DefFunc _VectorDot
	FrameBegin
	NameParams %$Out, %$V1, %$V2, %$Dim

	xor eax, eax
	movd xmm0, eax

	mov eax, %$V1
	mov ecx, %$Dim
	mov edx, %$V2

.loop_components:
	movss xmm1, [eax + (ecx - 1) * 4]
	mulss xmm1, [edx + (ecx - 1) * 4]
	addss xmm0, xmm1
	dec ecx
	jnz .loop_components

	mov edx, %$Out
	movss [edx], xmm0

	FrameEnd
	ret
