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
	mov eax, Vertex.size
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
	%define _T3 %[_CB_V]
	%undef _NUM_V
	%undef _NUM_I
	%undef _CB_V

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
	mov ecx, eax
	mov edx, eax
	dec ecx
	inc edx
	and ecx, _BM
	and edx, _BM
	mov eax, [esi + FloatMap.row_ptr + eax * 4]
	mov ecx, [esi + FloatMap.row_ptr + ecx * 4]
	mov edx, [esi + FloatMap.row_ptr + edx * 4]
	movss xmm0, [ecx]
	subss xmm0, [edx]
	mulss xmm0, xmm5 ;nz
	movss _T1, xmm0
	mov _T2, eax
	xor eax, eax
	mov _X, eax
.loopx:
	mov ecx, eax
	mov edx, eax
	dec ecx
	inc edx
	mov eax, _T2
	and ecx, _BM
	and edx, _BM
	mov ecx, [eax + ecx * 4]
	mov edx, [eax + edx * 4]
	movss xmm0, [ecx]
	subss xmm0, [edx]
	mulss xmm0, xmm5 ;nx
	
	mov eax, _T1
	mov [edi + Vertex.nz], eax
	mov dword[edi + Vertex.ny], 0x3F800000
	movss [edi + Vertex.nx], xmm0

	lea eax, [edi + Vertex.nx]
	invoke_cdecl _VectorNormal, eax, eax, 3

	mov eax, _X
	mov ecx, Vertex.size
	mul ecx
	add eax, _T2
	movss xmm0, [eax]
	mulss xmm0, Param(1)
	movss [edi + Vertex.y], xmm0

	movq xmm0, _X
	cvtdq2ps xmm0, xmm0
	movaps xmm1, xmm0
	mulps xmm0, xmm4
	mulps xmm1, xmm6
	pshufd xmm2, xmm0, _MM_SHUFFLE(1, 1, 1, 1)
	movss [edi + Vertex.x], xmm0
	movss [edi + Vertex.z], xmm2
	movq [edi + Vertex.u], xmm1
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
