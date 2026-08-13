
DefFunc _CreatePerlinMap2D
	FrameBegin ebx, esi
	DefVars %$AndVal
	DefSizedVar %$VectorBuffer, 0x20

	invoke_cdecl _CreateBitMap, Param(0), 2, 8
	mov ebx, eax

	mov dword %$AndVal, 0xFFFF

	mov eax, Param(0)
	cmp eax, 1
	jae .blae1

	mov esi, [ebx + BitMap.data]
	invoke_cdecl rand
	shl eax, 1
	sub eax, 0x7FFF
	mov [esi], eax
	fild dword [esi]
	fidiv dword %$AndVal
	fldpi
	fmul
	fsincos
	fstp dword [esi]
	fstp dword [esi + 4]

	jmp .end
.blae1:
	lea esi, Variable(4)
	and esi, 0xFFFFFFF0
	invoke_cdecl _CreateSeedVector, esi

	mov eax, __?float32?__(1.0)
	mov ecx, 0x343fD
	mov edx, 0x269EC3
	movd xmm2, eax
	movd xmm4, ecx
	movd xmm6, edx
	mov eax, 0xFFFFFFFF
	shufps xmm2, xmm2, 0
	shufps xmm4, xmm4, 0
	shufps xmm6, xmm6, 0
	movd xmm5, eax
	movaps xmm3, [esi]
	mov eax, [ebx + BitMap.data]
	mov ecx, [ebx + BitMap.num_pixels]
	movss xmm7, %$AndVal
	shr ecx, 1
	shufps xmm5, xmm5, _MM_SHUFFLE(1, 0, 1, 0)
	shufps xmm7, xmm7, 0
.generate:
	movaps xmm0, xmm3
	pmuludq xmm0, xmm4
	paddd xmm0, xmm6
	movaps xmm3, xmm0
	pand xmm0, xmm5
	pand xmm0, xmm7
	paddd xmm0, xmm0
	cvtdq2ps xmm0, xmm0
	cvtdq2ps xmm1, xmm7
	divps xmm0, xmm1
	subps xmm0, xmm2
	movaps [eax], xmm0

	fld dword [eax]
	fldpi
	fmul
	fsincos
	fstp dword [eax]
	fstp dword [eax + 4]
	fld dword [eax + 8]
	fldpi
	fmul
	fsincos
	fstp dword [eax + 8]
	fstp dword [eax + 12]

	add eax, 0x10
	loop .generate

.end:
	mov eax, ebx
	FrameEnd
	ret

DefFunc _ConvertPerlinMapToAltitude
	FrameBegin ebx, esi, edi
	NameParams %$Ratio, %$Amplitude, %$SrcMap
	DefVars %$Steps, %$Reciprocal, %$Matrix
	DefVars %$X, %$Y, %$BX, %$BY, %$IX, %$IY
	DefSizedVar %$MatrixBuffer, 6 * 0x10 + 0x10
	%define %$_P00XY_P10XY ebx + 0x00
	%define %$_P01XY_P11XY ebx + 0x10
	%define %$_UV1 ebx + 0x20
	%define %$_UV1M ebx + 0x30
	%define %$_UV2M ebx + 0x40
	%define %$_DP_00_10_01_11 ebx + 0x50

	mov esi, %$SrcMap
	mov eax, %$Ratio
	mul dword [esi + BitMap.border_len]
	invoke_cdecl _CreateBitMap, eax, 1, 4
	mov edi, eax

	lea eax, [%$MatrixBuffer_Addr + 0x10]
	and eax, 0xFFFFFFF0
	mov %$Matrix, eax

	mov eax, %$Ratio
	invoke_cdecl _malloc, &[eax * 4]
	mov %$Steps, eax
	mov ebx, %$Matrix
	pxor xmm0, xmm0
	mov eax, __?float32?__(1.0)
	movd xmm1, eax
	shufps xmm1, xmm1, 0
	mov ecx, 4
	movaps [%$_UV1M], xmm0
	movaps [%$_UV2M], xmm1
	mov eax, %$Ratio
	cvtsi2ss xmm0, eax
	rcpss xmm0, xmm0
	shufps xmm0, xmm0, 0
	movss %$Reciprocal, xmm0
	movaps [%$_UV1], xmm0
	mov dword[%$_UV1M + Vector.z], __?float32?__(1.0)
	mov [%$_UV2M + Vector.x], ecx

	xor eax, eax
	mov ebx, %$Steps
	mov %$X, eax
