%include "common.inc"

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
