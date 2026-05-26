%include "common.inc"

segment .text
DefFunc _BatchMax
	FrameBegin 1, 3, ebx, esi, edi
	AssignVars _RET

	mov esi, Param(0)
	mov eax, Param(1)

	test eax, eax ; param sanity check
	jnz .begin_process
	mov dword [ebx], 0xFF800000 ;-1.INF
	jmp .result
.begin_process:
	shl eax, 2
	mov edi, eax
	invoke_cdecl _aligned_malloc, edi, 16 ;allcate the intermediate buffer for fast reducing parallel max
	mov ebx, eax
	invoke_dll_cdecl memcpy, ebx, esi, edi
	mov eax, Param(1)
.on_choose_methods: ; to trim data or to batch process data
	mov esi, ebx
	test al, 0x3F
	jz .batch_64
	test al, 0x1F
	jz .batch_32
	test al, 0xF
	jz .batch_16
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
	mov ecx, eax ; batch process data: every 64 input, one 4 output to the intermediate buffer
	shr ecx, 6
	xor eax, eax
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
	maxps xmm0, xmm2
	maxps xmm4, xmm6
	maxps xmm0, xmm4
	movaps [ebx + eax * 4], xmm0
	add esi, 0x100
	add eax, 4
	loop .loop_64_to_4
	jmp .on_choose_methods
.batch_32:
	mov ecx, eax ; batch process data: every 16 input, one 4 output to the intermediate buffer
	shr ecx, 5
	xor eax, eax
.loop_32_to_4:
	movaps xmm0, [esi + 0x00]
	movaps xmm1, [esi + 0x20]
	movaps xmm2, [esi + 0x40]
	movaps xmm3, [esi + 0x60]
	maxps xmm0, [esi + 0x10]
	maxps xmm1, [esi + 0x30]
	maxps xmm2, [esi + 0x50]
	maxps xmm3, [esi + 0x70]
	maxps xmm0, xmm2
	maxps xmm1, xmm3
	maxps xmm0, xmm1
	movaps [ebx + eax * 4], xmm0
	add esi, 0x80
	add eax, 4
	loop .loop_32_to_4
	jmp .on_choose_methods
.batch_16:
	mov ecx, eax ; batch process data: every 16 input, one 4 output to the intermediate buffer
	shr ecx, 4
	xor eax, eax
.loop_16_to_4:
	movaps xmm0, [esi + 0x00]
	movaps xmm1, [esi + 0x20]
	maxps xmm0, [esi + 0x10]
	maxps xmm1, [esi + 0x30]
	maxps xmm0, xmm1
	movaps [ebx + eax * 4], xmm0
	add esi, 0x40
	add eax, 4
	loop .loop_16_to_4
	jmp .on_choose_methods
.batch_8:
	mov ecx, eax ; batch process data: every 8 input, one 4 output to the intermediate buffer
	shr ecx, 3
	xor eax, eax
.loop_8_to_4:
	movaps xmm0, [esi + 0x00]
	maxps xmm0, [esi + 0x10]
	movaps [ebx + eax * 4], xmm0
	add esi, 0x20
	add eax, 4
	loop .loop_8_to_4
	jmp .on_choose_methods

.result:
	movss xmm0, [ebx]
	movss _RET, xmm0
	invoke_cdecl _aligned_free, ebx
	fld dword _RET

.end:
	FrameEnd
	ret
	%undef _RET
