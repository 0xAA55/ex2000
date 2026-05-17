%include "matrix.inc"
%include "pool.inc"

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
extern _Pi_P
_Pi_P resd 1
extern _Pi_N
_Pi_N resd 1
extern _2Pi
_2Pi resd 1
extern _counter
_counter resd 1
extern _HaveSSE3
_HaveSSE3 resd 1
extern _HaveSSE41
_HaveSSE41 resd 1

segment .bss
alignb 16
extern _ZeroVector
_ZeroVector resd 4
extern _Rand4MulVal
_Rand4MulVal resd 4
extern _Rand4AddVal
_Rand4AddVal resd 4
extern _Rand4AndVal
_Rand4AndVal resd 4
extern _F1111
_F1111 resd 4
extern _F2222
_F2222 resd 4
extern _F3333
_F3333 resd 4
extern _F4444
_F4444 resd 4
extern _F8888
_F8888 resd 4
extern _FCCCC
_FCCCC resd 4
extern _FHHHH
_FHHHH resd 4
extern _I0123
_I0123 resd 4
extern _F0123
_F0123 resd 4
extern _UF0F0
_UF0F0 resd 4
extern _FP5P5P5P5
_FP5P5P5P5 resd 4
extern _IdentityMatrix
_IdentityMatrix resb Matrix.size

segment .rdata
extern _B0123
_B0123 db 0, 1, 2, 3
extern _2.0f
_2.0f dd 0x40000000
extern _M1.0f
_M1.0f dd 0xBF800000
extern _W6
_W6 dw 6
extern _W10
_W10 dw 10
extern _W15
_W15 dw 15
extern _FMAX
_FMAX dd 0x7F7FFFFF
extern _FMIN
_FMIN dd 0xFF7FFFFF

segment .text
DefFunc _MathInit
	FrameBegin 0, 0, ebx

	fldpi
	fldpi
	fadd
	fstp dword [_2Pi]
	fldpi
	fst dword [_Pi_P]
	fchs
	fstp dword [_Pi_N]

	movd xmm0, [_B0123]
	pxor xmm1, xmm1
	punpcklbw xmm0, xmm1
	punpcklwd xmm0, xmm1
	movaps [_I0123], xmm0
	cvtdq2ps xmm0, xmm0
	movaps [_F0123], xmm0

	mov eax, 0x3F800000
	mov ecx, 4
	xor edx, edx
.init_math:
	mov [_IdentityMatrix + edx], eax
	mov [_F1111 + (ecx - 1) * 4], eax
	mov byte  [_FP5P5P5P5 + (ecx - 1) * 4 + 3], 0x3F
	mov dword [_Rand4MulVal + (ecx - 1) * 4], 0x343fD
	mov dword [_Rand4AddVal + (ecx - 1) * 4], 0x269EC3
	mov word  [_Rand4AndVal + (ecx - 1) * 4], 0x7FFF
	add edx, 20
	loop .init_math
	dec ecx
	mov [_UF0F0], ecx
	mov [_UF0F0 + 8], ecx
	movaps xmm0, [_F1111]
	addps xmm0, xmm0
	movaps [_F2222], xmm0
	addps xmm0, [_F1111]
	movaps [_F3333], xmm0
	addps xmm0, [_F1111]
	movaps [_F4444], xmm0
	mulps xmm0, [_F2222]
	movaps [_F8888], xmm0
	addps xmm0, [_F4444]
	movaps [_FCCCC], xmm0
	addps xmm0, [_F4444]
	movaps [_FHHHH], xmm0

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

DefFunc _CreateFloatMap
	FrameBegin 1, 2, ebx, edi

	mov eax, Param(0)
	invoke_cdecl _malloc, &[eax * 4 + FloatMap.head_size]
	mov ebx, eax

	mov eax, Param(0)
	lea ecx, [eax - 1]
	test eax, ecx
	jz .good
.bad:
	int3
	jmp .bad
.good:
	mov [ebx + FloatMap.border_len], eax
	lea edi, [ebx + FloatMap.row_ptr]
	mul eax
	mov ecx, Param(1)
	mov [ebx + FloatMap.num_pixels], eax
	mov [ebx + FloatMap.dims], ecx
	mul ecx
	invoke_cdecl _aligned_malloc, &[eax * 4], 16
	mov [ebx + FloatMap.data], eax

	mov ecx, [ebx + FloatMap.border_len]
	lea eax, [ecx * 4]
	mul dword [ebx + FloatMap.dims]
	mov edx, eax
	mov eax, [ebx + FloatMap.data]
