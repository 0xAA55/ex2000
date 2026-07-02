%ifndef _FONT_GL_
%define _FONT_GL_

%include "buffer.inc"

struc OGLFC ;OpenGL Font Cache
	.capacity resd 1
	.hdc_font resd 1
	.hdc_canvas resd 1
	.canvas_width resd 1
	.canvas_height resd 1
	.canvas_pointer resd 1
	.font_size resd 1 ;Height
	.ascent resd 1 ;E.g. The upper part of Q is O, the height of O is ascent
	.descent resd 1 ;`font_size` - `ascent` = `descent`
	.font_map resd 1
	.font_map_size resd 1
	.lfu resd 1 ;LfuCache
	.vacant_coords resd 1 ;AVLBST
	.shader_program resd 1
	.location_font_map resd 1
	.location_font_size resd 1
	.location_font_color resd 1
	.location_resolution resd 1
	.location_offset resd 1
	.instance_buffer resb GlBuffer.size
	.vao resd 1
	.size equ $ - OGLFC
endstruc

;OGLFC *OGLFC_Create(HDC hDC, int cap_bits);
extern _OGLFC_Create

;void OGLFC_Destroy(OGLFC *oglfc);
extern _OGLFC_Destroy

;void OGLFC_Compose(OGLFC *oglfc, const char *text);
extern _OGLFC_Compose

;int GLPrintf(OGLFC *oglfc, int x, int y, const char *fmt, ...);
extern _GLPrintf

%macro GLPrintf 4-5+
	[segment .rdata]
	%%format db %4, 0

	__SECT__
	%if %0 >= 5
		invoke_stdcall _GLPrintf, %1, %2, %3, %%format, %5
	%else
		invoke_stdcall _GLPrintf, %1, %2, %3, %%format
	%endif
	add esp, __ParamIndex * 4
%endmacro

%endif
