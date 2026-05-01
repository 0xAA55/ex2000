%include "loaddll.inc"

%define MATRIX_ASM 1
%include "matrix.inc"

%define _MM_SHUFFLE(fp3,fp2,fp1,fp0) (((fp3) << 6) | ((fp2) << 4) | ((fp1) << 2) | ((fp0)))

extern _aligned_malloc
extern _aligned_free

import_dll_func memcpy
import_dll_func memset
import_dll_func cos
import_dll_func sin

segment .bss
alignb 16
global _ZeroVector
_ZeroVector resd 4

segment .rdata
global _2.0f
_2.0f dd 0x40000000

segment .text
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

DefFunc _VectorMultMatrixTransposed
	FrameBegin 0x14, 2, esi

	lea esi, Variable(4)
	and esi, 0xFFFFFFF0

	mov eax, Param(2)
	mov ecx, Param(1)

	movaps xmm1, [ecx]
	mulps xmm1, [eax + Matrix.x]
	movaps [esi + Matrix.x], xmm1
	movaps xmm1, [ecx]
	mulps xmm1, [eax + Matrix.y]
	movaps [esi + Matrix.y], xmm1
	movaps xmm1, [ecx]
	mulps xmm1, [eax + Matrix.z]
	movaps [esi + Matrix.z], xmm1
	movaps xmm1, [ecx]
	mulps xmm1, [eax + Matrix.w]
	movaps [esi + Matrix.w], xmm1

	invoke_cdecl _MatrixTranspose, esi, esi

	movaps xmm0, [esi + Matrix.x]
	movaps xmm1, [esi + Matrix.y]
	addps xmm0, [esi + Matrix.z]
	addps xmm1, [esi + Matrix.w]
	addps xmm0, xmm1

	mov eax, Param(0)
	movaps [eax], xmm0

	FrameEnd
	ret

DefFunc _MatrixIdentity
	FrameBegin 0, 0, edi

	mov edi, Param(0)
	movaps xmm0, [_ZeroVector]
	mov ecx, 4
	xor eax, eax
.fillzero:
	movaps [edi + eax], xmm0
	add al, 16
	loop .fillzero

	mov eax, 0x3F800000
	mov [edi + Matrix.xx], eax
	mov [edi + Matrix.yy], eax
	mov [edi + Matrix.zz], eax
	mov [edi + Matrix.ww], eax

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
	;yy = _CRCPMSR;
	;yz = _CRSPMSR;
	;yw = -_SR;
	;zx = _CR * SY + ZR12 + ZR27 + 0.0;
	;zy = _CPSR * _SY - _SP * _CY;
	;zz = _SPSR * _SY + _CY * CP;
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
	subss xmm2, _SR
	addss xmm4, xmm5
	subss xmm6, xmm7
	movss _CPSR, xmm0
	movss _SPSR, xmm1
	movss [eax + Matrix.xx], xmm3
	movss [eax + Matrix.xy], xmm4
	movss [eax + Matrix.xz], xmm6
	movss [eax + Matrix.yy], xmm2

	movss xmm0, _CR
	movss xmm1, [_ZeroVector]
	movss xmm2, _CR
	movss xmm3, _CPSR
	movss xmm4, _SP
	movss xmm5, _SPSR
	movss xmm6, _CY
	mulss xmm0, _SP
	subss xmm1, _SR
	mulss xmm2, _SY
	mulss xmm3, _SY
	mulss xmm4, _CY
	mulss xmm5, _SY
	mulss xmm6, _CP
	subss xmm0, _SR
	subss xmm3, xmm4
	addss xmm5, xmm6
	movss [eax + Matrix.yz], xmm0
	movss [eax + Matrix.yx], xmm1
	movss [eax + Matrix.yw], xmm1
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

DefFunc _MatrixLookAt
	FrameBegin 0x14, 3, esi

	lea esi, Variable(4)
	and esi, 0xFFFFFFF0

	xor eax, eax
	mov [esi + 0x20 + Vector.w], eax
	invoke_cdecl _VectorNormal, &[esi + 0x20], Param(2), 3
	mov eax, Param(3)
	invoke_cdecl _VectorCross, esi, eax, &[esi + 0x20]
	invoke_cdecl _VectorCross, &[esi + 0x10], &[esi + 0x20], esi

	movaps xmm0, [_ZeroVector]
	movaps [esi + 0x30], xmm0
	mov dword[esi + 0x30 + Vector.w], 0x3F800000

	xor eax, eax
	mov edx, Param(1)
.w:
	movss xmm0, [esi + eax + Vector.x]
	movss xmm1, [esi + eax + Vector.y]
	movss xmm2, [esi + eax + Vector.z]
	movss xmm3, [_ZeroVector]
	mulss xmm0, [edx + Vector.x]
	mulss xmm1, [edx + Vector.y]
	mulss xmm2, [edx + Vector.z]
	addss xmm0, xmm1
	addss xmm0, xmm2
	subss xmm3, xmm0
	movss [esi + eax + Vector.w], xmm3

	add eax, 0x10
	cmp eax, 0x30
	jb .w

	invoke_cdecl _MatrixTranspose, Param(0), esi

	FrameEnd
	ret

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

DefFunc _MatrixMultiplyTransposed
	FrameBegin 0, 3, esi, edi

	mov esi, Param(1)
	mov edi, Param(0)

	invoke_cdecl _VectorMultMatrixTransposed, &[edi + Matrix.x], &[esi + Matrix.x], Param(2)
	invoke_cdecl _VectorMultMatrixTransposed, &[edi + Matrix.y], &[esi + Matrix.y], Param(2)
	invoke_cdecl _VectorMultMatrixTransposed, &[edi + Matrix.z], &[esi + Matrix.z], Param(2)
	invoke_cdecl _VectorMultMatrixTransposed, &[edi + Matrix.w], &[esi + Matrix.w], Param(2)

	FrameEnd
	ret
