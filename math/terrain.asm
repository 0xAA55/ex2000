%include "common.inc"
%include "buffer.inc"

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
	mov _BM, eax ; bitmask for wrapping sampling
	mov eax, [esi + FloatMap.border_len]
	mov ecx, 6
	inc eax ; Extra vertices for seamless combinations
	mul eax
	mov _NUM_V, eax
	mov eax, [esi + FloatMap.num_pixels]
	mul ecx
	mov _NUM_I, eax
	mov eax, SimpleVertex.size
	mul dword _NUM_V
	mov _CB_V, eax ;cbVertices
	mov ecx, _NUM_I
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
	mov ecx, [esi + FloatMap.border_len]
	inc ecx
	movd xmm5, ecx
	pshufd xmm5, xmm5, 0x00
	mov _Y, eax
.loopy_i:
	mov _YI, eax
	inc eax
	mov _YI2, eax
	movq xmm4, _YI
	unpcklps xmm4, xmm4 ;yi, yi, yi1, yi1
	pmuludq xmm4, xmm5 ;yi * w, yi1 * w
	pshufd xmm4, xmm4, _MM_SHUFFLE(2, 2, 0, 0) ;yi * w, yi * w, yi1 * w, yi1 * w

	xor eax, eax
	mov _X, eax
.loopx_i:
	mov _T1, eax
	inc eax
	mov _T2, eax
	movq xmm0, _T1
	pshufd xmm0, xmm0, _MM_SHUFFLE(1, 0, 1, 0) ;xi, xi1, xi, xi1
	paddd xmm0, xmm4 ;xi + yi * w, xi1 + yi * w, xi + yi1 * w, xi1 + yi1 * w
	pshufd xmm1, xmm0, _MM_SHUFFLE(2, 3, 1, 2)
	movq [edi + 0], xmm0
	movdqu [edi + 8], xmm1
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
	%define _CURR_ROW %[_T1]
	%define _PREV_ROW %[_T2]
	%define _NEXT_ROW %[_CB_V]
	%define _NXZ_MOD %[_YI]
	%define _CUR_HEIGHT %[_YI2]
	%undef _T1
	%undef _T2
	%undef _CB_V
	%undef _YI
	%undef _YI2

	mov edi, [ebx + SimpleMesh.vertices]

	movss xmm7, Param(1) ; height_mod
	cvtsi2ss xmm5, [esi + FloatMap.border_len]
	movss xmm4, Param(2) ; size_mod
	movaps xmm6, [_F1111]
	shufps xmm5, xmm5, _MM_SHUFFLE(0, 0, 0, 0)
	shufps xmm4, xmm4, _MM_SHUFFLE(0, 0, 0, 0)
	addps xmm5, [_F1111]
	divps xmm6, xmm5 ; xmm6 = 1.0 / (border_len + 1.0)
	divps xmm4, xmm5 ; xmm4 = size_mod / (border_len + 1.0)
	movss xmm2, xmm4
	addss xmm2, xmm4
	divss xmm7, xmm2 ; height_mod / (2.0 * size_mod / (border_len + 1.0))
	shufps xmm7, xmm7, 0
	movss _NXZ_MOD, xmm7

	xor eax, eax
	mov _Y, eax
.loopy_v:
	and eax, _BM
	lea ecx, [eax - 1]
	lea edx, [eax + 1]
	and ecx, _BM
	and edx, _BM
	mov eax, [esi + FloatMap.row_ptr + eax * 4]
	mov ecx, [esi + FloatMap.row_ptr + ecx * 4]
	mov edx, [esi + FloatMap.row_ptr + edx * 4]
	mov _CURR_ROW, eax ; y
	mov _PREV_ROW, ecx ; y - 1
	mov _NEXT_ROW, edx ; y + 1
	xor eax, eax
	mov _X, eax
.loopx_v:
	and eax, _BM
	mov ecx, _PREV_ROW
	mov edx, _NEXT_ROW
	lea ecx, [ecx + eax * 4]
	lea edx, [edx + eax * 4]
	movd xmm2, [ecx] ;(x, y-1)
	movd xmm3, [edx] ;(x, y+1)
	lea ecx, [eax - 1]
	lea edx, [eax + 1]
	lea eax, [eax * 4]
	add eax, _CURR_ROW
	movss xmm0, [eax]
	mulss xmm0, Param(1)
	movss _CUR_HEIGHT, xmm0
	mov eax, _CURR_ROW
	and ecx, _BM
	and edx, _BM
	lea ecx, [eax + ecx * 4]
	lea edx, [eax + edx * 4]
	movd xmm0, [ecx] ;(x-1, y)
	movd xmm1, [edx] ;(x+1, y)
	movlhps xmm0, xmm2
	movlhps xmm1, xmm3
	subps xmm0, xmm1
	mulps xmm0, xmm7

	movups [edi + SimpleVertex.nx], xmm0

	invoke_cdecl _VectorNormal, &[edi + SimpleVertex.nx], &[edi + SimpleVertex.nx], 3

	movq xmm0, _X
	movd xmm1, _CUR_HEIGHT
	cvtdq2ps xmm0, xmm0
	movaps xmm3, xmm0
	mulps xmm0, xmm4 ; xz * size_mod / (border_len + 1.0)
	mulps xmm3, xmm6 ; uv / (border_len + 1.0)
	pshufd xmm2, xmm0, _MM_SHUFFLE(1, 1, 1, 1)
	movss [edi + SimpleVertex.x], xmm0
	movss [edi + SimpleVertex.y], xmm1
	movss [edi + SimpleVertex.z], xmm2
	mov dword[edi + SimpleVertex.ny], __?float32?__(1.0)
	movq [edi + SimpleVertex.u], xmm3
	add edi, SimpleVertex.size

	mov eax, _X
	inc eax
	mov _X, eax
	cmp eax, [esi + FloatMap.border_len]
	jbe .loopx_v

	mov eax, _Y
	inc eax
	mov _Y, eax
	cmp eax, [esi + FloatMap.border_len]
	jbe .loopy_v

	mov eax, ebx
	FrameEnd
	ret
	%undef _X
	%undef _Y
	%undef _CURR_ROW
	%undef _PREV_ROW
	%undef _NEXT_ROW
	%undef _BM
	%undef _NXZ_MOD
	%undef _CUR_HEIGHT
