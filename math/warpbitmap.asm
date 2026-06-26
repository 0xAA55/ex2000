%include "common.inc"

DefFunc _WarpBitMap
	FrameBegin 6, 3, ebx, esi, edi
	AssignVars _Y, _BITMASK, _SRC_ROWPTR, _DST_ROWPTR, _FIRST_COPY_LEN, _SECOND_COPY_LEN

	mov esi, Param(1)

	mov eax, [esi + BitMap.border_len]
	dec eax
	mov _BITMASK, eax

	mov eax, [esi + BitMap.bytes_per_pixel]
	imul dword[esi + BitMap.border_len]
	mov edi, eax

	mov eax, Param(2)
	and eax, _BITMASK
	imul dword[esi + BitMap.bytes_per_pixel]
	mov ebx, eax ; src_x_offset

	lea ecx, [edi - eax]
	lea edx, [edi - ecx]
	mov _FIRST_COPY_LEN, ecx
	mov _SECOND_COPY_LEN, edx

	mov edi, Param(0)

	xor eax, eax
	mov _Y, eax
.loopy:
	add eax, Param(3)
	and eax, _BITMASK
	mov ecx, [esi + BitMap.row_ptr + eax * 4]
	mov edx, [edi + BitMap.row_ptr + eax * 4]
	mov _SRC_ROWPTR, ecx
	mov _DST_ROWPTR, edx

	invoke_dll_cdecl memcpy, edx, &[ecx + ebx], _FIRST_COPY_LEN

	mov eax, _SECOND_COPY_LEN
	test eax, eax
	jz .next_y

	mov edx, _DST_ROWPTR
	add edx, _FIRST_COPY_LEN
	invoke_dll_cdecl memcpy, edx, _SRC_ROWPTR, _SECOND_COPY_LEN

.next_y:
	mov eax, _Y
	inc eax
	mov _Y, eax
	cmp eax, [esi + BitMap.border_len]
	jb .loopy

	FrameEnd
	ret
	%undef _Y
	%undef _BITMASK
	%undef _SRC_ROWPTR
	%undef _DST_ROWPTR
	%undef _FIRST_COPY_LEN
	%undef _SECOND_COPY_LEN
