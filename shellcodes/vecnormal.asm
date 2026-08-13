%include "common.inc"

DefFunc _VectorNormal
	FrameBegin
	NameParams %$Out, %$V, %$Dim

	xor eax, eax
	movd xmm0, eax

	mov eax, %$V
	mov ecx, %$Dim
	mov edx, %$Out

.loop_dot:
	movss xmm1, [eax + (ecx - 1) * 4]
	mulss xmm1, xmm1
	addss xmm0, xmm1
	dec ecx
	jnz .loop_dot

	rsqrtss xmm0, xmm0

	mov ecx, %$Dim

.loop_normalize:
	movss xmm1, [eax + (ecx - 1) * 4]
	mulss xmm1, xmm0
	movss [edx + (ecx - 1) * 4], xmm1
	dec ecx
	jnz .loop_normalize

	FrameEnd
	ret

