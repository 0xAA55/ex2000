%include "common.inc"

segment .text
DefFunc _VectorMultMatrix
	FrameBegin 0, 0

	mov eax, Param(2)
	mov ecx, Param(1)
	mov edx, Param(0)

	movaps xmm2, [ecx]
	movaps xmm3, xmm2

	movaps xmm1, xmm2
	shufps xmm1, xmm3, _MM_SHUFFLE(0, 0, 0, 0)
	mulps xmm1, [eax + Matrix.x]
	movaps xmm0, xmm1

	movaps xmm1, xmm2
	shufps xmm1, xmm3, _MM_SHUFFLE(1, 1, 1, 1)
	mulps xmm1, [eax + Matrix.y]
	addps xmm0, xmm1

	movaps xmm1, xmm2
	shufps xmm1, xmm3, _MM_SHUFFLE(2, 2, 2, 2)
	mulps xmm1, [eax + Matrix.z]
	addps xmm0, xmm1

	movaps xmm1, xmm2
	shufps xmm1, xmm3, _MM_SHUFFLE(3, 3, 3, 3)
	mulps xmm1, [eax + Matrix.w]
	addps xmm0, xmm1

	movaps [edx], xmm0

	FrameEnd
	ret
