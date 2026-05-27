%include "common.inc"

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
extern _Rand4MulVal
_Rand4MulVal resd 4
extern _Rand4AddVal
_Rand4AddVal resd 4
extern _Rand4AndVal
_Rand4AndVal resd 4
extern _FPMPM
_FPMPM resd 4
extern _FMPMP
_FMPMP resd 4
extern _FMMMM
_FMMMM resd 4
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
extern _UF000
_UF000 resd 4
extern _UFF00
_UFF00 resd 4
extern _UFFF0
_UFFF0 resd 4
extern _UFFFF
_UFFFF resd 4
extern _U0FFF
_U0FFF resd 4
extern _U00FF
_U00FF resd 4
extern _U000F
_U000F resd 4
extern _ZeroVector
_ZeroVector resd 4
extern _FP5P5P5P5
_FP5P5P5P5 resd 4
extern _point_001_vector
_point_001_vector resd 4
extern _IdentityMatrix
_IdentityMatrix:
extern _F1000
extern _F0100
extern _F0010
extern _F0001
_F1000 resd 4
_F0100 resd 4
_F0010 resd 4
_F0001 resd 4

segment .rdata
extern _B0123
_B0123 db 0, 1, 2, 3
extern _2.0f
_2.0f dd __?float32?__(2.0)
extern _M1.0f
_M1.0f dd __?float32?__(-1.0)
extern _M2.0f
_M2.0f dd __?float32?__(-2.0)
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

DefFunc _MathInit
	FrameBegin 0, 0, ebx

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
	mov [_FPMPM + (ecx - 1) * 4], eax
	mov dword [_point_001_vector + (ecx - 1) * 4], __?float32?__(0.001)
	mov byte  [_FP5P5P5P5 + (ecx - 1) * 4 + 3], 0x3F
	mov dword [_Rand4MulVal + (ecx - 1) * 4], 0x343fD
	mov dword [_Rand4AddVal + (ecx - 1) * 4], 0x269EC3
	mov word  [_Rand4AndVal + (ecx - 1) * 4], 0x7FFF
	add edx, 20
	loop .init_math_loop
	mov eax, ecx
	mov al, 1
	shl eax, 31
	or [_FPMPM + 0x4], eax
	or [_FPMPM + 0xC], eax
	pxor xmm0, xmm0
	pxor xmm1, xmm1
	subps xmm0, [_F1111]
	subps xmm1, [_FPMPM]
	movaps [_FMMMM], xmm0
	movaps [_FPMPM], xmm1
	dec ecx
	mov [_UF000], ecx
	movdqa xmm0, [_UF000]
	pshufd xmm0, xmm0, _MM_SHUFFLE(1, 0, 1, 0)
	pshufd xmm1, xmm0, _MM_SHUFFLE(0, 0, 0, 1)
	pshufd xmm2, xmm0, _MM_SHUFFLE(0, 0, 1, 1)
	pshufd xmm3, xmm0, _MM_SHUFFLE(0, 1, 1, 1)
	pshufd xmm4, xmm0, _MM_SHUFFLE(0, 0, 0, 0)
	movdqa [_UF0F0], xmm0
	movdqa [_U0FFF], xmm1
	movdqa [_U00FF], xmm2
	movdqa [_U000F], xmm3
	movdqa [_UFFFF], xmm4
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
	pxor xmm2, xmm4
	pxor xmm3, xmm4
	movdqa [_UFF00], xmm2
	movdqa [_UFFF0], xmm3
.end:
	FrameEnd
	ret

DefFunc _MathDeInit
	FrameBegin 0, 0
	FrameEnd
	ret

DefFunc _FMatrix2DMatrix
	FrameBegin 0, 0, ebx, esi

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

%ifdef _DEBUG
	DefFunc _DebugMatrix
		FrameBegin 0, 4, ebx
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
