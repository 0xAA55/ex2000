%include "common.inc"

segment .text
DefFunc _MatrixProjection
	FrameBegin 0, 0

	mov eax, Param(0)
	movaps xmm0, [_ZeroVector]
	movaps [eax + Matrix.x], xmm0
	movaps [eax + Matrix.y], xmm0
	movaps [eax + Matrix.z], xmm0
	movaps [eax + Matrix.w], xmm0

	mov dword [eax + Matrix.zw], 0x3F800000

	fld dword Param(1)
	fdiv dword [_2.0f]
	fsincos
	fdivp st1, st0
	fst dword [eax + Matrix.yy]
	fdiv dword Param(2)
	fstp dword [eax + Matrix.xx]

	movss xmm0, Param(4)
	movss xmm3, Param(4)
	subss xmm3, Param(3)
	divss xmm0, xmm3
	movss [eax + Matrix.zz], xmm0
	movss xmm1, [_ZeroVector]
	subss xmm1, Param(3)
	mulss xmm1, xmm0
	movss [eax + Matrix.wz], xmm0

	FrameEnd
	ret