.get_steps:
	cvtsi2ss xmm0, eax
	mulss xmm0, %$Reciprocal

	mov eax, __?float32?__(6.0)
	mov ecx, __?float32?__(15.0)
	mov edx, __?float32?__(10.0)

	movss xmm4, xmm0
	movd xmm1, eax
	movd xmm2, ecx
	movd xmm3, edx
	mulss xmm0, xmm1
	subss xmm0, xmm2
	mulss xmm0, xmm4
	addss xmm0, xmm3
	mulss xmm0, xmm4
	mulss xmm0, xmm4
	mulss xmm0, xmm4
	movss [ebx], xmm0

	add ebx, 4
	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, %$Ratio
	jb .get_steps

	mov ebx, %$Matrix
	xor eax, eax
	mov %$Y, eax
.loopy:
	mov eax, %$Y
	mul eax, %$Ratio
	mov %$BY, eax
	xor eax, eax
	mov %$X, eax
.loopx:
	mov eax, %$X
	mul eax, %$Ratio
	mov %$BX, eax
	invoke_cdecl _GetBitmapPixelAddress, %$X, %$Y, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [%$_P00XY_P10XY + Vector.x], eax
	mov [%$_P00XY_P10XY + Vector.y], edx
	mov eax, %$X
	inc eax
	invoke_cdecl _GetBitmapPixelAddress, eax, %$Y, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [%$_P00XY_P10XY + Vector.z], eax
	mov [%$_P00XY_P10XY + Vector.w], edx
	mov eax, %$Y
	inc eax
	invoke_cdecl _GetBitmapPixelAddress, %$X, eax, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [%$_P01XY_P11XY + Vector.x], eax
	mov [%$_P01XY_P11XY + Vector.y], edx
	mov eax, %$X
	mov ecx, %$Y
	inc eax
	inc ecx
	invoke_cdecl _GetBitmapPixelAddress, eax, ecx, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [%$_P01XY_P11XY + Vector.z], eax
	mov [%$_P01XY_P11XY + Vector.w], edx
	xor eax, eax
	mov %$IY, eax
.iloopy:
	xor eax, eax
	mov %$IX, eax
.iloopx:
	movq xmm0, %$IX; xmm0 <= (%$IX, %$IY) (0, 1)
	movlhps xmm0, xmm0; xmm0 <= (%$IX, %$IY, %$IX, %$IY) (0, 1, 2, 3)
	cvtdq2ps xmm0, xmm0; xmm0 <= (4f)xmm0

	movaps xmm1, xmm0
	mulps xmm0, [%$_UV1]
	mulps xmm1, [%$_UV1]
	subps xmm0, [%$_UV1M]
	subps xmm1, [%$_UV2M]
	mulps xmm0, [%$_P00XY_P10XY]
	mulps xmm1, [%$_P01XY_P11XY]
	invoke_cdecl _CheckSSE3
	test eax, eax
	jz .no_sse3
	haddps xmm0, xmm1
	movaps [%$_DP_00_10_01_11], xmm0
	jmp .after_dot
.no_sse3:
	movaps xmm2, xmm0
	shufps xmm2, xmm0, _MM_SHUFFLE(2, 3, 0, 1)
	addps xmm0, xmm2
	shufps xmm0, xmm0, _MM_SHUFFLE(3, 1, 2, 0)
	movaps xmm2, xmm1
	shufps xmm2, xmm1, _MM_SHUFFLE(2, 3, 0, 1)
	addps xmm1, xmm2
	shufps xmm1, xmm1, _MM_SHUFFLE(3, 1, 2, 0)
	movhlps xmm2, xmm0
	movlhps xmm2, xmm1
	movaps [%$_DP_00_10_01_11], xmm2

