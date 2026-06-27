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
MakeVector _Rand4MulVal
MakeVector _Rand4AddVal
MakeVector _Rand4AndVal
MakeVector _FPMPM
MakeVector _FMPMP
MakeVector _FMMMM
MakeVector _F1111
MakeVector _F2222
MakeVector _F3333
MakeVector _F4444
MakeVector _F8888
MakeVector _FCCCC
MakeVector _FHHHH
MakeVector _I0123
MakeVector _F0123
MakeVector _UF0F0
MakeVector _U0F0F
MakeVector _UF000
MakeVector _UFF00
MakeVector _UFFF0
MakeVector _UFFFF
MakeVector _U0FFF
MakeVector _U00FF
MakeVector _U000F
MakeVector _ZeroVector
MakeVector _FP5P5P5P5
MakeVector _point_001_vector
extern _IdentityMatrix
_IdentityMatrix:
MakeVector _F1000
MakeVector _F0100
MakeVector _F0010
MakeVector _F0001

segment .rdata
extern _B0123
_B0123 db 0, 1, 2, 3
extern _2.0f
_2.0f dd 2.0
extern _100.0f
_100.0f dd 100.0
extern _M1.0f
_M1.0f dd -1.0
extern _M2.0f
_M2.0f dd -2.0
extern _FMAX
_FMAX dd 0x7F7FFFFF
extern _FMIN
_FMIN dd 0xFF7FFFFF
extern _W6
_W6 dw 6
extern _W10
_W10 dw 10
extern _W15
_W15 dw 15

DefFunc _MathInit
	FrameBegin 0, ebx

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

	movd xmm0, [_B0123]
	pxor xmm1, xmm1
	punpcklbw xmm0, xmm1
	punpcklwd xmm0, xmm1
	movdqa [_I0123], xmm0
	cvtdq2ps xmm0, xmm0
	movaps [_F0123], xmm0

	mov eax, __?float32?__(1.0)
	mov ecx, 4
	xor edx, edx
.init_math_loop:
	mov [_IdentityMatrix + edx], eax
	mov [_F1111 + (ecx - 1) * 4], eax
	mov dword [_point_001_vector + (ecx - 1) * 4], __?float32?__(0.001)
	mov byte  [_FP5P5P5P5 + (ecx - 1) * 4 + 3], 0x3F
	mov dword [_Rand4MulVal + (ecx - 1) * 4], 0x343fD
	mov dword [_Rand4AddVal + (ecx - 1) * 4], 0x269EC3
	mov word  [_Rand4AndVal + (ecx - 1) * 4], 0x7FFF
	add edx, 20
	loop .init_math_loop
	xorps xmm0, xmm0
	movaps xmm1, [_F1111]
	movaps xmm2, [_F1111]
	subps xmm0, xmm1
	movaps [_FMMMM], xmm0
	unpcklps xmm1, xmm0
	unpcklps xmm0, xmm2
	movaps [_FPMPM], xmm1
	movaps [_FMPMP], xmm0
	dec ecx
	mov [_UF000], ecx
	movdqa xmm0, [_UF000]
	pshufd xmm0, xmm0, _MM_SHUFFLE(1, 0, 1, 0)
	pshufd xmm1, xmm0, _MM_SHUFFLE(0, 0, 0, 0)
	pshufd xmm2, xmm0, _MM_SHUFFLE(0, 0, 0, 1)
	pshufd xmm3, xmm0, _MM_SHUFFLE(0, 0, 1, 1)
	pshufd xmm4, xmm0, _MM_SHUFFLE(0, 1, 1, 1)
	movdqa [_UF0F0], xmm0
	movdqa [_UFFFF], xmm1
	movdqa [_U0FFF], xmm2
	movdqa [_U00FF], xmm3
	movdqa [_U000F], xmm4
	pxor xmm0, xmm1
	pxor xmm3, xmm1
	pxor xmm4, xmm1
	movdqa [_U0F0F], xmm0
	movdqa [_UFF00], xmm3
	movdqa [_UFFF0], xmm4
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
.end:
	FrameEnd
	ret

DefFunc _MathDeInit
	FrameBegin 0
	FrameEnd
	ret

%ifdef _DEBUG
	DefFunc _FMatrix2DMatrix
		FrameBegin 0, ebx, esi

		mov esi, Param(1)
		mov edi, Param(0)

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

	DefFunc _DebugMatrix
		FrameBegin 0, ebx
		invoke_cdecl _aligned_malloc, Matrix.size * 2, 0x10
		mov ebx, eax
		invoke_cdecl _FMatrix2DMatrix, ebx, Param(2)
		invoke_cdecl _DebugShowV, Param(0), Param(1), .format, ebx
		invoke_cdecl _aligned_free, ebx
		FrameEnd
		ret
	segment .rdata
		.format:
			db "%.2f", 0x9, "%.2f", 0x9, "%.2f", 0x9, "%.2f", 0x9, 0xd, 0xa
			db "%.2f", 0x9, "%.2f", 0x9, "%.2f", 0x9, "%.2f", 0x9, 0xd, 0xa
			db "%.2f", 0x9, "%.2f", 0x9, "%.2f", 0x9, "%.2f", 0x9, 0xd, 0xa
			db "%.2f", 0x9, "%.2f", 0x9, "%.2f", 0x9, "%.2f", 0x9, 0xd, 0xa, 0
%endif
