%include "common.inc"

; %define DEBUG_CONEMAP 1

DefFunc _ConeMapGenInitUVMapPoolProc
	FrameBegin ebx, esi, edi
	NameParams %$UVRowPtr, %$CommonData, %$Y
	DefVars %$X, %$CurHeight, %$K, %$Zero, %$NegSearchRadius
	DefVars %$SurrX, %$SurrY, %$SurrAbsX, %$SurrAbsY

	xor eax, eax
	lea edi, Variable(0)
	mov ecx, %$Frame_NumLocals
	rep stosd

	mov ebx, %$CommonData

	mov eax, [ebx + CMG.search_radius]
	neg eax
	mov %$NegSearchRadius, eax

	xor eax, eax
	mov %$X, eax
	mov edi, %$UVRowPtr
.proc_pixel:
	invoke_cdecl _GetBitmapPixelAddress, %$X, %$Y, [ebx + CMG.src_map]
	mov eax, [eax]
	mov %$CurHeight, eax

	xor eax, eax
	mov ecx, %$X
	mov edx, %$Y
	mov %$K, eax
	mov [edi + 0], ecx
	mov [edi + 4], edx

	mov eax, %$NegSearchRadius
	mov %$SurrY, eax
.loopy:
	mov eax, %$NegSearchRadius
	mov %$SurrX, eax
.loopx:
	or eax, %$SurrY
	jz .continue

	mov eax, %$X
	mov ecx, %$Y
	add eax, %$SurrX
	add ecx, %$SurrY
	mov %$SurrAbsX, eax
	mov %$SurrAbsY, ecx
	invoke_cdecl _GetBitmapPixelAddress, eax, ecx, [ebx + CMG.src_map]

	cvtsi2ss xmm0, %$SurrX
	cvtsi2ss xmm1, %$SurrY
	mulss xmm0, xmm0
	mulss xmm1, xmm1
	addss xmm0, xmm1
	rsqrtss xmm0, xmm0

	movss xmm1, [eax]
	subss xmm1, %$CurHeight
	mulss xmm1, xmm0
	maxss xmm1, %$Zero
	ucomiss xmm1, %$K
	jbe .continue

	movss %$K, xmm1
	mov eax, %$SurrAbsX
	mov ecx, %$SurrAbsY
	mov [edi + 0], eax
	mov [edi + 4], ecx

.continue:
	mov eax, %$SurrX
	inc eax
	mov %$SurrX, eax
	cmp eax, [ebx + CMG.search_radius]
	jle .loopx
	
	mov eax, %$SurrY
	inc eax
	mov %$SurrY, eax
	cmp eax, [ebx + CMG.search_radius]
	jle .loopy

	add edi, 8

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, [ebx + CMG.border_len]
	jb .proc_pixel

	FrameEnd
	ret

DefFunc _ConeMapGenIterationProc
	FrameBegin ebx, esi, edi
	NameParams %$UVRowPtr, %$CommonData, %$Y
	DefVars %$X, %$CurHeight, %$K, %$Zero
	DefVars %$SurrX, %$SurrY, %$NegSearchRadius
	DefVars %$DX, %$DY, %$BM, %$HalfBorder

	xor eax, eax
	lea edi, Variable(0)
	mov ecx, %$Frame_NumLocals
	rep stosd

	mov ebx, %$CommonData

	mov eax, [ebx + CMG.search_radius]
	neg eax
	mov %$NegSearchRadius, eax

	mov eax, [ebx + CMG.border_len]
	lea ecx, [eax - 1]
	shr eax, 1
	mov %$BM, ecx
	mov %$HalfBorder, eax

	mov edi, %$UVRowPtr

	xor eax, eax
	mov %$X, eax
.proc_pixel:
	invoke_cdecl _GetBitmapPixelAddress, %$X, %$Y, [ebx + CMG.src_map]
	mov eax, [eax]
	mov %$CurHeight, eax

	xor eax, eax
	mov %$K, eax

	mov eax, %$NegSearchRadius
	mov %$SurrY, eax
.loopy:
	mov eax, %$NegSearchRadius
	mov %$SurrX, eax
