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

%include "scfuncs.tmp"

DefExp _CreateBitMap
DefExp _DuplicateBitMap
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
DefExp _MatrixEulerTranslated
DefExp _MatrixViewEuler
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
DefExp _VectorCross
DefExp _VectorDot
DefExp _VectorLength
DefExp _VectorNormal
DefExp _RaymarchTerrainAltitude

%unmacro DefImp 1
%unmacro DefExp 1

%macro GetAbsAddr 2
	call %%label
	%%label:
	pOp %1
	add %1, %2 - %%label
%endmacro

%include "shellcode.inc"

%macro binform 2
DefFunc %1
incbin %strcat(%2, ".bin")
%endmacro

%include "bitmap.inc"
%include "bitmapdup.inc"
%include "samplefmap.inc"
binform _BatchAdd, "batchadd"
binform _BatchBias, "batchbias"
binform _BatchCurve, "batchcurve"
binform _BatchMax, "batchmax"
binform _BatchMin, "batchmin"
%include "fmnm.inc"
%include "conemap.inc"
%include "matmult.inc"
binform _MatrixProjection, "matproj"
%include "mateuler.inc"
%include "matteuler.inc"
%include "matveuler.inc"
binform _MatrixTranspose, "mattranspose"
binform _FloatMapApplyGain, "floatmapgain"
%include "floatmapmax.inc"
%include "floatmapmin.inc"
%include "floatmapcurve.inc"
%include "seedvec.inc"
%include "perlin.inc"
binform _VectorCross, "veccross"
binform _VectorDot, "vecdot"
binform _VectorLength, "veclength"
binform _VectorMultMatrix, "vecmultmat"
binform _VectorNormal, "vecnormal"
%include "raymarch.inc"

times 16 - ($ - $$) % 16 int3
