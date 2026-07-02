%include "loaddll.inc"
%include "utf.inc"

; int UtfReadCharFromPtr(char **ch);
DefFunc _UtfReadCharFromPtr
	FrameBegin 0, ebx, esi, edi

	xor eax, eax
	mov ebx, eax
	mov edi, Param(0)
	mov esi, [edi]
.read_char:
	xor eax, eax
	lodsb
	test al, al
	jz .end
	mov dl, al
	and dl, 0xFE
	cmp dl, 0xFC
	jz .6b
	mov dl, al
	and dl, 0xFC
	cmp dl, 0xF8
	jz .5b
	mov dl, al
	and dl, 0xF8
	cmp dl, 0xF0
	jz .4b
	mov dl, al
	and dl, 0xF0
	cmp dl, 0xE0
	jz .3b
	mov dl, al
	and dl, 0xE0
	cmp dl, 0xC0
	jz .2b
	mov dl, al
	and dl, 0xC0
	cmp dl, 0x80
	je .bad
	test al, 0x80
	jz .1b
.bad:
	mov eax, '?'
	jmp .end
.2b:
	and al, 0x1F
	shl eax, 6
	mov ebx, eax
	jmp .2b_join
.3b:
	and al, 0x0F
	shl eax, 12
	mov ebx, eax
	jmp .3b_join
.4b:
	and al, 0x07
	shl eax, 18
	mov ebx, eax
	jmp .4b_join
.5b:
	and al, 0x03
	shl eax, 24
	mov ebx, eax
	jmp .5b_join
.6b:
	and al, 0x01
	shl eax, 30
	mov ebx, eax
	call .load_mb
	shl eax, 24
	or ebx, eax
.5b_join:
	call .load_mb
	shl eax, 18
	or ebx, eax
.4b_join:
	call .load_mb
	shl eax, 12
	or ebx, eax
.3b_join:
	call .load_mb
	shl eax, 6
	or ebx, eax
.2b_join:
	call .load_mb
	or eax, ebx
.1b:

.end:
	mov [edi], esi
	FrameEnd
	ret
.load_mb:
	xor eax, eax
	lodsb
	mov dl, al
	and dl, 0xC0
	cmp dl, 0x80
	jne .bad_mb
	and al, 0x3F
	ret
.bad_mb:
	pop ecx
	jmp .bad

;int Utf32to16(uint32_t utf32, wchar_t **ch);
DefFunc _Utf32to16
	FrameBegin 0, ebx, edi

	mov ebx, Param(1)
	mov edi, [ebx]

	mov eax, Param(0)
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