.after_dot:
	mov eax, %$BX
	mov ecx, %$BY
	add eax, %$IX
	add ecx, %$IY
	invoke_cdecl _GetBitmapPixelAddress, eax, ecx, edi
	mov edx, eax

	mov eax, %$IX
	mov ecx, %$IY
	lea eax, [eax * 4]
	lea ecx, [ecx * 4]
	add eax, %$Steps
	add ecx, %$Steps

	movss xmm0, [%$_DP_00_10_01_11 + Vector.y]
	movss xmm1, [%$_DP_00_10_01_11 + Vector.w]
	subss xmm0, [%$_DP_00_10_01_11 + Vector.x]
	subss xmm1, [%$_DP_00_10_01_11 + Vector.z]
	mulss xmm0, [eax]
	mulss xmm1, [eax]
	addss xmm0, [%$_DP_00_10_01_11 + Vector.x]
	addss xmm1, [%$_DP_00_10_01_11 + Vector.z]
	subss xmm1, xmm0
	mulss xmm1, [ecx]
	addss xmm0, xmm1
	movss [edx], xmm0

	mov eax, %$IX
	inc eax
	mov %$IX, eax
	cmp eax, %$Ratio
	jb .iloopx

	mov eax, %$IY
	inc eax
	mov %$IY, eax
	cmp eax, %$Ratio
	jb .iloopy

	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, [esi + BitMap.border_len]
	jb .loopx

	mov eax, %$Y
	inc eax
	mov %$Y, eax
	cmp eax, [esi + BitMap.border_len]
	jb .loopy

	invoke_cdecl _free, %$Steps

	mov ebx, edi
	mov eax, __?float32?__(0.5)
	movd xmm5, eax
	shufps xmm5, xmm5, 0
	movss xmm7, %$Amplitude
	mov esi, [ebx + BitMap.data]
	mov eax, [ebx + BitMap.num_floats]
	test al, 0xF
	jz .batch_proc
	mov ecx, eax
.single_proc:
	movss xmm0, [esi + (ecx - 1) * 4]
	mulss xmm0, xmm5
	addss xmm0, xmm5
	mulss xmm0, xmm7
	movss [esi + (ecx - 1) * 4], xmm0
	loop .single_proc
	jmp .end
.batch_proc:
	shr eax, 4
	mov ecx, eax
	shufps xmm7, xmm7, 0
.batch_loop:
	movaps xmm0, [esi + 0x00]
	movaps xmm1, [esi + 0x10]
	movaps xmm2, [esi + 0x20]
	movaps xmm3, [esi + 0x30]
	mulps xmm0, xmm5
	mulps xmm1, xmm5
	mulps xmm2, xmm5
	mulps xmm3, xmm5
	addps xmm0, xmm5
	addps xmm1, xmm5
	addps xmm2, xmm5
	addps xmm3, xmm5
	mulps xmm0, xmm7
	mulps xmm1, xmm7
	mulps xmm2, xmm7
	mulps xmm3, xmm7
	movaps [esi + 0x00], xmm0
	movaps [esi + 0x10], xmm1
	movaps [esi + 0x20], xmm2
	movaps [esi + 0x30], xmm3
	add esi, 0x40
	loop .batch_loop

.end:
	mov eax, ebx
	FrameEnd
	ret

DefFunc _GenPerlinAltitude
	FrameBegin ebx, edi
	invoke_cdecl _CreatePerlinMap2D, Param(0)
	mov ebx, eax
	invoke_cdecl _ConvertPerlinMapToAltitude, Param(1), Param(2), ebx
	mov edi, eax
	invoke_cdecl _DestroyBitMap, ebx
	mov eax, edi
	FrameEnd
	ret

DefFunc _AccumulateFloatMap
	FrameBegin esi, edi

	mov esi, Param(1)
	mov edi, Param(0)
	mov ecx, [esi + BitMap.num_floats]
	mov eax, [edi + BitMap.num_floats]
	cmp eax, ecx
	je .good_size
.bad_size:
	int3
	jmp .bad_size
.good_size:
	mov ecx, eax
	mov esi, [esi + BitMap.data]
	mov edi, [edi + BitMap.data]
	xor eax, eax
	test ecx, 0xF
	jnz .tail
	shr ecx, 4
.proc:
	movaps xmm0, [esi + eax + 0x00]
	movaps xmm1, [esi + eax + 0x10]
	movaps xmm2, [esi + eax + 0x20]
	movaps xmm3, [esi + eax + 0x30]
	addps xmm0, [edi + eax + 0x00]
	addps xmm1, [edi + eax + 0x10]
	addps xmm2, [edi + eax + 0x20]
	addps xmm3, [edi + eax + 0x30]
	movaps [edi + eax + 0x00], xmm0
	movaps [edi + eax + 0x10], xmm1
	movaps [edi + eax + 0x20], xmm2
	movaps [edi + eax + 0x30], xmm3
	add eax, 64
	loop .proc
	jmp .end
.tail:
	movss xmm0, [esi + eax]
	addss xmm0, [edi + eax]
	movss [edi + eax], xmm0
	add eax, 4
	loop .tail
.end:
	FrameEnd
	ret

