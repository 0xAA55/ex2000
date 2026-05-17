%include "common.inc"

segment .text
DefFunc _VectorLength
	FrameBegin 0, 0

	mov eax, Param(1)
	mov ecx, Param(2)
	mov edx, Param(0)
	fldz
.muladd:
	fld dword [eax]
	fmul dword [eax]
	fadd
	add eax, 4
	loop .muladd
	fsqrt
	fstp dword [edx]

	FrameEnd
	ret