.set_row_ptr:
	stosd
	add eax, edx
	loop .set_row_ptr

	mov eax, ebx

	FrameEnd
	ret

DefFunc _DuplicateFloatMap
	FrameBegin 0, 3, ebx, edi
	mov ebx, Param(0)
	invoke_cdecl _CreateFloatMap, [ebx + FloatMap.border_len], [ebx + FloatMap.dims]
	mov edi, eax
	mov eax, [ebx + FloatMap.num_pixels]
	mul dword [ebx + FloatMap.dims]
	invoke_dll_cdecl memcpy, [edi + FloatMap.data], [ebx + FloatMap.data], &[eax * 4]
	mov eax, edi
	FrameEnd
	ret

DefFunc _DestroyFloatMap
	FrameBegin 0, 1, ebx

	mov ebx, Param(0)
	invoke_cdecl _aligned_free, [ebx + FloatMap.data]
	invoke_cdecl _free, ebx

	FrameEnd
	ret

DefFunc _WarpFloatMap
	FrameBegin 4, 2, ebx, esi, edi
	AssignVars _X, _Y, _BITMASK, _ROWPTR

	mov esi, Param(0)
	invoke_cdecl _CreateFloatMap, [esi + FloatMap.border_len], [esi + FloatMap.dims]
	mov ebx, eax
	mov edi, [eax + FloatMap.data]

	mov eax, [ebx + FloatMap.border_len]
	dec eax
	mov _BITMASK, eax

	xor eax, eax
	mov _Y, eax
.loopy:
	add eax, Param(2)
	and eax, _BITMASK
	mov esi, Param(0)
	mov eax, [esi + FloatMap.row_ptr + eax * 4]
	mov _ROWPTR, eax
	xor eax, eax
	mov _X, eax
.loopx:
	add eax, Param(1)
	and eax, _BITMASK
	mov esi, _ROWPTR
	mov ecx, [ebx + FloatMap.dims]
	mul ecx
	lea esi, [esi + eax * 4]
	rep movsd

	mov eax, _X
	inc eax
	mov _X, eax
	cmp eax, [ebx + FloatMap.border_len]
	jb .loopx

	mov eax, _Y
	inc eax
	mov _Y, eax
	cmp eax, [ebx + FloatMap.border_len]
	jb .loopy

	mov eax, ebx
	FrameEnd
	ret
	%undef _X
	%undef _Y
	%undef _BITMASK
	%undef _ROWPTR

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

DefFunc _CreatePerlinMap2D
	FrameBegin 0, 2, ebx, esi

	invoke_cdecl _CreateFloatMap, Param(0), 2
	mov ebx, eax

	mov eax, Param(0)
	cmp eax, 1
	jae .blae1

	mov esi, [ebx + FloatMap.data]
	invoke_dll_cdecl rand
	shl eax, 1
	sub eax, 0x7FFF
	mov [esi], eax
	fild dword [esi]
	fidiv dword [_Rand4AndVal]
	fldpi
	fmul
	fsincos
	fstp dword [esi]
	fstp dword [esi + 4]

	jmp .end
.blae1:
	invoke_cdecl _CreateSeedVector
	mov esi, eax

	mov eax, [ebx + FloatMap.data]
	mov ecx, [ebx + FloatMap.num_pixels]
	shr ecx, 1
	movaps xmm2, [_F1111]
	movaps xmm3, [esi]
	movaps xmm4, [_Rand4MulVal]
	movaps xmm5, [_UF0F0]
	movaps xmm6, [_Rand4AddVal]
	movaps xmm7, [_Rand4AndVal]
.generate:
	movaps xmm0, xmm3
	pmuludq xmm0, xmm4
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
	mov eax, ebx
	FrameEnd
	ret

DefFunc _GetXYFloatMap
	FrameBegin 0, 0, ebx

	mov ebx, Param(2)

	mov ecx, [ebx + FloatMap.border_len]
	lea edx, [ecx - 1]
	mov eax, Param(0)
	mov ecx, Param(1)
	and eax, edx
	and ecx, edx
	mul dword [ebx + FloatMap.dims]
	mov ecx, [ebx + FloatMap.row_ptr + ecx * 4]
	lea eax, [eax * 4 + ecx]

	FrameEnd
	ret

