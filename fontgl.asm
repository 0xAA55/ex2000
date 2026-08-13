%include "loaddll.inc"
%include "fontgl.inc"
%include "avlbst.inc"
%include "lfu.inc"
%include "math.inc"
%include "gl33.inc"
%include "shader.inc"
%include "utf.inc"

struc LfuData
	.x resd 1
	.y resd 1
	.xoff resd 1
	.yoff resd 1
	.blackbox_w resd 1
	.blackbox_h resd 1
	.xinc resw 1
	.yinc resw 1
	.size equ $ - LfuData
endstruc

struc InstBufferData
	.x resd 1
	.y resd 1
	.w resd 1
	.h resd 1
	.tx resd 1
	.ty resd 1
	.tw resd 1
	.th resd 1
	.size equ $ - InstBufferData
endstruc

;void OGLFC_OnLfuKeyRemove(void *key, void *context)
DefFunc _OGLFC_OnLfuKeyRemove
	FrameBegin ebx, esi, edi
	NameParams %$Key, %$Context
	mov ebx, %$Context
	invoke_cdecl _LfuGet, [ebx + OGLFC.lfu], %$Key
	mov esi, eax
	mov edi, [esi + LfuData.x]
	mov edx, [esi + LfuData.y]
	shl edx, 16
	or edi, edx
	invoke_cdecl _Get_AVLOps_Integer
	invoke_cdecl _AVLInsert, &[ebx + OGLFC.vacant_coords], edi, edi, NULL, eax
	FrameEnd
	ret

;void OGLFC_DescribeVAO(OGLFC *oglfc)
DefFunc _OGLFC_DescribeVAO
	FrameBegin ebx, edi
	NameParams %$OGLFC
	mov ebx, %$OGLFC
	invoke_dll_stdcall glBindVertexArray, [ebx + OGLFC.vao]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [ebx + OGLFC.bbbuf_gl_buffer]
	GetAttribLocation [ebx + OGLFC.shader_program], "position"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [ebx + OGLFC.instbuf_gl_buffer]
	GetAttribLocation [ebx + OGLFC.shader_program], "xy"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_FLOAT, 0, InstBufferData.size, 0x00
	invoke_dll_stdcall glVertexAttribDivisor, edi, 1
	GetAttribLocation [ebx + OGLFC.shader_program], "wh"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_FLOAT, 0, InstBufferData.size, 0x08
	invoke_dll_stdcall glVertexAttribDivisor, edi, 1
	GetAttribLocation [ebx + OGLFC.shader_program], "txy"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribIPointer, edi, 2, GL_INT, InstBufferData.size, 0x10
	invoke_dll_stdcall glVertexAttribDivisor, edi, 1
	GetAttribLocation [ebx + OGLFC.shader_program], "twh"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribIPointer, edi, 2, GL_INT, InstBufferData.size, 0x18
	invoke_dll_stdcall glVertexAttribDivisor, edi, 1
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, 0
	invoke_dll_stdcall glBindVertexArray, 0

	FrameEnd
	ret

