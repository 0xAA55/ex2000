%include "common.inc"

struc PoolProcParam
.curve_ptr resd 1
.curve_points resd 1
.size equ $ - PoolProcParam
endstruc

segment .bss
extern _FloatMapCurveNumWorkers
_FloatMapCurveNumWorkers resd 1

DefFunc _FloatMapCurvePoolProc
	FrameBegin ebx, esi, edi

	mov ebx, Param(0)
	mov edi, Param(1)
	mov eax, Param(2)
	mov esi, [edi + BitMap.row_ptr + eax * 4]

	mov eax, [edi + BitMap.border_len]
	mul dword[edi + BitMap.dims]

	invoke_cdecl _BatchCurve, esi, eax, [ebx + PoolProcParam.curve_ptr], [ebx + PoolProcParam.curve_points]

	FrameEnd
	ret

DefFunc _FloatMapCurve
	FrameBegin ebx, esi, edi

	mov ebx, Param(0)
	mov eax, [ebx + BitMap.border_len]
	shl eax, 2
	mov edi, eax
	add eax, PoolProcParam.size
	invoke_cdecl _malloc, eax
	mov esi, eax
	add edi, eax
	mov ecx, [ebx + BitMap.border_len]
	mov eax, edi
	mov edi, esi
	rep stosd

	cmp dword[_FloatMapCurveNumWorkers], 0
	jnz .proceed_to_work
	mov eax, [_SystemInfo + SYSTEM_INFO.dwNumberOfProcessors]
	shr eax, 1
	mov [_FloatMapCurveNumWorkers], eax
.proceed_to_work:

	mov eax, Param(1)
	mov ecx, Param(2)
	mov [edi + PoolProcParam.curve_ptr], eax
	mov [edi + PoolProcParam.curve_points], ecx

	invoke_cdecl _PoolRun, _FloatMapCurvePoolProc, ebx, [_FloatMapCurveNumWorkers], [ebx + BitMap.border_len], esi, 0, 0
	invoke_cdecl _free, esi

	FrameEnd
	ret