DefFunc _ConvertPerlinMapToAltitude
	FrameBegin 9, 3, ebx, esi, edi
	AssignVars _STEPS, _RECIPROCAL, _MATRIX
	AssignVars _X, _Y, _BX, _BY, _IX, _IY
	%define _P00XY_P10XY ebx + 0x00
	%define _P01XY_P11XY ebx + 0x10
	%define _UV1 ebx + 0x20
	%define _UV1M ebx + 0x30
	%define _UV2M ebx + 0x40
	%define _DP_00_10_01_11 ebx + 0x50

	mov esi, Param(2)
	mov eax, Param(0)
	mul dword [esi + FloatMap.border_len]
	invoke_cdecl _CreateFloatMap, eax, 1
	mov edi, eax

	invoke_cdecl _aligned_malloc, 6 * 0x10, 0x10
	mov _MATRIX, eax

	mov eax, Param(0)
	invoke_cdecl _malloc, &[eax * 4]
	mov _STEPS, eax
	xor eax, eax
	mov _X, eax
	fld1
	fidiv dword Param(0)
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
	cmp eax, Param(0)
	jb .get_steps

	mov ebx, _MATRIX
	xor eax, eax
	mov _Y, eax
.loopy:
	mov eax, _Y
	mul eax, Param(0)
	mov _BY, eax
	xor eax, eax
	mov _X, eax
.loopx:
	mov eax, _X
	mul eax, Param(0)
	mov _BX, eax
	invoke_cdecl _GetXYFloatMap, _X, _Y, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P00XY_P10XY + Vector.x], eax
	mov [_P00XY_P10XY + Vector.y], edx
	mov eax, _X
	inc eax
	invoke_cdecl _GetXYFloatMap, eax, _Y, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P00XY_P10XY + Vector.z], eax
	mov [_P00XY_P10XY + Vector.w], edx
	mov eax, _Y
	inc eax
	invoke_cdecl _GetXYFloatMap, _X, eax, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P01XY_P11XY + Vector.x], eax
	mov [_P01XY_P11XY + Vector.y], edx
	mov eax, _X
	mov ecx, _Y
	inc eax
	inc ecx
	invoke_cdecl _GetXYFloatMap, eax, ecx, esi
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
	invoke_cdecl _GetXYFloatMap, eax, ecx, edi
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
	movss [edx], xmm0

	mov eax, _IX
	inc eax
	mov _IX, eax
	cmp eax, Param(0)
	jb .iloopx

	mov eax, _IY
	inc eax
	mov _IY, eax
	cmp eax, Param(0)
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

	invoke_cdecl _free, _STEPS
	invoke_cdecl _aligned_free, _MATRIX

	mov ebx, edi
	movaps xmm5, [_FP5P5P5P5]
	movss xmm7, Param(1)
	mov esi, [ebx + FloatMap.data]
	mov eax, [ebx + FloatMap.num_pixels]
	mul dword [ebx + FloatMap.dims]
	test al, 0xF
	jz .batch_proc
	mov ecx, eax
.single_proc:
	movss xmm0, [esi + (ecx - 1) * 4]
	mulss xmm0, xmm5
	addss xmm0, xmm5
	mulss xmm0, xmm7
	movss [esi + (ecx - 1) * 4], xmm0
	loop .single_proc
	jmp .end
.batch_proc:
	shr eax, 4
	mov ecx, eax
	shufps xmm7, xmm7, 0
.batch_loop:
	movaps xmm0, [esi + 0x00]
	movaps xmm1, [esi + 0x10]
	movaps xmm2, [esi + 0x20]
	movaps xmm3, [esi + 0x30]
	mulps xmm0, xmm5
	mulps xmm1, xmm5
	mulps xmm2, xmm5
	mulps xmm3, xmm5
	addps xmm0, xmm5
	addps xmm1, xmm5
	addps xmm2, xmm5
	addps xmm3, xmm5
	mulps xmm0, xmm7
	mulps xmm1, xmm7
	mulps xmm2, xmm7
	mulps xmm3, xmm7
	movaps [esi + 0x00], xmm0
	movaps [esi + 0x10], xmm1
	movaps [esi + 0x20], xmm2
	movaps [esi + 0x30], xmm3
	add esi, 0x40
	loop .batch_loop

.end:
	mov eax, ebx
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
	FrameBegin 0, 3, ebx, edi
	invoke_cdecl _CreatePerlinMap2D, Param(0)
	mov ebx, eax
	invoke_cdecl _ConvertPerlinMapToAltitude, Param(1), Param(2), ebx
	mov edi, eax
	invoke_cdecl _DestroyFloatMap, ebx
	mov eax, edi
	FrameEnd
	ret