;OGLFC *OGLFC_Create(HDC hDC, int cap_bits);
DefFunc _OGLFC_Create
	FrameBegin ebx, edi
	NameParams %$hDC, %$CapacitorBits
	DefVars %$X, %$Y, %$NumCharsInARow
	DefSizedVar %$TextMetrics, TEXTMETRICW.size

	xor eax, eax
	mov ecx, %$CapacitorBits
	mov edx, eax
	inc eax
	mov dl, 16
	shl eax, ecx
	cmp eax, 16
	cmovb eax, edx
	cvtsi2sd xmm0, eax
	sqrtsd xmm0, xmm0
	cvtsd2si eax, xmm0
	mov %$NumCharsInARow, eax

	invoke_dll_stdcall GetTextMetricsW, %$hDC, &%$TextMetrics

	mov %$CapacitorBits, eax
	invoke_cdecl _calloc, 1, OGLFC.size
	mov ebx, eax

	mov byte[ebx + OGLFC.tab_width], 8
	xor eax, eax
	dec eax
	mov [ebx + OGLFC.fore_color], eax
	shl eax, 31
	mov [ebx + OGLFC.back_color], eax

	invoke_dll_stdcall CreateCompatibleDC, 0
	mov [ebx + OGLFC.hdc_canvas], eax

	invoke_dll_stdcall GetCurrentObject, %$hDC, OBJ_FONT
	invoke_dll_stdcall SelectObject, [ebx + OGLFC.hdc_canvas], eax
	invoke_dll_stdcall DeleteObject, eax

	invoke_dll_stdcall SetBkColor, [ebx + OGLFC.hdc_canvas], 0
	invoke_dll_stdcall SetTextColor, [ebx + OGLFC.hdc_canvas], 0xFFFFFF
	invoke_dll_stdcall SetBkMode, [ebx + OGLFC.hdc_canvas], OPAQUE

	mov eax, %$hDC
	mov ecx, [%$TextMetrics_Addr + TEXTMETRICW.tmAscent]
	mov edx, [%$TextMetrics_Addr + TEXTMETRICW.tmDescent]
	mov [ebx + OGLFC.hdc_font], eax
	mov [ebx + OGLFC.ascent], edx
	mov [ebx + OGLFC.descent], edx
	mov eax, [%$TextMetrics_Addr + TEXTMETRICW.tmHeight]
	mov [ebx + OGLFC.font_size], eax
	mov edx, eax
	mov ecx, eax
	shr edx, 1
	shl eax, 1
	add eax, ecx
	mov [ebx + OGLFC.grid_size], eax
	mov [ebx + OGLFC.space_size], edx
	mul dword %$NumCharsInARow
	bsr ecx, eax
	inc edx ;edx = 1
	shl edx, ecx
	cmp edx, eax
	jae .to_2N_size
	shl edx, 1
.to_2N_size:
	mov eax, edx
	mov [ebx + OGLFC.font_map_size], edx
	xor edx, edx
	div dword[ebx + OGLFC.grid_size]
	mov %$NumCharsInARow, eax
	mul eax
	mov [ebx + OGLFC.capacity], eax

	invoke_cdecl _Get_AVLOps_Integer
	invoke_cdecl _LfuCreate, [ebx + OGLFC.capacity], eax, ebx, _OGLFC_OnLfuKeyRemove
	mov [ebx + OGLFC.lfu], eax

	xor eax, eax
	mov %$Y, eax
.loop_y:

	xor eax, eax
	mov %$X, eax
.loop_x:
	mov edx, %$Y
	and eax, 0xFFFF
	shl edx, 16
	or eax, edx
	mov edi, eax
	invoke_cdecl _Get_AVLOps_Integer
	invoke_cdecl _AVLInsert, &[ebx + OGLFC.vacant_coords], edi, edi, NULL, eax
	
	mov eax, %$X
	inc eax
	mov %$X, eax
	cmp eax, %$NumCharsInARow
	jb .loop_x

	mov eax, %$Y
	inc eax
	mov %$Y, eax
	cmp eax, %$NumCharsInARow
	jb .loop_y

	invoke_dll_stdcall glGenTextures, 1, &[ebx + OGLFC.font_map]
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [ebx + OGLFC.font_map]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_RED, [ebx + OGLFC.font_map_size], [ebx + OGLFC.font_map_size], 0, GL_RED, GL_UNSIGNED_BYTE, NULL
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0

	SceneLoadShaderProgram &[ebx + OGLFC.shader_program], "assets\font.vsh", 0, "assets\font.fsh"
	mov [ebx + OGLFC.shader_program], eax

	GetUniformLocation [ebx + OGLFC.shader_program], "font_map"
	mov [ebx + OGLFC.location_font_map], eax
	GetUniformLocation [ebx + OGLFC.shader_program], "grid_size"
	mov [ebx + OGLFC.location_grid_size], eax
	GetUniformLocation [ebx + OGLFC.shader_program], "font_color"
	mov [ebx + OGLFC.location_font_color], eax
	GetUniformLocation [ebx + OGLFC.shader_program], "bkgr_color"
	mov [ebx + OGLFC.location_bkgr_color], eax
	GetUniformLocation [ebx + OGLFC.shader_program], "resolution"
	mov [ebx + OGLFC.location_resolution], eax
	GetUniformLocation [ebx + OGLFC.shader_program], "offset"
	mov [ebx + OGLFC.location_offset], eax

	DefSizedVar %$BillBoardVertices, 8
	mov dword [%$BillBoardVertices_Addr + 0], 0x00010000
	mov dword [%$BillBoardVertices_Addr + 4], 0x01010100
	invoke_cdecl _InitBuffer, &[ebx + OGLFC.billboard_buffer], GL_ARRAY_BUFFER, GL_STATIC_DRAW, 2, 4, & %$BillBoardVertices
	invoke_cdecl _InitBuffer, &[ebx + OGLFC.instance_buffer], GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW, InstBufferData.size, 64, 0

	invoke_dll_stdcall glGenVertexArrays, 1, &[ebx + OGLFC.vao]
	invoke_cdecl _OGLFC_DescribeVAO, ebx
	mov eax, ebx
	FrameEnd
	ret

