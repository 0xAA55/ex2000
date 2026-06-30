%include "common.inc"

; BitMap *CreateBitMap(int border_len, int dims, int bytes_per_pixel);
DefFunc _CreateBitMap
	FrameBegin 1, ebx, edi

	mov eax, Param(0)
	invoke_cdecl _malloc, &[eax * 4 + BitMap.head_size]
	mov ebx, eax

	mov eax, Param(0)
	lea ecx, [eax - 1]
	test eax, ecx
	jz .good
.bad:
	int3
	jmp .bad
.good:
	mov [ebx + BitMap.border_len], eax
	lea edi, [ebx + BitMap.row_ptr]
	mul eax
	mov ecx, Param(1)
	mov [ebx + BitMap.num_pixels], eax
	mov [ebx + BitMap.dims], ecx
	mul ecx
	mov [ebx + BitMap.num_floats], eax
	shl eax, 2
	mov [ebx + BitMap.num_bytes], eax
	invoke_cdecl _aligned_malloc, eax, 16
	mov [ebx + BitMap.data], eax

	mov eax, Param(2)
	mov [ebx + BitMap.bytes_per_pixel], eax

	mov ecx, [ebx + BitMap.border_len]
	lea eax, [ecx * 4]
	mul dword [ebx + BitMap.dims]
	mov edx, eax
	mov eax, [ebx + BitMap.data]
.set_row_ptr:
	stosd
	add eax, edx
	loop .set_row_ptr

	mov eax, ebx

	FrameEnd
	ret

DefFunc _DestroyBitMap
	FrameBegin 0, ebx

	mov ebx, Param(0)
	test ebx, ebx
	jz .end
	invoke_cdecl _aligned_free, [ebx + BitMap.data]
	invoke_cdecl _free, ebx

.end:
	FrameEnd
	ret

; float *GetBitmapPixelAddress(int x, int y, BitMap *map);
DefFunc _GetBitmapPixelAddress
	FrameBegin 0, ebx

	mov ebx, Param(2)

	mov ecx, [ebx + BitMap.border_len]
	lea edx, [ecx - 1]
	mov eax, Param(0)
	mov ecx, Param(1)
	and eax, edx
	and ecx, edx
	mul dword [ebx + BitMap.bytes_per_pixel]
	mov ecx, [ebx + BitMap.row_ptr + ecx * 4]
	add eax, ecx

	FrameEnd
	ret
