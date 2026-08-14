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
	DefImp _snprintf
	DefImp _DebugMsg
	DefImp _PoolRun
	DefImp _AVLInsert
	DefImp _AVLSearch
	DefImp _AVLRemove
	DefImp _AVLIterate
	DefImp _AVLClear
	DefImp _AVLBST_Min
	DefImp _Get_AVLOps_String
	DefImp _Get_AVLOps_Integer
	DefImp _GetDebugConsoleBuffer
	DefImp _GetDebugMsgBuffer
	DefImp _GetNumProcessors
	DefImp _CheckSSE3
	DefImp _CheckSSE41
%endmacro

%macro InstImpP 0
	DefImp ExitProcess
	DefImp GetProcessHeap
	DefImp HeapAlloc
	DefImp HeapReAlloc
	DefImp HeapFree
	DefImp MessageBoxA
	DefImp strcpy
	DefImp strlen
	DefImp strcmp
	DefImp printf
	DefImp memset
	DefImp memcpy
	DefImp vsnprintf
%endmacro

%macro InstImpFull 0
	InstImp
	InstImpP
	%include 'scfuncs.tmp'
	%include 'glfuncs.tmp'
%endmacro

%macro InstExp 0
	DefExp _ShellcodeInit
	DefExp _ShellcodeDeInit
	DefExp _TlsRegisterCallback
	DefExp _TlsInvokeCallbacks
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
	DefExp _UtfReadCharFromPtr
	DefExp _Utf32to16
	DefExp _LfuCreate
	DefExp _LfuGet
	DefExp _LfuPut
	DefExp _LfuDestroy
	DefExp _ProgramCreate
	DefExp _SceneLoadShaderProgram
	DefExp _InitBuffer
	DefExp _DeInitBuffer
	DefExp _BufferPushItem
	DefExp _BufferPopItem
	DefExp _BufferClear
	DefExp _BufferFlush
	DefExp _BufferTrimExcess
	DefExp _BufferResize
	DefExp _OGLFC_Create
	DefExp _OGLFC_Destroy
	DefExp _OGLFC_Compose
	DefExp _GLPrintf
	DefExp _GLPrintfXY
	DefExp _RaymarchTerrainAltitude
%endmacro

%macro GetAbsAddr 2-*
	call %%label
	%%label:
	pOp %1
	%if %0 == 2
		add %1, %2 - %%label
	%elif %0 == 4
		lea %2, [%1 + %4 - %%label]
		add %1, %3 - %%label
	%elif %0 == 6
		lea %2, [%1 + %5 - %%label]
		lea %3, [%1 + %6 - %%label]
		add %1, %4 - %%label
	%elif %0 == 8
		lea %2, [%1 + %6 - %%label]
		lea %3, [%1 + %7 - %%label]
		lea %4, [%1 + %8 - %%label]
		add %1, %5 - %%label
	%else
		%error Bad usage of `GetAbsAddr`
	%endif
%endmacro

%endif