DefFunc _AccumulateFloatMap
	FrameBegin 0, 0, esi, edi

	mov esi, Param(1)
	mov edi, Param(0)
	mov eax, [esi + FloatMap.num_pixels]
	mul dword [esi + FloatMap.dims]
	mov ecx, eax
	mov eax, [edi + FloatMap.num_pixels]
	mul dword [edi + FloatMap.dims]
	cmp eax, ecx
	je .good_size
.bad_size:
	int3
	jmp .bad_size
.good_size:
	mov ecx, eax
	mov esi, [esi + FloatMap.data]
	mov edi, [edi + FloatMap.data]
	xor eax, eax
	test ecx, 0xF
	jnz .tail
	shr ecx, 4
.proc:
	movaps xmm0, [esi + eax + 0x00]
	movaps xmm1, [esi + eax + 0x10]
	movaps xmm2, [esi + eax + 0x20]
	movaps xmm3, [esi + eax + 0x30]
	addps xmm0, [edi + eax + 0x00]
	addps xmm1, [edi + eax + 0x10]
	addps xmm2, [edi + eax + 0x20]
	addps xmm3, [edi + eax + 0x30]
	movaps [edi + eax + 0x00], xmm0
	movaps [edi + eax + 0x10], xmm1
	movaps [edi + eax + 0x20], xmm2
	movaps [edi + eax + 0x30], xmm3
	add eax, 64
	loop .proc
	jmp .end
.tail:
	movss xmm0, [esi + eax]
	addss xmm0, [edi + eax]
	movss [edi + eax], xmm0
	add eax, 4
	loop .tail
.end:
	FrameEnd
	ret

DefFunc _MultiplyFloatMap
	FrameBegin 0, 0, esi, edi

	mov esi, Param(1)
	mov edi, Param(0)
	mov eax, [esi + FloatMap.num_pixels]
	mul dword [esi + FloatMap.dims]
	mov ecx, eax
	mov eax, [edi + FloatMap.num_pixels]
	mul dword [edi + FloatMap.dims]
	cmp eax, ecx
	je .good_size
.bad_size:
	int3
	jmp .bad_size
.good_size:
	mov ecx, eax
	mov esi, [esi + FloatMap.data]
	mov edi, [edi + FloatMap.data]
	xor eax, eax
	test ecx, 0xF
	jnz .tail
	shr ecx, 4
.proc:
	movaps xmm0, [esi + eax + 0x00]
	movaps xmm1, [esi + eax + 0x10]
	movaps xmm2, [esi + eax + 0x20]
	movaps xmm3, [esi + eax + 0x30]
	mulps xmm0, [edi + eax + 0x00]
	mulps xmm1, [edi + eax + 0x10]
	mulps xmm2, [edi + eax + 0x20]
	mulps xmm3, [edi + eax + 0x30]
	movaps [edi + eax + 0x00], xmm0
	movaps [edi + eax + 0x10], xmm1
	movaps [edi + eax + 0x20], xmm2
	movaps [edi + eax + 0x30], xmm3
	add eax, 64
	loop .proc
	jmp .end
.tail:
	movss xmm0, [esi + eax]
	mulss xmm0, [edi + eax]
	movss [edi + eax], xmm0
	add eax, 4
	loop .tail
.end:
	FrameEnd
	ret

DefFunc _FloatMapApplyGain
	FrameBegin 0, 0, ebx, esi

	mov ebx, Param(0)

	mov eax, [ebx + FloatMap.num_pixels]
	mul dword[ebx + FloatMap.dims]
	mov esi, [ebx + FloatMap.data]
	movss xmm7, Param(1)
	test al, 0xF
	mov ecx, eax
	jz .batch_proc
.single_proc:
	movss xmm0, [esi + (ecx - 1) * 4]
	mulss xmm0, xmm7
	movss [esi + (ecx - 1) * 4], xmm0
	loop .single_proc
	jmp .end
.batch_proc:
	shr ecx, 4
	shufps xmm7, xmm7, 0
.proc:
	movaps xmm0, [esi + 0x00]
	movaps xmm1, [esi + 0x10]
	movaps xmm2, [esi + 0x20]
	movaps xmm3, [esi + 0x30]
	mulps xmm0, xmm7
	mulps xmm1, xmm7
	mulps xmm2, xmm7
	mulps xmm3, xmm7
	movaps [esi + 0x00], xmm0
	movaps [esi + 0x10], xmm1
	movaps [esi + 0x20], xmm2
	movaps [esi + 0x30], xmm3
	add esi, 0x40
	loop .proc

