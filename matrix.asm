%include "loaddll.inc"

%define MATRIX_ASM 1
%include "matrix.inc"

%define _MM_SHUFFLE(fp3,fp2,fp1,fp0) (((fp3) << 6) | ((fp2) << 4) | ((fp1) << 2) | ((fp0)))

extern _malloc
extern _calloc
extern _free
extern _aligned_malloc
extern _aligned_free

import_dll_func memcpy
import_dll_func memset
import_dll_func rand
import_dll_func srand
import_dll_func ExitProcess

%define SEED_OF_RAND(s) ((0x343fD * (s) + 0x269EC3) & 0xFFFFFFFF)
%define RAND(s) (SEED_OF_RAND(s) & 0x7FFF)

segment .bss
global _counter
_counter resd 1
global _HaveSSE3
_HaveSSE3 resd 1
global _HaveSSE41
_HaveSSE41 resd 1

segment .bss
alignb 16
global _ZeroVector
_ZeroVector resd 4
global _Rand4MulVal
_Rand4MulVal resd 4
global _Rand4AddVal
_Rand4AddVal resd 4
global _Rand4AndVal
_Rand4AndVal resd 4
global _F1111
_F1111 resd 4
global _0101
_0101 resd 4
global _Scale127_5
_Scale127_5 resd 4
global _BMxmm
_BMxmm resd 4
global _IdentityMatrix
_IdentityMatrix resb Matrix.size

segment .rdata
align 16
global _2.0f
_2.0f dd 0x40000000
global _M1.0f
_M1.0f dd 0xBF800000
global _W6
_W6 dw 6
global _W10
_W10 dw 10
global _W15
_W15 dw 15

segment .text
DefFunc _MathInit
	FrameBegin 0, 0, ebx

	mov eax, 0x3F800000
	mov ecx, 4
	xor edx, edx
.init_math:
	mov [_IdentityMatrix + edx], eax
	mov [_F1111 + (ecx - 1) * 4], eax
	mov dword [_Scale127_5 + (ecx - 1) * 4], 0x42FF0000
	mov dword [_Rand4MulVal + (ecx - 1) * 4], 0x343fD
	mov dword [_Rand4AddVal + (ecx - 1) * 4], 0x269EC3
	mov dword [_Rand4AndVal + (ecx - 1) * 4], 0x7FFF
	mov byte [_BMxmm + (ecx - 1) * 4], 0xFF
	add edx, 20
	loop .init_math
	dec ecx
	mov [_0101], ecx
	mov [_0101 + 8], ecx

	xor eax, eax
	inc eax
	cpuid
	test edx, (1 << 26)
	jz .no_sse2
	test ecx, (1 << 0)
	jz .no_sse3
	mov byte [_HaveSSE3], 1
.no_sse3:
	test ecx, (1 << 19)
	jz .no_sse41
	mov byte [_HaveSSE41], 1

	jmp .end

.no_sse2:
	debug_msg "SSE2 is needed for the program to run."
	invoke_dll_stdcall ExitProcess, 1

.no_sse41:
.end:
	FrameEnd
	ret

DefFunc _CreateSeedVector
	FrameBegin 0, 2, ebx

	invoke_cdecl _aligned_malloc, 16, 16
	mov ebx, eax

	mov eax, 1
	lock xadd [_counter], eax
	mov [esp], eax
	fild dword [esp]
	fsincos
	fadd
	fstp dword [esp]
	call [_addr_of_srand]
	invoke_dll_cdecl rand
	mov [ebx], eax

	fild dword [ebx]
	fidiv dword [_Rand4AndVal]
	fldpi
	fldpi
	fadd
	fmul
	fst dword [ebx]
	fld st0
	fsincos
	fstp dword [ebx + 4]
	fstp dword [ebx + 8]
	fsincos
	fadd
	fstp dword [ebx + 12]

	mov eax, ebx
	FrameEnd
	ret

DefFunc _DestroySeedVector
	FrameBegin 0, 1

	invoke_cdecl _aligned_free, Param(0)

	FrameEnd
	ret

