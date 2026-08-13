%include "common.inc"

DefFunc _MatrixMultiply
	FrameBegin esi, edi
	NameParams %$DstMat, %$L, %$R

	mov esi, %$L
	mov edi, %$DstMat

	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.x], &[esi + Matrix.x], %$R
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.y], &[esi + Matrix.y], %$R
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.z], &[esi + Matrix.z], %$R
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.w], &[esi + Matrix.w], %$R

	FrameEnd
	ret

DefFunc _MatrixMultiplyTo
	FrameBegin ebx, edi
	NameParams %$DstMat, %$R
	DefSizedVar %$MatrixBuffer, 0x10 + Matrix.size

	lea ebx, Variable(4)
	mov edi, %$DstMat
	and ebx, 0xFFFFFFF0

	invoke_cdecl _MatrixMultiply, ebx, edi, %$R

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