.end:
	FrameEnd
	ret

struc GenPerlinLayerData
	.perlin_border_len resd 1
	.ratio resd 1
	.amplitude resd 1
	.size equ $ - GenPerlinLayerData
endstruc

DefFunc _GenPerlinLayerPoolProc
	FrameBegin 0, 3, ebx

	mov ebx, Param(0)
	invoke_cdecl _GenPerlinAltitude, \
		[ebx + GenPerlinLayerData.perlin_border_len], \
		[ebx + GenPerlinLayerData.ratio], \
		[ebx + GenPerlinLayerData.amplitude]

	FrameEnd
	ret

DefFunc _GenMultiLayerPerlinAltitude
	FrameBegin 1, 5, ebx, esi, edi
	AssignVars _JOBS

	mov eax, Param(0)
	bsr ecx, eax
	cmp eax, 8
	jae .good_param1
.fail:
	int3
	jmp .fail
.good_param1:
	mov edx, eax
	dec edx
	test edx, eax
	jz .param1_fix_done
	inc ecx
	xor eax, eax
	inc eax
	shl eax, cl
.param1_fix_done:
	mov Param(0), eax
	mov eax, Param(2)
	dec ecx
	cmp ecx, eax
	cmova ecx, eax
	mov Param(2), ecx ; ecx = num_layers = min(bits(eax) - 1, num_layers);

	mov eax, GenPerlinLayerData.size
	mul ecx
	invoke_cdecl _malloc, &[eax + ecx * 4] ; (sizeof GenPerlinLayerData) * num_layers + (sizeof GenPerlinLayerData*) * num_layers
	mov _JOBS, eax
	mov ebx, eax ; ebx = jobs
	mov ecx, Param(2)
	lea esi, &[eax + ecx * 4] ; esi = ebx + (sizeof GenPerlinLayerData*) * num_layers

	mov eax, 1
	mov ecx, Param(2)
	movss xmm0, [_F1111]
	shl eax, ecx
	mov edx, 2
	cvtsi2ss xmm1, eax
	mov eax, Param(0)
	divss xmm0, xmm1
.setjobs1:
	mulss xmm0, [_2.0f]
	shr eax, 1 ; perlin_border_len /= 2
	mov [esi + GenPerlinLayerData.perlin_border_len], eax
	mov [esi + GenPerlinLayerData.ratio], edx
	movss [esi + GenPerlinLayerData.amplitude], xmm0
	shl edx, 1 ; ratio *= 2
	mov [ebx], esi
	add ebx, 4
	add esi, GenPerlinLayerData.size
	loop .setjobs1
	mov ebx, ecx
	inc ebx ; ebx = 1

	invoke_cdecl _PoolRun, _GenPerlinLayerPoolProc, 8, Param(2), _JOBS, 0
	mov edi, eax
.accumulate:
	invoke_cdecl _AccumulateFloatMap, [edi], [edi + ebx * 4]
	invoke_cdecl _DestroyFloatMap, [edi + ebx * 4]
	inc ebx
	cmp ebx, Param(2)
	jb .accumulate

	invoke_cdecl _free, _JOBS
	mov ebx, [edi]
	invoke_cdecl _free, edi

	invoke_cdecl _FloatMapGetMaxValue, ebx
	fdivr dword Param(1)
	fstp dword _JOBS

	invoke_cdecl _FloatMapApplyGain, ebx, _JOBS

	mov eax, ebx
	FrameEnd
	ret
	%undef _JOBS

DefFunc _GenRadiusMap
	FrameBegin 2, 1, ebx, esi, edi
	AssignVars DistSq, Y_Y

	mov eax, Param(0)
	test eax, eax
	jnz .good_param1
.bad_param1:
	int3
	jmp .bad_param1
.good_param1:
	mul eax
	mov DistSq, eax
	shl eax, 2
	invoke_cdecl _malloc, &[eax * 4 + 4]
	mov ebx, eax

	xor eax, eax
	mov [ebx + 4], eax
	inc eax
	mov [ebx], eax
	mov edi, eax
.loopy:
	mov eax, edi
	mul eax
	mov Y_Y, eax ; y * y
	xor eax, eax
	inc eax
	mov esi, eax
