%ifndef _SHELLCODE_INC_
%define _SHELLCODE_INC_ 1

%macro DefImp 1
.%1 resb 5
%endmacro

struc SCHead
.imports:
	DefImp _malloc
	DefImp _calloc
	DefImp _realloc
	DefImp _free
	DefImp _aligned_malloc
	DefImp _aligned_free
	DefImp _AssetsQuery

	%include 'scfuncs.tmp'

.exports:
	._CreateBitMap resd 1
	._DestroyBitMap resd 1
	._GetBitmapPixelAddress resd 1
	._SampleFloatMap resd 1
	._BatchAdd resd 1
.last_ptr:
	.size equ $ - SCHead
endstruc

%endif
