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
DefImp _GetNumProcessors
DefImp _CheckSSE3
DefImp _CheckSSE41
DefImp _SmootherStep

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
DefExp _FloatMapNextMip
DefExp _ConeMapGen
DefExp _VectorMultMatrix
DefExp _MatrixMultiply
DefExp _MatrixMultiplyTo
DefExp _MatrixProjection
DefExp _MatrixRotationEuler
DefExp _MatrixTranspose
DefExp _FloatMapApplyGain
DefExp _CreateSeedVector
DefExp _CreatePerlinMap2D
DefExp _ConvertPerlinMapToAltitude
DefExp _GenPerlinAltitude
DefExp _AccumulateFloatMap
DefExp _GenMultiLayerPerlinAltitude
DefExp _FloatMapCurve
DefExp _FloatMapGetMinValue
DefExp _FloatMapGetMaxValue

%define StackSegmentAttrib nobits
%define StackSegmentIsBss 1
[warning -pp-macro-redef-multi]
%unmacro extern 1-*
%macro extern 1-*
%endmacro
[warning +pp-macro-redef-multi]

%unmacro DefImp 1
%unmacro DefExp 1

%macro GetAbsAddr 2
	call %%label
	%%label:
	pOp %1
	add %1, %2 - %%label
%endmacro

%define _MM_SHUFFLE(fp3,fp2,fp1,fp0) (((fp3) << 6) | ((fp2) << 4) | ((fp1) << 2) | ((fp0)))

%include "shellcode.inc"
%include "math/common.inc"

%include "bitmap.inc"
%include "samplefmap.inc"
%include "batchadd.inc"
%include "batchbias.inc"
%include "batchcurve.inc"
%include "batchmax.inc"
%include "batchmin.inc"
%include "fmnm.inc"
%include "conemap.inc"
%include "vecmultmat.inc"
%include "matmult.inc"
%include "matproj.inc"
%include "mateuler.inc"
%include "mattranspose.inc"
%include "floatmapgain.inc"
%include "floatmapmax.inc"
%include "floatmapmin.inc"
%include "floatmapcurve.inc"
%include "seedvec.inc"
%include "perlin.inc"

times 16 - ($ - $$) % 16 int3
