%ifndef _BUFFER_INC_
%define _BUFFER_INC_ 1

%include "frame.inc"

struc GlBuffer
	.pointer resd 1
	.num_items resd 1
	.capacity resd 1
	.size_of_item resd 1
	.gl_buffer resd 1
	.gl_buffer_type resd 1
	.gl_buffer_usage resd 1
	.gl_buffer_cap resd 1
	.flushed resd 1 ; Non-zero or zero
	.size equ $ - .pointer
endstruc

%ifndef BUFFER_ASM
extern _InitBuffer
extern _DeInitBuffer

extern _BufferPushItem
extern _BufferPopItem

extern _BufferFlush
extern _BufferTrimExcess
extern _BufferResize
%endif

%macro InitBuffer 5
	ResetPassReg
	PrepParam 0, %1 ;pointer_to_GlBuffer
	PrepParam 1, %2 ;buffer_type
	PrepParam 2, %3 ;buffer_usage
	PrepParam 3, %4 ;item_size
	PrepParam 4, %5 ;capacity
	call _InitBuffer
%endmacro

%macro DeInitBuffer 1
	ResetPassReg
	PrepParam 0, %1 ;pointer_to_GlBuffer
	call _DeInitBuffer
%endmacro

%macro BufferPushItem 2
	ResetPassReg
	PrepParam 0, %1 ;pointer_to_GlBuffer
	PrepParam 1, %2 ;pointer_to_item
	call _BufferPushItem
%endmacro

%macro BufferPopItem 2
	ResetPassReg
	PrepParam 0, %1 ;pointer_to_GlBuffer
	PrepParam 1, %2 ;pointer_to_item or NULL
	call _BufferPopItem
%endmacro

%macro BufferFlush 1
	ResetPassReg
	PrepParam 0, %1 ;pointer_to_GlBuffer
	call _BufferFlush
%endmacro

%macro BufferTrimExcess 1
	ResetPassReg
	PrepParam 0, %1 ;pointer_to_GlBuffer
	call _BufferTrimExcess
%endmacro

%macro BufferResize 2
	ResetPassReg
	PrepParam 0, %1 ;pointer_to_GlBuffer
	PrepParam 1, %2 ;new size
	call _BufferResize
%endmacro

%endif