;void OGLFC_Destroy(OGLFC *oglfc);
DefFunc _OGLFC_Destroy
	FrameBegin ebx
	NameParams %$OGLFC
	mov ebx, %$OGLFC

	invoke_cdecl _LfuDestroy, [ebx + OGLFC.lfu]
	invoke_cdecl _AVLClear, &[ebx + OGLFC.vacant_coords]
	invoke_cdecl _DeInitBuffer, &[ebx + OGLFC.instance_buffer]

	invoke_dll_stdcall glDeleteProgram, [ebx + OGLFC.shader_program]
	invoke_dll_stdcall glDeleteTextures, 1, &[ebx + OGLFC.font_map]
	invoke_dll_stdcall glDeleteVertexArrays, 1, &[ebx + OGLFC.vao]

	invoke_dll_stdcall DeleteDC, [ebx + OGLFC.hdc_canvas]

	invoke_cdecl _free, ebx

	FrameEnd
	ret

;HBITMAP OGLFC_CreateAndSelectBitmap(HDC hDC, int w, int h, void **pptr)
DefFunc _OGLFC_CreateAndSelectBitmap
	FrameBegin edi
	NameParams %$hDC, %$Width, %$Height, %$PPtr
	DefSizedVar %$BMIF, BITMAPINFOHEADER.size
	DefSizedVar %$Palette, 1024

	xor eax, eax
	lea edi, Variable(0)
	mov ecx, %$Frame_NumLocals
	rep stosd
	mov eax, %$Width
	mov ecx, %$Height
	mov dword[%$BMIF_Addr + BITMAPINFOHEADER.biSize], 40
	neg ecx
	mov [%$BMIF_Addr + BITMAPINFOHEADER.biWidth], eax
	mov [%$BMIF_Addr + BITMAPINFOHEADER.biHeight], ecx
	mov dword[%$BMIF_Addr + BITMAPINFOHEADER.biPlanes], 0x00080001
	mov word[%$BMIF_Addr + BITMAPINFOHEADER.biClrUsed], 256

	lea edi, %$Palette
	xor eax, eax
.loop_set_palette:
	stosb
	stosb
	stosb
	inc edi
	inc eax
	cmp ax, 256
	jb .loop_set_palette

	invoke_dll_stdcall CreateDIBSection, %$hDC, & %$BMIF, 0, %$PPtr, NULL, 0
	invoke_dll_stdcall SelectObject, %$hDC, eax

	FrameEnd
	ret

