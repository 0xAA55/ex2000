%include "loaddll.inc"
%include "fontgl.inc"
%include "avlbst.inc"
%include "lfu.inc"
%include "math.inc"
%include "gl33.inc"
%include "shader.inc"
%include "utf.inc"

extern _BillBoardVertices
extern _BillboardVerticesBuffer

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
	FrameBegin 0, ebx, esi
	mov ebx, Param(1)
	invoke_cdecl _LfuGet, [ebx + OGLFC.lfu], Param(0)
	mov esi, eax
	mov eax, [esi + LfuData.x]
	mov edx, [esi + LfuData.y]
	shl edx, 16
	or eax, edx
	invoke_cdecl _AVLInsert, &[ebx + OGLFC.vacant_coords], eax, eax, NULL, _AVLOps_Integer 
	FrameEnd
	ret

;void OGLFC_DescribeVAO(OGLFC *oglfc)
DefFunc _OGLFC_DescribeVAO
	FrameBegin 0, ebx, esi, edi
	mov ebx, Param(0)
	lea esi, [ebx + OGLFC.instance_buffer]
	invoke_dll_stdcall glBindVertexArray, [ebx + OGLFC.vao]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_BillboardVerticesBuffer + GlBuffer.gl_buffer]
	GetAttribLocation [ebx + OGLFC.shader_program], "position"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [esi + GlBuffer.gl_buffer]
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
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_FLOAT, 0, InstBufferData.size, 0x10
	invoke_dll_stdcall glVertexAttribDivisor, edi, 1
	GetAttribLocation [ebx + OGLFC.shader_program], "twh"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_FLOAT, 0, InstBufferData.size, 0x18
	invoke_dll_stdcall glVertexAttribDivisor, edi, 1
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, 0
	invoke_dll_stdcall glBindVertexArray, 0

	FrameEnd
	ret

;OGLFC *OGLFC_Create(HDC hDC, int cap_bits);
DefFunc _OGLFC_Create
	FrameBegin 3 + SizedVar(TEXTMETRICW.size), ebx
	AssignVars _X, _Y, _NumCharsInARow
	AssignSizedVar _TextMetrics, TEXTMETRICW.size

	xor eax, eax
	mov ecx, Param(1)
	mov edx, eax
	inc eax
	mov dl, 16
	shl eax, ecx
	cmp eax, 16
	cmovb eax, edx
	cvtsi2sd xmm0, eax
	sqrtsd xmm0, xmm0
	cvtsd2si eax, xmm0
	mov _NumCharsInARow, eax

	invoke_dll_stdcall GetTextMetricsW, Param(0), &_TextMetrics

	mov Param(1), eax
	invoke_cdecl _calloc, 1, OGLFC.size
	mov ebx, eax

	invoke_dll_stdcall CreateCompatibleDC, 0
	mov [ebx + OGLFC.hdc_canvas], eax

	invoke_dll_stdcall GetCurrentObject, Param(0), OBJ_FONT
	invoke_dll_stdcall SelectObject, [ebx + OGLFC.hdc_canvas], eax
	invoke_dll_stdcall DeleteObject, eax

	invoke_dll_stdcall SetBkColor, [ebx + OGLFC.hdc_canvas], 0
	invoke_dll_stdcall SetTextColor, [ebx + OGLFC.hdc_canvas], 0xFFFFFF
	invoke_dll_stdcall SetBkMode, [ebx + OGLFC.hdc_canvas], OPAQUE

	mov eax, Param(0)
	mov ecx, [_TextMetrics_Addr + TEXTMETRICW.tmAscent]
	mov edx, [_TextMetrics_Addr + TEXTMETRICW.tmDescent]
	mov [ebx + OGLFC.hdc_font], eax
	mov [ebx + OGLFC.ascent], edx
	mov [ebx + OGLFC.descent], edx
	mov eax, [_TextMetrics_Addr + TEXTMETRICW.tmHeight]
	mov [ebx + OGLFC.font_size], eax
	mul dword _NumCharsInARow
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
	div dword[ebx + OGLFC.font_size]
	mov _NumCharsInARow, eax
	mul eax
	mov [ebx + OGLFC.capacity], eax

	invoke_cdecl _LfuCreate, eax, _AVLOps_Integer, ebx, _OGLFC_OnLfuKeyRemove
	mov [ebx + OGLFC.lfu], eax

	xor eax, eax
	mov _Y, eax
.loop_y:

	xor eax, eax
	mov _X, eax
