%include "common.inc"

DefFunc _DuplicateBitMap
	FrameBegin ebx, edi
	NameParams %$SrcMap
	mov ebx, %$SrcMap
	invoke_cdecl _CreateBitMap, [ebx + BitMap.border_len], [ebx + BitMap.dims], [ebx + BitMap.bytes_per_pixel]
	mov edi, eax
	invoke_cdecl memcpy, [edi + BitMap.data], [ebx + BitMap.data], [ebx + BitMap.num_bytes]
	mov eax, edi
	FrameEnd
	ret
