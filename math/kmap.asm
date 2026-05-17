%include "common.inc"

segment .text
DefFunc _FloatMapKMapGenProc
	FrameBegin 5, 3, ebx, esi, edi
	AssignVars _X, _WY, _HF, _MAX, _DMAP

	mov ebx, Param(0)
	mov esi, [ebx + FMDataCmn.src_map]
	mov edi, [ebx + FMDataCmn.dst_map]
	mov eax, [ebx + FMDataCmn.userdata]
	mov eax, [eax + FloatMap.data]
	mov _DMAP, eax

	mov eax, [esi + FloatMap.border_len]
	shr eax, 1
	mov _HF, eax

	mov eax, Param(1)
	mov edi, [edi + FloatMap.row_ptr + eax * 4]
	add eax, _HF
	mov _WY, eax

	xor eax, eax
	mov _X, eax
.loopx:
	add eax, _HF
	invoke_cdecl _WarpFloatMap, esi, eax, _WY
	mov ebx, eax

	mov eax, [ebx + FloatMap.data]
	mov edx, _DMAP
	mov ecx, [ebx + FloatMap.num_pixels]
	test cl, 0xF
	jz .vector_process
.single_process:
	movss xmm0, [eax + (ecx - 1) * 4]
	divss xmm0, [edx + (ecx - 1) * 4]
	movss [eax + (ecx - 1) * 4], xmm0
	loop .single_process
	jmp .process_end

.vector_process:
	shr ecx, 4
.vector_loop:
	movaps xmm0, [eax + 0x00]
	movaps xmm1, [eax + 0x10]
	movaps xmm2, [eax + 0x20]
	movaps xmm3, [eax + 0x30]
	divps xmm0, [edx + 0x00]
	divps xmm1, [edx + 0x10]
	divps xmm2, [edx + 0x20]
	divps xmm3, [edx + 0x30]
	movaps [eax + 0x00], xmm0
	movaps [eax + 0x10], xmm1
	movaps [eax + 0x20], xmm2
	movaps [eax + 0x30], xmm3
	add eax, 0x40
	add edx, 0x40
	loop .vector_loop

.process_end:
	invoke_cdecl _FloatMapGetMaxValue, ebx
	fstp dword _MAX
	invoke_cdecl _DestroyFloatMap, ebx
	mov eax, _X
	mov ecx, _MAX
	mov [edi + eax * 4], ecx
	inc eax
	mov _X, eax
	cmp eax, [esi + FloatMap.border_len]
	jb .loopx

	FrameEnd
	ret
	%undef _X
	%undef _WY
	%undef _HF
	%undef _MAX
	%undef _DMAP

DefFunc _FloatMapKMapGen
	FrameBegin 1, 5, ebx, esi
	mov eax, Param(0)
	invoke_cdecl _GenDistanceMap, [eax + FloatMap.border_len]
	mov esi, eax
	invoke_cdecl _FloatMapMTPool, Param(0), 8, esi, _FloatMapKMapGenProc, 0
	mov ebx, eax
	invoke_cdecl _DestroyFloatMap, esi
	mov eax, ebx
	FrameEnd
	ret
