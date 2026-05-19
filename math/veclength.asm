%include "common.inc"

segment .text
DefFunc _VectorLength
	FrameBegin 0, 0

	mov eax, Param(1)
	mov ecx, Param(2)
	mov edx, Param(0)
	dec ecx
	shl ecx, 4

	movups xmm0, [eax]
	pand xmm0, [_UF000 + ecx]
	mulps xmm0, xmm0
	cmp dword [_HaveSSE3], 0
	jz .no_sse3
	haddps xmm0, xmm0
	haddps xmm0, xmm0
	jmp .after_dot
.no_sse3:
	movhlps xmm1, xmm0
	movaps xmm2, xmm0
	addps xmm2, xmm1
	pshufd xmm0, xmm2, _MM_SHUFFLE(1, 1, 1, 1)
	addss xmm0, xmm2
.after_dot:
	sqrtss xmm0
	movss [edx], xmm0

	FrameEnd
	ret
