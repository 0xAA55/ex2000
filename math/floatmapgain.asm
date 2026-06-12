%include "common.inc"

DefFunc _BitMapApplyGain
	FrameBegin 0, 0, ebx, esi

	mov ebx, Param(0)

	mov eax, [ebx + BitMap.num_floats]
	mov esi, [ebx + BitMap.data]
	movss xmm7, Param(1)
	test al, 0xF
	mov ecx, eax
	jz .batch_proc
.single_proc:
	movss xmm0, [esi + (ecx - 1) * 4]
	mulss xmm0, xmm7
	movss [esi + (ecx - 1) * 4], xmm0
	loop .single_proc
	jmp .end
.batch_proc:
	shr ecx, 4
	shufps xmm7, xmm7, 0
.proc:
	movaps xmm0, [esi + 0x00]
	movaps xmm1, [esi + 0x10]
	movaps xmm2, [esi + 0x20]
	movaps xmm3, [esi + 0x30]
	mulps xmm0, xmm7
	mulps xmm1, xmm7
	mulps xmm2, xmm7
	mulps xmm3, xmm7
	movaps [esi + 0x00], xmm0
	movaps [esi + 0x10], xmm1
	movaps [esi + 0x20], xmm2
	movaps [esi + 0x30], xmm3
	add esi, 0x40
	loop .proc

.end:
	FrameEnd
	ret