;uint64_t OGLFC_Compose(OGLFC *oglfc, int w, int h, const char *text);
DefFunc _OGLFC_Compose
	FrameBegin ebx, esi, edi
	NameParams %$Inst, %$Width, %$Height, %$Text
	DefVars %$PointerToChar, %$X, %$Y, %$Buffer
	DefVars %$BufferSize, %$FontVacKey, %$WCharBuf, %$WCharPtr, %$WCharLen
	DefVars %$SizeW, %$SizeH, %$CanvasW, %$CanvasH
	DefVars %$SrcX, %$SrcY, %$MaxX, %$MaxY
	DefSizedVar %$MInstBufferData, InstBufferData.size
	DefSizedVar %$GlyphMetrics, GLYPHMETRICS.size

	xor eax, eax
	lea edi, Variable(0)
	mov ecx, %$Frame_NumLocals
	rep stosd

	mov eax, [ebx + OGLFC.space_size]
	mul dword[ebx + OGLFC.tab_width]
	mov [ebx + OGLFC.tab_width_px], eax

	mov ebx, %$Inst
	mov eax, %$Text
	mov %$PointerToChar, eax

	invoke_cdecl _BufferClear, &[ebx + OGLFC.instance_buffer]
	;Push a placeholder for the background
	invoke_cdecl _BufferPushItem, &[ebx + OGLFC.instance_buffer], &[%$MInstBufferData_Addr]
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [ebx + OGLFC.font_map]

.loop_compose:
	invoke_cdecl _UtfReadCharFromPtr, &%$PointerToChar
	test eax, eax
	jz .loop_end
	cmp eax, ` `
	jz .space
	cmp eax, `\r`
	jz .cr
	cmp eax, `\n`
	jz .newline
	cmp eax, `\t`
	jz .tab
	cmp eax, 0x20
	jb .loop_compose
	jmp .draw_glyph
.space:
	mov eax, [ebx + OGLFC.space_size]
	add %$X, eax
	jmp .after_advance
.newline:
	xor eax, eax
	mov ecx, [ebx + OGLFC.font_size]
	mov %$X, eax
	add %$Y, ecx
	jmp .after_advance
.cr:
	mov dword %$X, 0
	jmp .after_advance
.tab:
	xor edx, edx
	mov ecx, [ebx + OGLFC.tab_width_px]
	mov eax, %$X
	dec eax
	div ecx
	inc eax
	mul ecx
	mov %$X, eax
	jmp .after_advance

.draw_glyph:
	mov esi, eax

.after_new_glyph_cached:
	invoke_cdecl _LfuGet, [ebx + OGLFC.lfu], esi
	test eax, eax
	jz .cache_new_glyph
	mov edi, eax

	movq xmm3, [edi + LfuData.xoff]
	movq xmm0, %$X
	movq xmm1, [edi + LfuData.blackbox_w]
	movq xmm2, [edi + LfuData.x]
	movq xmm4, xmm1
	cvtdq2ps xmm3, xmm3
	cvtdq2ps xmm0, xmm0
	cvtdq2ps xmm1, xmm1
	subps xmm0, xmm3
	movq [%$MInstBufferData_Addr + InstBufferData.x], xmm0
	movq [%$MInstBufferData_Addr + InstBufferData.w], xmm1
	movq [%$MInstBufferData_Addr + InstBufferData.tw], xmm4
	movq [%$MInstBufferData_Addr + InstBufferData.tx], xmm2
	invoke_cdecl _BufferPushItem, &[ebx + OGLFC.instance_buffer], &[%$MInstBufferData_Addr]

	movzx eax, word[edi + LfuData.xinc]
	movzx ecx, word[edi + LfuData.yinc]
	add %$X, eax
	add %$Y, ecx
.after_advance:
	mov eax, %$X
	mov ecx, %$Y
	sub ecx, [edi + LfuData.yoff]
	add ecx, [edi + LfuData.blackbox_h]
	push ebx
	mov edx, %$MaxX
	mov ebx, %$MaxY
	cmp eax, edx
	cmova edx, eax
	cmp ecx, ebx
	cmova ebx, ecx
	mov %$MaxX, edx
	mov %$MaxY, ebx
	pop ebx
	cmp eax, %$Width
	jb .loop_compose
	xor eax, eax
	mov %$X, eax
	mov eax, [ebx + OGLFC.font_size]
	add %$Y, eax
	mov eax, %$Height
	cmp %$Y, eax
	jae .loop_end

	jmp .loop_compose
