%include "common.inc"

segment .rdata
extern _FMNMProcs
_FMNMProcs:
	dd _FloatMapNextAvrMipPoolProc
	dd _FloatMapNextMaxMipPoolProc
.num_methods equ ($ - _FMNMProcs) / 4

DefFunc _FloatMapNextMip
	FrameBegin ebx, esi, edi
	NameParams %$SrcMap, %$Method, %$ThreadPoolSize
	DefVars %$DstMap, %$SrcMap_

	mov ebx, %$SrcMap
	cmp byte[ebx + BitMap.bytes_per_pixel], 4
	jz .good
.bad:
	int3
	jmp .bad
.good:
	mov eax, [ebx + BitMap.border_len]
	shr eax, 1
	test eax, eax
	jz .end
	invoke_cdecl _CreateBitMap, eax, 1, 4
	mov edi, eax

	mov %$SrcMap_, ebx
	mov %$DstMap, eax

	mov eax, %$ThreadPoolSize
	mov ecx, [_SystemInfo + SYSTEM_INFO.dwNumberOfProcessors]
	test eax, eax
	cmovz eax, ecx
	mov ecx, %$Method
	cmp ecx, _FMNMProcs.num_methods
	jae .bad
	invoke_cdecl _PoolRun, [_FMNMProcs + ecx * 4], & %$DstMap, eax, [edi + BitMap.border_len], &[edi + BitMap.row_ptr], 0, 0
	mov eax, edi
.end:
	FrameEnd
	ret

DefFunc _FloatMapNextMaxMipPoolProc
	FrameBegin ebx, edi
	NameParams %$RowPtr, %$CommonData, %$Y

	mov ebx, %$CommonData
	mov eax, [ebx + 0] ;dst
	mov ebx, [ebx + 4] ;src

	mov edx, %$Y
	mov edi, %$RowPtr
	mov ecx, [eax + BitMap.border_len]
	lea eax, [edx * 2]
	mov edx, [ebx + BitMap.row_ptr + eax * 4 + 4]
	mov eax, [ebx + BitMap.row_ptr + eax * 4 + 0]

	test dword[ebx + BitMap.border_len], 0x0F
	jz .proc_many

.loop_proc:
	movss xmm0, [eax + 0]
	maxss xmm0, [edx + 0]
	maxss xmm0, [eax + 4]
	maxss xmm0, [edx + 4]
	movss [edi], xmm0
	add eax, 8
	add edx, 8
	add edi, 4

	dec ecx
	jnz .loop_proc
	jmp .end

.proc_many:
	shr ecx, 3
.loop_many:
	movaps xmm0, [eax + 0x00]
	movaps xmm1, [eax + 0x10]
	movaps xmm2, [eax + 0x20]
	movaps xmm3, [eax + 0x30]
	movaps xmm4, [edx + 0x00]
	movaps xmm5, [edx + 0x10]
	movaps xmm6, [edx + 0x20]
	movaps xmm7, [edx + 0x30]
	maxps xmm0, xmm4
	maxps xmm1, xmm5
	maxps xmm2, xmm6
	maxps xmm3, xmm7
	movaps xmm4, xmm0
	movaps xmm5, xmm1
	movaps xmm6, xmm2
	movaps xmm7, xmm3
	shufps xmm0, xmm0, _MM_SHUFFLE(2, 3, 0, 1)
	shufps xmm1, xmm1, _MM_SHUFFLE(2, 3, 0, 1)
	shufps xmm2, xmm2, _MM_SHUFFLE(2, 3, 0, 1)
	shufps xmm3, xmm3, _MM_SHUFFLE(2, 3, 0, 1)
	maxps xmm0, xmm4
	maxps xmm1, xmm5
	maxps xmm2, xmm6
	maxps xmm3, xmm7
	shufps xmm0, xmm0, _MM_SHUFFLE(2, 0, 2, 0)
	shufps xmm1, xmm1, _MM_SHUFFLE(2, 0, 2, 0)
	shufps xmm2, xmm2, _MM_SHUFFLE(2, 0, 2, 0)
	shufps xmm3, xmm3, _MM_SHUFFLE(2, 0, 2, 0)
	movq [edi + 0x00], xmm0
	movq [edi + 0x08], xmm1
	movq [edi + 0x10], xmm2
	movq [edi + 0x18], xmm3
	add eax, 0x40
	add edx, 0x40
	add edi, 0x20

	dec ecx
	jnz .loop_many

.end:
	FrameEnd
	ret

DefFunc _FloatMapNextAvrMipPoolProc
	FrameBegin ebx, edi
	NameParams %$RowPtr, %$CommonData, %$Y

	mov ebx, %$CommonData
	mov eax, [ebx + 0] ;dst
	mov ebx, [ebx + 4] ;src

	mov edx, %$Y
	mov edi, %$RowPtr
	mov ecx, [eax + BitMap.border_len]
	lea eax, [edx * 2]
	mov edx, [ebx + BitMap.row_ptr + eax * 4 + 4]
	mov eax, [ebx + BitMap.row_ptr + eax * 4 + 0]

	test dword[ebx + BitMap.border_len], 0x0F
	jz .proc_many

.loop_proc:
	movss xmm0, [eax + 0]
	addss xmm0, [edx + 0]
	addss xmm0, [eax + 4]
	addss xmm0, [edx + 4]
	divss xmm0, [_F4444]
	movss [edi], xmm0
	add eax, 8
	add edx, 8
	add edi, 4

	dec ecx
	jnz .loop_proc
	jmp .end

.proc_many:
	shr ecx, 3
.loop_many:
	movaps xmm0, [eax + 0x00]
	movaps xmm1, [eax + 0x10]
	movaps xmm2, [eax + 0x20]
	movaps xmm3, [eax + 0x30]
	addps xmm0, [edx + 0x00]
	addps xmm1, [edx + 0x10]
	addps xmm2, [edx + 0x20]
	addps xmm3, [edx + 0x30]
	movaps xmm4, xmm0
	movaps xmm5, xmm1
	movaps xmm6, xmm2
	movaps xmm7, xmm3
	shufps xmm0, xmm0, _MM_SHUFFLE(2, 0, 2, 0)
	shufps xmm1, xmm1, _MM_SHUFFLE(2, 0, 2, 0)
	shufps xmm2, xmm2, _MM_SHUFFLE(2, 0, 2, 0)
	shufps xmm3, xmm3, _MM_SHUFFLE(2, 0, 2, 0)
	shufps xmm4, xmm4, _MM_SHUFFLE(3, 1, 3, 1)
	shufps xmm5, xmm5, _MM_SHUFFLE(3, 1, 3, 1)
	shufps xmm6, xmm6, _MM_SHUFFLE(3, 1, 3, 1)
	shufps xmm7, xmm7, _MM_SHUFFLE(3, 1, 3, 1)
	addps xmm0, xmm4
	addps xmm1, xmm5
	addps xmm2, xmm6
	addps xmm3, xmm7
	divps xmm0, [_F4444]
	divps xmm1, [_F4444]
	divps xmm2, [_F4444]
	divps xmm3, [_F4444]
	movq [edi + 0x00], xmm0
	movq [edi + 0x08], xmm1
	movq [edi + 0x10], xmm2
	movq [edi + 0x18], xmm3
	add eax, 0x40
	add edx, 0x40
	add edi, 0x20

	dec ecx
	jnz .loop_many

.end:
	FrameEnd
	ret
