%include "common.inc"

%define _EULER_DEBUG 1

segment .text
%ifndef _EULER_DEBUG
DefFunc _MatrixViewEuler
	FrameBegin 10, 0
	AssignVars _CY, _SY, _CP, _SP, _CR, _SR, CYCP, SYSP, SYCP, CYSP

	xor eax, eax
	mov ecx, eax
	mov cl, 3
	mov edx, ecx
	dec edx
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
	%define CYCPSR_P_SYSP [eax + Matrix.yx]
	%define SYCPSR_M_CYSP [eax + Matrix.yz]
	%define CYSPSR_M_SYCP [eax + Matrix.zx]
	%define SYSPSR_P_CYCP [eax + Matrix.zz]

	;xx = CYCR;
	;xy = NSR;
	;xz = SYCR;
	;xw = 0.0;
	;yx = CYCPSR_P_SYSP;
	;yy = CPCR;
	;yz = SYCPSR_M_CYSP;
	;yw = 0.0;
	;zx = CYSPSR_M_SYCP;
	;zy = SPCR;
	;zz = SYSPSR_P_CYCP;
	;zw = 0.0;
	;wx = -(CYCR * EYEX + CYCPSR_P_SYSP * EYEY + CYSPSR_M_SYCP * EYEZ);
	;wy = -(NSR * EYEX + CPCR * EYEY + SPCR * EYEZ);
	;wz = -(SYCR * EYEX + SYCPSR_M_CYSP * EYEY + SYSPSR_P_CYCP * EYEZ);
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
	movss [eax + Matrix.xw], xmm5
	movss [eax + Matrix.yw], xmm5
	movss [eax + Matrix.zw], xmm5
	mulss xmm6, _CR
	mulss xmm7, _CR
	subss xmm5, _SR
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
	movss CYCPSR_P_SYSP, xmm1
	movss SYCPSR_M_CYSP, xmm2
	movss CYSPSR_M_SYCP, xmm3
	movss SYSPSR_P_CYCP, xmm4
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
	movss [eax + Matrix.wy], xmm5
	addss xmm0, xmm1
	mulss xmm6, [_M1.0f]
	addss xmm0, xmm3
	movss [eax + Matrix.wz], xmm6
	mulss xmm0, [_M1.0f]
	movss [eax + Matrix.wx], xmm0
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
%else
DefFunc _MatrixViewEuler
	FrameBegin 0x14, 4, ebx, esi

	lea esi, Variable(4)
	and esi, 0xFFFFFFF0
	mov ebx, Param(0)

	invoke_cdecl _MatrixRotationEuler, esi, Param(2), Param(3), Param(4)
	invoke_cdecl _MatrixTranspose, ebx, esi
	invoke_cdecl _VectorDot, &[ebx + Matrix.wx], &[esi + Matrix.x], Param(1), 3
	invoke_cdecl _VectorDot, &[ebx + Matrix.wy], &[esi + Matrix.y], Param(1), 3
	invoke_cdecl _VectorDot, &[ebx + Matrix.wz], &[esi + Matrix.z], Param(1), 3
	mov eax, 0x80000000
	xor [ebx + Matrix.wx], eax
	xor [ebx + Matrix.wy], eax
	xor [ebx + Matrix.wz], eax

	FrameEnd
	ret
%endif
