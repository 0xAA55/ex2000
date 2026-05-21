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

	movss xmm3, Param(3)
	movss xmm4, Param(4)

	fld dword Param(1)
	fdiv dword [_2.0f]
	fsincos
	fdivp
	fst dword [eax + Matrix.yy]
	fdiv dword Param(2)
	fstp dword [eax + Matrix.xx]

	movss xmm0, xmm3
	movss xmm1, xmm3
	movss xmm2, xmm3
	subss xmm0, xmm4 ;zn - zf
	addss xmm1, xmm4 ;zn + zf
	mulss xmm2, xmm4
	mulss xmm2, [_2.0f] ;2znzf
	divss xmm1, xmm0 ;(zn + zf) / (zn - zf)
	divss xmm2, xmm0 ;2znzf / (zn - zf)
	movss [eax + Matrix.zz], xmm1
	movss [eax + Matrix.zw], xmm2
	mov dword [eax + Matrix.wz], __?float32?__(-1.0)

	FrameEnd
	ret
