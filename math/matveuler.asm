%include "common.inc"

segment .text
DefFunc _MatrixViewEuler
	FrameBegin 10, 0
	AssignVars _CY, _SY, _CP, _SP, _CR, _SR, CYCP, SYSP, SYCP, CYSP

	xor eax, eax
	mov ecx, 3
	mov edx, 2
.sincos:
	fld dword Param(edx)
	fsincos
	fstp Variable(eax)
	fstp Variable(eax + 1)
	inc edx
	add al, 2
	loop .sincos

	mov eax, Param(0)
	mov edx, Param(1)

	%define EYEX [edx + Vector.x]
	%define EYEY [edx + Vector.y]
	%define EYEZ [edx + Vector.z]
	%define CYCR [eax + Matrix.xx]
	%define NSR  [eax + Matrix.xy]
	%define SYCR [eax + Matrix.xz]
	%define CPCR [eax + Matrix.yy]
	%define SPCR [eax + Matrix.zy]
	%define CYCP_SR_P_SYSP [eax + Matrix.yx]
	%define SYCP_SR_M_CYSP [eax + Matrix.yz]
	%define CYSP_SR_M_SYCP [eax + Matrix.zx]
	%define SYSP_SR_P_CYCP [eax + Matrix.zz]

	;t0 = CYCP;
	;t1 = SYSP;
	;t2 = SYCP;
	;t3 = CYSP;
	;xx = CYCR;
	;xy = NSR;
	;xz = SYCR;
	;yy = CPCR;
	;zy = SPCR;
	;yx = CYCP_SR_P_SYSP;
	;yz = SYCP_SR_M_CYSP;
	;zx = CYSP_SR_M_SYCP;
	;zz = SYSP_SR_P_CYCP;
	;xw = -(CYCR * EYEX + CYCP_SR_P_SYSP * EYEY + CYSP_SR_M_SYCP * EYEZ);
	;yw = -(NSR * EYEX + CPCR * EYEY + SPCR * EYEZ);
	;zw = -(SYCR * EYEX + SYCP_SR_M_CYSP * EYEY + SYSP_SR_P_CYCP * EYEZ);
	;wx = 0.0;
	;wy = 0.0;
	;wz = 0.0;
	;ww = 1.0;

	movss xmm0, _CY
	movss xmm1, _SY
	movss xmm2, xmm1
	movss xmm3, xmm0
	movss xmm4, xmm0
	movaps xmm5, [_ZeroVector]
	movss xmm6, xmm1
	movss xmm7, _CP
	mulss xmm0, _CP
	mulss xmm1, _SP
	mulss xmm2, _CP
	mulss xmm3, _SP
	mulss xmm4, _CR
	movaps [eax + Matrix.w], xmm5
	mulss xmm6, _CR
	mulss xmm7, _CR
	movss CYCP, xmm0
	movss SYSP, xmm1
	movss SYCP, xmm2
	movss CYSP, xmm3
	movss CYCR, xmm4
	movss NSR, xmm5
	movss SYCR, xmm6
	movss CPCR, xmm7
	movss xmm0, _SP
	movss xmm1, CYCP
	movss xmm2, SYCP
	movss xmm3, CYSP
	movss xmm4, SYSP
	mulss xmm5, EYEX
	mulss xmm6, EYEX
	mulss xmm7, EYEY
	mulss xmm0, _CR
	mulss xmm1, _SR
	mulss xmm2, _SR
	mulss xmm3, _SR
	mulss xmm4, _SR
	addss xmm1, SYSP
	subss xmm2, CYSP
	subss xmm3, SYCP
	addss xmm4, CYCP
	movss SPCR, xmm0
	movss CYCP_SR_P_SYSP, xmm1
	movss SYCP_SR_M_CYSP, xmm2
	movss CYSP_SR_M_SYCP, xmm3
	movss SYSP_SR_P_CYCP, xmm4
	mulss xmm0, EYEZ
	mulss xmm1, EYEY
	mulss xmm2, EYEY
	mulss xmm4, EYEZ
	addss xmm5, xmm0
	addss xmm6, xmm2
	mulss xmm3, EYEZ
	addss xmm5, xmm7
	addss xmm6, xmm4
	movss xmm0, CYCR
	mulss xmm5, [_M1.0f]
	mulss xmm0, EYEX
	movss [eax + Matrix.yw], xmm5
	addss xmm0, xmm1
	mulss xmm6, [_M1.0f]
	addss xmm0, xmm3
	movss [eax + Matrix.zw], xmm6
	mulss xmm0, [_M1.0f]
	movss [eax + Matrix.xw], xmm0
	mov dword [eax + Matrix.ww], 0x3F800000

	FrameEnd
	ret
	%undef EYEX
	%undef EYEY
	%undef EYEZ
	%undef CYCR
	%undef NSR
	%undef SYCR
	%undef CPCR
	%undef SPCR
	%undef CYCP
	%undef SYSP
	%undef SYCP
	%undef CYSP
	%undef CYCPSR_P_SYSP
	%undef SYCPSR_M_CYSP
	%undef CYSPSR_M_SYCP
	%undef SYSPSR_P_CYCP
