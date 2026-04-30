%include "loaddll.inc"

%define MATRIX_ASM 1
%include "matrix.inc"

%define _MM_SHUFFLE(fp3,fp2,fp1,fp0) (((fp3) << 6) | ((fp2) << 4) | ((fp1) << 2) | ((fp0)))

import_dll_func memcpy
import_dll_func memset
import_dll_func cos
import_dll_func sin

segment .bss
align 16
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
	FrameBegin 0x10, 2, esi

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

	LoadParam eax, 0
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

	LoadParam edi, 0
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

	LoadParam eax, 0
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

	LoadParam eax, 0
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
	FrameBegin 18, 3, edi
	AssignVars _CY, _SY, _CP, _SP, _CR, _SR, _CPCR, _CRSP, _SRCP, _SRSP, _ZR1, _ZR2, _ZR3, _ZR4

	mov edi, Param(0)
	xor eax, eax
	mov edx, 1
	mov ecx, 4
	lea edi, _ZR1
	rep stosd
	mov edi, Param(0)
	movups xmm0, _ZR1
	movaps [edi + Matrix.x], xmm0
	movaps [edi + Matrix.y], xmm0
	movaps [edi + Matrix.z], xmm0
	movaps [edi + Matrix.w], xmm0
	mov cl, 3
.cysycpspcrsr:
	fld dword Param(edx)
	fld st0
	fcos
	fst dword Variable(eax)
	fsin
	fst dword Variable(eax + 1)
	inc edx
	add al, 2
	loop .cysycpspcrsr

	movss Variable(14), xmm4
	movss Variable(15), xmm5
	movss Variable(16), xmm6
	movss Variable(17), xmm7

	movss xmm0, _CY
	movss xmm1, _SY
	movss xmm2, _SRCP
	movss xmm3, _SRSP
	movss xmm4, _CR
	movss xmm7, _CPCR
	movss xmm5, xmm1
	movss xmm6, xmm0
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
	movss xmm2, xmm0
	movss xmm3, _ZR1
	movss xmm4, _CY
	mulss xmm0, _SR
	mulss xmm1, xmm4
	mulss xmm2, _CP
	subss xmm3, _SP
	mulss xmm4, _CP
	addss xmm0, xmm1

	movss [edi + Matrix.yz], xmm0
	movss [edi + Matrix.zx], xmm2
	movss [edi + Matrix.zy], xmm3
	movss [edi + Matrix.zz], xmm4
	mov dword [edi + Matrix.ww], 0x3F800000

	movss xmm4, Variable(14)
	movss xmm5, Variable(15)
	movss xmm6, Variable(16)
	movss xmm7, Variable(17)

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
	%undef _ZR1
	%undef _ZR2
	%undef _ZR3
	%undef _ZR4

DefFunc _MatrixTranspose
	FrameBegin 0x10, 0

	LoadParam edx, 0
	LoadParam eax, 1

	movups Variable(0x00), xmm4
	movups Variable(0x04), xmm5
	movups Variable(0x08), xmm6
	movups Variable(0x0C), xmm7

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

	movups xmm4, Variable(0x00)
	movups xmm5, Variable(0x04)
	movups xmm6, Variable(0x08)
	movups xmm7, Variable(0x0C)

	FrameEnd
	ret

DefFunc _MatrixMultiply
	FrameBegin 0, 3, esi, edi

	LoadParam edi, 0
	LoadParam esi, 1

	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.x], &[esi + Matrix.x], Param(2)
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.y], &[esi + Matrix.y], Param(2)
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.z], &[esi + Matrix.z], Param(2)
	invoke_cdecl _VectorMultMatrix, &[edi + Matrix.w], &[esi + Matrix.w], Param(2)

	FrameEnd
	ret

DefFunc _MatrixMultiplyTransposed
	FrameBegin 0, 3, esi, edi

	LoadParam edi, 0
	LoadParam esi, 1

	invoke_cdecl _VectorMultMatrixTransposed, &[edi + Matrix.x], &[esi + Matrix.x], Param(2)
	invoke_cdecl _VectorMultMatrixTransposed, &[edi + Matrix.y], &[esi + Matrix.y], Param(2)
	invoke_cdecl _VectorMultMatrixTransposed, &[edi + Matrix.z], &[esi + Matrix.z], Param(2)
	invoke_cdecl _VectorMultMatrixTransposed, &[edi + Matrix.w], &[esi + Matrix.w], Param(2)

	FrameEnd
	ret
