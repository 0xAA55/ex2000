%include "common.inc"

; %define DEBUG_CONEMAP 1

struc CMGData
	.border_len resd 1
	.num_levels resd 1
	.dst_map resd 1
	.head_size equ $ - CMGData
	.src_map:
	.src_map_levels:
endstruc

;int dist_interval_wrap(int p, int a, int b, int s);
DefFunc _ConeMapDistWrap
	FrameBegin ebx, esi
	NameParams %$P, %$A, %$B, %$S

	mov eax, %$P
	mov edx, %$A
	mov ebx, %$B
	mov esi, %$S
	cmp eax, edx
	jl .outside_a
	cmp eax, ebx
	jg .outside_b
	xor eax, eax
	jmp .end
.outside_b:
	cmp eax, edx
.outside_a:
	jge .p_ge_a
	mov ecx, %$S
	sub eax, edx
	sub ecx, ebx
	neg eax
	add ecx, %$P
	jmp .p_lt_a
.p_ge_a:
	mov ecx, edx
	sub eax, ebx
	add ecx, %$S
	sub ecx, %$P
.p_lt_a:
	cmp eax, ecx
	cmovge eax, ecx
.end:
	FrameEnd
	ret


;xmm0x ConeMapDistToBlockWrap(float *result, int ox, int oy, int x0, int y0, int x1, int y1, int s);
DefFunc _ConeMapDistToBlockWrap
	FrameBegin
	NameParams %$Result, %$OX, %$OY, %$X0, %$Y0, %$X1, %$Y1, %$S
	DefVars %$DX, %$DY

	invoke_cdecl _ConeMapDistWrap, %$OX, %$X0, %$X1, %$S
	mov %$DX, eax
	invoke_cdecl _ConeMapDistWrap, %$OY, %$Y0, %$Y1, %$S
	mov %$DY, eax

	cvtsi2ss xmm0, %$DX
	cvtsi2ss xmm1, %$DY
	mulss xmm0, xmm0
	mulss xmm1, xmm1
	addss xmm0, xmm1
	sqrtss xmm0, xmm0
	mov eax, %$Result
	movss [eax], xmm0

	FrameEnd
	ret

;void ConeMapSearchBlock(void *common_data, float *best, float h, int ox, int oy, int x0, int y0, int x1, int y1);
DefFunc _ConeMapSearchBlock
	FrameBegin ebx, esi, edi
	NameParams %$CommonData, %$Best, %$H, %$OX, %$OY, %$X0, %$Y0, %$X1, %$Y1
	DefVars %$BW, %$BH, %$MaxH, %$Dist, %$MidX, %$MidY, %$MidX1, %$MidY1, %$MipX, %$MipY

	mov ebx, %$CommonData
	mov edi, %$Best

	mov eax, %$X1
	mov ecx, %$Y1
	sub eax, %$X0
	sub ecx, %$Y0
	inc eax
	inc ecx
	mov %$BW, eax
	mov %$BH, ecx
	bsf ecx, eax
	mov esi, [ebx + CMGData.src_map_levels + ecx * 4]

	mov eax, %$X0
	xor edx, edx
	div dword %$BW
	mov %$MipX, eax

	mov eax, %$Y0
	xor edx, edx
	div dword %$BH
	mov %$MipY, eax

	invoke_cdecl _GetBitmapPixelAddress, %$MipX, %$MipY, esi
	mov eax, [eax]
	mov %$MaxH, eax

	invoke_cdecl _ConeMapDistToBlockWrap, & %$Dist, %$OX, %$OY, %$X0, %$Y0, %$X1, %$Y1, [ebx + CMGData.border_len]
	ucomiss xmm0, [_0.01f]
	jb .block_include_origin
	movss xmm1, %$MaxH
	movss xmm2, %$H
	movss xmm3, [edi]
	mulss xmm3, xmm0
	addss xmm2, xmm3
	ucomiss xmm1, xmm2
	jbe .end
.block_include_origin:

	mov eax, %$X1
	mov ecx, %$Y1
	sub eax, %$X0
	sub ecx, %$Y0
	or eax, ecx
	jnz .not_leaf

	mov eax, %$X0
	mov ecx, %$Y0
	sub eax, %$OX
	sub ecx, %$OY
	or eax, ecx
	jz .end

	invoke_cdecl _GetBitmapPixelAddress, %$X0, %$Y0, [ebx + CMGData.src_map]
	movss xmm0, [eax]
	subss xmm0, %$H
	divss xmm0, %$Dist
	ucomiss xmm0, [edi]
	jbe .not_best
	movss [edi], xmm0
