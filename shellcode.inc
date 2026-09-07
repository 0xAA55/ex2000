%ifndef _SHELLCODE_INC_
%define _SHELLCODE_INC_ 1

%macro InstImp 0
	DefImp _LoadLibrary
	DefImp _GetProcAddress
	DefImp _SafeRelease
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
	DefExp _TlsInit
	DefExp _TlsRegisterCallback
	DefExp _TlsInvokeCallbacks
	DefExp _TlsDeInit
	DefExp _CreateBitMap
	DefExp _DestroyBitMap
	DefExp _DuplicateBitMap
	DefExp _GetBitmapPixelAddress
	DefExp _SampleFloatMap
	DefExp _FloatMapNextMip
	DefExp _FloatMapApplyGain
	DefExp _FloatMapCurve
	DefExp _FloatMapGetMinValue
	DefExp _FloatMapGetMaxValue
	DefExp _AccumulateFloatMap
	DefExp _BatchAdd
	DefExp _BatchBias
	DefExp _BatchCurve
	DefExp _BatchMax
	DefExp _BatchMin
	DefExp _ConeMapGen
	DefExp _VectorMultMatrix
	DefExp _MatrixMultiply
	DefExp _MatrixMultiplyTo
	DefExp _MatrixProjection
	DefExp _MatrixRotationEuler
	DefExp _MatrixEulerTranslated
	DefExp _MatrixViewEuler
	DefExp _MatrixTranspose
	DefExp _CreateSeedVector
	DefExp _CreatePerlinMap2D
	DefExp _ConvertPerlinMapToAltitude
	DefExp _GenPerlinAltitude
	DefExp _GenMultiLayerPerlinAltitude
	DefExp _VectorCross
	DefExp _VectorDot
	DefExp _VectorLength
	DefExp _VectorNormal
	DefExp _UtfReadCharFromPtr
	DefExp _Utf32to16
	DefExp _HRSleepInit
	DefExp _HRSleepDeInit
	DefExp _HRSleep500us
	DefExp _GetSysTimerVal
	DefExp _GetTimerVal
	DefExp _InitTimer
	DefExp _UpdateTimer
	DefExp _IsTimerPaused
	DefExp _PauseTimer
	DefExp _UnpauseTimer
	DefExp _HybridWaitUs
	DefExp _LfuInit
	DefExp _LfuCreate
	DefExp _LfuGet
	DefExp _LfuPut
	DefExp _LfuDestroy
	DefExp _ProgramCreate
	DefExp _DeleteProgram
	DefExp _SceneLoadShaderProgram
	DefExp _SceneOnDisposeShaders
	DefExp _SceneLoadDrawProgressProgram
	DefExp _SceneLoadDrawTerrainProgram
	DefExp _SceneLoadDrawWaterProgram
	DefExp _SceneLoadDrawCompositeProgram
	DefExp _SceneLoadDrawBlurProgram
	DefExp _SceneLoadDrawHDR2LDRProgram
	DefExp _Scene_check_fbo
	DefExp _Scene_clear_color
	DefExp _Scene_clear_buffers
	DefExp _SetupSSFBOOutputs
	DefExp _SetupSSTextureMipmaps
	DefExp _SetupSSTextureShaderInput
	DefExp _InitDepthBuffer
	DefExp _DeleteRenderbuffer
	DefExp _InitRGBA32FBufferTexture
	DefExp _InitRGBA8BufferTexture
	DefExp _InitSSTextureSets
	DefExp _InitTexRenderTarget
	DefExp _InitTexRepeatLinear
	DefExp _InitTexRepeatLinearMipmap
	DefExp _DeleteTexture
	DefExp _DeInitSSTextureSets
	DefExp _InitBuffer
	DefExp _BufferPushItem
	DefExp _BufferPopItem
	DefExp _BufferClear
	DefExp _BufferFlush
	DefExp _BufferTrimExcess
	DefExp _BufferResize
	DefExp _DeInitBuffer
	DefExp _OGLFC_Create
	DefExp _OGLFC_Destroy
	DefExp _OGLFC_Compose
	DefExp _GLPrintf
	DefExp _GLPrintfXY
	DefExp _RaymarchTerrainAltitude
	DefExp _VBlankInit
	DefExp _VBlankDeInit
	DefExp _VBlankReInit
	DefExp _WaitForVBlank
%endmacro

%endif
