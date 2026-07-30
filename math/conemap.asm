%include "common.inc"

%define SEARCH_RADIUS 1

segment .bss
extern _ConeMapPoolSize
_ConeMapPoolSize resd 1

%macro mov_eax_minus_SR 0
	%if SEARCH_RADIUS == 1
		xor eax, eax
		dec eax
	%else
		mov eax, -SEARCH_RADIUS
	%endif
%endmacro

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
	%define %$Modified [ebp + 0]
	%define %$SrcMap [ebp + 4]
	%define %$UVMap [ebp + 8]

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

	mov_eax_minus_SR
	mov %$SurrY, eax
.loopy:
	mov_eax_minus_SR
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
	cmp eax, SEARCH_RADIUS
	jle .loopx
	
	mov eax, %$SurrY
	inc eax
	mov %$SurrY, eax
	cmp eax, SEARCH_RADIUS
	jle .loopy

	add edi, 8

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, [ebx + BitMap.border_len]
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
	%define %$Modified [ebp + 0]
	%define %$SrcMap [ebp + 4]
	%define %$UVMap [ebp + 8]

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

	mov_eax_minus_SR
	mov %$SurrY, eax
.loopy:
	mov_eax_minus_SR
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
	cmp eax, SEARCH_RADIUS
	jle .loopx
	
	mov eax, %$SurrY
	inc eax
	mov %$SurrY, eax
	cmp eax, SEARCH_RADIUS
	jle .loopy

	cmp dword %$Updated, 0
	jz .skip_mark_modified
	lock inc dword %$Modified; Write non-zero
.skip_mark_modified:
	add edi, 8

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, [ebx + BitMap.border_len]
	jb .proc_pixel

	FrameEnd
	ret

DefFunc _ConeMapGenPoolProc
	FrameBegin ebp, ebx, esi, edi
	NameParams %$DstRowPtr, %$CommonData, %$Y
	DefVars %$X, %$CurHeight, %$MaxDist, %$Zero

	xor eax, eax
	lea edi, Variable(0)
	mov ecx, %$Frame_NumLocals
	rep stosd

	mov ebp, %$CommonData
	%define %$Modified [ebp + 0]
	%define %$SrcMap [ebp + 4]
	%define %$UVMap [ebp + 8]
	%define %$DstMap [ebp + 12]

	mov ebx, %$UVMap
	mov edi, %$DstRowPtr

	cvtsi2ss xmm0, [ebx + BitMap.border_len]
	mulss xmm0, xmm0
	sqrtss xmm0, xmm0
	movss %$MaxDist, xmm0

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
	mulss xmm1, %$MaxDist
	maxss xmm1, %$Zero
	movd eax, xmm1

.store_eax:
	stosd

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, [ebx + BitMap.border_len]
	jb .proc_pixel

	FrameEnd
	ret


; BitMap *ConeMapGen(BitMap *map);
DefFunc _ConeMapGen
	FrameBegin ebp, ebx, esi, edi

	mov ebx, Param(0)

	cmp dword[_ConeMapPoolSize], 0
	jnz .proceed_to_work
	mov eax, [_SystemInfo + SYSTEM_INFO.dwNumberOfProcessors]
	shr eax, 1
	mov [_ConeMapPoolSize], eax
.proceed_to_work:
	invoke_cdecl _CreateBitMap, [ebx + BitMap.border_len], 2, 8
	mov esi, eax

	invoke_cdecl _CreateBitMap, [ebx + BitMap.border_len], 1, 4
	mov edi, eax

	DefVars %$Modified, %$SrcMap, %$UVMap, %$DstMap, %$NumIter

	mov %$SrcMap, ebx
	mov %$UVMap, esi
	mov %$DstMap, edi
	mov ebp, [ebx + BitMap.border_len]

	invoke_cdecl _PoolRun, _ConeMapGenInitUVMapPoolProc, & %$Modified, [_ConeMapPoolSize], ebp, &[esi + BitMap.row_ptr], 0, 0
	mov %$NumIter, eax
.proc_again:
	mov %$Modified, eax
	invoke_cdecl _PoolRun, _ConeMapGenIterationPoolProc, & %$Modified, [_ConeMapPoolSize], ebp, &[esi + BitMap.row_ptr], 0, 0
	mov ecx, %$NumIter
	inc ecx
	mov %$NumIter, ecx
	cmp ecx, Param(1)
	jae .break_loop
	cmp %$Modified, eax
	jnz .proc_again
.break_loop:

	invoke_cdecl _PoolRun, _ConeMapGenPoolProc, & %$Modified, [_ConeMapPoolSize], ebp, &[edi + BitMap.row_ptr], 0, 0
	invoke_cdecl _DestroyBitMap, esi

	;VisualizeFloatMap1D edi, 'testcone.bmp'

	mov eax, edi
	FrameEnd
	ret
