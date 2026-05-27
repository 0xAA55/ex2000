%include "common.inc"

DefFunc _CreateFloatMap
	FrameBegin 1, 2, ebx, edi

	mov eax, Param(0)
	invoke_cdecl _malloc, &[eax * 4 + FloatMap.head_size]
	mov ebx, eax

	mov eax, Param(0)
	lea ecx, [eax - 1]
	test eax, ecx
	jz .good
.bad:
	int3
	jmp .bad
.good:
	mov [ebx + FloatMap.border_len], eax
	lea edi, [ebx + FloatMap.row_ptr]
	mul eax
	mov ecx, Param(1)
	mov [ebx + FloatMap.num_pixels], eax
	mov [ebx + FloatMap.dims], ecx
	mul ecx
	mov [ebx + FloatMap.num_floats], eax
	shl eax, 2
	mov [ebx + FloatMap.num_bytes], eax
	invoke_cdecl _aligned_malloc, eax, 16
	mov [ebx + FloatMap.data], eax

	mov eax, [ebx + FloatMap.dims]
	shl eax, 2
	mov [ebx + FloatMap.bytes_per_pixel], eax

	mov ecx, [ebx + FloatMap.border_len]
	lea eax, [ecx * 4]
	mul dword [ebx + FloatMap.dims]
	mov edx, eax
	mov eax, [ebx + FloatMap.data]
.set_row_ptr:
	stosd
	add eax, edx
	loop .set_row_ptr

	mov eax, ebx

	FrameEnd
	ret

DefFunc _DestroyFloatMap
	FrameBegin 0, 1, ebx

	mov ebx, Param(0)
	test ebx, ebx
	jz .end
	invoke_cdecl _aligned_free, [ebx + FloatMap.data]
	invoke_cdecl _free, ebx

.end:
	FrameEnd
	ret

DefFunc _GetXYFloatMap
	FrameBegin 0, 0, ebx

	mov ebx, Param(2)

	mov ecx, [ebx + FloatMap.border_len]
	lea edx, [ecx - 1]
	mov eax, Param(0)
	mov ecx, Param(1)
	and eax, edx
	and ecx, edx
	mul dword [ebx + FloatMap.dims]
	mov ecx, [ebx + FloatMap.row_ptr + ecx * 4]
	lea eax, [eax * 4 + ecx]

	FrameEnd
	ret
