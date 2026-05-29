%include "common.inc"

struc PoolProcParam
.curve_ptr resd 1
.curve_points resd 1
.fmap resd 1
.size equ $ - PoolProcParam
endstruc

segment .bss
extern _FloatMapCurveNumWorkers
_FloatMapCurveNumWorkers resd 1

DefFunc _FloatMapCurvePoolProc
	FrameBegin 0, 4, ebx, esi, edi

	mov ebx, Param(0)
	mov edi, [ebx + PoolProcParam.fmap]
	mov eax, Param(1)
	mov esi, [edi + FloatMap.row_ptr + eax * 4]

	mov eax, [edi + FloatMap.border_len]
	mul dword[edi + FloatMap.dims]

	invoke_cdecl _BatchCurve, esi, eax, [ebx + PoolProcParam.curve_ptr], [ebx + PoolProcParam.curve_points]

	FrameEnd
	ret


DefFunc _FloatMapCurve
	FrameBegin 0, 5, ebx, esi, edi

	mov ebx, Param(0)
	mov eax, [ebx + FloatMap.border_len]
	shl eax, 2
	mov edi, eax
	add eax, PoolProcParam.size
	invoke_cdecl _malloc, eax
	mov esi, eax
	add edi, eax
	mov ecx, [ebx + FloatMap.border_len]
	mov eax, edi
	mov edi, esi
	rep stosd
	mov eax, [_FloatMapCurveNumWorkers]
	mov cl, 8
	test eax, eax
	cmovz eax, ecx
	mov [_FloatMapCurveNumWorkers], eax

	mov eax, Param(1)
	mov ecx, Param(2)
	mov [edi + PoolProcParam.curve_ptr], eax
	mov [edi + PoolProcParam.curve_points], ecx
	mov [edi + PoolProcParam.fmap], ebx

	invoke_cdecl _PoolRun, _FloatMapCurvePoolProc, [_FloatMapCurveNumWorkers], [ebx + FloatMap.border_len], esi, 0
	invoke_cdecl _free, eax
	invoke_cdecl _free, esi

	FrameEnd
	ret
