%include "common.inc"
%include "avlbst.inc"

DefFunc _BatchMax
	FrameBegin 8, ebx, esi, edi

	lea edi, Variable(4)
	and edi, 0xFFFFFFF0

	mov ebx, Param(0)
	mov eax, Param(1)

	test eax, eax ; param sanity check
	jnz .good
	mov dword[edi], 0xFF800000
	jmp .result
.good:
	movaps xmm0, [ebx]
	movaps [edi], xmm0
	mov eax, Param(1)
.on_choose_methods: ; to trim data or to batch process data
	mov esi, ebx
	test al, 0x3F
	jz .batch_64
	test al, 0x7
	jz .batch_8
	mov ecx, eax ; trim from back
	and ecx, 7
	mov edx, ecx
	movss xmm0, [ebx]
.loop_single:
	maxss xmm0, [ebx + (ecx - 1) * 4]
	loop .loop_single
	movss [ebx], xmm0
	sub eax, edx
	jz .result
	jmp .on_choose_methods
.batch_64:
	mov ecx, eax ; batch process data: every 64 input
	shr ecx, 6
.loop_64_to_4:
	movaps xmm0, [esi + 0x00]
	movaps xmm1, [esi + 0x20]
	movaps xmm2, [esi + 0x40]
	movaps xmm3, [esi + 0x60]
	movaps xmm4, [esi + 0x80]
	movaps xmm5, [esi + 0xA0]
	movaps xmm6, [esi + 0xC0]
	movaps xmm7, [esi + 0xE0]
	maxps xmm0, [esi + 0x10]
	maxps xmm1, [esi + 0x30]
	maxps xmm2, [esi + 0x50]
	maxps xmm3, [esi + 0x70]
	maxps xmm4, [esi + 0x90]
	maxps xmm5, [esi + 0xB0]
	maxps xmm6, [esi + 0xD0]
	maxps xmm7, [esi + 0xF0]
	maxps xmm0, xmm1
	maxps xmm2, xmm3
	maxps xmm4, xmm5
	maxps xmm6, xmm7
	movaps xmm1, [edi]
	maxps xmm0, xmm2
	maxps xmm4, xmm6
	maxps xmm0, xmm4
	maxps xmm0, xmm1
	movaps [edi], xmm0
	add esi, 0x100
	dec ecx
	jnz .loop_64_to_4
	mov eax, 4
	jmp .on_choose_methods
.batch_8:
	mov ecx, eax ; batch process data: every 8 input, one 4 output to the intermediate buffer
	shr ecx, 3
	movaps xmm0, [edi]
.loop_8_to_4:
	maxps xmm0, [esi + 0x00]
	maxps xmm0, [esi + 0x10]
	add esi, 0x20
	loop .loop_8_to_4
	movaps [edi], xmm0
	mov eax, 4
	jmp .on_choose_methods

.result:
	fld dword [edi]

.end:
	FrameEnd
	ret
