%include "common.inc"

; BitMap *CreateBitMap(int border_len, int dims, int bytes_per_pixel);
DefFunc _CreateBitMap
	FrameBegin ebx, edi
	NameParams %$BorderLen, %$Dims, %$BytesPerPixel

	mov eax, %$BorderLen
	lea ecx, [eax - 1]
	test eax, ecx
	jz .good
.bad:
	int3
	jmp .bad
.good:
	mov eax, %$BorderLen
	invoke_cdecl _calloc, &[eax * 4 + BitMap.head_size], 1
	mov ebx, eax

	mov eax, %$BorderLen
	mov [ebx + BitMap.border_len], eax
	lea edi, [ebx + BitMap.row_ptr]
	mul eax ;eax = border_len * border_len
	mov ecx, %$Dims
	mov [ebx + BitMap.num_pixels], eax
	lea edx, [ecx * 4]
	mov [ebx + BitMap.dims], ecx
	cmp edx, %$BytesPerPixel
	jnz .not_floats
	mov [ebx + BitMap.bytes_per_pixel], edx
	mul ecx
	mov [ebx + BitMap.num_floats], eax
	shl eax, 2
	mov [ebx + BitMap.num_bytes], eax
	jmp .ready_to_allocate
.not_floats:
	mov ecx, %$BytesPerPixel
	mul ecx
	mov [ebx + BitMap.bytes_per_pixel], ecx
	mov [ebx + BitMap.num_bytes], eax
.ready_to_allocate:
	invoke_cdecl _aligned_malloc, eax, 16
	mov [ebx + BitMap.data], eax

	push eax
	mov ecx, [ebx + BitMap.border_len]
	mov eax, [ebx + BitMap.bytes_per_pixel]
	mul ecx
	mov edx, eax
	pop eax
.set_row_ptr:
	stosd
	add eax, edx
	loop .set_row_ptr

	mov eax, ebx
	FrameEnd
	ret

DefFunc _DestroyBitMap
	FrameBegin ebx
	NameParams %$Map

	mov ebx, %$Map
	test ebx, ebx
	jz .end
	invoke_cdecl _aligned_free, [ebx + BitMap.data]
	invoke_cdecl _free, ebx

.end:
	FrameEnd
	ret
