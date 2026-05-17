%include "common.inc"
%include "buffer.inc"

segment .text
DefFunc _AltitudeToTerrain
	FrameBegin 3, 2, ebx, esi, edi
	AssignVars _X, _Y, _RET

	mov ebx, Param(0)
	cmp dword[ebx + FloatMap.dims], 1
	je .good
.bad:
	int3
	jmp .bad
.good:
	invoke_cdecl _CreateFloatMap, [ebx + FloatMap.border_len], 4
	mov _RET, eax

	xor eax, eax
	mov _Y, eax
.loopy:
	mov edx, _RET
	mov esi, [ebx + FloatMap.row_ptr + eax * 4]
	mov edi, [edx + FloatMap.row_ptr + eax * 4]

	xor eax, eax
	mov _X, eax
.loopx:
	



	mov eax, _X
	inc eax
	mov _X, eax
	cmp eax, [ebx + FloatMap.border_len]
	jb .loopx

	mov eax, _Y
	inc eax
	mov _Y, eax
	cmp eax, [ebx + FloatMap.border_len]
	jb .loopy


	mov eax, edi
	FrameEnd
	ret
	%undef _X
	%undef _Y
