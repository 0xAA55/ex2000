
DefFunc _VectorCross
	FrameBegin
	NameParams %$Out, %$V1, %$V2

	mov eax, %$V1
	mov ecx, %$V2
	mov edx, %$Out

	movaps xmm0, [eax]
	movaps xmm1, xmm0
	movaps xmm2, [ecx]
	movaps xmm3, xmm2
	shufps xmm0, xmm0, _MM_SHUFFLE(3, 0, 2, 1)
	shufps xmm1, xmm1, _MM_SHUFFLE(3, 1, 0, 2)
	shufps xmm2, xmm2, _MM_SHUFFLE(3, 1, 0, 2)
	shufps xmm3, xmm3, _MM_SHUFFLE(3, 0, 2, 1)
	mulps xmm0, xmm2
	mulps xmm1, xmm3
	subps xmm0, xmm1

	movaps [edx], xmm0

	FrameEnd
	ret
