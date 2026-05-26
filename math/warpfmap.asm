%include "common.inc"

DefFunc _WarpFloatMap
	FrameBegin 4, 2, ebx, esi, edi
	AssignVars _X, _Y, _BITMASK, _ROWPTR

	mov esi, Param(0)
	invoke_cdecl _CreateFloatMap, [esi + FloatMap.border_len], [esi + FloatMap.dims]
	mov ebx, eax
	mov edi, [eax + FloatMap.data]

	mov eax, [ebx + FloatMap.border_len]
	dec eax
	mov _BITMASK, eax

	xor eax, eax
	mov _Y, eax
.loopy:
	add eax, Param(2)
	and eax, _BITMASK
	mov esi, Param(0)
	mov eax, [esi + FloatMap.row_ptr + eax * 4]
	mov _ROWPTR, eax
	xor eax, eax
	mov _X, eax
.loopx:
	add eax, Param(1)
	and eax, _BITMASK
	mov esi, _ROWPTR
	mov ecx, [ebx + FloatMap.dims]
	mul ecx
	lea esi, [esi + eax * 4]
	rep movsd

	mov eax, _X
	inc eax
	mov _X, eax
	cmp eax, [ebx + FloatMap.border_len]
	jb .loopx

	mov eax, _Y
	inc eax
	mov _Y, eax
	cmp eax, [ebx + FloatMap.border_len]
	jb .loopy

	mov eax, ebx
	FrameEnd
	ret
	%undef _X
	%undef _Y
	%undef _BITMASK
	%undef _ROWPTR
