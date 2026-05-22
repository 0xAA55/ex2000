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

	movss xmm6, Param(3)
	movss xmm7, Param(4)
	movss xmm1, [_M1.0f]
	movss xmm2, [_M2.0f]

	fld dword Param(1)
	fsincos
	fdivp
	fst dword [eax + Matrix.xx]
	fmul dword Param(2)
	fstp dword [eax + Matrix.yy]

	;W = tan(fovy)
	;H = W * Aspect
	;Depth = Far - Near
	;W, 0, 0, 0
	;0, H, 0, 0
	;0, 0, -Far / Depth, -1
	;0, 0, -2 * Near * Far / Depth, 0

	movss xmm0, xmm7
	movss xmm3, xmm7
	mulss xmm2, xmm6
	mulss xmm0, xmm1
	subss xmm3, xmm6 ; Depth
	mulss xmm2, xmm7
	divss xmm0, xmm3
	movss xmm7, xmm7
	divss xmm2, xmm3
	movss [eax + Matrix.zz], xmm0
	movss [eax + Matrix.zw], xmm1
	movss [eax + Matrix.wz], xmm2

	FrameEnd
	ret
