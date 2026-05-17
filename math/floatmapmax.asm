%include "common.inc"

segment .text
DefFunc _FloatMapGetMaxValue
	FrameBegin 2, 3, ebx, esi, edi
	AssignVars _RET, _NUM_FLOATS

	mov dword _RET, 0xFF7FFFFF
	mov ebx, Param(0)
	mov eax, [ebx + FloatMap.num_pixels]
	mul dword [ebx + FloatMap.dims]
	test eax, eax
	jnz .good
.bad:
	int3
	jmp .bad
.good:
	mov _NUM_FLOATS, eax
	mov esi, [ebx + FloatMap.data]
	invoke_cdecl _aligned_malloc, &[eax * 4], 16
	mov ebx, eax
	mov eax, _NUM_FLOATS
	invoke_dll_cdecl memcpy, ebx, esi, &[eax * 4]
	mov eax, _NUM_FLOATS
.on_choose_methods:
	test al, 0x3F
	jz .vector_process
	test al, 0x3
	jnz .single_process
.four_process:
	mov esi, ebx
	mov ecx, eax
	xor eax, eax
	movaps xmm0, [esi]
	add esi, 16
	add eax, 4
	cmp eax, ecx
	je .after_four
.four_process_loop:
	maxps xmm0, [esi]
	add esi, 16
	add eax, 4
	cmp eax, ecx
	jb .four_process_loop
	movaps [ebx], xmm0
.after_four:
	mov eax, 4
.single_process:
	mov esi, ebx
	mov ecx, eax
	movss xmm0, [esi]
	dec ecx
	jz .result
.single_loop:
	maxss xmm0, [esi + ecx * 4]
	loop .single_loop
.result:
	movss _RET, xmm0
	invoke_cdecl _aligned_free, ebx
	fld dword _RET
	jmp .end
.vector_process:
	mov esi, ebx
	mov edi, ebx
	mov edx, eax
	xor eax, eax
	cmp edx, 64
	jae .loop_64_to_4
	mov _NUM_FLOATS, edx
	mov eax, edx
	jmp .on_choose_methods

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
	movaps [edi], xmm0
	add esi, 0x100
	add edi, 0x10
	add eax, 4
	sub edx, 64
	ja .loop_64_to_4
	jmp .vector_process

.end:
	FrameEnd
	ret
	%undef _RET
	%undef _TMP
