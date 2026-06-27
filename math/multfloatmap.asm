%include "common.inc"

DefFunc _MultiplyFloatMap
	FrameBegin 0, esi, edi

	mov edi, Param(0)
	mov esi, Param(1)
	mov eax, [edi + BitMap.num_floats]
	mov ecx, [esi + BitMap.num_floats]
	cmp eax, ecx
	je .good_size
.bad_size:
	int3
	jmp .bad_size
.good_size:
	mov ecx, eax
	mov esi, [esi + BitMap.data]
	mov edi, [edi + BitMap.data]
	xor eax, eax
	test ecx, 0xF
	jnz .tail
	shr ecx, 4
.proc:
	movaps xmm0, [esi + eax + 0x00]
	movaps xmm1, [esi + eax + 0x10]
	movaps xmm2, [esi + eax + 0x20]
	movaps xmm3, [esi + eax + 0x30]
	mulps xmm0, [edi + eax + 0x00]
	mulps xmm1, [edi + eax + 0x10]
	mulps xmm2, [edi + eax + 0x20]
	mulps xmm3, [edi + eax + 0x30]
	movaps [edi + eax + 0x00], xmm0
	movaps [edi + eax + 0x10], xmm1
	movaps [edi + eax + 0x20], xmm2
	movaps [edi + eax + 0x30], xmm3
	add eax, 64
	loop .proc
	jmp .end
.tail:
	movss xmm0, [esi + eax]
	mulss xmm0, [edi + eax]
	movss [edi + eax], xmm0
	add eax, 4
	loop .tail
.end:
	FrameEnd
	ret