.cache_new_glyph:
	invoke_cdecl _calloc, 1, LfuData.size
	mov edi, eax
	mov ecx, [ebx + OGLFC.vacant_coords]
	mov eax, [ecx + AVLBST_Node.key]
	mov edx, eax
	and eax, 0xFFFF
	shr edx, 16
	mov [edi + LfuData.x], eax
	mov [edi + LfuData.y], edx
	invoke_cdecl _AVLRemove, &[ebx + OGLFC.vacant_coords], [ecx + AVLBST_Node.key]
	mov ecx, [ebx + OGLFC.grid_size]
	mov eax, [edi + LfuData.x]
	mul ecx
	mov %$SrcX, eax
	mov eax, [edi + LfuData.y]
	mul ecx
	mov %$SrcY, eax
	cmp dword %$Buffer, 0
	jnz .have_buffer
	mov eax, [ebx + OGLFC.grid_size]
	shl eax, 1
	mul eax
	mov %$BufferSize, eax
	invoke_cdecl _malloc, eax
	mov %$Buffer, eax
.have_buffer:
	invoke_dll_stdcall GetGlyphOutlineW, [ebx + OGLFC.hdc_font], esi, GGO_GRAY8_BITMAP, &%$GlyphMetrics, %$BufferSize, %$Buffer, .mat2
	cmp eax, 0xFFFFFFFF
	jz .non_ttf
	mov eax, %$Buffer
	mov ecx, %$BufferSize
	push esi
	push edi
	mov esi, eax
	mov edi, esi
.convert_65_to_256:
	lodsb
	mov dl, 0x3F
	cmp al, 0x40
	cmove eax, edx
	mov dl, al
	shl al, 2
	shr dl, 4
	or al, dl
	stosb
	dec ecx
	jnz .convert_65_to_256
	pop edi
	pop esi
	lea eax, %$GlyphMetrics
	mov ecx, [eax + GLYPHMETRICS.gmptGlyphOrigin_x]
	mov edx, [eax + GLYPHMETRICS.gmptGlyphOrigin_y]
	sub edx, [ebx + OGLFC.font_size]
	mov [edi + LfuData.xoff], ecx
	mov [edi + LfuData.yoff], edx
	mov ecx, [eax + GLYPHMETRICS.gmBlackBoxX]
	mov edx, [eax + GLYPHMETRICS.gmBlackBoxY]
	mov [edi + LfuData.blackbox_w], ecx
	mov [edi + LfuData.blackbox_h], edx
	mov ecx, [eax + GLYPHMETRICS.gmCellIncX] ;gmCellIncX, gmCellIncY
	mov [edi + LfuData.xinc], ecx ;xinc, yinc
	invoke_dll_stdcall glTexSubImage2D, GL_TEXTURE_2D, 0, %$SrcX, %$SrcY, [edi + LfuData.blackbox_w], [edi + LfuData.blackbox_h], GL_RED, GL_UNSIGNED_BYTE, %$Buffer
.lfudata_ready:
	invoke_cdecl _LfuPut, [ebx + OGLFC.lfu], esi, edi, _free
	jmp .after_new_glyph_cached
.non_ttf:
	lea eax, %$WCharBuf
	mov %$WCharPtr, eax
	invoke_cdecl _Utf32to16, esi, &%$WCharPtr
	mov %$WCharLen, eax
	invoke_dll_stdcall GetTextExtentPoint32W, [ebx + OGLFC.hdc_font], &%$WCharBuf, eax, &%$SizeW
	mov eax, %$SizeW
	mov ecx, [ebx + OGLFC.font_size]
	mov %$CanvasW, eax
	mov %$CanvasH, ecx
	cmp eax, [ebx + OGLFC.canvas_width]
	jne .recreate_canvas
	cmp ecx, [ebx + OGLFC.canvas_height]
	je .have_canvas