DefFunc _VectorCross
	FrameBegin 0, 0

	mov eax, Param(1)
	mov ecx, Param(2)
	mov edx, Param(0)

	movaps xmm0, [eax]
	movaps xmm1, xmm0
	movaps xmm2, [ecx]
	movaps xmm3, xmm2
	shufps xmm0, xmm0, _MM_SHUFFLE(3, 0, 2, 1)
	shufps xmm1, xmm1, _MM_SHUFFLE(3, 1, 0, 2)
	shufps xmm2, xmm2, _MM_SHUFFLE(3, 1, 0, 2)
	shufps xmm3, xmm3, _MM_SHUFFLE(3, 0, 2, 1)
	mulps xmm0, xmm2
	mulps xmm1, xmm3
	subps xmm0, xmm1

	movaps [edx], xmm0

	FrameEnd
	ret

DefFunc _VectorLength
	FrameBegin 0, 0

	mov eax, Param(1)
	mov ecx, Param(2)
	mov edx, Param(0)
	fldz
.muladd:
	fld dword [eax]
	fmul dword [eax]
	fadd
	add eax, 4
	loop .muladd
	fsqrt
	fstp dword [edx]

	FrameEnd
	ret

DefFunc _VectorNormal
	FrameBegin 1, 3

	invoke_cdecl _VectorLength, &Variable(0), Param(1), Param(2)
	mov eax, Param(1)
	mov ecx, Param(2)
	mov edx, Param(0)
.divide:
	fld dword [eax + (ecx - 1) * 4]
	fdiv dword Variable(0)
	fstp dword [edx + (ecx - 1) * 4]
	loop .divide

	FrameEnd
	ret

DefFunc _VectorMultMatrix
	FrameBegin 0, 0

	mov eax, Param(2)
	mov ecx, Param(1)
	mov edx, Param(0)

	movaps xmm2, [ecx]
	movaps xmm3, xmm2

	movaps xmm1, xmm2
	shufps xmm1, xmm3, _MM_SHUFFLE(0, 0, 0, 0)
	mulps xmm1, [eax + Matrix.x]
	movaps xmm0, xmm1

	movaps xmm1, xmm2
	shufps xmm1, xmm3, _MM_SHUFFLE(1, 1, 1, 1)
	mulps xmm1, [eax + Matrix.y]
	addps xmm0, xmm1

	movaps xmm1, xmm2
	shufps xmm1, xmm3, _MM_SHUFFLE(2, 2, 2, 2)
	mulps xmm1, [eax + Matrix.z]
	addps xmm0, xmm1

	movaps xmm1, xmm2
	shufps xmm1, xmm3, _MM_SHUFFLE(3, 3, 3, 3)
	mulps xmm1, [eax + Matrix.w]
	addps xmm0, xmm1

	movaps [edx], xmm0

	FrameEnd
	ret

; void MatrixRotationEuler(Matrix_p out, float yaw, float pitch, float roll)
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

DefFunc _MatrixTransformPositionEuler
	FrameBegin 0, 4

	invoke_cdecl _MatrixRotationEuler, Param(0), Param(2), Param(3), Param(4)
	mov eax, Param(0)
	mov ecx, Param(1)
	movaps xmm0, [ecx]
	movaps [eax + Matrix.w], xmm0
	mov dword [eax + Matrix.ww], 0x3F800000

	FrameEnd
	ret

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

DefFunc _MatrixProjection
	FrameBegin 0, 0

	mov eax, Param(0)
	movaps xmm0, [_ZeroVector]
	movaps [eax + Matrix.x], xmm0
	movaps [eax + Matrix.y], xmm0
	movaps [eax + Matrix.z], xmm0
	movaps [eax + Matrix.w], xmm0

	mov dword [eax + Matrix.zw], 0x3F800000

	fld dword Param(1)
	fdiv dword [_2.0f]
	fsincos
	fdivp st1, st0
	fst dword [eax + Matrix.yy]
	fdiv dword Param(2)
	fstp dword [eax + Matrix.xx]

	movss xmm0, Param(4)
	movss xmm3, Param(4)
	subss xmm3, Param(3)
	divss xmm0, xmm3
	movss [eax + Matrix.zz], xmm0
	movss xmm1, [_ZeroVector]
	subss xmm1, Param(3)
	mulss xmm1, xmm0
	movss [eax + Matrix.wz], xmm0

	FrameEnd
	ret

