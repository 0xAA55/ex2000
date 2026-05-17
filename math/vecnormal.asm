%include "common.inc"

segment .text
DefFunc _VectorNormal
	FrameBegin 1, 3

	invoke_cdecl _VectorLength, &Variable(0), Param(1), Param(2)
	mov eax, Param(1)
	mov ecx, Param(2)
	mov edx, Param(0)
.divide:
	fld dword [eax + (ecx - 1) * 4]
	fdiv dword Variable(0)
	fstp dword [edx + (ecx - 1) * 4]
	loop .divide

	FrameEnd
	ret