.loop_x:
	mov edx, _Y
	and eax, 0xFFFF
	shl edx, 16
	or eax, edx
	invoke_cdecl _AVLInsert, &[ebx + OGLFC.vacant_coords], eax, eax, NULL, _AVLOps_Integer
	
	mov eax, _X
	inc eax
	mov _X, eax
	cmp eax, _NumCharsInARow
	jb .loop_x

	mov eax, _Y
	inc eax
	mov _Y, eax
	cmp eax, _NumCharsInARow
	jb .loop_y

	invoke_dll_stdcall glGenTextures, 1, &[ebx + OGLFC.font_map]
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [ebx + OGLFC.font_map]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_RED, [ebx + OGLFC.font_map_size], [ebx + OGLFC.font_map_size], 0, GL_RED, GL_UNSIGNED_BYTE, NULL
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0

	SceneLoadShaderProgram &[ebx + OGLFC.shader_program], "assets\font.vsh", 0, "assets\font.fsh"
	mov [ebx + OGLFC.shader_program], eax

	GetUniformLocation [ebx + OGLFC.shader_program], "font_map"
	mov [ebx + OGLFC.location_font_map], eax
	GetUniformLocation [ebx + OGLFC.shader_program], "font_size"
	mov [ebx + OGLFC.location_font_size], eax
	GetUniformLocation [ebx + OGLFC.shader_program], "font_color"
	mov [ebx + OGLFC.location_font_color], eax
	GetUniformLocation [ebx + OGLFC.shader_program], "resolution"
	mov [ebx + OGLFC.location_resolution], eax
	GetUniformLocation [ebx + OGLFC.shader_program], "offset"
	mov [ebx + OGLFC.location_offset], eax

	invoke_cdecl _InitBuffer, &[ebx + OGLFC.instance_buffer], GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW, InstBufferData.size, 64, 0

	invoke_dll_stdcall glGenVertexArrays, 1, &[ebx + OGLFC.vao]
	invoke_cdecl _OGLFC_DescribeVAO, ebx
	mov eax, ebx
	FrameEnd
	ret
	%undef _X
	%undef _Y
	%undef _NumCharsInARow
	%undef _TextMetrics

;void OGLFC_Destroy(OGLFC *oglfc);
DefFunc _OGLFC_Destroy
	FrameBegin 0, ebx

	mov ebx, Param(0)

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
	FrameBegin SizedVar(BITMAPINFOHEADER.size + 1024), edi
	AssignSizedVar _BMIF, BITMAPINFOHEADER.size
	AssignVars _Palette

	xor eax, eax
	lea edi, _BMIF
	mov ecx, Frame_NumLocals
	rep stosd
	mov eax, Param(1)
	mov ecx, Param(2)
	mov dword[_BMIF_Addr + BITMAPINFOHEADER.biSize], 40
	neg ecx
	mov [_BMIF_Addr + BITMAPINFOHEADER.biWidth], eax
	mov [_BMIF_Addr + BITMAPINFOHEADER.biHeight], ecx
	mov dword[_BMIF_Addr + BITMAPINFOHEADER.biPlanes], 0x00080001
	mov word[_BMIF_Addr + BITMAPINFOHEADER.biClrUsed], 256

	lea edi, _Palette
	xor eax, eax
.loop_set_palette:
	stosb
	stosb
	stosb
	inc edi
	inc eax
	cmp ax, 256
	jb .loop_set_palette

	invoke_dll_stdcall CreateDIBSection, Param(0), &_BMIF, 0, Param(3), NULL, 0
	invoke_dll_stdcall SelectObject, Param(0), eax

	FrameEnd
	ret
	%undef _BMIF
	%undef _BMIF_Addr
	%undef _Palette

;void OGLFC_Compose(OGLFC *oglfc, int w, int h, const char *text);
DefFunc _OGLFC_Compose
	FrameBegin 15 + SizedVar(InstBufferData.size) + SizedVar(GLYPHMETRICS.size), ebx, esi, edi
	AssignVars _PointerToChar, _X, _Y, _Buffer
	AssignVars _BufferSize, _FontVacKey, _WCharBuf, _WCharPtr, _WCharLen
	AssignVars _SizeW, _SizeH, _CanvasW, _CanvasH
	AssignVars _SrcX, _SrcY
	AssignSizedVar _InstBufferData, InstBufferData.size
	AssignSizedVar _GlyphMetrics, GLYPHMETRICS.size

	xor eax, eax
	lea edi, _PointerToChar
	mov ecx, Frame_NumLocals
	rep stosd

	mov ebx, Param(0)
	mov eax, Param(3)
	mov _PointerToChar, eax

	invoke_cdecl _BufferClear, &[ebx + OGLFC.instance_buffer]
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [ebx + OGLFC.font_map]