DefFunc _MatrixTranspose
	FrameBegin 0, 0

	mov eax, Param(1)
	movaps xmm3, [eax + Matrix.y]
	movaps xmm1, [eax + Matrix.x]
	shufps xmm1, xmm3, 0x44
	movaps xmm4, xmm1
	movaps xmm1, [eax + Matrix.x]
	shufps xmm1, xmm3, 0xEE
	movaps xmm6, xmm1
	movaps xmm1, [eax + Matrix.z]
	movaps xmm3, [eax + Matrix.w]
	shufps xmm1, xmm3, 0x44
	movaps xmm5, xmm1
	movaps xmm1, [eax + Matrix.z]
	shufps xmm1, xmm3, 0xEE
	movaps xmm7, xmm1

	mov eax, Param(0)
	movaps xmm1, xmm4
	movaps xmm3, xmm5
	shufps xmm1, xmm3, 0x88
	movaps [eax + Matrix.x], xmm1
	movaps xmm1, xmm4
	shufps xmm1, xmm3, 0xDD
	movaps [eax + Matrix.y], xmm1
	movaps xmm1, xmm6
	movaps xmm3, xmm7
	shufps xmm1, xmm3, 0x88
	movaps [eax + Matrix.z], xmm1
	movaps xmm1, xmm6
	shufps xmm1, xmm3, 0xDD
	movaps [eax + Matrix.w], xmm1

	FrameEnd
	ret

DefFunc _MatrixMultiply
	FrameBegin 0, 3, esi, edi

	mov esi, Param(1)
	mov edi, Param(0)

	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.x], &[esi + Matrix.x], Param(2)
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.y], &[esi + Matrix.y], Param(2)
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.z], &[esi + Matrix.z], Param(2)
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.w], &[esi + Matrix.w], Param(2)

	FrameEnd
	ret

DefFunc _CleanupFloatMap
	FrameBegin 0, 1, ebx

	mov ebx, Param(0)
	invoke_cdecl _aligned_free, [ebx + FloatMap.data]
	xor eax, eax
	mov [ebx + FloatMap.data], eax

	FrameEnd
	ret

DefFunc _SmootherStep
	FrameBegin 0, 0

	fld dword Param(0)
	fimul word [_W6]
	fisub word [_W15]
	fmul dword Param(0)
	fiadd word [_W10]
	fmul dword Param(0)
	fmul dword Param(0)
	fmul dword Param(0)

	FrameEnd
	ret

DefFunc _GenPerlinMap2D
	FrameBegin 1, 2, ebx, esi

	invoke_cdecl _CreateSeedVector
	test eax, eax
	jz .fail
	mov esi, eax

	mov ebx, Param(0)
	mov eax, Param(1)
	mov [ebx + FloatMap.border_len], eax
	mul eax
	cmp eax, 4
	jae .success
.fail:
	int3
	jmp .fail
.success:
	mov Variable(0), eax
	invoke_cdecl _aligned_malloc, &[eax * 8], 0x10
	mov [ebx + FloatMap.data], eax
	test eax, eax
	jz .end
	mov ecx, Variable(0)
	shr ecx, 1
	mov edx, [_HaveSSE41]
	movaps xmm2, [_F1111]
	movaps xmm3, [esi]
	movaps xmm4, [_Rand4MulVal]
	movaps xmm5, [_0101]
	movaps xmm6, [_Rand4AddVal]
	movaps xmm7, [_Rand4AndVal]
.generate:
	movaps xmm0, xmm3
	test edx, edx
	jz .no_sse41
	pmulld xmm0, xmm4
	jmp .after_mul
.no_sse41:
	movaps xmm1, xmm0
	psrldq xmm1, 4
	pmuludq xmm0, xmm4
	pmuludq xmm1, xmm4
	pand xmm0, xmm5
	pand xmm1, xmm5
	pslldq xmm1, 4
	paddd xmm0, xmm1
.after_mul:
	paddd xmm0, xmm6
	movaps xmm3, xmm0
	pand xmm0, xmm5
	pand xmm0, xmm7
	paddd xmm0, xmm0
	cvtdq2ps xmm0, xmm0
	cvtdq2ps xmm1, xmm7
	divps xmm0, xmm1
	subps xmm0, xmm2
	movaps [eax], xmm0

	fld dword [eax]
	fldpi
	fmul
	fsincos
	fstp dword [eax]
	fstp dword [eax + 4]
	fld dword [eax + 8]
	fldpi
	fmul
	fsincos
	fstp dword [eax + 8]
	fstp dword [eax + 12]

	add eax, 0x10
	loop .generate

	invoke_cdecl _DestroySeedVector, esi

.end:
	mov eax, [ebx + FloatMap.data]
	FrameEnd
	ret

