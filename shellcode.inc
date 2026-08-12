%ifndef _SHELLCODE_INC_
%define _SHELLCODE_INC_ 1

%macro DefImp 1
.%1 resb 5
%endmacro

%macro DefExp 1
.%1 resd 1
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
	DefImp _PoolRun
	DefImp _GetNumProcessors

	%include 'scfuncs.tmp'

.exports:
	DefExp _ShellcodeInit
	DefExp _CreateBitMap
	DefExp _DestroyBitMap
	DefExp _GetBitmapPixelAddress
	DefExp _SampleFloatMap
	DefExp _BatchAdd
	DefExp _BatchBias
	DefExp _BatchCurve
	DefExp _BatchMax
	DefExp _BatchMin
.last_ptr:
	.size equ $ - SCHead
endstruc

%endif
