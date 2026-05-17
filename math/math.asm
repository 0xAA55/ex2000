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
