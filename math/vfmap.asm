%include "common.inc"

DefFunc _VisualizeFloatMap
	FrameBegin ebx, esi, edi
	DefVars %$Buffer, %$MaxValue, %$BitmapSize
	DefSizedVar %$BMFH, 14
	DefSizedVar %$BMIF, 52

	mov ebx, Param(0)
	xor eax, eax
	mov ecx, %$Frame_NumLocals
	lea edi, Variable(0)
	rep stosd

	mov eax, [ebx + BitMap.num_pixels]
	shl eax, 2
	add eax, 2;Paddings to the bitmap data to make sure the whole file is 4-bytes padded
	mov %$BitmapSize, eax
	invoke_cdecl _aligned_malloc, eax, 16
	mov %$Buffer, eax
	mov esi, [ebx + BitMap.data]
	mov edi, eax

	mov eax, %$BitmapSize
	add eax, 14 + 40 + 12
	mov ecx, [ebx + BitMap.border_len]
	mov edx, ecx
	neg edx
	mov word[%$BMFH_Addr], 'BM'
	mov [%$BMFH_Addr + 2], eax
	mov byte[%$BMFH_Addr + 10], 14 + 52
	mov byte[%$BMIF_Addr + BITMAPINFOHEADER.biSize], 40
	mov [%$BMIF_Addr + BITMAPINFOHEADER.biWidth], ecx
	mov [%$BMIF_Addr + BITMAPINFOHEADER.biHeight], edx
	mov eax, %$BitmapSize
	mov byte[%$BMIF_Addr + BITMAPINFOHEADER.biPlanes], 1
	mov byte[%$BMIF_Addr + BITMAPINFOHEADER.biBitCount], 32
	mov byte[%$BMIF_Addr + BITMAPINFOHEADER.biCompression], BI_BITFIELDS
	mov [%$BMIF_Addr + BITMAPINFOHEADER.biSizeImage], eax
	mov byte[%$BMIF_Addr + 40], 0xFF
	mov byte[%$BMIF_Addr + 45], 0xFF
	mov byte[%$BMIF_Addr + 50], 0xFF

	invoke_cdecl _BatchMax, esi, [ebx + BitMap.num_pixels]
	fstp dword %$MaxValue

	mov eax, %$MaxValue
	mov edx, 0x3F800000
	test eax, eax
	cmovz eax, edx
	mov %$MaxValue, eax

	xor ecx, ecx
	mov edx, 255
	movaps xmm4, [_UFFF0]
	rcpss xmm5, %$MaxValue
	cvtsi2ss xmm7, edx
	shufps xmm5, xmm5, 0
	movaps xmm6, [_F0001]
	shufps xmm7, xmm7, 0
	mulps xmm6, xmm7
	mulps xmm7, xmm5
	cmp dword[ebx + BitMap.num_pixels], 4;If the square POT bitmap is big enough, no trailing data should be processed
	jb .proc_very_little_data
	mov edx, 16
.loop_pack:
	cmp dword[ebx + BitMap.dims], 1
	jz .multi_1d
	cmp dword[ebx + BitMap.dims], 2
	jz .multi_2d
	cmp dword[ebx + BitMap.dims], 3
	jz .multi_3d
	cmp dword[ebx + BitMap.dims], 4
	jz .multi_4d
.bad:
	int3
	jmp .bad
.multi_1d:
	movd xmm0, [esi + 0x0]
	movd xmm1, [esi + 0x4]
	movd xmm2, [esi + 0x8]
	movd xmm3, [esi + 0xC]
	shufps xmm0, xmm0, _MM_SHUFFLE(1, 0, 0, 0)
	shufps xmm1, xmm1, _MM_SHUFFLE(1, 0, 0, 0)
	shufps xmm2, xmm2, _MM_SHUFFLE(1, 0, 0, 0)
	shufps xmm3, xmm3, _MM_SHUFFLE(1, 0, 0, 0)
	add esi, edx
	jmp .multi_rgb_set
.multi_2d:
	movq xmm0, [esi + 0x00]
	movq xmm1, [esi + 0x08]
	movq xmm2, [esi + 0x10]
	movq xmm3, [esi + 0x18]
	add esi, 0x20
	jmp .multi_rgb_set
