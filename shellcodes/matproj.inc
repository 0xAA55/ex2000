
DefFunc _MatrixProjection
	FrameBegin
	NameParams %$Out, %$FovY, %$Aspect, %$ZN, %$ZF

	mov eax, %$Out
	xorps xmm0, xmm0
	movaps [eax + Matrix.x], xmm0
	movaps [eax + Matrix.y], xmm0
	movaps [eax + Matrix.z], xmm0
	movaps [eax + Matrix.w], xmm0

	mov ecx, __?float32?__(-1.0)
	mov edx, __?float32?__(2.0)

	movss xmm6, %$ZN
	movss xmm7, %$ZF
	movd xmm1, ecx
	movd xmm2, edx

	fld dword %$FovY
	fsincos
	fdivp
	fst dword [eax + Matrix.xx]
	fmul dword %$Aspect
	fstp dword [eax + Matrix.yy]

	;W = tan(fovy)
	;H = W * Aspect
	;Depth = Far - Near
	;W, 0, 0, 0
	;0, H, 0, 0
	;0, 0, -Far / Depth, -1
	;0, 0, -2 * Near * Far / Depth, 0

	movss xmm0, xmm7
	movss xmm3, xmm6
	mulss xmm2, xmm6
	subss xmm3, xmm7 ; -Depth
	mulss xmm2, xmm7
	divss xmm0, xmm3
	divss xmm2, xmm3
	movss [eax + Matrix.zz], xmm0
	movss [eax + Matrix.zw], xmm1
	movss [eax + Matrix.wz], xmm2

	FrameEnd
	ret
