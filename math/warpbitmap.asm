%include "common.inc"

DefFunc _WarpBitMap
	FrameBegin ebx, esi, edi
	DefVars %$Y, %$BitMask, %$SrcRowPtr, %$DstRowPtr, %$FirstCopyLen, %$SecondCopyLen

	mov esi, Param(1)

	mov eax, [esi + BitMap.border_len]
	dec eax
	mov %$BitMask, eax

	mov eax, [esi + BitMap.bytes_per_pixel]
	imul dword[esi + BitMap.border_len]
	mov edi, eax

	mov eax, Param(2)
	and eax, %$BitMask
	imul dword[esi + BitMap.bytes_per_pixel]
	mov ebx, eax ; src_x_offset

	mov ecx, edi
	mov edx, edi
	sub ecx, eax
	sub edx, ecx
	mov %$FirstCopyLen, ecx
	mov %$SecondCopyLen, edx

	mov edi, Param(0)

	xor eax, eax
	mov %$Y, eax
.loopy:
	add eax, Param(3)
	and eax, %$BitMask
	mov ecx, [esi + BitMap.row_ptr + eax * 4]
	mov edx, [edi + BitMap.row_ptr + eax * 4]
	mov %$SrcRowPtr, ecx
	mov %$DstRowPtr, edx

	invoke_dll_cdecl memcpy, edx, &[ecx + ebx], %$FirstCopyLen

	mov eax, %$SecondCopyLen
	test eax, eax
	jz .next_y

	mov edx, %$DstRowPtr
	add edx, %$FirstCopyLen
	invoke_dll_cdecl memcpy, edx, %$SrcRowPtr, %$SecondCopyLen

.next_y:
	mov eax, %$Y
	inc eax
	mov %$Y, eax
	cmp eax, [esi + BitMap.border_len]
	jb .loopy

	FrameEnd
	ret
