%include "common.inc"

segment .text
DefFunc _VectorLength
	FrameBegin 0, 4, ebx

	mov ebx, Param(0)
	invoke_cdecl _VectorDot, Param(0), Param(1), Param(1), Param(2)
	movss xmm0, [ebx]
	sqrtss xmm0, xmm0
	movss [ebx], xmm0

	FrameEnd
	ret