.loopx:
	;mov eax, %$SurrX
	mov ecx, %$SurrY
	add eax, %$X
	add ecx, %$Y
	invoke_cdecl _GetBitmapPixelAddress, eax, ecx, [ebx + CMG.uv_map]
	mov esi, eax
	invoke_cdecl _GetBitmapPixelAddress, [esi + 0], [esi + 4], [ebx + CMG.src_map]

	mov ecx, [esi + 0]
	mov edx, [esi + 4]
	sub ecx, %$X
	sub edx, %$Y
	and ecx, %$BM
	and edx, %$BM
	cmp ecx, %$HalfBorder
	jbe .dx_ok
	sub ecx, [ebx + CMG.border_len]
.dx_ok:
	cmp edx, %$HalfBorder
	jbe .dy_ok
	sub edx, [ebx + CMG.border_len]
.dy_ok:
	push ecx
	or ecx, edx
	pop ecx
	jz .continue

	mov %$DX, ecx
	mov %$DY, edx

	cvtsi2ss xmm0, ecx
	cvtsi2ss xmm1, edx
	mulss xmm0, xmm0
	mulss xmm1, xmm1
	addss xmm0, xmm1
	rsqrtss xmm0, xmm0

	movss xmm1, [eax]
	subss xmm1, %$CurHeight
	mulss xmm1, xmm0
	maxss xmm1, %$Zero
	ucomiss xmm1, %$K
	jbe .continue

	movss %$K, xmm1
	mov eax, %$X
	mov ecx, %$Y
	add eax, %$DX
	add ecx, %$DY
	mov [edi + 0], eax
	mov [edi + 4], ecx

.continue:
	mov eax, %$SurrX
	inc eax
	mov %$SurrX, eax
	cmp eax, [ebx + CMG.search_radius]
	jle .loopx
	
	mov eax, %$SurrY
	inc eax
	mov %$SurrY, eax
	cmp eax, [ebx + CMG.search_radius]
	jle .loopy

	add edi, 8

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, [ebx + CMG.border_len]
	jb .proc_pixel

	FrameEnd
	ret

DefFunc _ConeMapGenPoolProc
	FrameBegin ebx, esi, edi
	NameParams %$DstRowPtr, %$CommonData, %$Y
	DefVars %$X, %$CurHeight, %$Normalize, %$Zero

	xor eax, eax
	lea edi, Variable(0)
	mov ecx, %$Frame_NumLocals
	rep stosd

	mov ebx, %$CommonData
	mov edi, %$DstRowPtr

	cvtsi2ss xmm0, [ebx + CMG.border_len]
	movss %$Normalize, xmm0

	xor eax, eax
	mov %$X, eax
.proc_pixel:
	invoke_cdecl _GetBitmapPixelAddress, %$X, %$Y, [ebx + CMG.src_map]
	mov eax, [eax]
	mov %$CurHeight, eax

	invoke_cdecl _GetBitmapPixelAddress, %$X, %$Y, [ebx + CMG.uv_map]
	mov esi, eax

	invoke_cdecl _GetBitmapPixelAddress, [esi + 0], [esi + 4], [ebx + CMG.src_map]

	mov ecx, [esi + 0]
	mov edx, [esi + 4]
	sub ecx, %$X
	sub edx, %$Y
	push ecx
	or ecx, edx
	pop ecx
	jz .max_slope_on_self

	cvtsi2ss xmm0, ecx
	cvtsi2ss xmm1, edx
	mulss xmm0, xmm0
	mulss xmm1, xmm1
	addss xmm0, xmm1
	rsqrtss xmm0, xmm0
	movss xmm1, [eax]
	subss xmm1, %$CurHeight
	mulss xmm1, xmm0
	mulss xmm1, %$Normalize
	maxss xmm1, %$Zero
	movd eax, xmm1
	jmp .store_eax
.max_slope_on_self:
	mov eax, 0x3F800000

.store_eax:
	stosd

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, [ebx + CMG.border_len]
	jb .proc_pixel

	FrameEnd
	ret


