%include "common.inc"

%define _EULER_DEBUG 1

segment .text
DefFunc _MatrixViewEuler
	FrameBegin 0x18, 4, ebx, esi, edi

	mov edi, Param(0)
	lea esi, Variable(4)
	and esi, 0xFFFFFFF0
	lea ebx, [esi + Matrix.size]

	mov eax, Param(1)
	movups xmm0, [eax]
	mulps xmm0, [_FMMMM]
	movaps [ebx], xmm0

	invoke_cdecl _MatrixRotationEuler, edi, Param(2), Param(3), Param(4)
	invoke_cdecl _MatrixTranspose, esi, edi
	invoke_cdecl _VectorDot, &[edi + Matrix.wx], &[esi + Matrix.x], ebx, 3
	invoke_cdecl _VectorDot, &[edi + Matrix.wy], &[esi + Matrix.y], ebx, 3
	invoke_cdecl _VectorDot, &[edi + Matrix.wz], &[esi + Matrix.z], ebx, 3

	FrameEnd
	ret
