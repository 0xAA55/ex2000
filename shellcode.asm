bits 32

%define reljmp 0xE9, 0, 0, 0, 0

%macro DefImp 1
	segment .text
	%1: db 0xE9, 0xE9, 0xE9, 0xE9, 0xE9
%endmacro

%macro DefExp 1
	segment .text
	dd %1
%endmacro

DefImp _malloc
DefImp _calloc
DefImp _realloc
DefImp _free
DefImp _aligned_malloc
DefImp _aligned_free
DefImp _AssetsQuery
DefImp _PoolRun

%include "scfuncs.tmp"

DefExp _CreateBitMap
DefExp _DestroyBitMap
DefExp _GetBitmapPixelAddress
DefExp _SampleFloatMap
DefExp _BatchAdd
DefExp _BatchBias
DefExp _BatchCurve
DefExp _BatchMax
DefExp _BatchMin

%define StackSegmentAttrib nobits
%define StackSegmentIsBss 1
[warning -pp-macro-redef-multi]
%unmacro extern 1-*
%macro extern 1-*
%endmacro
[warning +pp-macro-redef-multi]

%unmacro DefImp 1
%unmacro DefExp 1

%include "shellcode.inc"
%include "math/common.inc"

%include "bitmap.inc"
%include "samplefmap.inc"
%include "batchadd.inc"
%include "batchbias.inc"
%include "batchcurve.inc"
%include "batchmax.inc"
%include "batchmin.inc"

times 16 - ($ - $$) % 16 int3
