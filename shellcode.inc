%ifndef _SHELLCODE_INC_
%define _SHELLCODE_INC_ 1

struc SCHead
.imports:
	.malloc resb 5
	.calloc resb 5
	.realloc resb 5
	.free resb 5
	.aligned_malloc resb 5
	.aligned_free resb 5
.exports:
	.CreateBitMap resd 1
	.DestroyBitMap resd 1
	.GetBitmapPixelAddress resd 1
	.SampleFloatMap resd 1
.last_ptr:
	.size equ $ - SCHead
endstruc

%endif
