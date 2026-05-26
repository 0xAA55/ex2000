%include "common.inc"

DefFunc _CreatePerlinMap2D
	FrameBegin 0, 2, ebx, esi

	invoke_cdecl _CreateFloatMap, Param(0), 2
	mov ebx, eax

	mov eax, Param(0)
	cmp eax, 1
	jae .blae1

	mov esi, [ebx + FloatMap.data]
	invoke_dll_cdecl rand
	shl eax, 1
	sub eax, 0x7FFF
	mov [esi], eax
	fild dword [esi]
	fidiv dword [_Rand4AndVal]
	fldpi
	fmul
	fsincos
	fstp dword [esi]
	fstp dword [esi + 4]

	jmp .end
.blae1:
	invoke_cdecl _CreateSeedVector
	mov esi, eax

	mov eax, [ebx + FloatMap.data]
	mov ecx, [ebx + FloatMap.num_pixels]
	shr ecx, 1
	movaps xmm2, [_F1111]
	movaps xmm3, [esi]
	movaps xmm4, [_Rand4MulVal]
	movaps xmm5, [_UF0F0]
	movaps xmm6, [_Rand4AddVal]
	movaps xmm7, [_Rand4AndVal]
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

	invoke_cdecl _DestroySeedVector, esi

.end:
	mov eax, ebx
	FrameEnd
	ret

DefFunc _ConvertPerlinMapToAltitude
	FrameBegin 9, 3, ebx, esi, edi
	AssignVars _STEPS, _RECIPROCAL, _MATRIX
	AssignVars _X, _Y, _BX, _BY, _IX, _IY
	%define _P00XY_P10XY ebx + 0x00
	%define _P01XY_P11XY ebx + 0x10
	%define _UV1 ebx + 0x20
	%define _UV1M ebx + 0x30
	%define _UV2M ebx + 0x40
	%define _DP_00_10_01_11 ebx + 0x50

	mov esi, Param(2)
	mov eax, Param(0)
	mul dword [esi + FloatMap.border_len]
	invoke_cdecl _CreateFloatMap, eax, 1
	mov edi, eax

	invoke_cdecl _aligned_malloc, 6 * 0x10, 0x10
	mov _MATRIX, eax

	mov eax, Param(0)
	invoke_cdecl _malloc, &[eax * 4]
	mov _STEPS, eax
	xor eax, eax
	mov _X, eax
	fld1
	fidiv dword Param(0)
	fst dword _RECIPROCAL
	mov ebx, _MATRIX
	mov eax, _RECIPROCAL
	pxor xmm0, xmm0
	movaps xmm1, [_F1111]
	mov edx, 0x3F800000
	mov ecx, 4
	movaps [_UV1M], xmm0
	movaps [_UV2M], xmm1
.init_uv:
	mov [_UV1 + (ecx - 1) * 4], eax
	loop .init_uv
	mov [_UV1M + Vector.z], edx
	mov [_UV2M + Vector.x], ecx

	mov ebx, _STEPS
.get_steps:
	fild dword _X
	fmul dword _RECIPROCAL
	fstp CallParam(0)
	call _SmootherStep
	fstp dword [ebx]
	add ebx, 4
	mov eax, _X
	inc eax
	mov _X, eax
	cmp eax, Param(0)
	jb .get_steps

	mov ebx, _MATRIX
	xor eax, eax
	mov _Y, eax
.loopy:
	mov eax, _Y
	mul eax, Param(0)
	mov _BY, eax
	xor eax, eax
	mov _X, eax
.loopx:
	mov eax, _X
	mul eax, Param(0)
	mov _BX, eax
	invoke_cdecl _GetXYFloatMap, _X, _Y, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P00XY_P10XY + Vector.x], eax
	mov [_P00XY_P10XY + Vector.y], edx
	mov eax, _X
	inc eax
	invoke_cdecl _GetXYFloatMap, eax, _Y, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P00XY_P10XY + Vector.z], eax
	mov [_P00XY_P10XY + Vector.w], edx
	mov eax, _Y
	inc eax
	invoke_cdecl _GetXYFloatMap, _X, eax, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P01XY_P11XY + Vector.x], eax
	mov [_P01XY_P11XY + Vector.y], edx
	mov eax, _X
	mov ecx, _Y
	inc eax
	inc ecx
	invoke_cdecl _GetXYFloatMap, eax, ecx, esi
	mov edx, [eax + 4]
	mov eax, [eax]
	mov [_P01XY_P11XY + Vector.z], eax
	mov [_P01XY_P11XY + Vector.w], edx
	xor eax, eax
	mov _IY, eax
.iloopy:
	xor eax, eax
	mov _IX, eax
.iloopx:
	movq xmm0, _IX; xmm0 <= (_IX, _IY) (0, 1)
	movlhps xmm0, xmm0; xmm0 <= (_IX, _IY, _IX, _IY) (0, 1, 2, 3)
	cvtdq2ps xmm0, xmm0; xmm0 <= (4f)xmm0

	movaps xmm1, xmm0
	mulps xmm0, [_UV1]
	mulps xmm1, [_UV1]
	subps xmm0, [_UV1M]
	subps xmm1, [_UV2M]
	mulps xmm0, [_P00XY_P10XY]
	mulps xmm1, [_P01XY_P11XY]
	cmp dword [_HaveSSE3], 0
	jz .no_sse3
	haddps xmm0, xmm1
	movaps [_DP_00_10_01_11], xmm0
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
	movaps [_DP_00_10_01_11], xmm2

