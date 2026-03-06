%include "frame.inc"

global _strcmp

segment .text
_strcmp:
	FrameBegin 2, 0
	StoreVariable 0, esi
	StoreVariable 1, edi

	LoadParam edi, 0
	LoadParam esi, 1
	xor eax, eax
	mov edx, eax

.check:
	mov al, [edi]
	mov dl, [esi]
	cmp al, dl
	jne .nequal
	test al, al
	je .equal
	inc edi
	inc esi
	jmp .check

.nequal:
	sub eax, edx
	jmp .end

.equal:
	xor eax, eax

.end:

	LoadVariable esi, 0
	LoadVariable edi, 1
	FrameEnd
	ret

 