.not_best:
	jmp .end
.not_leaf:

	mov eax, %$X1
	mov ecx, %$Y1
	add eax, %$X0
	add ecx, %$Y0
	shr eax, 1
	shr ecx, 1
	mov %$MidX, eax
	mov %$MidY, ecx
	inc eax
	inc ecx
	mov %$MidX1, eax
	mov %$MidY1, ecx

	invoke_cdecl _ConeMapSearchBlock, ebx, edi, %$H, %$OX, %$OY, %$X0, %$Y0, %$MidX, %$MidY
	invoke_cdecl _ConeMapSearchBlock, ebx, edi, %$H, %$OX, %$OY, %$MidX1, %$Y0, %$X1, %$MidY
	invoke_cdecl _ConeMapSearchBlock, ebx, edi, %$H, %$OX, %$OY, %$X0, %$MidY1, %$MidX, %$Y1
	invoke_cdecl _ConeMapSearchBlock, ebx, edi, %$H, %$OX, %$OY, %$MidX1, %$MidY1, %$X1, %$Y1

.end:
	FrameEnd
	ret

DefFunc _ConeMapGenMapPoolProc
	FrameBegin ebx, esi, edi
	NameParams %$UVRowPtr, %$CommonData, %$Y
	DefVars %$X, %$Best, %$Mult

	mov ebx, %$CommonData
	mov esi, [ebx + CMGData.border_len]
	mov edi, %$UVRowPtr
	cvtsi2ss xmm0, esi
	movss %$Mult, xmm0

	xor eax, eax
	mov %$X, eax
.proc_pixel:
	xor eax, eax
	mov %$Best, eax
	invoke_cdecl _GetBitmapPixelAddress, %$X, %$Y, [ebx + CMGData.src_map]
	lea edx, [esi - 1]
	invoke_cdecl _ConeMapSearchBlock, ebx, & %$Best, [eax], %$X, %$Y, 0, 0, edx, edx
	movss xmm0, %$Best
	mulss xmm0, %$Mult
	movd eax, xmm0
	stosd

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, esi
	jb .proc_pixel

	FrameEnd
	ret

; BitMap *ConeMapGen(BitMap *map, int thread_pool_size);
DefFunc _ConeMapGen
	FrameBegin ebx, esi, edi
	NameParams %$SrcMap, %$ThreadPoolSize
	DefVars %$CommonData, %$NumLevels

	mov esi, %$SrcMap

	mov eax, [esi + BitMap.border_len]
	bsf ecx, eax
	inc ecx
	mov %$NumLevels, ecx
	invoke_cdecl _calloc, 1, & [CMGData.head_size + ecx * 4 + 4]
	mov ebx, eax

	invoke_cdecl _CreateBitMap, [esi + BitMap.border_len], 1, 4
	mov ecx, %$NumLevels
	mov edx, [esi + BitMap.border_len]
	mov [ebx + CMGData.dst_map], eax
	mov [ebx + CMGData.num_levels], ecx
	mov [ebx + CMGData.border_len], edx
	lea edi, [ebx + CMGData.src_map_levels]
	mov eax, esi
	stosd

.gen_next_mipmap:
	invoke_cdecl _FloatMapNextMip, eax, FMNM_MAX, %$ThreadPoolSize
	stosd
	test eax, eax
	jnz .gen_next_mipmap

	mov edi, [ebx + CMGData.dst_map]
	mov eax, %$ThreadPoolSize
	mov ecx, [_SystemInfo + SYSTEM_INFO.dwNumberOfProcessors]
	test eax, eax
	cmovz eax, ecx
	invoke_cdecl _PoolRun, _ConeMapGenMapPoolProc, ebx, eax, [ebx + CMGData.border_len], &[edi + BitMap.row_ptr], 0, 0

	VisualizeFloatMap edi, `testcone.bmp`

.end:
	lea esi, [ebx + CMGData.src_map_levels + 4]
.loop_free:
	lodsd
	test eax, eax
	jz .all_freed
	invoke_cdecl _DestroyBitMap, eax
	jmp .loop_free
.all_freed:
	invoke_cdecl _free, ebx
	mov eax, edi
	FrameEnd
	ret