DefFunc _GetXYFloatMap
	FrameBegin 0, 0, ebx

	xor edx, edx
	mov ebx, Param(2)
	mov eax, Param(1)
	div dword [ebx + FloatMap.border_len]
	mov Param(1), edx
	xor edx, edx
	mov eax, Param(0)
	div dword [ebx + FloatMap.border_len]
	mov Param(0), edx
	mov eax, Param(1)
	mul dword [ebx + FloatMap.border_len]
	add eax, Param(0)
	lea eax, [eax * 4]
	mul dword Param(3)
	add eax, [ebx + FloatMap.data]

	FrameEnd
	ret

DefFunc _ConvertPerlinMapToAltitude
	FrameBegin 9, 4, ebx, esi, edi
	AssignVars _STEPS, _RECIPROCAL, _MATRIX
	AssignVars _X, _Y, _BX, _BY, _IX, _IY
	%define _P00XY_P10XY ebx + 0x00
	%define _P01XY_P11XY ebx + 0x10
	%define _UV1 ebx + 0x20
	%define _UV1M ebx + 0x30
	%define _UV2M ebx + 0x40
	%define _DP_00_10_01_11 ebx + 0x50

	invoke_cdecl _aligned_malloc, 6 * 0x10, 0x10
	mov _MATRIX, eax
	test eax, eax
	jz .end
	xor eax, eax
	mov edx, eax
	mov esi, Param(3)
	mov edi, Param(0)
	mov eax, Param(1)
	mul eax, [esi + FloatMap.border_len]
	mov [edi + FloatMap.border_len], eax
	mov eax, Param(1)
	invoke_cdecl _malloc, &[eax * 4]
	mov _STEPS, eax
	test eax, eax
	jz .end
	xor eax, eax
	mov _X, eax
	fld1
	fidiv dword Param(1)
	fst dword _RECIPROCAL
	mov ebx, _MATRIX
	mov eax, _RECIPROCAL
	movaps xmm0, [_ZeroVector]
	movaps xmm1, [_F1111]
	mov edx, 0x3F800000
	mov ecx, 4
	movaps [_UV1M], xmm0
	movaps [_UV2M], xmm1
.init_uv:
	mov [_UV1 + (ecx - 1) * 4], eax
	loop .init_uv
	mov [_UV1M + Vector.z], edx
	mov [_UV2M + Vector.x], ecx

	mov ebx, _STEPS
.get_steps:
	fild dword _X
	fmul dword _RECIPROCAL
	fstp CallParam(0)
	call _SmootherStep
	fstp dword [ebx]
	add ebx, 4
	mov eax, _X
	inc eax
	mov _X, eax
	cmp eax, Param(1)
	jb .get_steps

	mov ebx, _MATRIX
	mov eax, [edi + FloatMap.border_len]
	mul eax
	invoke_cdecl _aligned_malloc, &[eax * 4], 0x10
	mov [edi + FloatMap.data], eax
	test eax, eax
	jz .end
	xor eax, eax
	mov _Y, eax
.loopy:
	mov eax, _Y
	mul eax, Param(1)
	mov _BY, eax
	xor eax, eax
	mov _X, eax
.loopx:
	mov eax, _X
	mul eax, Param(1)
	mov _BX, eax
	invoke_cdecl _GetXYFloatMap, _X, _Y, esi, 2
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P00XY_P10XY + Vector.x], eax
	mov [_P00XY_P10XY + Vector.y], edx
	mov eax, _X
	inc eax
	invoke_cdecl _GetXYFloatMap, eax, _Y, esi, 2
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P00XY_P10XY + Vector.z], eax
	mov [_P00XY_P10XY + Vector.w], edx
	mov eax, _Y
	inc eax
	invoke_cdecl _GetXYFloatMap, _X, eax, esi, 2
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P01XY_P11XY + Vector.x], eax
	mov [_P01XY_P11XY + Vector.y], edx
	mov eax, _X
	mov ecx, _Y
	inc eax
	inc ecx
	invoke_cdecl _GetXYFloatMap, eax, ecx, esi, 2
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P01XY_P11XY + Vector.z], eax
	mov [_P01XY_P11XY + Vector.w], edx
	xor eax, eax
	mov _IY, eax
.iloopy:
	xor eax, eax
	mov _IX, eax