.loopx:
	mov eax, esi
	mul eax
	add eax, Y_Y ; x * x + y * y
	cmp eax, DistSq
	jg .continue

	mov eax, [ebx]
	mov [ebx + 4 + eax * 4 + 0x0], si
	mov [ebx + 4 + eax * 4 + 0x2], di
	inc eax
	cmp esi, edi
	jz .continue
	mov [ebx + 4 + eax * 4 + 0x0], di
	mov [ebx + 4 + eax * 4 + 0x2], si
	inc eax

.continue:
	mov [ebx], eax

	inc esi
	cmp esi, edi
	jbe .loopx

	xor edx, edx
	mov [ebx + 4 + eax * 4 + 0x0], di
	mov [ebx + 4 + eax * 4 + 0x2], edx
	mov [ebx + 4 + eax * 4 + 0x6], di
	neg edi
	mov [ebx + 4 + eax * 4 + 0x8], dx
	mov [ebx + 4 + eax * 4 + 0xA], di
	mov [ebx + 4 + eax * 4 + 0xC], di
	mov [ebx + 4 + eax * 4 + 0xE], dx
	neg edi
	add eax, 4
	mov [ebx], eax

	inc edi
	cmp edi, Param(0)
	jb .loopy

	mov eax, ebx
	FrameEnd
	ret
	%undef DistSq
	%undef Y_Y

DefFunc _FloatMapMTPool
	FrameBegin 1, 5, ebx, esi, edi
	AssignVars _JOBS

	; ebx = src_map
	; edi = dst_map
	; esi = cmn_data

	mov ebx, Param(0)

	invoke_cdecl _CreateFloatMap, [ebx + FloatMap.border_len], [ebx + FloatMap.dims]
	mov edi, eax

	invoke_cdecl _malloc, FMDataCmn.size
	mov esi, eax

	mov eax, Param(2)
	mov [esi + FMDataCmn.dst_map], edi
	mov [esi + FMDataCmn.src_map], ebx
	mov [esi + FMDataCmn.userdata], eax

	mov eax, [ebx + FloatMap.border_len]
	invoke_cdecl _malloc, &[eax * 4]
	mov _JOBS, eax

	push edi
	mov edi, eax
	mov ecx, [ebx + FloatMap.border_len]
	mov eax, esi
	rep stosd
	pop edi

	invoke_cdecl _PoolRun, Param(3), Param(1), [ebx + FloatMap.border_len], _JOBS, Param(4)

	invoke_cdecl _free, eax
	invoke_cdecl _free, esi
	invoke_cdecl _free, _JOBS

	mov eax, edi
	FrameEnd
	ret
	%undef _JOBS

DefFunc _FloatMapGaussianBlurPoolProc
	FrameBegin 2, 3, ebx, esi, edi
	AssignVars _X, _Y

	xor eax, eax
	mov ecx, Param(1)
	mov _X, eax
	mov _Y, ecx

	mov ebx, Param(0)
	mov esi, [ebx + FMDataCmn.userdata]
	cvtsi2ss xmm6, [esi]

.proc_pixels:
	xor eax, eax
	mov edi, eax
	movq xmm5, _X
	movd xmm7, eax
	ResetPassReg
	PrepParam 2, [ebx + FMDataCmn.src_map]
.gather_gaussian:
	movd xmm0, [esi + 4 + edi * 4]
	pxor xmm1, xmm1
	pcmpgtw xmm1, xmm0
	punpcklwd xmm0, xmm1
	paddd xmm0, xmm5
	movq CallParam(0), xmm0
	call _GetXYFloatMap
	addss xmm7, [eax]
	inc edi
	cmp edi, [esi]
	jb .gather_gaussian
	divss xmm7, xmm6
	movq xmm0, _X

	ResetPassReg
	PrepParam 2, [ebx + FMDataCmn.dst_map]
	movq CallParam(0), xmm5
	call _GetXYFloatMap
	movss [eax], xmm7

	mov eax, _X
	inc eax
	mov _X, eax
	mov ecx, [ebx + FMDataCmn.src_map]
	cmp eax, [ecx + FloatMap.border_len]
	jb .proc_pixels

	FrameEnd
	ret
	%undef _X
	%undef _Y

DefFunc _FloatMapGaussianBlur
	FrameBegin 1, 5, ebx

	invoke_cdecl _GenRadiusMap, Param(1)
	mov Variable(0), eax
	invoke_cdecl _FloatMapMTPool, Param(0), 8, eax, _FloatMapGaussianBlurPoolProc, 0
	mov ebx, eax
	invoke_cdecl _free, Variable(0)
	mov eax, ebx
	FrameEnd
	ret

