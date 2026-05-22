%include "common.inc"

%define _EULER_DEBUG 1

segment .text
DefFunc _MatrixViewEuler
	FrameBegin 0x14, 4, ebx, esi

	lea esi, Variable(4)
	and esi, 0xFFFFFFF0
	mov ebx, Param(0)

	invoke_cdecl _MatrixRotationEuler, esi, Param(2), Param(3), Param(4)
	invoke_cdecl _VectorDot, &[ebx + Matrix.xw], &[esi + Matrix.x], Param(1), 3
	invoke_cdecl _VectorDot, &[ebx + Matrix.yw], &[esi + Matrix.y], Param(1), 3
	invoke_cdecl _VectorDot, &[ebx + Matrix.zw], &[esi + Matrix.z], Param(1), 3
	mov eax, 0x80000000
	xor [ebx + Matrix.xw], eax
	xor [ebx + Matrix.yw], eax
	xor [ebx + Matrix.zw], eax
	invoke_cdecl _MatrixTranspose, ebx, esi

	FrameEnd
	ret
