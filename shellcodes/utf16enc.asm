%include "common.inc"

;int Utf32to16(uint32_t utf32, wchar_t **ch);
DefFunc _Utf32to16
	FrameBegin ebx, edi
	NameParams %$CodePoint, %$RetPtr

	mov ebx, %$RetPtr
	mov edi, [ebx]

	mov eax, %$CodePoint
	cmp eax, 0x10000
	jb .single
	sub eax, 0x10000
	mov edx, eax
	shr eax, 10
	and eax, 0x3FF
	and edx, 0x3FF
	or ax, 0xD800
	or dx, 0xDC00
	shl eax, 16
	or eax, edx
	stosd
	xor eax, eax
	mov al, 2
	jmp .end
.single:
	stosw
	xor eax, eax
	inc eax
.end:
	mov [ebx], edi
	FrameEnd
	ret