.multi_3d:
	movaps xmm0, [esi + 0x00]
	movups xmm1, [esi + 0x0C]
	movaps xmm2, [esi + 0x18]
	movups xmm3, [esi + 0x24]
	andps xmm0, xmm4
	andps xmm1, xmm4
	andps xmm2, xmm4
	andps xmm3, xmm4
	add esi, 0x30
.multi_rgb_set:
	mulps xmm0, xmm7
	mulps xmm1, xmm7
	mulps xmm2, xmm7
	mulps xmm3, xmm7
	orps xmm0, xmm6
	orps xmm1, xmm6
	orps xmm2, xmm6
	orps xmm3, xmm6
	jmp .multi_normalized
.multi_4d:
	movaps xmm0, [esi + 0x00]
	movaps xmm1, [esi + 0x10]
	movaps xmm2, [esi + 0x20]
	movaps xmm3, [esi + 0x30]
	mulps xmm0, xmm7
	mulps xmm1, xmm7
	mulps xmm2, xmm7
	mulps xmm3, xmm7
	add esi, 0x40
.multi_normalized:
	cvtps2dq xmm0, xmm0
	cvtps2dq xmm1, xmm1
	cvtps2dq xmm2, xmm2
	cvtps2dq xmm3, xmm3
	packssdw xmm0, xmm1
	packssdw xmm2, xmm3
	packuswb xmm0, xmm2
	movaps [edi], xmm0
	add edi, edx
	add ecx, 4
	cmp ecx, [ebx + BitMap.num_pixels]
	jb .loop_pack
	jmp .after_proc
.proc_very_little_data:
	cmp dword[ebx + BitMap.dims], 1
	jz .single_1d
	cmp dword[ebx + BitMap.dims], 2
	jz .single_2d
	cmp dword[ebx + BitMap.dims], 3
	jz .single_3d
	cmp dword[ebx + BitMap.dims], 4
	jz .single_4d
	jmp .bad
.single_1d:
	lodsd
	movd xmm0, eax
	shufps xmm0, xmm0, _MM_SHUFFLE(1, 0, 0, 0)
	jmp .single_rgb_set
.single_2d:
	movq xmm0, [esi]
	add esi, 8
	jmp .single_rgb_set
.single_3d:
	movups xmm0, [esi]
	andps xmm0, xmm4
	add esi, 12
.single_rgb_set:
	mulps xmm0, xmm7
	orps xmm0, xmm6
	jmp .single_normalized
.single_4d:
	movaps xmm0, [esi]
	mulps xmm0, xmm7
	add esi, edx
.single_normalized:
	cvtps2dq xmm0, xmm0
	packssdw xmm0, xmm0
	packuswb xmm0, xmm0
	movd eax, xmm0
	stosd
	inc ecx
	cmp ecx, [ebx + BitMap.num_pixels]
	jb .proc_very_little_data
.after_proc:
	xor eax, eax
	mov edx, %$Buffer
	add edx, %$BitmapSize
.fill_tail:
	cmp edi, edx
	jae .fill_end
	stosb
	jmp .fill_tail
.fill_end:

; NOTE: Output verification requires manually inspecting the generated `.bmp` file.
;       If no file is created, run under a debugger to diagnose potential failures.
	invoke_dll_cdecl fopen, Param(1), _FopenTypeWb
	mov ebx, eax
	test eax, eax
	jz .fail

	invoke_dll_cdecl fwrite, & %$BMFH, 14, 1, ebx
	test eax, eax
	jz .fail
	invoke_dll_cdecl fwrite, & %$BMIF, 52, 1, ebx
	test eax, eax
	jz .fail
	invoke_dll_cdecl fwrite, %$Buffer, %$BitmapSize, 1, ebx
	test eax, eax
	jz .fail
	invoke_dll_cdecl fclose, ebx

	invoke_cdecl _aligned_free, %$Buffer
	xor eax, eax
	inc eax
	jmp .end
.fail:
	invoke_cdecl _aligned_free, %$Buffer
	test ebx, ebx
	jz .file_closed
	invoke_dll_cdecl fclose, ebx
.file_closed:
	invoke_dll_cdecl remove, Param(1)

	xor eax, eax
.end:
	FrameEnd
	ret