; CMG *ConeMapGenStart(BitMap *map);
DefFunc _ConeMapGenStart
	FrameBegin ebx, esi, edi
	NameParams %$SrcMap, %$ThreadPoolSize

	invoke_cdecl _calloc, CMG.size, 1
	mov ebx, eax
	mov byte[ebx + CMG.modified], 1

	mov esi, %$SrcMap
	mov eax, %$ThreadPoolSize
	mov ecx, [_SystemInfo + SYSTEM_INFO.dwNumberOfProcessors]
	mov edi, [esi + BitMap.border_len]
	test eax, eax
	cmovz eax, ecx

	mov [ebx + CMG.src_map], esi
	mov [ebx + CMG.thread_pool_size], eax
	mov [ebx + CMG.border_len], edi

	invoke_cdecl _CreateBitMap, edi, 2, 8
	mov esi, eax
	mov [ebx + CMG.uv_map], eax

	invoke_cdecl _CreateBitMap, edi, 1, 4
	mov [ebx + CMG.dst_map], eax

	invoke_cdecl _aligned_malloc, [esi + BitMap.num_bytes], 16
	mov [ebx + CMG.uv_map_data_backup], eax

	invoke_cdecl _PoolRun, _ConeMapGenInitUVMapPoolProc, ebx, [ebx + CMG.thread_pool_size], edi, &[esi + BitMap.row_ptr], 0, 0
	invoke_dll_cdecl memcpy, [ebx + CMG.uv_map_data_backup], [esi + BitMap.data], [esi + BitMap.num_bytes]

	mov eax, ebx
	FrameEnd
	ret

; int ConeMapGenIter(CMG *inst, int search_radius);
DefFunc _ConeMapGenIter
	FrameBegin ebx, esi, edi
	NameParams %$Inst, %$SearchRadius

	mov ebx, %$Inst
	cmp dword[ebx + CMG.modified], 0
	jz .end

	xor eax, eax
	mov edi, eax
	mov esi, [ebx + CMG.uv_map]
	inc eax
	mov ecx, %$SearchRadius
	cmp ecx, eax
	cmovb ecx, eax
	mov [ebx + CMG.search_radius], ecx

.loopy_fwd:
	invoke_cdecl _ConeMapGenIterationProc, [esi + BitMap.row_ptr + edi * 4], ebx, edi
	inc edi
	cmp edi, [ebx + CMG.border_len]
	jb .loopy_fwd

.loopy_rvs:
	dec edi
	invoke_cdecl _ConeMapGenIterationProc, [esi + BitMap.row_ptr + edi * 4], ebx, edi
	test edi, edi
	jnz .loopy_rvs

	inc dword[ebx + CMG.num_iter]

	invoke_dll_cdecl memcmp, [ebx + CMG.uv_map_data_backup], [esi + BitMap.data], [esi + BitMap.num_bytes]
	mov [ebx + CMG.modified], eax
	test eax, eax
	jz .end
	invoke_dll_cdecl memcpy, [ebx + CMG.uv_map_data_backup], [esi + BitMap.data], [esi + BitMap.num_bytes]

%ifdef DEBUG_CONEMAP
	invoke_cdecl _ConeMapGenXtrResult, ebx

[segment .bss]
	.printf_buffer resb 256

__SECT__
	snprintf .printf_buffer, 256, `testiter_%02d.bmp`, [ebx + CMG.num_iter]
	invoke_cdecl _VisualizeFloatMap, [ebx + CMG.dst_map], .printf_buffer

%endif
.end:
	mov eax, [ebx + CMG.modified]
	FrameEnd
	ret

; BitMap *ConeMapGenXtrResult(CMG *inst);
DefFunc _ConeMapGenXtrResult
	FrameBegin ebx, esi, edi
	NameParams %$Inst

	mov ebx, %$Inst
	mov edi, [ebx + CMG.dst_map]

	invoke_cdecl _PoolRun, _ConeMapGenPoolProc, ebx, [ebx + CMG.thread_pool_size], [ebx + CMG.border_len], &[edi + BitMap.row_ptr], 0, 0

	mov eax, edi
	FrameEnd
	ret

; BitMap *ConeMapGenEnd(CMG *inst);
DefFunc _ConeMapGenEnd
	FrameBegin ebx, edi
	NameParams %$Inst

	mov ebx, %$Inst

	invoke_cdecl _ConeMapGenXtrResult, ebx
	mov edi, eax

	invoke_cdecl _DestroyBitMap, [ebx + CMG.uv_map]
	invoke_cdecl _aligned_free, [ebx + CMG.uv_map_data_backup]
	invoke_cdecl _free, ebx

	mov eax, edi
	FrameEnd
	ret
