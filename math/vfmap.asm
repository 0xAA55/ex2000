%include "common.inc"

DefFunc _VisualizeFloatMap1D
	FrameBegin ebx, esi, edi
	DefVars %$Buffer, %$MaxValue, %$BitmapSize
	DefSizedVar %$BMFH, 14
	DefSizedVar %$BMIF, 52

	mov ebx, Param(0)
	cmp dword[ebx + BitMap.dims], 1
	jz .good
.bad:
	int3
	jmp .bad
.good:
	xor eax, eax
	mov ecx, %$Frame_NumLocals
	lea edi, Variable(0)
	rep stosd

	mov eax, [ebx + BitMap.num_pixels]
	shl eax, 2
	add eax, 2
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

	mov edx, 255
	xor ecx, ecx
	cvtsi2ss xmm7, edx
	shl edx, 24
	movd xmm6, edx
	divss xmm7, %$MaxValue
	pshufd xmm6, xmm6, 0
	cmp dword[ebx + BitMap.num_pixels], 4
	jb .proc_very_little_data
	mov edx, 16
.loop_pack:
	movss xmm0, [esi + 0x0]
	movss xmm1, [esi + 0x4]
	movss xmm2, [esi + 0x8]
	movss xmm3, [esi + 0xC]
	mulss xmm0, xmm7
	mulss xmm1, xmm7
	mulss xmm2, xmm7
	mulss xmm3, xmm7
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	cvtps2dq xmm0, xmm0
	cvtps2dq xmm1, xmm1
	cvtps2dq xmm2, xmm2
	cvtps2dq xmm3, xmm3
	packssdw xmm0, xmm1
	packssdw xmm2, xmm3
	packuswb xmm0, xmm2
	por xmm0, xmm6
	movaps [edi], xmm0
	add esi, edx
	add edi, edx
	add ecx, 4
	cmp ecx, [ebx + BitMap.num_pixels]
	jb .loop_pack
	jmp .save_file
.proc_very_little_data:
	lodsd
	movd xmm0, eax
	mulss xmm0, xmm7
	shufps xmm0, xmm0, 0
	cvtps2dq xmm0, xmm0
	packssdw xmm0, xmm0
	packuswb xmm0, xmm0
	por xmm0, xmm6
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
