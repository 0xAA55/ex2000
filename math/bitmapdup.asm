%include "common.inc"

DefFunc _DuplicateBitMap
	FrameBegin 0, ebx, edi
	mov ebx, Param(0)
	invoke_cdecl _CreateBitMap, [ebx + BitMap.border_len], [ebx + BitMap.dims], [ebx + BitMap.bytes_per_pixel]
	mov edi, eax
	invoke_dll_cdecl memcpy, [edi + BitMap.data], [ebx + BitMap.data], [ebx + BitMap.num_bytes]
	mov eax, edi
	FrameEnd
	ret
