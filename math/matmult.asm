%include "common.inc"

DefFunc _MatrixMultiply
	FrameBegin 0, 3, esi, edi

	mov esi, Param(1)
	mov edi, Param(0)

	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.x], &[esi + Matrix.x], Param(2)
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.y], &[esi + Matrix.y], Param(2)
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.z], &[esi + Matrix.z], Param(2)
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.w], &[esi + Matrix.w], Param(2)


	FrameEnd
	ret

DefFunc _MatrixMultiplyTo
	FrameBegin 0x14, 3, ebx, edi

	lea ebx, Variable(4)
	mov edi, Param(0)
	and ebx, 0xFFFFFFF0

	invoke_cdecl _MatrixMultiply, ebx, edi, Param(1)

	movaps xmm0, [ebx + Matrix.x]
	movaps xmm1, [ebx + Matrix.y]
	movaps xmm2, [ebx + Matrix.z]
	movaps xmm3, [ebx + Matrix.w]
	movaps [edi + Matrix.x], xmm0
	movaps [edi + Matrix.y], xmm1
	movaps [edi + Matrix.z], xmm2
	movaps [edi + Matrix.w], xmm3

	FrameEnd
	ret
