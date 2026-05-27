%include "common.inc"

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

	;(smx, smy) = min((sx, sy), (0, 0))
	;(dmx, dmy) = min((dx, dy), (0, 0))
	;Fix less than zero (sx, sy) and (dx, dy) coord
	;(sx, sy) -= (smx, smy)
	;(dx, dy) += (smx, smy)
	;(dw, dh) -= (smx, smy)
	;(sx, sy) -= (dmx, dmy)
	;(dx, dy) -= (dmx, dmy)
	;(dw, dh) += (dmx, dmy)
	;(dr, db) = (dx, dy) + (dw, dh)
	;if (sx >= sl || sy >= sl) return;
	;if (dx >= dl || dy >= dl) return;
	;if (dr <= 0 || db <= 0) return;
	;(dr, db) = min((dr, db), (dl, dl))
	;(dw, dh) = (dr, db) - (dx, dy)
	;(dw, dh) = min((dw, dh), (sl, sl))

	movq xmm0, Param(6) ;sx, sy
	movq xmm1, Param(1) ;dx, dy
	movq xmm2, Param(6) ;sx, sy
	movq xmm3, Param(1) ;dx, dy
	movq xmm4, Param(3) ;dw, dh
	pxor xmm7, xmm7
	pcmpgtd xmm0, xmm7
	pcmpgtd xmm1, xmm7
	pandn xmm0, xmm2 ;(smx, smy) = min((sx, sy), (0, 0))
	pandn xmm1, xmm3 ;(dmx, dmy) = min((dx, dy), (0, 0))
	psubd xmm2, xmm0 ;(sx, sy) -= (smx, smy)
	paddd xmm3, xmm0 ;(dx, dy) += (smx, smy)
	psubd xmm4, xmm0 ;(dw, dh) -= (smx, smy)
	psubd xmm2, xmm1 ;(sx, sy) -= (dmx, dmy)
	psubd xmm3, xmm1 ;(dx, dy) -= (dmx, dmy)
	paddd xmm4, xmm1 ;(dw, dh) += (dmx, dmy)
	movd xmm0, [esi + FloatMap.border_len]
	movd xmm1, [edi + FloatMap.border_len]
	movq _SX, xmm2
	movq _DX, xmm3
	pshufd xmm0, xmm0, 0 ;sl, sl, sl, sl
	pshufd xmm1, xmm1, 0 ;dl, dl, dl, dl
	movq xmm5, xmm2
	movq xmm6, xmm3
	pcmpgtd xmm5, xmm0 ;if (sx > sl || sy > sl) sg = 1;
	pcmpgtd xmm6, xmm1 ;if (dx > dl || dy > dl) dg = 1;
	pcmpeqd xmm2, xmm0 ;if (sx == sl || sy == sl) se = 1;
	pcmpeqd xmm3, xmm1 ;if (dx == dl || dy == dl) de = 1;
	por xmm5, xmm6 ;sg |= dg
	por xmm2, xmm3 ;se |= de
	por xmm2, xmm5 ;se |= sg
	pand xmm2, [_UFF00]
	pmovmskb eax, xmm2
	test eax, eax ;if (se) return 0;
	jnz .no_pixels_todo_ret
	movq xmm5, _DX
	paddd xmm4, xmm5 ;(dr, db) = (dx, dy) + (dw, dh)
	pxor xmm2, xmm2
	pxor xmm3, xmm3
	pcmpgtd xmm2, xmm4 ;if (0 > dr || 0 > db) rbg = 1;
	pcmpeqd xmm3, xmm4 ;if (0 == dr || 0 == db) rbe = 1;
	por xmm2, xmm3 ;rbg |= rbe
	pand xmm2, [_UFF00]
	pmovmskb eax, xmm2
	test eax, eax ;if(rbg) return 0;
	jnz .no_pixels_todo_ret
	movq xmm2, xmm4 ;(dr, db)
	pcmpgtd xmm2, xmm1 ;if ((dr, db) > (dl, dl)) f = 1;
	movq xmm3, xmm2
	pand xmm2, xmm1 ;f ? (dl, dl) : (0, 0)
	pandn xmm3, xmm4 ;f ? (0, 0) : (dr, db)
	por xmm2, xmm3 ;(dr, db) = min((dr, db), (dl, dl))
	movq _DR, xmm2
	movq xmm1, _DX
	psubd xmm2, xmm1 ;(dw, dh) = (dr, db) - (dx, dy)
	movq xmm4, xmm2 ;(dw, dh)
	pcmpgtd xmm2, xmm0 ;if ((dw, dh) > (sl, sl)) f = 1;
	movq xmm3, xmm2
	pand xmm2, xmm0 ;f ? (sl, sl) : (0, 0)
	pandn xmm3, xmm4 ;f ? (0, 0) : (dw, dh)
	por xmm2, xmm3 ;(dw, dh) = min((dw, dh), (sl, sl))
	movq _DW, xmm2

	mov eax, _DX
	mul dword [edi + FloatMap.bytes_per_pixel]
	mov _DX, eax

	mov eax, _SX
	mul dword [esi + FloatMap.bytes_per_pixel]
	mov _SX, eax

	xor eax, eax
	mov _DY, eax
.loopy:
	mov ecx, _SY
	mov eax, [edi + FloatMap.row_ptr + eax * 4]
	mov edx, [esi + FloatMap.row_ptr + ecx * 4]
	inc ecx
	mov _SY, ecx

	add eax, _DX
	add edx, _SX
	invoke_cdecl Param(9), eax, edx, _DW, ebx

	mov eax, _DY
	inc eax
	mov _DY, eax
	cmp eax, _DH
	jb .loopy

	mov eax, _DW
	mul dword _DH
	jmp .end
.no_pixels_todo_ret:
	xor eax, eax

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
