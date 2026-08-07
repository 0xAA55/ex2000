%ifndef _FONT_GL_
%define _FONT_GL_

%include "buffer.inc"

struc OGLFC ;OpenGL Font Cache
.public_rw:
	.space_size resd 1
	.tab_width resd 1
	.ascent resd 1 ;E.g. The upper part of Q is O, the height of O is ascent
	.descent resd 1 ;`font_size` - `ascent` = `descent`

.public_ro:
	.capacity resd 1
	.font_size resd 1 ;Height
	.grid_size resd 1
	.tab_width_px resd 1

.protected:
	.hdc_font resd 1
	.hdc_canvas resd 1
	.canvas_width resd 1
	.canvas_height resd 1
	.canvas_pointer resd 1
	.font_map resd 1
	.font_map_size resd 1
	.lfu resd 1 ;LfuCache
	.vacant_coords resd 1 ;AVLBST
	.shader_program resd 1
	.location_font_map resd 1
	.location_grid_size resd 1
	.location_font_color resd 1
	.location_resolution resd 1
	.location_offset resd 1
	.instance_buffer:
		InstGlBuffer instbuf_
	.vao resd 1
	.size equ $ - OGLFC
endstruc

;OGLFC *OGLFC_Create(HDC hDC, int cap_bits);
extern _OGLFC_Create

;void OGLFC_Destroy(OGLFC *oglfc);
extern _OGLFC_Destroy

;uint64_t OGLFC_Compose(OGLFC *oglfc, const char *text);
;// The returned `uint64_t` is actually a `struct {uint32_t w, h;};`
extern _OGLFC_Compose

;int GLPrintf(OGLFC *oglfc, const char *fmt, ...);
extern _GLPrintf

;int GLPrintfXY(OGLFC *oglfc, int x, int y, const char *fmt, ...);
extern _GLPrintfXY

%macro GLPrintf 2-3+
	[segment .rdata]
	%%format db %2, 0

	__SECT__
	%if %0 >= 3
		invoke_cdecl _GLPrintf, %1, %%format, %3
	%else
		invoke_cdecl _GLPrintf, %1, %%format
	%endif
%endmacro

%macro GLPrintfXY 4-5+
	[segment .rdata]
	%%format db %4, 0

	__SECT__
	%if %0 >= 5
		invoke_cdecl _GLPrintfXY, %1, %2, %3, %%format, %5
	%else
		invoke_cdecl _GLPrintfXY, %1, %2, %3, %%format
	%endif
%endmacro

%endif
