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
DefFunc _VectorMultMatrix
	FrameBegin 0, 0

	LoadParam eax, 2

	movaps xmm2, Param(1)
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

	movaps Param(0), xmm0

	FrameEnd
	ret

DefFunc _VectorMultMatrixTransposed
	FrameBegin 20, 2, esi

	lea esi, Variable(4)
	and esi, 0xFFFFFFF0

	LoadParam eax, 2

	movaps xmm1, Param(1)
	mulps xmm1, [eax + Matrix.x]
	movaps [esi + Matrix.x], xmm1
	movaps xmm1, Param(1)
	mulps xmm1, [eax + Matrix.y]
	movaps [esi + Matrix.y], xmm1
	movaps xmm1, Param(1)
	mulps xmm1, [eax + Matrix.z]
	movaps [esi + Matrix.z], xmm1
	movaps xmm1, Param(1)
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
	AssignVars _CY, _SY, _CP, _SP, _CR, _SR, _CPCR, _CRSP, _SRCP, _SRSP, _ZR
	FrameBegin 11, 2, ebx

	mov ebx, Param(0)
	xor eax, eax
	mov edx, 1
	mov ecx, 3
	mov _ZR, eax
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
	movss xmm2, _CY
	movss xmm3, _SR
	movss xmm4, xmm1
	movss xmm5, _ZR
	movss xmm6, _CR
	movss xmm7, _SY
	mulss xmm1, _SY
	mulss xmm2, _SR
	mulss xmm3, _SY
	mulss xmm4, _CY
	mulss xmm6, _CY
	subss xmm5, _SRCP
	mulss xmm7, _SRSP
	addss xmm1, xmm2
	addss xmm3, xmm4
	subss xmm6, xmm7
	movss xmm2, _ZR

	movss [ebx + Matrix.xx], xmm0
	movss [ebx + Matrix.xy], xmm1
	movss [ebx + Matrix.xz], xmm3
	movss [ebx + Matrix.xw], xmm2
	movss [ebx + Matrix.yx], xmm5
	movss [ebx + Matrix.yy], xmm6

	movss xmm0, _SY
	movss xmm1, _SRSP
	movss xmm2, _ZR
	movss xmm3, _CP
	movss xmm4, _ZR
	movss xmm5, _ZR
	movss xmm6, _SP
	mulss xmm0, _CR
	mulss xmm1, _CY
	subss xmm2, _SY
	mulss xmm3, _CY
	subss xmm4, _SY
	addss xmm0, xmm1
	mulss xmm2, _CP

	movss [ebx + Matrix.yz], xmm0
	movss [ebx + Matrix.yw], xmm5
	movss [ebx + Matrix.zx], xmm6
	movss [ebx + Matrix.zy], xmm2
	movss [ebx + Matrix.zz], xmm3
	movss [ebx + Matrix.zw], xmm5
	movss [ebx + Matrix.wx], xmm5
	movss [ebx + Matrix.wy], xmm4
	movss [ebx + Matrix.wz], xmm5
	mov dword [ebx + Matrix.ww], 0x3F800000

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

DefFunc _MatrixTranspose
	FrameBegin 0, 0

	LoadParam edx, 0
	LoadParam eax, 1

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

	FrameEnd
	ret

DefFunc _MatrixMultiply
	FrameBegin 0, 3, esi, edi

	LoadParam edi, 0
	LoadParam esi, 1

	invoke_cdecl _VectorMultMatrix, [edi + Matrix.x], [esi + Matrix.x], Param(2)
	invoke_cdecl _VectorMultMatrix, [edi + Matrix.y], [esi + Matrix.y], Param(2)
	invoke_cdecl _VectorMultMatrix, [edi + Matrix.z], [esi + Matrix.z], Param(2)
	invoke_cdecl _VectorMultMatrix, [edi + Matrix.w], [esi + Matrix.w], Param(2)

	FrameEnd
	ret

DefFunc _MatrixMultiplyTransposed
	FrameBegin 0, 3, esi, edi

	LoadParam edi, 0
	LoadParam esi, 1

	invoke_cdecl _VectorMultMatrixTransposed, [edi + Matrix.x], [esi + Matrix.x], Param(2)
	invoke_cdecl _VectorMultMatrixTransposed, [edi + Matrix.y], [esi + Matrix.y], Param(2)
	invoke_cdecl _VectorMultMatrixTransposed, [edi + Matrix.z], [esi + Matrix.z], Param(2)
	invoke_cdecl _VectorMultMatrixTransposed, [edi + Matrix.w], [esi + Matrix.w], Param(2)

	FrameEnd
	ret