struc GenPerlinLayerData
	.perlin_border_len resd 1
	.ratio resd 1
	.amplitude resd 1
	.size equ $ - GenPerlinLayerData
endstruc

DefFunc _GenPerlinLayerPoolProc
	FrameBegin ebx

	mov ebx, Param(0)
	invoke_cdecl srand, Param(2)
	invoke_cdecl _GenPerlinAltitude, \
		[ebx + GenPerlinLayerData.perlin_border_len], \
		[ebx + GenPerlinLayerData.ratio], \
		[ebx + GenPerlinLayerData.amplitude]

	FrameEnd
	ret

DefFunc _GenMultiLayerPerlinAltitude
	FrameBegin ebx, esi, edi
	NameParams %$Size, %$Altitude, %$NumLayers, %$Curve, %$ThreadPoolSize
	DefVars %$Jobs, %$CurLayer

	mov eax, %$Size
	bsr ecx, eax
	cmp eax, 8
	jae .good_param1
.fail:
	int3
	jmp .fail
.good_param1:
	mov edx, eax
	dec edx
	test edx, eax
	jz .param1_fix_done
	inc ecx
	xor eax, eax
	inc eax
	shl eax, cl
.param1_fix_done:
	mov %$Size, eax
	mov eax, %$NumLayers
	dec ecx
	cmp ecx, eax
	cmova ecx, eax
	mov %$NumLayers, ecx ; ecx = num_layers = min(bits(eax) - 1, num_layers);

	mov eax, GenPerlinLayerData.size
	mul ecx
	invoke_cdecl _malloc, &[eax + ecx * 4] ; (sizeof GenPerlinLayerData) * num_layers + (sizeof GenPerlinLayerData*) * num_layers
	mov %$Jobs, eax
	mov ebx, eax ; ebx = jobs
	mov ecx, %$NumLayers
	lea esi, &[eax + ecx * 4] ; esi = ebx + (sizeof GenPerlinLayerData*) * num_layers

	xor eax, eax
	inc eax
	mov %$CurLayer, eax
	mov ecx, %$NumLayers
	mov edx, 2
	mov eax, %$Size
.setjobs1:
	fld dword %$CurLayer
	fdiv dword %$NumLayers
	fld dword %$Curve
	fyl2x
	fld st0
	frndint
	fsub st1, st0
	fxch st1
	f2xm1
	fld1
	faddp st1, st0
	fscale
	fstp st1
	fstp [esi + GenPerlinLayerData.amplitude]
	shr eax, 1 ; perlin_border_len /= 2
	mov [esi + GenPerlinLayerData.perlin_border_len], eax
	mov [esi + GenPerlinLayerData.ratio], edx
	shl edx, 1 ; ratio *= 2
	mov [ebx], esi
	add ebx, 4
	add esi, GenPerlinLayerData.size
	inc dword %$CurLayer
	dec ecx
	jnz .setjobs1
	mov ebx, ecx
	inc ebx ; ebx = 1

	invoke_cdecl _GetNumProcessors
	mov ecx, eax
	mov eax, %$ThreadPoolSize
	test eax, eax
	cmovz eax, ecx
	mov %$ThreadPoolSize, eax
	GetAbsAddr ecx, _GenPerlinLayerPoolProc
	invoke_cdecl _PoolRun, ecx, NULL, %$ThreadPoolSize, %$NumLayers, %$Jobs, 0, 1
	mov edi, eax
.accumulate:
	invoke_cdecl _AccumulateFloatMap, [edi], [edi + ebx * 4]
	invoke_cdecl _DestroyBitMap, [edi + ebx * 4]
	inc ebx
	cmp ebx, %$NumLayers
	jb .accumulate

	invoke_cdecl _free, %$Jobs

	%xdefine %$Gain %$Jobs
	%xdefine %$Bias %$CurLayer
	%undef %$Jobs
	%undef %$CurLayer

	mov ebx, [edi]
	invoke_cdecl _free, edi

	invoke_cdecl _FloatMapGetMinValue, ebx
	fchs
	fstp dword %$Bias

	invoke_cdecl _BatchBias, [ebx + BitMap.data], %$Bias, [ebx + BitMap.num_floats]

	invoke_cdecl _FloatMapGetMaxValue, ebx
	fdivr dword %$Altitude
	fstp dword %$Gain

	invoke_cdecl _FloatMapApplyGain, ebx, %$Gain

	mov eax, ebx
	FrameEnd
	ret
