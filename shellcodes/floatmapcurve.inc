%include "common.inc"

struc PoolProcParam
.bitmap resd 1
.curve_ptr resd 1
.curve_points resd 1
.size equ $ - PoolProcParam
endstruc

DefFunc _FloatMapCurvePoolProc
	FrameBegin ebx, esi, edi
	NameParams %$Params, %$CommonData, %$Index

	mov ebx, %$CommonData
	mov esi, %$Params
	mov edi, [ebx + PoolProcParam.bitmap]

	mov eax, [edi + BitMap.border_len]
	mul dword[edi + BitMap.dims]

	invoke_cdecl _BatchCurve, esi, eax, [ebx + PoolProcParam.curve_ptr], [ebx + PoolProcParam.curve_points]

	FrameEnd
	ret

DefFunc _FloatMapCurve
	FrameBegin ebx
	NameParams %$Map, %$Curve, %$NumCurvePoints, %$ThreadPoolSize

	mov ebx, %$Map

	invoke_cdecl _GetNumProcessors
	mov ecx, eax
	mov eax, %$ThreadPoolSize
	test eax, eax
	cmovz eax, ecx
	mov %$ThreadPoolSize, eax
	GetAbsAddr ecx, _FloatMapCurvePoolProc
	invoke_cdecl _PoolRun, ecx, & %$Map, %$ThreadPoolSize, [ebx + BitMap.border_len], &[ebx + BitMap.row_ptr], 0, 0

	FrameEnd
	ret
