%include "common.inc"

segment .text
DefFunc _FloatMapGaussianBlurPoolProc
	FrameBegin 2, 3, ebx, esi, edi
	AssignVars _X, _Y

	xor eax, eax
	mov ecx, Param(1)
	mov _X, eax
	mov _Y, ecx

	mov ebx, Param(0)
	mov esi, [ebx + FMDataCmn.userdata]
	cvtsi2ss xmm6, [esi]

.proc_pixels:
	xor eax, eax
	mov edi, eax
	movq xmm5, _X
	movd xmm7, eax
	ResetPassReg
	PrepParam 2, [ebx + FMDataCmn.src_map]
.gather_gaussian:
	movd xmm0, [esi + 4 + edi * 4]
	pxor xmm1, xmm1
	pcmpgtw xmm1, xmm0
	punpcklwd xmm0, xmm1
	paddd xmm0, xmm5
	movq CallParam(0), xmm0
	call _GetXYFloatMap
	addss xmm7, [eax]
	inc edi
	cmp edi, [esi]
	jb .gather_gaussian
	divss xmm7, xmm6
	movq xmm0, _X

	ResetPassReg
	PrepParam 2, [ebx + FMDataCmn.dst_map]
	movq CallParam(0), xmm5
	call _GetXYFloatMap
	movss [eax], xmm7

	mov eax, _X
	inc eax
	mov _X, eax
	mov ecx, [ebx + FMDataCmn.src_map]
	cmp eax, [ecx + FloatMap.border_len]
	jb .proc_pixels

	FrameEnd
	ret
	%undef _X
	%undef _Y

DefFunc _FloatMapGaussianBlur
	FrameBegin 1, 5, ebx

	invoke_cdecl _GenRadiusMap, Param(1)
	mov Variable(0), eax
	invoke_cdecl _FloatMapMTPool, Param(0), 8, eax, _FloatMapGaussianBlurPoolProc, 0
	mov ebx, eax
	invoke_cdecl _free, Variable(0)
	mov eax, ebx
	FrameEnd
	ret
