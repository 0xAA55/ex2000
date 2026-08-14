%include "common.inc"

; float *GetBitmapPixelAddress(int x, int y, BitMap *map);
DefFunc _GetBitmapPixelAddress
	FrameBegin ebx
	NameParams %$X, %$Y, %$Map

	mov ebx, %$Map

	mov ecx, [ebx + BitMap.border_len]
	lea edx, [ecx - 1]
	mov eax, %$X
	mov ecx, %$Y
	and eax, edx
	and ecx, edx
	mul dword [ebx + BitMap.bytes_per_pixel]
	mov ecx, [ebx + BitMap.row_ptr + ecx * 4]
	add eax, ecx

	FrameEnd
	ret