; FloatMap *GenDistanceMap(int size);
DefFunc _GenDistanceMap
	FrameBegin 3, 2, ebx, edi
	AssignVars _Y, _SV, _EV

	invoke_cdecl _CreateFloatMap, Param(0), 1
	mov ebx, eax

	mov eax, Param(0)
	shr eax, 1
	mov _EV, eax
	neg eax
	mov _SV, eax
	mov _Y, eax
.loopy:
	sub eax, _SV
	mov edi, [ebx + FloatMap.row_ptr + eax * 4]
	cmp dword Param(0), 16
	jge .vector_process
.single_process:
	mov eax, _SV
.loopx_small:
	cvtsi2ss xmm0, eax
	cvtsi2ss xmm1, _Y
	mulss xmm0, xmm0
	mulss xmm1, xmm1
	addss xmm0, xmm1
	sqrtss xmm0, xmm0
	movss [edi], xmm0
	add edi, 4

	inc eax
	cmp eax, _EV
	jl .loopx_small

	jmp .ycontinue
.vector_process:
	mov eax, _SV
	cvtsi2ss xmm7, _Y
	cvtsi2ss xmm6, _SV
	mulss xmm7, xmm7
	shufps xmm6, xmm6, _MM_SHUFFLE(0, 0, 0, 0)
	shufps xmm7, xmm7, _MM_SHUFFLE(0, 0, 0, 0)
	addps xmm6, [_F0123]
.loopx:
	movaps xmm0, xmm6
	movaps xmm1, xmm6
	movaps xmm2, xmm6
	movaps xmm3, xmm6
	addps xmm1, [_F4444]
	addps xmm2, [_F8888]
	addps xmm3, [_FCCCC]
	addps xmm6, [_FHHHH]
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	mulps xmm3, xmm3
	addps xmm0, xmm7
	addps xmm1, xmm7
	addps xmm2, xmm7
	addps xmm3, xmm7
	sqrtps xmm0, xmm0
	sqrtps xmm1, xmm1
	sqrtps xmm2, xmm2
	sqrtps xmm3, xmm3
	movaps [edi + 0x00], xmm0
	movaps [edi + 0x10], xmm1
	movaps [edi + 0x20], xmm2
	movaps [edi + 0x30], xmm3
	add edi, 0x40
	add eax, 16
	cmp eax, _EV
	jl .loopx

.ycontinue:
	mov eax, _Y
	inc eax
	mov _Y, eax
	cmp eax, _EV
	jl .loopy

	mov eax, ebx

	FrameEnd
	ret
	%undef _Y
	%undef _SV
	%undef _EV

DefFunc _FloatMapGetMaxValue
	FrameBegin 2, 3, ebx, esi, edi
	AssignVars _RET, _NUM_FLOATS

	mov dword _RET, 0xFF7FFFFF
	mov ebx, Param(0)
	mov eax, [ebx + FloatMap.num_pixels]
	mul dword [ebx + FloatMap.dims]
	test eax, eax
	jnz .good
.bad:
	int3
	jmp .bad
.good:
	mov _NUM_FLOATS, eax
	mov esi, [ebx + FloatMap.data]
	invoke_cdecl _aligned_malloc, &[eax * 4], 16
	mov ebx, eax
	mov eax, _NUM_FLOATS
	invoke_dll_cdecl memcpy, ebx, esi, &[eax * 4]
	mov eax, _NUM_FLOATS
.on_choose_methods:
	test al, 0x3F
	jz .vector_process
	test al, 0x3
	jnz .single_process
.four_process:
	mov esi, ebx
	mov ecx, eax
	xor eax, eax
	movaps xmm0, [esi]
	add esi, 16
	add eax, 4
	cmp eax, ecx
	je .after_four
.four_process_loop:
	maxps xmm0, [esi]
	add esi, 16
	add eax, 4
	cmp eax, ecx
	jb .four_process_loop
	movaps [ebx], xmm0
.after_four:
	mov eax, 4
.single_process:
	mov esi, ebx
	mov ecx, eax
	movss xmm0, [esi]
	dec ecx
	jz .result
.single_loop:
	maxss xmm0, [esi + ecx * 4]
	loop .single_loop
.result:
	movss _RET, xmm0
	invoke_cdecl _aligned_free, ebx
	fld dword _RET
	jmp .end
.vector_process:
	mov esi, ebx
	mov edi, ebx
	mov edx, eax
	xor eax, eax
	cmp edx, 64
	jae .loop_64_to_4
	mov _NUM_FLOATS, edx
	mov eax, edx
	jmp .on_choose_methods

