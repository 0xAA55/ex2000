%include "common.inc"

DefFunc _MatrixRotationEuler
	FrameBegin
	NameParams %$Out, %$Yaw, %$Pitch, %$Roll
	DefVars %$CosY, %$SinY, %$CosP, %$SinP, %$CosR, %$SinR

	xor eax, eax
	mov ecx, 3
	mov edx, 1
.sincos:
	fld dword Param(edx)
	fsincos
	fstp Variable(eax)
	fstp Variable(eax + 1)
	inc edx
	add al, 2
	loop .sincos

	mov eax, %$Out
	xorps xmm0, xmm0
	movaps [eax + Matrix.x], xmm0
	movaps [eax + Matrix.y], xmm0
	movaps [eax + Matrix.z], xmm0
	movaps [eax + Matrix.w], xmm0

	;xx = cy * cr + spsr * sy
	;xy = cp * sr
	;xz = spsr * cy - sy * cr
	;yx = spcr * sy - cy * sr
	;yy = cr * cp
	;yz = sr * sy + spcr * cy
	;zx = sy * cp
	;zy = -sp
	;zz = cy * cp
	;ww = 1.0

	movss xmm0, %$SinP
	movss xmm1, %$SinP
	movss xmm2, %$CosY
	movss xmm4, %$CosP
	movss xmm5, %$SinY
	movss xmm7, %$CosY
	mulss xmm0, %$SinR ;SPSR
	mulss xmm1, %$CosR ;SPCR
	mulss xmm2, %$CosR
	movss xmm3, xmm0
	movss xmm6, xmm1
	mulss xmm7, %$SinR
	mulss xmm4, %$SinR ;xy
	mulss xmm3, %$SinY
	mulss xmm0, %$CosY
	mulss xmm5, %$CosR
	mulss xmm6, %$SinY
	addss xmm2, xmm3 ;xx
	subss xmm0, xmm5 ;xz
	subss xmm6, xmm7 ;yx
	movss [eax + Matrix.xy], xmm4
	movss [eax + Matrix.xx], xmm2
	movss [eax + Matrix.xz], xmm0
	movss [eax + Matrix.yx], xmm6

	movss xmm0, %$CosR
	mulss xmm1, %$CosY
	movss xmm2, %$SinR
	movss xmm3, %$SinY
	xorps xmm4, xmm4
	movss xmm5, %$CosY
	mulss xmm0, %$CosP ;yy
	mulss xmm2, %$SinY
	mulss xmm3, %$CosP ;zx
	subss xmm4, %$SinP ;zy
	mulss xmm5, %$CosP ;zz
	addss xmm1, xmm2 ;yz
	movss [eax + Matrix.yy], xmm0
	movss [eax + Matrix.zx], xmm3
	movss [eax + Matrix.zy], xmm4
	movss [eax + Matrix.zz], xmm5
	movss [eax + Matrix.yz], xmm1
	mov dword[eax + Matrix.ww], __float32__(1.0)

	FrameEnd
	ret
