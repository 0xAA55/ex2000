%ifndef _SHELLCODE_INC_
%define _SHELLCODE_INC_ 1

%macro InstImp 0
	DefImp _malloc
	DefImp _calloc
	DefImp _realloc
	DefImp _free
	DefImp _aligned_malloc
	DefImp _aligned_free
	DefImp _AssetsQuery
	DefImp _PoolRun
	DefImp _AVLInsert
	DefImp _AVLSearch
	DefImp _AVLRemove
	DefImp _AVLIterate
	DefImp _AVLClear
	DefImp _AVLBST_Min
	DefImp _Get_AVLOps_String
	DefImp _Get_AVLOps_Integer
	DefImp _GetNumProcessors
	DefImp _CheckSSE3
	DefImp _CheckSSE41
	DefImp _ProgramCreate
	DefImp _SceneLoadShaderProgram
%endmacro

%macro InstExp 0
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
%endmacro

%endif
