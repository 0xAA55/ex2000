%include "common.inc"

DefFunc _ConeMapGenInitUVMapPoolProc
	FrameBegin ebp, ebx, esi, edi
	NameParams %$UVRowPtr, %$CommonData, %$Y
	DefVars %$X, %$CurHeight, %$K, %$Zero
	DefVars %$SurrX, %$SurrY, %$SurrAbsX, %$SurrAbsY

	xor eax, eax
	lea edi, Variable(0)
	mov ecx, %$Frame_NumLocals
	rep stosd

	mov ebp, %$CommonData
	%define %$Modified [ebp + CMG.modified]
	%define %$SrcMap [ebp + CMG.src_map]
	%define %$UVMap [ebp + CMG.uv_map]

	mov ebx, %$SrcMap

	xor eax, eax
	mov %$X, eax
	mov edi, %$UVRowPtr
.proc_pixel:
	invoke_cdecl _GetBitmapPixelAddress, %$X, %$Y, ebx
	mov eax, [eax]
	mov %$CurHeight, eax

	xor eax, eax
	mov ecx, %$X
	mov edx, %$Y
	mov %$K, eax
	mov [edi + 0], ecx
	mov [edi + 4], edx

	mov eax, [ebp + CMG.search_radius]
	neg eax
	mov %$SurrY, eax
.loopy:
	mov eax, [ebp + CMG.search_radius]
	neg eax
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
	invoke_cdecl _GetBitmapPixelAddress, eax, ecx, ebx

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
	cmp eax, [ebp + CMG.search_radius]
	jle .loopx
	
	mov eax, %$SurrY
	inc eax
	mov %$SurrY, eax
	cmp eax, [ebp + CMG.search_radius]
	jle .loopy

	add edi, 8

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, [ebp + CMG.border_len]
	jb .proc_pixel

	FrameEnd
	ret

DefFunc _ConeMapGenIterationPoolProc
	FrameBegin ebp, ebx, esi, edi
	NameParams %$UVRowPtr, %$CommonData, %$Y
	DefVars %$X, %$CurHeight, %$K, %$Zero
	DefVars %$SurrX, %$SurrY, %$Updated

	xor eax, eax
	lea edi, Variable(0)
	mov ecx, %$Frame_NumLocals
	rep stosd

	mov ebp, %$CommonData
	%define %$Modified [ebp + CMG.modified]
	%define %$SrcMap [ebp + CMG.src_map]
	%define %$UVMap [ebp + CMG.uv_map]

	mov ebx, %$SrcMap

	xor eax, eax
	mov %$X, eax
	mov edi, %$UVRowPtr
.proc_pixel:
	invoke_cdecl _GetBitmapPixelAddress, %$X, %$Y, ebx
	mov eax, [eax]
	mov %$CurHeight, eax

	xor eax, eax
	mov %$K, eax
	mov %$Updated, eax

	mov eax, [ebp + CMG.search_radius]
	neg eax
	mov %$SurrY, eax
.loopy:
	mov eax, [ebp + CMG.search_radius]
	neg eax
	mov %$SurrX, eax
.loopx:
	mov ecx, %$SurrY
	add eax, %$X
	add ecx, %$Y
	invoke_cdecl _GetBitmapPixelAddress, eax, ecx, %$UVMap
	mov esi, eax
	invoke_cdecl _GetBitmapPixelAddress, [esi + 0], [esi + 4], ebx

	mov ecx, [esi + 0]
	mov edx, [esi + 4]
	sub ecx, %$X
	sub edx, %$Y
	push ecx
	or ecx, edx
	pop ecx
	jz .continue

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

	mov eax, [esi + 0]
	cmp eax, [edi + 0]
	jnz .changed
	mov eax, [esi + 4]
	cmp eax, [edi + 4]
	jnz .changed
	jmp .continue

.changed:
	mov byte %$Updated, 1

	mov eax, [esi + 0]
	mov ecx, [esi + 4]
	mov [edi + 0], eax
	mov [edi + 4], ecx

.continue:
	mov eax, %$SurrX
	inc eax
	mov %$SurrX, eax
	cmp eax, [ebp + CMG.search_radius]
	jle .loopx
	
	mov eax, %$SurrY
	inc eax
	mov %$SurrY, eax
	cmp eax, [ebp + CMG.search_radius]
	jle .loopy

	cmp dword %$Updated, 0
	jz .skip_mark_modified
	lock inc dword %$Modified; Write non-zero
.skip_mark_modified:
	add edi, 8

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, [ebp + CMG.border_len]
	jb .proc_pixel

	FrameEnd
	ret

