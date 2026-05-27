%include "common.inc"

DefFunc _FloatMapClamp
	FrameBegin 0, 0, ebx, edi

	movss xmm6, Param(1)
	movss xmm7, Param(2)
	mov ebx, Param(0)
	shufps xmm6, xmm6, 0
	shufps xmm7, xmm7, 0

	mov edi, [ebx + FloatMap.data]
	mov eax, [ebx + FloatMap.num_floats]

.process_16:
	cmp eax, 0x10
	jb .process_4
	movaps xmm0, [edi + 0x00]
	movaps xmm1, [edi + 0x10]
	movaps xmm2, [edi + 0x20]
	movaps xmm3, [edi + 0x30]
	minps xmm0, xmm6
	minps xmm1, xmm6
	minps xmm2, xmm6
	minps xmm3, xmm6
	maxps xmm0, xmm7
	maxps xmm1, xmm7
	maxps xmm2, xmm7
	maxps xmm3, xmm7
	movaps [edi + 0x00], xmm0
	movaps [edi + 0x10], xmm1
	movaps [edi + 0x20], xmm2
	movaps [edi + 0x30], xmm3
	sub eax, 0x10
	add edi, 0x40
	jmp .process_16
.process_4:
	cmp eax, 4
	jb .process_1
	movups xmm0, [edi]
	minps xmm0, xmm6
	maxps xmm0, xmm7
	movups [edi], xmm0
	sub eax, 4
	add edi, 0x10
	jmp .process_4
.process_1:
	test eax, eax
	jz .end
	mov ecx, eax
.proc_loop:
	movss xmm0, [edi + (ecx - 1) * 4]
	minss xmm0, xmm6
	maxss xmm0, xmm7
	movss [edi + (ecx - 1) * 4], xmm0
	loop .proc_loop

.end:
	FrameEnd
	ret
