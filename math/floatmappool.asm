%include "common.inc"

segment .text
DefFunc _FloatMapMTPool
	FrameBegin 1, 5, ebx, esi, edi
	AssignVars _JOBS

	; ebx = src_map
	; edi = dst_map
	; esi = cmn_data

	mov ebx, Param(0)

	invoke_cdecl _CreateFloatMap, [ebx + FloatMap.border_len], [ebx + FloatMap.dims]
	mov edi, eax

	invoke_cdecl _malloc, FMDataCmn.size
	mov esi, eax

	mov eax, Param(2)
	mov [esi + FMDataCmn.dst_map], edi
	mov [esi + FMDataCmn.src_map], ebx
	mov [esi + FMDataCmn.userdata], eax

	mov eax, [ebx + FloatMap.border_len]
	invoke_cdecl _malloc, &[eax * 4]
	mov _JOBS, eax

	push edi
	mov edi, eax
	mov ecx, [ebx + FloatMap.border_len]
	mov eax, esi
	rep stosd
	pop edi

	invoke_cdecl _PoolRun, Param(3), Param(1), [ebx + FloatMap.border_len], _JOBS, Param(4)

	invoke_cdecl _free, eax
	invoke_cdecl _free, esi
	invoke_cdecl _free, _JOBS

	mov eax, edi
	FrameEnd
	ret
	%undef _JOBS
