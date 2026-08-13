%include "common.inc"

segment .bss
extern _Pi_P
_Pi_P resd 1
extern _Pi_N
_Pi_N resd 1
extern _2Pi
_2Pi resd 1
extern _HaveSSE3
_HaveSSE3 resd 1
extern _HaveSSE41
_HaveSSE41 resd 1

%macro MakeVector 1
extern %1
%1:
	InstVector
%endmacro

segment .bss
alignb 16
MakeVector _UF000
MakeVector _UFF00
MakeVector _UFFF0
MakeVector _UFFFF
MakeVector _U0FFF
MakeVector _U00FF
MakeVector _U000F
MakeVector _point_001_vector
extern _IdentityMatrix
_IdentityMatrix:
MakeVector _F1000
MakeVector _F0100
MakeVector _F0010
MakeVector _F0001

segment .rdata
extern _2.0f
_2.0f dd 2.0

DefFunc _MathInit
	FrameBegin ebx

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
	jmp .no_sse41

.no_sse2:
	debug_msg "SSE2 is needed for the program to run."
	invoke_dll_stdcall ExitProcess, 1

.no_sse41:
	fldpi
	fldpi
	fadd
	fstp dword [_2Pi]
	fldpi
	fst dword [_Pi_P]
	fchs
	fstp dword [_Pi_N]

	mov eax, __float32__(1.0)
	mov ecx, 4
	xor edx, edx
.init_math_loop:
	mov [_IdentityMatrix + edx], eax
	mov dword [_point_001_vector + (ecx - 1) * 4], __float32__(0.001)
	add edx, 20
	loop .init_math_loop
	dec ecx
	mov [_UF000], ecx
	movd xmm0, ecx
	pshufd xmm0, xmm0, _MM_SHUFFLE(0, 0, 0, 0)
	pshufd xmm1, xmm0, _MM_SHUFFLE(0, 0, 0, 1)
	pshufd xmm2, xmm0, _MM_SHUFFLE(0, 0, 1, 1)
	pshufd xmm3, xmm0, _MM_SHUFFLE(0, 1, 1, 1)
	movdqa [_UFFFF], xmm0
	movdqa [_U0FFF], xmm1
	movdqa [_U00FF], xmm2
	movdqa [_U000F], xmm3
	pxor xmm2, xmm0
	pxor xmm3, xmm0
	movdqa [_UFF00], xmm2
	movdqa [_UFFF0], xmm3
.end:
	FrameEnd
	ret

DefFunc _MathDeInit
	FrameBegin
	FrameEnd
	ret

%ifdef _DEBUG
	DefFunc _FMatrix2DMatrix
		FrameBegin ebx, esi
		NameParams %$DstMat, %$SrcMat

		mov esi, %$SrcMat
		mov edi, %$DstMat

		movaps xmm0, [esi + Matrix.x]
		movaps xmm1, [esi + Matrix.y]
		movaps xmm2, [esi + Matrix.z]
		movaps xmm3, [esi + Matrix.w]

		movhlps xmm4, xmm0
		movhlps xmm5, xmm1
		movhlps xmm6, xmm2
		movhlps xmm7, xmm3

		cvtps2pd xmm0, xmm0
		cvtps2pd xmm1, xmm1
		cvtps2pd xmm2, xmm2
		cvtps2pd xmm3, xmm3
		cvtps2pd xmm4, xmm4
		cvtps2pd xmm5, xmm5
		cvtps2pd xmm6, xmm6
		cvtps2pd xmm7, xmm7

		movaps [edi + DMatrix.xx], xmm0
		movaps [edi + DMatrix.xz], xmm4
		movaps [edi + DMatrix.yx], xmm1
		movaps [edi + DMatrix.yz], xmm5
		movaps [edi + DMatrix.zx], xmm2
		movaps [edi + DMatrix.zz], xmm6
		movaps [edi + DMatrix.wx], xmm3
		movaps [edi + DMatrix.wz], xmm7

		FrameEnd
		ret
%endif