DefFunc _ConeMapGenPoolProc
	FrameBegin ebp, ebx, esi, edi
	NameParams %$DstRowPtr, %$CommonData, %$Y
	DefVars %$X, %$CurHeight, %$Normalize, %$Zero

	xor eax, eax
	lea edi, Variable(0)
	mov ecx, %$Frame_NumLocals
	rep stosd

	mov ebp, %$CommonData
	%define %$Modified [ebp + CMG.modified]
	%define %$SrcMap [ebp + CMG.src_map]
	%define %$UVMap [ebp + CMG.uv_map]
	%define %$DstMap [ebp + CMG.dst_map]

	mov ebx, %$UVMap
	mov edi, %$DstRowPtr

	cvtsi2ss xmm0, [ebp + CMG.border_len]
	movss %$Normalize, xmm0

	xor eax, eax
	mov %$X, eax
.proc_pixel:
	invoke_cdecl _GetBitmapPixelAddress, %$X, %$Y, %$SrcMap
	mov eax, [eax]
	mov %$CurHeight, eax

	invoke_cdecl _GetBitmapPixelAddress, %$X, %$Y, ebx
	mov esi, eax

	invoke_cdecl _GetBitmapPixelAddress, [esi + 0], [esi + 4], %$SrcMap

	mov ecx, [esi + 0]
	mov edx, [esi + 4]
	sub ecx, %$X
	sub edx, %$Y
	push ecx
	or ecx, edx
	pop ecx
	jz .store_zero

	cvtsi2ss xmm0, ecx
	cvtsi2ss xmm1, edx
	mulss xmm0, xmm0
	mulss xmm1, xmm1
	addss xmm0, xmm1
	sqrtss xmm0, xmm0
	ucomiss xmm0, [_0.01f]
	jae .good_dist_value
.store_zero:
	xor eax, eax
	jmp .store_eax
.good_dist_value:
	movss xmm1, [eax]
	subss xmm1, %$CurHeight
	divss xmm1, xmm0
	mulss xmm1, %$Normalize
	maxss xmm1, %$Zero
	movd eax, xmm1

.store_eax:
	stosd

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, [ebp + CMG.border_len]
	jb .proc_pixel

	FrameEnd
	ret


; CMG *ConeMapGenStart(BitMap *map);
DefFunc _ConeMapGenStart
	FrameBegin ebx, esi, edi
	NameParams %$SrcMap, %$ThreadPoolSize

	invoke_cdecl _calloc, CMG.size, 1
	mov ebx, eax

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

	invoke_cdecl _PoolRun, _ConeMapGenInitUVMapPoolProc, ebx, [ebx + CMG.thread_pool_size], edi, &[esi + BitMap.row_ptr], 0, 0
	mov eax, ebx
	FrameEnd
	ret

; int ConeMapGenIter(CMG *inst, int steps, int search_radius);
DefFunc _ConeMapGenIter
	FrameBegin ebx, esi, edi
	NameParams %$Inst, %$Steps, %$SearchRadius
	DefVars %$NumIter

	mov ebx, %$Inst
	xor eax, eax
	mov esi, [ebx + CMG.uv_map]
	inc eax
	mov ecx, %$SearchRadius
	mov edi, [ebx + CMG.border_len]
	cmp ecx, eax
	cmovb ecx, eax
	mov [ebx + CMG.search_radius], ecx

	dec eax
	mov edi, eax
.proc_again:
	mov [ebx + CMG.modified], eax
	invoke_cdecl _PoolRun, _ConeMapGenIterationPoolProc, ebx, [ebx + CMG.thread_pool_size], [ebx + CMG.border_len], &[esi + BitMap.row_ptr], 0, 0
	inc edi
	cmp edi, %$Steps
	jae .end
	cmp [ebx + CMG.modified], eax
	jnz .proc_again
	inc eax

.end:
	add [ebx + CMG.num_iter], edi
	FrameEnd
	ret

; int _ConeMapGenEnd(CMG *inst);
DefFunc _ConeMapGenEnd
	FrameBegin ebx, esi, edi
	NameParams %$Inst

	mov ebx, %$Inst
	mov esi, [ebx + CMG.uv_map]
	mov edi, [ebx + CMG.dst_map]

	invoke_cdecl _PoolRun, _ConeMapGenPoolProc, ebx, [ebx + CMG.thread_pool_size], [ebx + CMG.border_len], &[edi + BitMap.row_ptr], 0, 0
	invoke_cdecl _DestroyBitMap, esi
	invoke_cdecl _free, ebx

	VisualizeFloatMap edi, 'testcone.bmp'

	mov eax, edi
	FrameEnd
	ret
