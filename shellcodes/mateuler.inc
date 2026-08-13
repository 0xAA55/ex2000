%include "common.inc"

; %define _EULER_DEBUG 1

%ifndef _EULER_DEBUG
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
	mov dword[eax + Matrix.ww], __?float32?__(1.0)

	FrameEnd
	ret
%else
DefFunc _MakeIdentity
	FrameBegin
	NameParams %$Out
	mov eax, %$Out
	movaps xmm0, [_IdentityMatrix + Matrix.x]
	movaps xmm1, [_IdentityMatrix + Matrix.y]
	movaps xmm2, [_IdentityMatrix + Matrix.z]
	movaps xmm3, [_IdentityMatrix + Matrix.w]
	movaps [eax + Matrix.x], xmm0
	movaps [eax + Matrix.y], xmm1
	movaps [eax + Matrix.z], xmm2
	movaps [eax + Matrix.w], xmm3
	FrameEnd
	ret

DefFunc _MatrixRotationX
	FrameBegin ebx
	NameParams %$Out, %$Angle

	mov ebx, %$Out
	invoke_cdecl _MakeIdentity, ebx

	fld dword %$Angle
	fsincos
	fst dword [ebx + Matrix.yy]
	fstp dword [ebx + Matrix.zz]
	fst dword [ebx + Matrix.yz]
	fchs
	fstp dword [ebx + Matrix.zy]

	FrameEnd
	ret

DefFunc _MatrixRotationY
	FrameBegin ebx
	NameParams %$Out, %$Angle

	mov ebx, %$Out
	invoke_cdecl _MakeIdentity, ebx

	fld dword %$Angle
	fsincos
	fst dword [ebx + Matrix.xx]
	fstp dword [ebx + Matrix.zz]
	fst dword [ebx + Matrix.zx]
	fchs
	fstp dword [ebx + Matrix.xz]

	FrameEnd
	ret

DefFunc _MatrixRotationZ
	FrameBegin ebx
	NameParams %$Out, %$Angle

	mov ebx, %$Out
	invoke_cdecl _MakeIdentity, ebx

	fld dword %$Angle
	fsincos
	fst dword [ebx + Matrix.xx]
	fstp dword [ebx + Matrix.yy]
	fst dword [ebx + Matrix.xy]
	fchs
	fstp dword [ebx + Matrix.yx]

	FrameEnd
	ret

DefFunc _MatrixRotationEuler
	FrameBegin ebx
	NameParams %$Out, %$Yaw, %$Pitch, %$Roll
	DefSizedVar %$MatrixBuffer, 0x10 + Matrix.size * 4

	lea ebx, Variable(4)
	and ebx, 0xFFFFFFF0
	%define YM   ebx
	%define PM   &[ebx + Matrix.size * 1]
	%define RM   &[ebx + Matrix.size * 2]
	%define RPM  &[ebx + Matrix.size * 3]
	invoke_cdecl _MatrixRotationZ, RM, %$Roll
	invoke_cdecl _MatrixRotationX, PM, %$Pitch
	invoke_cdecl _MatrixRotationY, YM, %$Yaw
	invoke_cdecl _MatrixMultiply, RPM, RM, PM
	invoke_cdecl _MatrixMultiply, %$Out, RPM, YM

	FrameEnd
	ret

%endif
