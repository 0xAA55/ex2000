%include "common.inc"

DefFunc _GenRadiusMap
	FrameBegin 2, 1, ebx, esi, edi
	AssignVars DistSq, Y_Y

	mov eax, Param(0)
	test eax, eax
	jnz .good_param1
.bad_param1:
	int3
	jmp .bad_param1
.good_param1:
	mul eax
	mov DistSq, eax
	shl eax, 2
	invoke_cdecl _malloc, &[eax * 4 + 4]
	mov ebx, eax

	xor eax, eax
	mov [ebx + 4], eax
	inc eax
	mov [ebx], eax
	mov edi, eax
.loopy:
	mov eax, edi
	mul eax
	mov Y_Y, eax ; y * y
	xor eax, eax
	inc eax
	mov esi, eax
.loopx:
	mov eax, esi
	mul eax
	add eax, Y_Y ; x * x + y * y
	cmp eax, DistSq
	jg .continue

	mov eax, [ebx]
	mov [ebx + 4 + eax * 4 + 0x0], si
	mov [ebx + 4 + eax * 4 + 0x2], di
	inc eax
	cmp esi, edi
	jz .continue
	mov [ebx + 4 + eax * 4 + 0x0], di
	mov [ebx + 4 + eax * 4 + 0x2], si
	inc eax

.continue:
	mov [ebx], eax

	inc esi
	cmp esi, edi
	jbe .loopx

	xor edx, edx
	mov [ebx + 4 + eax * 4 + 0x0], di
	mov [ebx + 4 + eax * 4 + 0x2], edx
	mov [ebx + 4 + eax * 4 + 0x6], di
	neg edi
	mov [ebx + 4 + eax * 4 + 0x8], dx
	mov [ebx + 4 + eax * 4 + 0xA], di
	mov [ebx + 4 + eax * 4 + 0xC], di
	mov [ebx + 4 + eax * 4 + 0xE], dx
	neg edi
	add eax, 4
	mov [ebx], eax

	inc edi
	cmp edi, Param(0)
	jb .loopy

	mov eax, ebx
	FrameEnd
	ret
	%undef DistSq
	%undef Y_Y