.after_dot:
	mov eax, _BX
	mov ecx, _BY
	add eax, _IX
	add ecx, _IY
	invoke_cdecl _GetXYFloatMap, eax, ecx, edi
	mov edx, eax

	mov eax, _IX
	mov ecx, _IY
	lea eax, [eax * 4]
	lea ecx, [ecx * 4]
	add eax, _STEPS
	add ecx, _STEPS

	movss xmm0, [_DP_00_10_01_11 + Vector.y]
	movss xmm1, [_DP_00_10_01_11 + Vector.w]
	subss xmm0, [_DP_00_10_01_11 + Vector.x]
	subss xmm1, [_DP_00_10_01_11 + Vector.z]
	mulss xmm0, [eax]
	mulss xmm1, [eax]
	addss xmm0, [_DP_00_10_01_11 + Vector.x]
	addss xmm1, [_DP_00_10_01_11 + Vector.z]
	subss xmm1, xmm0
	mulss xmm1, [ecx]
	addss xmm0, xmm1
	movss [edx], xmm0

	mov eax, _IX
	inc eax
	mov _IX, eax
	cmp eax, Param(0)
	jb .iloopx

	mov eax, _IY
	inc eax
	mov _IY, eax
	cmp eax, Param(0)
	jb .iloopy

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

	invoke_cdecl _free, _STEPS
	invoke_cdecl _aligned_free, _MATRIX

	mov ebx, edi
	movaps xmm5, [_FP5P5P5P5]
	movss xmm7, Param(1)
	mov esi, [ebx + FloatMap.data]
	mov eax, [ebx + FloatMap.num_pixels]
	mul dword [ebx + FloatMap.dims]
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
	%undef _STEPS
	%undef _RECIPROCAL
	%undef _MATRIX
	%undef _X
	%undef _Y
	%undef _BX
	%undef _BY
	%undef _IX
	%undef _IY
	%undef _P00XY_P10XY
	%undef _P01XY_P11XY
	%undef _UV1
	%undef _UV1M
	%undef _UV2M
	%undef _DP_00_10_01_11

DefFunc _GenPerlinAltitude
	FrameBegin 0, 3, ebx, edi
	invoke_cdecl _CreatePerlinMap2D, Param(0)
	mov ebx, eax
	invoke_cdecl _ConvertPerlinMapToAltitude, Param(1), Param(2), ebx
	mov edi, eax
	invoke_cdecl _DestroyFloatMap, ebx
	mov eax, edi
	FrameEnd
	ret

DefFunc _AccumulateFloatMap
	FrameBegin 0, 0, esi, edi

	mov esi, Param(1)
	mov edi, Param(0)
	mov eax, [esi + FloatMap.num_pixels]
	mul dword [esi + FloatMap.dims]
	mov ecx, eax
	mov eax, [edi + FloatMap.num_pixels]
	mul dword [edi + FloatMap.dims]
	cmp eax, ecx
	je .good_size
.bad_size:
	int3
	jmp .bad_size
.good_size:
	mov ecx, eax
	mov esi, [esi + FloatMap.data]
	mov edi, [edi + FloatMap.data]
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
	FrameBegin 0, 3, ebx

	mov ebx, Param(0)
	invoke_cdecl _GenPerlinAltitude, \
		[ebx + GenPerlinLayerData.perlin_border_len], \
		[ebx + GenPerlinLayerData.ratio], \
		[ebx + GenPerlinLayerData.amplitude]

	FrameEnd
	ret

DefFunc _GenMultiLayerPerlinAltitude
	FrameBegin 1, 5, ebx, esi, edi
	AssignVars _JOBS

	mov eax, Param(0)
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
	mov Param(0), eax
	mov eax, Param(2)
	dec ecx
	cmp ecx, eax
	cmova ecx, eax
	mov Param(2), ecx ; ecx = num_layers = min(bits(eax) - 1, num_layers);

	mov eax, GenPerlinLayerData.size
	mul ecx
	invoke_cdecl _malloc, &[eax + ecx * 4] ; (sizeof GenPerlinLayerData) * num_layers + (sizeof GenPerlinLayerData*) * num_layers
	mov _JOBS, eax
	mov ebx, eax ; ebx = jobs
	mov ecx, Param(2)
	lea esi, &[eax + ecx * 4] ; esi = ebx + (sizeof GenPerlinLayerData*) * num_layers

	mov eax, 1
	mov ecx, Param(2)
	movss xmm0, [_F1111]
	shl eax, ecx
	mov edx, 2
	cvtsi2ss xmm1, eax
	mov eax, Param(0)
	divss xmm0, xmm1
.setjobs1:
	mulss xmm0, [_2.0f]
	shr eax, 1 ; perlin_border_len /= 2
	mov [esi + GenPerlinLayerData.perlin_border_len], eax
	mov [esi + GenPerlinLayerData.ratio], edx
	movss [esi + GenPerlinLayerData.amplitude], xmm0
	shl edx, 1 ; ratio *= 2
	mov [ebx], esi
	add ebx, 4
	add esi, GenPerlinLayerData.size
	loop .setjobs1
	mov ebx, ecx
	inc ebx ; ebx = 1

	invoke_cdecl _PoolRun, _GenPerlinLayerPoolProc, 8, Param(2), _JOBS, 0
	mov edi, eax
.accumulate:
	invoke_cdecl _AccumulateFloatMap, [edi], [edi + ebx * 4]
	invoke_cdecl _DestroyFloatMap, [edi + ebx * 4]
	inc ebx
	cmp ebx, Param(2)
	jb .accumulate

	invoke_cdecl _free, _JOBS

	%define _GAIN %[_JOBS]
	%undef _JOBS

	mov ebx, [edi]
	invoke_cdecl _free, edi

	invoke_cdecl _FloatMapGetMaxValue, ebx
	fdivr dword Param(1)
	fstp dword _GAIN

	invoke_cdecl _FloatMapApplyGain, ebx, _GAIN

	mov eax, ebx
	FrameEnd
	ret
	%undef _GAIN