.recreate_canvas:
	invoke_cdecl _OGLFC_CreateAndSelectBitmap, [ebx + OGLFC.hdc_canvas], %$CanvasW, %$CanvasH, &[ebx + OGLFC.canvas_pointer]
	invoke_dll_stdcall DeleteObject, eax
	mov eax, %$CanvasW
	mov ecx, %$CanvasH
	mov [ebx + OGLFC.canvas_width], eax
	mov [ebx + OGLFC.canvas_height], ecx
.have_canvas:
	invoke_dll_stdcall ExtTextOutW, [ebx + OGLFC.hdc_canvas], 0, 0, ETO_OPAQUE, NULL, &%$WCharBuf, %$WCharLen, NULL
	mov eax, [ebx + OGLFC.canvas_width]
	mov ecx, [ebx + OGLFC.canvas_height]
	mov [edi + LfuData.blackbox_w], eax
	mov [edi + LfuData.blackbox_h], ecx
	mov [edi + LfuData.xinc], ax
	invoke_dll_stdcall glTexSubImage2D, GL_TEXTURE_2D, 0, %$SrcX, %$SrcY, [edi + LfuData.blackbox_w], [edi + LfuData.blackbox_h], GL_RED, GL_UNSIGNED_BYTE, [ebx + OGLFC.canvas_pointer]
	jmp .lfudata_ready

.loop_end:
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0
	invoke_cdecl _free, %$Buffer

	mov edi, [ebx + OGLFC.instbuf_pointer]

	mov eax, %$MaxX
	mov edx, %$MaxY
	mov [ebx + OGLFC.composed_max_x], eax
	mov [ebx + OGLFC.composed_max_y], edx
	movq xmm0, [ebx + OGLFC.composed_max_x]
	cvtdq2ps xmm0, xmm0
	movq [edi + InstBufferData.w], xmm0
	FrameEnd
	ret
[segment .rdata]
.mat2:
	dd 65536, 0
	dd 0, 65536

;void OGLFC_Present(OGLFC *oglfc, int x, int y);
DefFunc _OGLFC_Present
	FrameBegin ebx, esi, edi
	NameParams %$Inst, %$X, %$Y
	DefVars %$VPX, %$VPY, %$VPW, %$VPH
	DefVars %$FCR, %$FCG, %$FCB, %$FCA
	DefVars %$BCR, %$BCG, %$BCB, %$BCA

	mov ebx, %$Inst
	lea esi, [ebx + OGLFC.instance_buffer]

	invoke_dll_stdcall glGetIntegerv, GL_VIEWPORT, & %$VPX
	movq xmm0, %$X
	movq xmm1, %$VPW
	cvtdq2ps xmm0, xmm0
	cvtdq2ps xmm1, xmm1
	movq %$X, xmm0
	movq %$VPW, xmm1

	mov edi, [esi + GlBuffer.gl_buffer]
	invoke_cdecl _BufferFlush, esi
	cmp edi, [esi + GlBuffer.gl_buffer]
	je .buffer_not_changed
	invoke_cdecl _OGLFC_DescribeVAO, ebx
