%include "common.inc"

segment .text
DefFunc _FloatMapBlt
	FrameBegin 8, 4, ebx, esi, edi
	AssignVars _DX, _DY, _DW, _DH, _DR, _DB, _SX, _SY

	mov eax, Param(9)
	mov ecx, _FloatMapBltDefLineProc
	mov edi, Param(0) ;dst
	mov esi, Param(5) ;src
	mov ebx, Param(8) ;userdata

	test eax, eax
	cmovz eax, ecx
	cmovz ebx, esi
	mov Param(9), eax

	movq xmm0, Param(1) ;dx, dy
	pxor xmm1, xmm1
	movq xmm2, Param(1) ;dx, dy
	movq xmm3, Param(6) ;sx, sy
	movq xmm4, Param(3) ;dw, dh
	pxor xmm5, xmm5
	pcmpgtd xmm0, xmm1
	pandn xmm0, xmm2
	psubd xmm3, xmm0 ;sx, sy -= min((dx, dy), (0, 0))
	paddd xmm4, xmm0 ;dw, dh += min((dx, dy), (0, 0))
	movd _DX, xmm0
	paddd xmm2, xmm4 ;dr, db = (dx, dy) + (dw, dh)

	pcmpgtd xmm1, xmm2
	pcmpeqd xmm5, xmm2
	por xmm1, xmm5 ; (dr, db) <= (0, 0) ? -1: 0
	pand xmm1, [_UFF00]
	pmovmskb eax, xmm1
	test eax, eax
	jnz .end ; if (dr <= 0 || db <= 0) return;

	mov eax, [edi + FloatMap.border_len]
	mov ecx, [esi + FloatMap.border_len]
	cmp eax, ecx
	cmova eax, ecx
	movd xmm6, eax
	pshufd xmm6, xmm6, 0 ; (dl, dl, dl, dl)
	movdqa xmm1, xmm2 ; dr, db
	pcmpgtd xmm2, xmm6 ; (bmx, bmy) = (dr, db) > (dl, dl) ? (-1, -1) : (0, 0)
	pand xmm6, xmm2 ; xmm6 = (dr, db) > (dl, dl) ? (dl, dl) : (0, 0)
	pandn xmm2, xmm1 ; xmm2 = (dr, db) <= (dl, dl) ? (dr, db) : (0, 0)
	por xmm2, xmm6 ; dr, db = min((dr, db), (dl, dl))

	psubd xmm2, xmm0 ; (dw, dh) = (dr, db) - (dx, dy)
	movq _DW, xmm2
	movq _SX, xmm3

	mov eax, _DX
	mul dword [edi + FloatMap.dims]
	shl eax, 4
	mov _DX, eax

	mov eax, _SX
	mul dword [esi + FloatMap.dims]
	shl eax, 4
	mov _SX, eax

	xor eax, eax
	mov _DY, eax
.loopy:
	mov ecx, _SY
	mov eax, [edi + FloatMap.row_ptr + eax * 4]
	mov edx, [esi + FloatMap.row_ptr + ecx * 4]
	inc ecx
	mov _SY, ecx

	invoke_cdecl Param(9), eax, edx, _DW, ebx

	mov eax, _DY
	inc eax
	mov _DY, eax
	cmp eax, _DH
	jb .loopy

.end:
	FrameEnd
	ret
	%undef _DX
	%undef _DY
	%undef _DW
	%undef _DH
	%undef _DR
	%undef _DB
	%undef _SX
	%undef _SY

DefFunc _FloatMapBltDefLineProc
	FrameBegin 0, 3, ebx

	mov ebx, Param(3)
	mov eax, [ebx + FloatMap.dims]
	mul dword Param(2)
	invoke_dll_cdecl memcpy, Param(0), Param(1), &[eax * 4]

	FrameEnd
	ret
