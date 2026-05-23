%include "common.inc"

segment .text
DefFunc _MatrixEulerTranslated
	FrameBegin 0, 4, edi

	mov edi, Param(0)
	invoke_cdecl _MatrixRotationEuler, edi, Param(2), Param(3), Param(4)
	mov ecx, Param(1)
	jecxz .end
	movaps xmm0, [ecx]
	pand xmm0, [_UFFF0]
	addps xmm0, [edi + Matrix.w]
	movaps [edi + Matrix.w], xmm0

.end:
	FrameEnd
	ret
