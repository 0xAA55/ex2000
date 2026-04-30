%include "loaddll.inc"

%define MATRIX_ASM 1
%include "matrix.inc"

%define _MM_SHUFFLE(fp3,fp2,fp1,fp0) (((fp3) << 6) | ((fp2) << 4) | ((fp1) << 2) | ((fp0)))

import_dll_func memcpy
import_dll_func memset
import_dll_func cos
import_dll_func sin

segment .bss
alignb 16
global _ZeroVector
_ZeroVector resd 4

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

DefFunc _PreMatRot
	fld dword [eax]
	fld st0
	fcos
	fst dword [edx + 0]
	fsin
	fld st0
	fst dword [edx + 4]
	fchs
	fst dword [edx + 8]
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

DefFunc _MatrixRotationX
	FrameBegin 3, 1

	invoke_cdecl _MatrixIdentity, Param(0)

	lea eax, Param(1)
	lea edx, Variable(0)
	call _PreMatRot

	LoadParam eax, 0
	mov ecx, Variable(0)
	mov edx, Variable(1)

	mov [eax + Matrix.yy], ecx
	mov [eax + Matrix.yz], edx
	mov [eax + Matrix.zz], ecx
	mov edx, Variable(2)
	mov [eax + Matrix.zy], edx

	FrameEnd
	ret

DefFunc _MatrixRotationY
	FrameBegin 3, 1

	invoke_cdecl _MatrixIdentity, Param(0)

	lea eax, Param(1)
	lea edx, Variable(0)
	call _PreMatRot

	mov eax, Param(0)
	mov ecx, Variable(0)
	mov edx, Variable(1)

	mov [eax + Matrix.xx], ecx
	mov [eax + Matrix.zx], edx
	mov [eax + Matrix.zz], ecx
	mov edx, Variable(2)
	mov [eax + Matrix.xz], edx

	FrameEnd
	ret

DefFunc _MatrixRotationZ
	FrameBegin 3, 1

	invoke_cdecl _MatrixIdentity, Param(0)

	lea eax, Param(1)
	lea edx, Variable(0)
	call _PreMatRot

	mov eax, Param(0)
	mov ecx, Variable(0)
	mov edx, Variable(1)

	mov [eax + Matrix.xx], ecx
	mov [eax + Matrix.xy], edx
	mov [eax + Matrix.yy], ecx
	mov edx, Variable(2)
	mov [eax + Matrix.yx], edx

	FrameEnd
	ret

; void MatrixRotationEuler(Matrix_p out, float yaw, float pitch, float roll)
DefFunc _MatrixRotationEuler
	FrameBegin 15, 0, edi
	AssignVars _CY, _SY, _CP, _SP, _CR, _SR, _CPCR, _CRSP, _SRCP, _SRSP, _ZR, _H4, _H5, _H6, _H7

	xor eax, eax
	mov _ZR, eax
	mov ecx, 3
	mov edx, 1
	mov edi, Param(0)
	movaps xmm0, [_ZeroVector]
	movaps [edi + Matrix.x], xmm0
	movaps [edi + Matrix.y], xmm0
	movaps [edi + Matrix.z], xmm0
	movaps [edi + Matrix.w], xmm0
.cysycpspcrsr:
	fld dword Param(edx)
	fld st0
	fcos
	fstp dword Variable(eax)
	fsin
	fstp dword Variable(eax + 1)
	ffree st0
	inc edx
	add al, 2
	loop .cysycpspcrsr

	movss xmm0, _CP
	movss xmm1, _CR
	movss xmm2, _SR
	movss xmm3, _SR
	mulss xmm0, _CR
	mulss xmm1, _SP
	mulss xmm2, _CP
	mulss xmm3, _SP
	movss _CPCR, xmm0
	movss _CRSP, xmm1
	movss _SRCP, xmm2
	movss _SRSP, xmm3

	movss _H4, xmm4
	movss _H5, xmm5
	movss _H6, xmm6
	movss _H7, xmm7

	movss xmm0, _CY
	movss xmm1, _SY
	movss xmm2, _SRCP
	movss xmm3, _SRSP
	movss xmm4, _CR
	movss xmm5, _SY
	movss xmm6, _CY
	movss xmm7, _CPCR
	mulss xmm0, _CR
	mulss xmm1, _SRSP
	mulss xmm3, _CY
	mulss xmm4, _SY
	mulss xmm5, _CRSP
	mulss xmm6, _SR
	addss xmm0, xmm1
	subss xmm3, xmm4
	subss xmm5, xmm6
	movss [edi + Matrix.xx], xmm0
	movss [edi + Matrix.xy], xmm2
	movss [edi + Matrix.xz], xmm3
	movss [edi + Matrix.yx], xmm5
	movss [edi + Matrix.yy], xmm7

	movss xmm0, _SY
	movss xmm1, _CRSP
	movss xmm2, _SY
	movss xmm3, _ZR
	movss xmm4, _CY
	mulss xmm0, _SR
	mulss xmm1, _CY
	mulss xmm2, _CP
	subss xmm3, _SP
	mulss xmm4, _CP
	addss xmm0, xmm1

	movss [edi + Matrix.yz], xmm0
	movss [edi + Matrix.zx], xmm2
	movss [edi + Matrix.zy], xmm3
	movss [edi + Matrix.zz], xmm4
	mov dword [edi + Matrix.ww], 0x3F800000

	movss xmm4, _H4
	movss xmm5, _H5
	movss xmm6, _H6
	movss xmm7, _H7

	FrameEnd
	ret
	%undef _CY
	%undef _SY
	%undef _CP
	%undef _SP
	%undef _CR
	%undef _SR
	%undef _CPCR
	%undef _CRSP
	%undef _SRCP
	%undef _SRSP
	%undef _ZR
	%undef _H4
	%undef _H5
	%undef _H6
	%undef _H7

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
	fld dword [esi + eax + Vector.x]
	fmul dword [edx + Vector.x]
	fld dword [esi + eax + Vector.y]
	fmul dword [edx + Vector.y]
	fadd
	fld dword [esi + eax + Vector.z]
	fmul dword [edx + Vector.z]
	fadd
	fchs
	fstp dword [esi + eax + Vector.w]

	add eax, 0x10
	cmp eax, 0x30
	jb .w

	invoke_cdecl _MatrixTranspose, Param(0), esi

	FrameEnd
	ret

DefFunc _MatrixTranspose
	FrameBegin 0x14, 0

	mov eax, Param(1)
	lea ecx, Variable(4)
	mov edx, Param(0)

	and ecx, 0xFFFFFFF0
	movaps [ecx + 0x00], xmm4
	movaps [ecx + 0x10], xmm5
	movaps [ecx + 0x20], xmm6
	movaps [ecx + 0x30], xmm7

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

	movaps xmm1, xmm4
	movaps xmm3, xmm5
	shufps xmm1, xmm3, 0x88
	movaps [edx + Matrix.x], xmm1
	movaps xmm1, xmm4
	shufps xmm1, xmm3, 0xDD
	movaps [edx + Matrix.y], xmm1
	movaps xmm1, xmm6
	movaps xmm3, xmm7
	shufps xmm1, xmm3, 0x88
	movaps [edx + Matrix.z], xmm1
	movaps xmm1, xmm6
	shufps xmm1, xmm3, 0xDD
	movaps [edx + Matrix.w], xmm1

	movaps xmm4, [ecx + 0x00]
	movaps xmm5, [ecx + 0x10]
	movaps xmm6, [ecx + 0x20]
	movaps xmm7, [ecx + 0x30]

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
