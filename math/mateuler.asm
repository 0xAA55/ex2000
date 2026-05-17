%include "common.inc"

segment .text
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
