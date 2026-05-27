%include "common.inc"

DefFunc _DuplicateFloatMap
	FrameBegin 0, 3, ebx, edi
	mov ebx, Param(0)
	invoke_cdecl _CreateFloatMap, [ebx + FloatMap.border_len], [ebx + FloatMap.dims]
	mov edi, eax
	invoke_dll_cdecl memcpy, [edi + FloatMap.data], [ebx + FloatMap.data], [ebx + FloatMap.num_bytes]
	mov eax, edi
	FrameEnd
	ret
