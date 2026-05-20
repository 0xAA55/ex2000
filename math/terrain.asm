%include "common.inc"
%include "buffer.inc"

segment .text
DefFunc _AltitudeToTerrain
	FrameBegin 8, 3, ebx, esi, edi
	AssignVars _X, _Y, _NUM_V, _NUM_I, _CB_V, _BM, _YI, _YI2

	mov esi, Param(0)
	cmp dword[esi + FloatMap.dims], 1
	je .good
.bad:
	int3
	jmp .bad
.good:

	mov eax, [esi + FloatMap.border_len]
	dec eax
	mov _BM, eax
	mov eax, [esi + FloatMap.border_len]
	mov ecx, 6
	inc eax
	mul eax
	mov _NUM_V, eax
	mov eax, [esi + FloatMap.num_pixels]
	mul ecx
	mov _NUM_I, eax
	mov eax, SimpleVertex.size
	mul dword _NUM_V
	mov _CB_V, eax ;cbVertices
	mov ecx, _NUM_I
	lea edx, [ecx * 4]
	invoke_cdecl _malloc, &[eax + ecx * 4 + SimpleMesh.size]
	mov ebx, eax
	lea eax, [ebx + SimpleMesh.size]
	mov [ebx + SimpleMesh.vertices], eax
	add eax, _CB_V ;cbVertices
	mov ecx, _NUM_V
	mov edx, _NUM_I
	mov [ebx + SimpleMesh.indices], eax
	mov [ebx + SimpleMesh.num_vertices], ecx
	mov [ebx + SimpleMesh.num_indices], edx

.gen_indices:
	%define _T1 %[_NUM_V]
	%define _T2 %[_NUM_I]
	%undef _NUM_V
	%undef _NUM_I

	xor eax, eax
	mov edi, [ebx + SimpleMesh.indices]
	movd xmm5, [esi + FloatMap.border_len]
	pshufd xmm5, xmm5, 0x00
	mov _Y, eax
.loopy_i:
	mov _YI, eax
	inc eax
	and eax, _BM
	mov _YI2, eax
	movq xmm4, _YI
	unpcklps xmm4, xmm4 ;yi, yi, yi1, yi1
	pmuludq xmm4, xmm5 ;yi * w, yi1 * w
	pshufd xmm4, xmm4, _MM_SHUFFLE(2, 2, 0, 0)

	xor eax, eax
	mov _X, eax
.loopx_i:
	mov _T1, eax
	inc eax
	and eax, _BM
	mov _T2, eax
	movq xmm0, _T1
	pshufd xmm0, xmm0, _MM_SHUFFLE(1, 0, 1, 0)
	paddd xmm0, xmm4
	pshufd xmm1, xmm0, _MM_SHUFFLE(2, 3, 1, 2)
	movq [edi + 0], xmm0
	movups [edi + 8], xmm1
	add edi, 6 * 4

	mov eax, _X
	inc eax
	mov _X, eax
	cmp eax, [esi + FloatMap.border_len]
	jb .loopx_i

	mov eax, _Y
	inc eax
	mov _Y, eax
	cmp eax, [esi + FloatMap.border_len]
	jb .loopy_i

.gen_vertices:
	%define _CUR_ROW %[_T1]
	%define _PREV_ROW %[_T2]
	%define _NEXT_ROW %[_CB_V]
	%undef _T1
	%undef _T2
	%undef _CB_V

	mov edi, [ebx + SimpleMesh.vertices]
	cvtsi2ss xmm5, [esi + FloatMap.border_len]
	movss xmm4, Param(2)
	movaps xmm6, [_F1111]
	shufps xmm5, xmm5, _MM_SHUFFLE(0, 0, 0, 0)
	shufps xmm4, xmm4, _MM_SHUFFLE(0, 0, 0, 0)
	divps xmm6, xmm5
	addps xmm5, [_F1111]
	divps xmm4, xmm5

	xor eax, eax
	mov _Y, eax
.loopy:
	lea ecx, [eax - 1]
	lea edx, [eax + 1]
	and ecx, _BM
	and edx, _BM
	mov eax, [esi + FloatMap.row_ptr + eax * 4]
	mov ecx, [esi + FloatMap.row_ptr + ecx * 4]
	mov edx, [esi + FloatMap.row_ptr + edx * 4]
	mov _CUR_ROW, eax
	mov _PREV_ROW, ecx
	mov _NEXT_ROW, edx
	xor eax, eax
	mov _X, eax
.loopx:
	mov ecx, _PREV_ROW
	mov edx, _NEXT_ROW
	lea ecx, [ecx + eax * 4]
	lea edx, [edx + eax * 4]
	movss xmm2, [ecx]
	subss xmm2, [edx]
	mulss xmm2, xmm5 ;nz
	lea ecx, [eax - 1]
	lea edx, [eax + 1]
	lea eax, [eax * 4]
	add eax, _CUR_ROW
	movss xmm1, [eax]
	mov eax, _CUR_ROW
	and ecx, _BM
	and edx, _BM
	lea ecx, [eax + ecx * 4]
	lea edx, [eax + edx * 4]
	movss xmm0, [ecx]
	mulss xmm1, Param(1)
	subss xmm0, [edx]
	movss [edi + SimpleVertex.y], xmm1
	mulss xmm0, xmm5 ;nx

	movss [edi + SimpleVertex.nx], xmm0
	mov dword[edi + SimpleVertex.ny], 0x3F800000
	movss [edi + SimpleVertex.nz], xmm1

	lea eax, [edi + SimpleVertex.nx]
	invoke_cdecl _VectorNormal, eax, eax, 3

	movq xmm0, _X
	cvtdq2ps xmm0, xmm0
	movaps xmm1, xmm0
	mulps xmm0, xmm4
	mulps xmm1, xmm6
	pshufd xmm2, xmm0, _MM_SHUFFLE(1, 1, 1, 1)
	movss [edi + SimpleVertex.x], xmm0
	movss [edi + SimpleVertex.z], xmm2
	movq [edi + SimpleVertex.u], xmm1
	add edi, ecx

	mov eax, _X
	inc eax
	mov _X, eax
	cmp eax, [esi + FloatMap.border_len]
	jb .loopx

	mov eax, _Y
	inc eax
	mov _Y, eax
	cmp eax, [esi + FloatMap.border_len]
	jb .loopy

	mov eax, ebx
	FrameEnd
	ret
	%undef _X
	%undef _Y
	%undef _CUR_ROW
	%undef _PREV_ROW
	%undef _NEXT_ROW
	%undef _BM
	%undef _YI
	%undef _YI2
