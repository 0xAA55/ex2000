
;void SampleFloatMap(BitMap *map, float u, float v, float *ret);
DefFunc _SampleFloatMap
	FrameBegin ebx, esi, edi
	NameParams %$Map, %$SU, %$SV, %$Ret
	DefVars %$X0, %$Y0, %$X1, %$Y1
	DefVars %$U, %$V, %$Dims
	DefVars %$Addr00, %$Addr10, %$Addr01, %$Addr11

	mov ebx, %$Map

	mov eax, [ebx + BitMap.border_len]
	cvtsi2ss xmm6, eax
	dec eax
	movd xmm7, eax
	shufps xmm6, xmm6, 0 ;border_len
	pshufd xmm7, xmm7, 0 ;mask x 4

	xor eax, eax
	inc eax

	movq xmm0, %$SU ;x, y
	mulps xmm0, xmm6

	movd xmm3, eax
	cvttps2dq xmm1, xmm0 ;xmm1 = {ix, iy}
	cvtdq2ps xmm2, xmm1
	pshufd xmm3, xmm3, 0
	subps xmm0, xmm2 ;xmm0 = {u, v}
	movq xmm2, xmm1 ;xmm2 = {ix, iy}
	paddd xmm1, xmm3 ;xmm1 = {ix+1, iy+1}

	movq %$X0, xmm2
	movq %$X1, xmm1
	movq %$U, xmm0

	lea edi, %$Addr00
	invoke_cdecl _GetBitmapPixelAddress, %$X0, %$Y0, ebx
	stosd
	invoke_cdecl _GetBitmapPixelAddress, %$X1, %$Y0, ebx
	stosd
	invoke_cdecl _GetBitmapPixelAddress, %$X0, %$Y1, ebx
	stosd
	invoke_cdecl _GetBitmapPixelAddress, %$X1, %$Y1, ebx
	stosd

	xor esi, esi
	mov eax, [ebx + BitMap.dims]
	mov %$Dims, eax

	mov eax, %$Addr00
	mov ecx, %$Addr10
	mov edx, %$Addr01
	mov ebx, %$Addr11
	mov edi, %$Ret

	movss xmm6, %$U
	movss xmm7, %$V
.proc_dims:
	movss xmm0, [eax + esi * 4]
	movss xmm1, [ecx + esi * 4]
	movss xmm2, [edx + esi * 4]
	movss xmm3, [ebx + esi * 4]
	subss xmm1, xmm0 ;p10-p00
	subss xmm3, xmm2 ;p11-p01
	mulss xmm1, xmm6
	mulss xmm3, xmm6
	addss xmm0, xmm1 ;y0 = p00 + (p10-p00) * U
	addss xmm2, xmm3 ;y1 = p01 + (p11-p01) * U
	subss xmm2, xmm0 ;y1-y0
	mulss xmm2, xmm7
	addss xmm0, xmm2 ;y0 + (y1-y0) * V
	movss [edi + esi * 4], xmm0
	inc esi
	cmp esi, %$Dims
	jb .proc_dims

	FrameEnd
	ret