.iloopx:
	movq xmm0, _IX; xmm0 <= (_IX, _IY) (0, 1)
	movlhps xmm0, xmm0; xmm0 <= (_IX, _IY, _IX, _IY) (0, 1, 2, 3)
	cvtdq2ps xmm0, xmm0; xmm0 <= (4f)xmm0

	movaps xmm1, xmm0
	mulps xmm0, [_UV1]
	mulps xmm1, [_UV1]
	subps xmm0, [_UV1M]
	subps xmm1, [_UV2M]
	mulps xmm0, [_P00XY_P10XY]
	mulps xmm1, [_P01XY_P11XY]
	cmp dword [_HaveSSE3], 0
	jz .no_sse3
	haddps xmm0, xmm1
	movaps [_DP_00_10_01_11], xmm0
	jmp .after_dot
.no_sse3:
	movaps xmm2, xmm0
	shufps xmm2, xmm0, _MM_SHUFFLE(2, 3, 0, 1)
	addps xmm0, xmm2
	shufps xmm0, xmm0, _MM_SHUFFLE(3, 1, 2, 0)
	movaps xmm2, xmm1
	shufps xmm2, xmm1, _MM_SHUFFLE(2, 3, 0, 1)
	addps xmm1, xmm2
	shufps xmm1, xmm1, _MM_SHUFFLE(3, 1, 2, 0)
	movhlps xmm2, xmm0
	movlhps xmm2, xmm1
	movaps [_DP_00_10_01_11], xmm2

.after_dot:
	mov eax, _BX
	mov ecx, _BY
	add eax, _IX
	add ecx, _IY
	invoke_cdecl _GetXYFloatMap, eax, ecx, edi, 1
	mov edx, eax

	mov eax, _IX
	mov ecx, _IY
	lea eax, [eax * 4]
	lea ecx, [ecx * 4]
	add eax, _STEPS
	add ecx, _STEPS

	movss xmm0, [_DP_00_10_01_11 + Vector.y]
	movss xmm1, [_DP_00_10_01_11 + Vector.w]
	subss xmm0, [_DP_00_10_01_11 + Vector.x]
	subss xmm1, [_DP_00_10_01_11 + Vector.z]
	mulss xmm0, [eax]
	mulss xmm1, [eax]
	addss xmm0, [_DP_00_10_01_11 + Vector.x]
	addss xmm1, [_DP_00_10_01_11 + Vector.z]
	subss xmm1, xmm0
	mulss xmm1, [ecx]
	addss xmm0, xmm1
	mulss xmm0, Param(2)
	movss [edx], xmm0

	mov eax, _IX
	inc eax
	mov _IX, eax
	cmp eax, Param(1)
	jb .iloopx

	mov eax, _IY
	inc eax
	mov _IY, eax
	cmp eax, Param(1)
	jb .iloopy

	mov eax, _X
	inc eax
	mov _X, eax
	cmp eax, [esi + FloatMap.border_len]
	jb .loopx

	mov eax, _Y
	inc eax
	mov _Y, eax
	cmp eax, [esi + FloatMap.border_len]
	jb .loopy

.end:
	invoke_cdecl _free, _STEPS
	invoke_cdecl _aligned_free, _MATRIX
	mov eax, [edi + FloatMap.data]
	FrameEnd
	ret
	%undef _STEPS
	%undef _RECIPROCAL
	%undef _MATRIX
	%undef _X
	%undef _Y
	%undef _BX
	%undef _BY
	%undef _IX
	%undef _IY
	%undef _P00XY_P10XY
	%undef _P01XY_P11XY
	%undef _UV1
	%undef _UV1M
	%undef _UV2M
	%undef _DP_00_10_01_11

DefFunc _GenPerlinAltitude
	FrameBegin 1, 4

	invoke_cdecl _calloc, FloatMap.size, 1
	mov Variable(0), eax
	test eax, eax
	jz .fail
	invoke_cdecl _GenPerlinMap2D, Variable(0), Param(1)
	test eax, eax
	jz .fail
	invoke_cdecl _ConvertPerlinMapToAltitude, Param(0), Param(2), Param(3), Variable(0)
	test eax, eax
	jz .fail

	invoke_cdecl _CleanupFloatMap, Variable(0)
	invoke_cdecl _free, Variable(0)
	jmp .end
.fail:
	mov eax, Variable(0)
	test eax, eax
	jz .free_1
	invoke_cdecl _CleanupFloatMap, eax
	invoke_cdecl _free, Variable(0)
.free_1:
	xor eax, eax

.end:
	FrameEnd
	ret