.loop_compose:
	invoke_cdecl _UtfReadCharFromPtr, &_PointerToChar
	test eax, eax
	jz .loop_end
	cmp eax, ` `
	jz .space
	cmp eax, `\n`
	jz .newline
	cmp eax, `\t`
	jz .tab
	cmp eax, 0x20
	jb .loop_compose
	jmp .draw_glyph
.space:
	mov eax, [ebx + OGLFC.font_size]
	shr eax, 1
	add _X, eax
	jmp .after_advance
.newline:
	xor eax, eax
	mov ecx, [ebx + OGLFC.font_size]
	mov _X, eax
	add _Y, ecx
	jmp .after_advance
.tab:
	mov ecx, [ebx + OGLFC.font_size]
	shl ecx, 1
	mov eax, _X
	dec eax
	div ecx
	inc eax
	mul ecx
	mov _X, eax
	jmp .after_advance

.draw_glyph:
	mov esi, eax

.after_new_glyph_cached:
	invoke_cdecl _LfuGet, [ebx + OGLFC.lfu], esi
	test eax, eax
	jz .cache_new_glyph
	mov edi, eax

	movq xmm3, [edi + LfuData.xoff]
	movq xmm0, _X
	movq xmm1, [edi + LfuData.blackbox_w]
	movq xmm2, [edi + LfuData.x]
	cvtdq2ps xmm3, xmm3
	cvtdq2ps xmm0, xmm0
	cvtdq2ps xmm1, xmm1
	cvtdq2ps xmm2, xmm2
	subps xmm0, xmm3
	movq [_InstBufferData_Addr + InstBufferData.x], xmm0
	movq [_InstBufferData_Addr + InstBufferData.w], xmm1
	movq [_InstBufferData_Addr + InstBufferData.tw], xmm1
	movq [_InstBufferData_Addr + InstBufferData.tx], xmm2
	invoke_cdecl _BufferPushItem, &[ebx + OGLFC.instance_buffer], &[_InstBufferData_Addr]

	movzx eax, word[edi + LfuData.xinc]
	movzx ecx, word[edi + LfuData.yinc]
	add _X, eax
	add _Y, ecx
.after_advance:
	cmp eax, Param(1)
	jb .loop_compose
	xor eax, eax
	mov _X, eax
	mov eax, [ebx + OGLFC.font_size]
	add _Y, eax
	mov eax, Param(2)
	cmp dword _Y, eax
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
	mov ecx, [ebx + OGLFC.font_size]
	mov eax, [edi + LfuData.x]
	mul ecx
	mov _SrcX, eax
	mov eax, [edi + LfuData.y]
	mul ecx
	mov _SrcY, eax
	cmp dword _Buffer, 0
	jnz .have_buffer
	mov eax, [ebx + OGLFC.font_size]
	shl eax, 3
	mul eax
	mov _BufferSize, eax
	invoke_cdecl _malloc, eax
	mov _Buffer, eax
.have_buffer:
	invoke_dll_stdcall GetGlyphOutlineW, [ebx + OGLFC.hdc_font], esi, GGO_GRAY8_BITMAP, &_GlyphMetrics, _BufferSize, _Buffer, .mat2
	cmp eax, 0xFFFFFFFF
	jz .non_ttf
	mov eax, _Buffer
	mov ecx, _BufferSize
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
	lea eax, _GlyphMetrics
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
	invoke_dll_stdcall glTexSubImage2D, GL_TEXTURE_2D, 0, _SrcX, _SrcY, [edi + LfuData.blackbox_w], [edi + LfuData.blackbox_h], GL_RED, GL_UNSIGNED_BYTE, _Buffer
.lfudata_ready:
	invoke_cdecl _LfuPut, [ebx + OGLFC.lfu], esi, edi, _free
	jmp .after_new_glyph_cached
