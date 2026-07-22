%include "common.inc"

DefFunc _BatchBias
	FrameBegin edi

	mov edi, Param(0)
	movss xmm7, Param(1)
	mov eax, Param(2)
	mov edx, 16
	shufps xmm7, xmm7, 0

.proc16:
	cmp eax, edx
	jb .proc4
	shl edx, 2
	mov ecx, eax
	shr ecx, 4
.proc16_loop:
	movups xmm0, [edi + 0x00]
	movups xmm1, [edi + 0x10]
	movups xmm2, [edi + 0x20]
	movups xmm3, [edi + 0x30]
	addps xmm0, xmm7
	addps xmm1, xmm7
	addps xmm2, xmm7
	addps xmm3, xmm7
	movups [edi + 0x00], xmm0
	movups [edi + 0x10], xmm1
	movups [edi + 0x20], xmm2
	movups [edi + 0x30], xmm3
	add edi, edx
	loop .proc16_loop
	mov cl, 15
	and eax, ecx
	test eax, eax
	jz .end

.proc4:
	mov dl, 4
	cmp eax, edx
	jb .proc1
	mov ecx, eax
	shr ecx, 2
.proc4_loop:
	movups xmm0, [edi]
	addps xmm0, xmm7
	movups [edi], xmm0
	add edi, edx
	loop .proc4_loop
	and al, 3
	test eax, eax
	jz .end

.proc1:
	mov ecx, eax
	mov al, 4
.proc1_loop:
	movss xmm0, [edi]
	addss xmm0, xmm7
	movss [edi], xmm0
	add edi, eax
	loop .proc1_loop

.end:
	FrameEnd
	ret

