%include "common.inc"

DefFunc _BitMapMTPool
	FrameBegin 1, ebx, esi, edi
	AssignVars _JOBS

	; ebx = src_map
	; edi = dst_map
	; esi = cmn_data

	mov ebx, Param(0)

	invoke_cdecl _CreateBitMap, [ebx + BitMap.border_len], [ebx + BitMap.dims], [ebx + BitMap.bytes_per_pixel]
	mov edi, eax

	invoke_cdecl _malloc, BMDataCmn.size
	mov esi, eax

	mov eax, Param(2)
	mov [esi + BMDataCmn.dst_map], edi
	mov [esi + BMDataCmn.src_map], ebx
	mov [esi + BMDataCmn.userdata], eax

	mov eax, [ebx + BitMap.border_len]
	invoke_cdecl _malloc, &[eax * 4]
	mov _JOBS, eax

	push edi
	mov edi, eax
	mov ecx, [ebx + BitMap.border_len]
	mov eax, esi
	rep stosd
	pop edi

	invoke_cdecl _PoolRun, Param(3), Param(1), [ebx + BitMap.border_len], _JOBS, Param(4)

	invoke_cdecl _free, eax
	invoke_cdecl _free, esi
	invoke_cdecl _free, _JOBS

	mov eax, edi
	FrameEnd
	ret
	%undef _JOBS