.non_ttf:
	lea eax, _WCharBuf
	mov _WCharPtr, eax
	invoke_cdecl _Utf32to16, esi, &_WCharPtr
	mov _WCharLen, eax
	invoke_dll_stdcall GetTextExtentPoint32W, [ebx + OGLFC.hdc_font], &_WCharBuf, eax, &_SizeW
	mov eax, _SizeW
	mov ecx, [ebx + OGLFC.font_size]
	mov _CanvasW, eax
	mov _CanvasH, ecx
	cmp eax, [ebx + OGLFC.canvas_width]
	jne .recreate_canvas
	cmp ecx, [ebx + OGLFC.canvas_height]
	je .have_canvas
.recreate_canvas:
	invoke_cdecl _OGLFC_CreateAndSelectBitmap, [ebx + OGLFC.hdc_canvas], _CanvasW, _CanvasH, &[ebx + OGLFC.canvas_pointer]
	invoke_dll_stdcall DeleteObject, eax
	mov eax, _CanvasW
	mov ecx, _CanvasH
	mov [ebx + OGLFC.canvas_width], eax
	mov [ebx + OGLFC.canvas_height], ecx
.have_canvas:
	invoke_dll_stdcall ExtTextOutW, [ebx + OGLFC.hdc_canvas], 0, 0, ETO_OPAQUE, NULL, &_WCharBuf, _WCharLen, NULL
	mov eax, [ebx + OGLFC.canvas_width]
	mov ecx, [ebx + OGLFC.canvas_height]
	mov [edi + LfuData.blackbox_w], eax
	mov [edi + LfuData.blackbox_h], ecx
	mov [edi + LfuData.xinc], ax
	invoke_dll_stdcall glTexSubImage2D, GL_TEXTURE_2D, 0, _SrcX, _SrcY, [edi + LfuData.blackbox_w], [edi + LfuData.blackbox_h], GL_RED, GL_UNSIGNED_BYTE, [ebx + OGLFC.canvas_pointer]
	jmp .lfudata_ready

.loop_end:
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0
	invoke_cdecl _free, _Buffer

	FrameEnd
	ret
[segment .rdata]
.mat2:
	dd 65536, 0
	dd 0, 65536
	%undef _PointerToChar
	%undef _X
	%undef _Y
	%undef _Buffer
	%undef _BufferSize
	%undef _FontVacKey
	%undef _WCharBuf
	%undef _WCharPtr
	%undef _WCharLen
	%undef _SizeW
	%undef _SizeH
	%undef _CanvasW
	%undef _CanvasH
	%undef _SrcX
	%undef _SrcY
	%undef _InstBufferData
	%undef _InstBufferData_Addr
	%undef _GlyphMetrics

;void OGLFC_Present(OGLFC *oglfc, int x, int y);
DefFunc _OGLFC_Present
	FrameBegin 4, ebx, esi, edi
	AssignVars _VPX, _VPY, _VPW, _VPH

	mov ebx, Param(0)
	lea esi, [ebx + OGLFC.instance_buffer]

	invoke_dll_stdcall glGetIntegerv, GL_VIEWPORT, &_VPX
	movq xmm0, Param(1)
	movq xmm1, _VPW
	cvtsi2ss xmm2, [ebx + OGLFC.font_size]
	cvtdq2ps xmm0, xmm0
	cvtdq2ps xmm1, xmm1
	movq Param(1), xmm0
	movq _VPW, xmm1
	movss Variable(0), xmm2

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
	invoke_dll_stdcall glUniform1f, [ebx + OGLFC.location_font_size], Variable(0)
	invoke_dll_stdcall glUniform2f, [ebx + OGLFC.location_resolution], _VPW, _VPH
	invoke_dll_stdcall glUniform2f, [ebx + OGLFC.location_offset], Param(1), Param(2)
	invoke_dll_stdcall glDrawArraysInstanced, GL_TRIANGLE_STRIP, 0, 4, [esi + GlBuffer.num_items]
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0
	invoke_dll_stdcall glBindVertexArray, 0

	FrameEnd
	ret
	%undef _VPX
	%undef _VPY
	%undef _VPW
	%undef _VPH


;int GLPrintf(OGLFC *oglfc, int x, int y, const char *fmt, ...);
DefFunc _GLPrintf
	FrameBegin 0, ebx

	lea eax, Param(4)
	invoke_dll_cdecl vsnprintf, [_DebugMsgBuffer], _DebugMsgBufferSize, Param(3), eax
	mov ebx, eax

	invoke_cdecl _OGLFC_Compose, Param(0), 0xFFFFFFFF, 0xFFFFFFFF, [_DebugMsgBuffer]
	invoke_cdecl _OGLFC_Present, Param(0), Param(1), Param(2)

	mov eax, ebx
	FrameEnd
	ret
