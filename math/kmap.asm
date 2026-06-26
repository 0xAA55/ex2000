%include "common.inc"

DefFunc _GenKMapOfAltitudeMap
	FrameBegin 0, 5, ebx, esi, edi

	mov esi, Param(0)
	invoke_cdecl _GenDistanceMap, [esi + BitMap.border_len]
	mov ebx, eax

	invoke_cdecl _BitMapMTPool, esi, 8, ebx, _GenKMapOfAltitudeMapPoolProc, 0
	mov edi, eax

	invoke_cdecl _DestroyBitMap, ebx
	mov eax, edi
	FrameEnd
	ret

DefFunc _GenKMapOfAltitudeMapPoolProc
	FrameBegin 7, 0, ebx, esi, edi
	AssignVars _X, _IX, _IY, _CbMap, _HalfSize, _AltDivDistMap, _DstRowPtr

	mov ebx, Param(0)
	mov esi, [ebx + BMDataCmn.src_map]
	mov edi, [ebx + BMDataCmn.dst_map]
	mov ebx, [ebx + BMDataCmn.userdata]

	mov eax, [ebx + BitMap.border_len]
	mov ecx, eax
	mul eax
	shr ecx, 1
	shl eax, 2
	mov _HalfSize, ecx
	mov _CbMap, eax

	invoke_cdecl _CreateBitMap, [ebx + BitMap.border_len], 1
	mov _AltDivDistMap, eax

	mov eax, Param(1)
	mov eax, [edi + BitMap.row_ptr + eax * 4]
	mov _DstRowPtr, eax

	xor eax, eax
	mov _X, eax
.proc_line:
	sub eax, _HalfSize
	invoke_cdecl _WarpBitMap, _AltDivDistMap, esi, eax, Param(1)
	invoke_cdecl _FloatMapDivide, _AltDivDistMap, ebx
	invoke_cdecl _FloatMapGetMaxValue, _AltDivDistMap
	mov edx, _DstRowPtr
	mov eax, _X
	fstp dword [edx + eax * 4]

	dec eax
	mov _X, eax
	cmp eax, [edi + BitMap.border_len]
	jb .proc_line

	invoke_cdecl _DestroyBitMap, _AltDivDistMap

	FrameEnd
	ret