.buffer_not_changed:
	invoke_dll_stdcall glEnable, GL_BLEND
	invoke_dll_stdcall glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA

	invoke_dll_stdcall glUseProgram, [ebx + OGLFC.shader_program]
	invoke_dll_stdcall glBindVertexArray, [ebx + OGLFC.vao]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [ebx + OGLFC.font_map]
	invoke_dll_stdcall glUniform1i, [ebx + OGLFC.location_font_map], 0
	invoke_dll_stdcall glUniform1i, [ebx + OGLFC.location_grid_size], [ebx + OGLFC.grid_size]
	invoke_dll_stdcall glUniform2f, [ebx + OGLFC.location_resolution], %$VPW, %$VPH
	invoke_dll_stdcall glUniform2f, [ebx + OGLFC.location_offset], %$X, %$Y
	xor eax, eax
	dec al
	movd xmm0, [ebx + OGLFC.fore_color]
	movd xmm1, [ebx + OGLFC.back_color]
	cvtsi2ss xmm2, eax
	pxor xmm7, xmm7
	rcpss xmm2, xmm2
	punpcklbw xmm0, xmm7
	punpcklbw xmm1, xmm7
	punpcklwd xmm0, xmm7
	punpcklwd xmm1, xmm7
	pshufd xmm2, xmm2, 0
	cvtdq2ps xmm0, xmm0
	cvtdq2ps xmm1, xmm1
	mulps xmm0, xmm2
	mulps xmm1, xmm2
	movups %$FCR, xmm0
	movups %$BCR, xmm1
	invoke_dll_stdcall glUniform4f, [ebx + OGLFC.location_font_color], %$FCR, %$FCG, %$FCB, %$FCA
	invoke_dll_stdcall glUniform4f, [ebx + OGLFC.location_bkgr_color], %$BCR, %$BCG, %$BCB, %$BCA
	invoke_dll_stdcall glDrawArraysInstanced, GL_TRIANGLE_STRIP, 0, 4, [esi + GlBuffer.num_items]
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0
	invoke_dll_stdcall glBindVertexArray, 0

	FrameEnd
	ret

;int GLPrintf(OGLFC *oglfc, const char *fmt, ...);
DefFunc _GLPrintf
	FrameBegin ebx, esi, edi
	NameParams %$OGLFC, %$Fmt, %$Args
	DefVars %$ConLengthAll, %$PrintfLength

	mov ebx, %$OGLFC
	lea eax, %$Args
	mov edi, [_DebugConsoleBuffer]
	invoke_dll_cdecl vsnprintf, [_DebugMsgBuffer], _DebugMsgBufferSize, %$Fmt, eax
	mov %$PrintfLength, eax

	invoke_dll_cdecl strlen, edi
	mov %$ConLengthAll, eax
	mov ecx, eax
	add ecx, %$PrintfLength
	cmp ecx, _DebugConsoleBufferSize
	jb .eat_console
	mov byte[edi], 0
	jmp .ready_to_concat

.eat_console:
	lea esi, [edi + eax]

	xor ecx, ecx
.find_last_lines:
	cmp esi, edi
	jz .ready_to_concat
	dec esi
	cmp byte[esi], `\r`
	jnz .find_last_lines
	cmp byte[esi], `\n`
	jnz .find_last_lines
	inc ecx
	cmp ecx, _DebugConsoleMaxLines
	jb .find_last_lines
	inc esi

	invoke_dll_cdecl strlen, esi
	invoke_dll_cdecl memmove, edi, esi, &[eax + 1]

.ready_to_concat:
	invoke_dll_cdecl strcat, edi, [_DebugMsgBuffer]

	invoke_cdecl _OGLFC_Compose, ebx, 0xFFFFFFFF, 0xFFFFFFFF, edi
	invoke_cdecl _OGLFC_Present, ebx, 0, 0

	mov eax, ebx
	FrameEnd
	ret

;int GLPrintfXY(OGLFC *oglfc, int x, int y, const char *fmt, ...);
DefFunc _GLPrintfXY
	FrameBegin ebx, esi, edi
	NameParams %$OGLFC, %$X, %$Y, %$Fmt, %$Args

	mov ebx, %$OGLFC
	lea eax, %$Args
	mov edi, [_DebugMsgBuffer]
	invoke_dll_cdecl vsnprintf, edi, _DebugMsgBufferSize, %$Fmt, eax

	invoke_cdecl _OGLFC_Compose, ebx, 0xFFFFFFFF, 0xFFFFFFFF, edi
	invoke_cdecl _OGLFC_Present, ebx, %$X, %$Y

	mov eax, ebx
	FrameEnd
	ret
