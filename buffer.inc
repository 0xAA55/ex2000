%ifndef _BUFFER_INC_
%define _BUFFER_INC_ 1

%macro InstGlBuffer 0
	.address:
	.pointer resd 1
	.num_items resd 1
	.capacity resd 1
	.size_of_item resd 1
	.gl_buffer resd 1
	.gl_buffer_type resd 1
	.gl_buffer_usage resd 1
	.gl_buffer_cap resd 1
	.flushed resd 1 ; Non-zero or zero
	.size equ $ - .address
%endmacro

struc GlBuffer
	InstGlBuffer
endstruc

; void InitBuffer(GlBuffer *p_buffer, GLenum buffer_type, GLenum buffer_usage, size_t item_size, size_t capacity, void *pointer_to_data_or_null);
extern _InitBuffer

; void DeInitBuffer(GlBuffer *p_buffer);
extern _DeInitBuffer

; void BufferPushItem(GlBuffer *p_buffer, void *item);
extern _BufferPushItem

; void BufferPopItem(GlBuffer *p_buffer, void *item_or_null);
extern _BufferPopItem

; void BufferClear(GlBuffer *p_buffer);
extern _BufferClear

; void BufferFlush(GlBuffer *p_buffer);
extern _BufferFlush

; void BufferTrimExcess(GlBuffer *p_buffer);
extern _BufferTrimExcess

; vooid BufferResize(GlBuffer *p_buffer, size_t new_num_items);
extern _BufferResize

%endif
