%include "common.inc"

segment .text
DefFunc _VectorNormal
	FrameBegin 1, 3

	invoke_cdecl _VectorLength, &Variable(0), Param(1), Param(2)
	mov eax, Param(1)
	mov ecx, Param(2)
	mov edx, Param(0)
	dec ecx
	shl ecx, 4

	movss xmm2, Variable(0)
	movups xmm0, [edx]
	shufps xmm2, xmm2, 0
	movups xmm1, [eax]
	pand xmm0, [_U0FFF + ecx]
	pand xmm1, [_UF000 + ecx]
	divps xmm1, xmm2
	por xmm0, xmm1
	movups [edx], xmm0

	FrameEnd
	ret

