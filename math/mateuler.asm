%include "common.inc"

%define _EULER_DEBUG 1

segment .text
%ifndef _EULER_DEBUG
DefFunc _MatrixRotationEuler
	FrameBegin 8, 0
	AssignVars _CY, _SY, _CP, _SP, _CR, _SR, _CPSR, _SPSR

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
	movaps xmm0, [_ZeroVector]
	movaps [eax + Matrix.x], xmm0
	movaps [eax + Matrix.y], xmm0
	movaps [eax + Matrix.z], xmm0
	movaps [eax + Matrix.w], xmm0

	;xx = _CY * _CR
	;xy = _CY * _CPSR + _SY * _SP;
	;xz = _CY * _SPSR - _SY * _CP;
	;yx = -_SR;
	;yy = _CRCP;
	;yz = _CRSP;
	;zx = _CR * _SY;
	;zy = _CPSR * _SY - _SP * _CY;
	;zz = _SPSR * _SY + _CP * _CY;
	;ww = 1.0;

	movss xmm0, _CP
	movss xmm1, _SP
	movss xmm2, _CR
	movss xmm3, _CY
	movss xmm4, _CY
	movss xmm5, _SY
	movss xmm6, _CY
	movss xmm7, _SY
	mulss xmm0, _SR
	mulss xmm1, _SR
	mulss xmm2, _CP
	mulss xmm3, _CR
	mulss xmm4, xmm0
	mulss xmm5, _SP
	mulss xmm6, xmm1
	mulss xmm7, _CP
	addss xmm4, xmm5
	subss xmm6, xmm7
	movss _CPSR, xmm0
	movss _SPSR, xmm1
	movss [eax + Matrix.xx], xmm3
	movss [eax + Matrix.xy], xmm4
	movss [eax + Matrix.xz], xmm6
	movss [eax + Matrix.yy], xmm2

	movss xmm0, [_ZeroVector]
	movss xmm1, _CR
	movss xmm2, _CR
	movss xmm3, _CPSR
	movss xmm4, _SP
	movss xmm5, _SPSR
	movss xmm6, _CY
	subss xmm0, _SR
	mulss xmm1, _SP
	mulss xmm2, _SY
	mulss xmm3, _SY
	mulss xmm4, _CY
	mulss xmm5, _SY
	mulss xmm6, _CP
	subss xmm3, xmm4
	addss xmm5, xmm6
	movss [eax + Matrix.yx], xmm0
	movss [eax + Matrix.yz], xmm1
	movss [eax + Matrix.zx], xmm2
	movss [eax + Matrix.zy], xmm3
	movss [eax + Matrix.zz], xmm5
	mov dword[eax + Matrix.ww], 0x3F800000

	FrameEnd
	ret
	%undef _CY
	%undef _SY
	%undef _CP
	%undef _SP
	%undef _CR
	%undef _SR
	%undef _CPSR
	%undef _SPSR
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
	FrameBegin 0, 0, ebx

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
	FrameBegin 0, 0, ebx

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
	FrameBegin 0, 0, ebx

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
	FrameBegin 4, 3
	AssignVars YM, PM, RM, RPM

	invoke_cdecl _aligned_malloc, Matrix.size, 0x10
	mov YM, eax
	invoke_cdecl _aligned_malloc, Matrix.size, 0x10
	mov PM, eax
	invoke_cdecl _aligned_malloc, Matrix.size, 0x10
	mov RM, eax
	invoke_cdecl _aligned_malloc, Matrix.size, 0x10
	mov RPM, eax
	invoke_cdecl _MatrixRotationZ, RM, Param(3)
	invoke_cdecl _MatrixRotationX, PM, Param(2)
	invoke_cdecl _MatrixRotationY, YM, Param(1)
	invoke_cdecl _MatrixMultiply, RPM, RM, PM
	invoke_cdecl _MatrixMultiply, Param(0), YM, RPM
	invoke_cdecl _aligned_free, YM
	invoke_cdecl _aligned_free, PM
	invoke_cdecl _aligned_free, RM
	invoke_cdecl _aligned_free, RPM

	FrameEnd
	ret

%endif
