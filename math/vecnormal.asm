%include "common.inc"

DefFunc _VectorNormal
	FrameBegin 1, 4

	invoke_cdecl _VectorDot, &Variable(0), Param(1), Param(1), Param(2)
	mov eax, Param(1)
	mov ecx, Param(2)
	mov edx, Param(0)
	movss xmm2, Variable(0)
	shufps xmm2, xmm2, 0
	shl ecx, 4
	movups xmm0, [edx]
	movups xmm1, [eax]
	rsqrtps xmm2, xmm2
	andps xmm0, [_U0FFF + ecx - 0x10] ; Data should be preserved
	andps xmm1, [_UF000 + ecx - 0x10] ; Our vector
	mulps xmm1, xmm2
	orps xmm0, xmm1
	movups [edx], xmm0

	FrameEnd
	ret

