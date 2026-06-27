%include "common.inc"

; %define _EULER_DEBUG 1

%ifndef _EULER_DEBUG
DefFunc _MatrixRotationEuler
	FrameBegin 6
	AssignVars _CY, _SY, _CP, _SP, _CR, _SR

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

	mov eax, Param(0)
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

	movss xmm0, _SP
	movss xmm1, _SP
	movss xmm2, _CY
	movss xmm4, _CP
	movss xmm5, _SY
	movss xmm7, _CY
	mulss xmm0, _SR ;SPSR
	mulss xmm1, _CR ;SPCR
	mulss xmm2, _CR
	movss xmm3, xmm0
	movss xmm6, xmm1
	mulss xmm7, _SR
	mulss xmm4, _SR ;xy
	mulss xmm3, _SY
	mulss xmm0, _CY
	mulss xmm5, _CR
	mulss xmm6, _SY
	addss xmm2, xmm3 ;xx
	subss xmm0, xmm5 ;xz
	subss xmm6, xmm7 ;yx
	movss [eax + Matrix.xy], xmm4
	movss [eax + Matrix.xx], xmm2
	movss [eax + Matrix.xz], xmm0
	movss [eax + Matrix.yx], xmm6

	movss xmm0, _CR
	mulss xmm1, _CY
	movss xmm2, _SR
	movss xmm3, _SY
	xorps xmm4, xmm4
	movss xmm5, _CY
	mulss xmm0, _CP ;yy
	mulss xmm2, _SY
	mulss xmm3, _CP ;zx
	subss xmm4, _SP ;zy
	mulss xmm5, _CP ;zz
	addss xmm1, xmm2 ;yz
	movss [eax + Matrix.yy], xmm0
	movss [eax + Matrix.zx], xmm3
	movss [eax + Matrix.zy], xmm4
	movss [eax + Matrix.zz], xmm5
	movss [eax + Matrix.yz], xmm1
	mov dword[eax + Matrix.ww], __?float32?__(1.0)

	FrameEnd
	ret
	%undef _CY
	%undef _SY
	%undef _CP
	%undef _SP
	%undef _CR
	%undef _SR
%else
DefFunc _MakeIdentity
	movaps xmm0, [_IdentityMatrix + Matrix.x]
	movaps xmm1, [_IdentityMatrix + Matrix.y]
	movaps xmm2, [_IdentityMatrix + Matrix.z]
	movaps xmm3, [_IdentityMatrix + Matrix.w]
	movaps [ebx + Matrix.x], xmm0
	movaps [ebx + Matrix.y], xmm1
	movaps [ebx + Matrix.z], xmm2
	movaps [ebx + Matrix.w], xmm3
	ret

DefFunc _MatrixRotationX
	FrameBegin 0, ebx

	mov ebx, Param(0)
	call _MakeIdentity

	fld dword Param(1)
	fsincos
	fst dword [ebx + Matrix.yy]
	fstp dword [ebx + Matrix.zz]
	fst dword [ebx + Matrix.yz]
	fchs
	fstp dword [ebx + Matrix.zy]

	FrameEnd
	ret

DefFunc _MatrixRotationY
	FrameBegin 0, ebx

	mov ebx, Param(0)
	call _MakeIdentity

	fld dword Param(1)
	fsincos
	fst dword [ebx + Matrix.xx]
	fstp dword [ebx + Matrix.zz]
	fst dword [ebx + Matrix.zx]
	fchs
	fstp dword [ebx + Matrix.xz]

	FrameEnd
	ret

DefFunc _MatrixRotationZ
	FrameBegin 0, ebx

	mov ebx, Param(0)
	call _MakeIdentity

	fld dword Param(1)
	fsincos
	fst dword [ebx + Matrix.xx]
	fstp dword [ebx + Matrix.yy]
	fst dword [ebx + Matrix.xy]
	fchs
	fstp dword [ebx + Matrix.yx]

	FrameEnd
	ret

DefFunc _MatrixRotationEuler
	FrameBegin 0x44, ebx

	lea ebx, Variable(4)
	and ebx, 0xFFFFFFF0
	%define YM   ebx
	%define PM   &[ebx + Matrix.size * 1]
	%define RM   &[ebx + Matrix.size * 2]
	%define RPM  &[ebx + Matrix.size * 3]
	invoke_cdecl _MatrixRotationZ, RM, Param(3)
	invoke_cdecl _MatrixRotationX, PM, Param(2)
	invoke_cdecl _MatrixRotationY, YM, Param(1)
	invoke_cdecl _MatrixMultiply, RPM, RM, PM
	invoke_cdecl _MatrixMultiply, Param(0), RPM, YM

	FrameEnd
	ret

%endif