.loop_64_to_4:
	movaps xmm0, [esi + 0x00]
	movaps xmm1, [esi + 0x20]
	movaps xmm2, [esi + 0x40]
	movaps xmm3, [esi + 0x60]
	movaps xmm4, [esi + 0x80]
	movaps xmm5, [esi + 0xA0]
	movaps xmm6, [esi + 0xC0]
	movaps xmm7, [esi + 0xE0]
	maxps xmm0, [esi + 0x10]
	maxps xmm1, [esi + 0x30]
	maxps xmm2, [esi + 0x50]
	maxps xmm3, [esi + 0x70]
	maxps xmm4, [esi + 0x90]
	maxps xmm5, [esi + 0xB0]
	maxps xmm6, [esi + 0xD0]
	maxps xmm7, [esi + 0xF0]
	maxps xmm0, xmm1
	maxps xmm2, xmm3
	maxps xmm4, xmm5
	maxps xmm6, xmm7
	maxps xmm0, xmm2
	maxps xmm4, xmm6
	maxps xmm0, xmm4
	movaps [edi], xmm0
	add esi, 0x100
	add edi, 0x10
	add eax, 4
	sub edx, 64
	ja .loop_64_to_4
	jmp .vector_process

.end:
	FrameEnd
	ret
	%undef _RET
	%undef _TMP

DefFunc _FloatMapKMapGenProc
	FrameBegin 7, 3, ebx, esi, edi
	AssignVars _X, _WY, _WM, _HF, _DRP, _MAX, _DMAP

	mov ebx, Param(0)
	mov esi, [ebx + FMDataCmn.src_map]
	mov edi, [ebx + FMDataCmn.dst_map]
	mov eax, [ebx + FMDataCmn.userdata]
	mov eax, [eax + FloatMap.data]
	mov _DMAP, eax

	mov eax, [esi + FloatMap.border_len]
	shr eax, 1
	mov _HF, eax

	mov eax, Param(1)
	add eax, _HF
	mov _WY, eax

	mov eax, Param(1)
	mov eax, [edi + FloatMap.row_ptr + eax * 4]
	mov _DRP, eax

	xor eax, eax
	mov _X, eax
.loopx:
	add eax, _HF
	invoke_cdecl _WarpFloatMap, esi, eax, _WY
	mov ebx, eax

	mov eax, [ebx + FloatMap.data]
	mov edx, _DMAP
	mov ecx, [ebx + FloatMap.num_pixels]
	test cl, 0xF
	jz .vector_process
.single_process:
	movss xmm0, [eax + (ecx - 1) * 4]
	divss xmm0, [edx + (ecx - 1) * 4]
	movss [eax + (ecx - 1) * 4], xmm0
	loop .single_process
	jmp .process_end
.vector_process:
	shr ecx, 4
.vector_loop:
	movaps xmm0, [eax + 0x00]
	movaps xmm1, [eax + 0x10]
	movaps xmm2, [eax + 0x20]
	movaps xmm3, [eax + 0x30]
	mulss xmm0, [edx + 0x00]
	mulss xmm1, [edx + 0x10]
	mulss xmm2, [edx + 0x20]
	mulss xmm3, [edx + 0x30]
	movaps [eax + 0x00], xmm0
	movaps [eax + 0x10], xmm1
	movaps [eax + 0x20], xmm2
	movaps [eax + 0x30], xmm3
	add eax, 0x40
	add edx, 0x40
	loop .vector_loop

.process_end:
	invoke_cdecl _FloatMapGetMaxValue, ebx
	mov _MAX, eax
	invoke_cdecl _DestroyFloatMap, ebx
	mov eax, _X
	mov ecx, _MAX
	mov edx, _DRP
	mov [edx + eax * 4], ecx
	inc eax
	mov _X, eax
	cmp eax, [esi + FloatMap.border_len]
	jb .loopx

	FrameEnd
	ret

DefFunc _FloatMapKMapGen
	FrameBegin 1, 5, ebx, esi
	mov eax, Param(0)
	invoke_cdecl _GenDistanceMap, [eax + FloatMap.border_len]
	mov esi, eax
	invoke_cdecl _FloatMapMTPool, Param(0), 8, esi, _FloatMapKMapGenProc, 0
	mov ebx, eax
	invoke_cdecl _DestroyFloatMap, esi
	mov eax, ebx
	FrameEnd
	ret
