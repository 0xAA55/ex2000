%include "common.inc"

segment .text
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
