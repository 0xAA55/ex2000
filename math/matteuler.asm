%include "common.inc"

segment .text
DefFunc _MatrixTransformPositionEuler
	FrameBegin 0, 4

	invoke_cdecl _MatrixRotationEuler, Param(0), Param(2), Param(3), Param(4)
	mov eax, Param(0)
	mov ecx, Param(1)
	movaps xmm0, [ecx]
	movaps [eax + Matrix.w], xmm0
	mov dword [eax + Matrix.ww], 0x3F800000

	FrameEnd
	ret
