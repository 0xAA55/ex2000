%include "loaddll.inc"
%include "timer.inc"
%include "gl33.inc"

%define BUFFER_ASM
%include "buffer.inc"

extern _malloc
extern _realloc
extern _free
import_dll_func memcpy

segment .text
global _InitBuffer
_InitBuffer: ;pointer to GlBuffer, buffer type, buffer usage, item_size, capacity
	%define PRM_INST 0
	%define PRM_BUF_TYPE 1
	%define PRM_BUF_USAGE 2
	%define PRM_ITEM_SIZE 3
	%define PRM_CAPACITY 4
	%define VAR_GLOBJ 0
	%define VAR_CBSIZE 1
	FrameBegin 2, 1, esi, edi

	StoreVariable VAR_GLOBJ, 0

	xor eax, eax
	mov ecx, GlBuffer.size / 4
	LoadParam esi, PRM_INST
	mov edi, esi
	rep stosd

	LoadParam eax, PRM_ITEM_SIZE
	mul dword Param(PRM_CAPACITY)
	test edx, edx
	jnz .failexit
	StoreVariable VAR_CBSIZE, eax

	invoke_cdecl _malloc, eax
	mov [esi + GlBuffer.pointer], eax

	lea eax, Variable(VAR_GLOBJ)
	invoke_dll_stdcall glGenBuffers, 1, eax

	cmp dword [esi + GlBuffer.pointer], 0
	jz .failexit
	cmp dword Variable(VAR_GLOBJ), 0
	jz .failexit

	mov edi, Param(PRM_BUF_TYPE)

	invoke_dll_stdcall glBindBuffer, edi, Variable(VAR_GLOBJ)
	invoke_dll_stdcall glBufferData, edi, Variable(VAR_CBSIZE), 0, Param(PRM_BUF_USAGE)
	invoke_dll_stdcall glBindBuffer, edi, 0

	xor eax, eax
	LoadParam ecx, PRM_CAPACITY
	LoadParam edx, PRM_ITEM_SIZE
	mov [esi + GlBuffer.num_items], eax
	mov [esi + GlBuffer.flushed], eax
	LoadVariable eax, VAR_GLOBJ
	mov [esi + GlBuffer.capacity], ecx
	mov [esi + GlBuffer.gl_buffer_cap], ecx
	LoadParam ecx, PRM_BUF_USAGE
	mov [esi + GlBuffer.gl_buffer_type], edi
	mov [esi + GlBuffer.size_of_item], edx
	mov [esi + GlBuffer.gl_buffer], eax
	mov [esi + GlBuffer.gl_buffer_usage], ecx

	xor eax, eax
	inc eax
	jmp .end
.failexit:
	PrepParam 0, esi
	call _DeInitBuffer

	xor eax, eax
.end:
	FrameEnd
	%undef PRM_INST
	%undef PRM_BUF_TYPE
	%undef PRM_BUF_USAGE
	%undef PRM_ITEM_SIZE
	%undef PRM_CAPACITY
	%undef VAR_GLOBJ
	%undef VAR_CBSIZE
	ret

global _DeInitBuffer
_DeInitBuffer:
	FrameBegin 0, 1, edi

	LoadParam edi, 0
	invoke_cdecl _free, [edi + GlBuffer.pointer]

	cmp dword [edi + GlBuffer.gl_buffer], 0
	jz .end

	lea eax, [edi + GlBuffer.gl_buffer]
	invoke_dll_stdcall glDeleteBuffers, 1, eax

.end:
	mov ecx, GlBuffer.size / 4
	rep stosd

	FrameEnd
	ret

global _BufferSizeGrow
_BufferSizeGrow:
	FrameBegin 1, 2, esi

	LoadParam esi, 0
	mov eax, [esi + GlBuffer.capacity]
	mov ecx, 3
	mul ecx
	dec ecx
	div ecx
	inc eax
	StoreVariable 0, eax
	mul dword [esi + GlBuffer.size_of_item]

	invoke_cdecl _realloc, [esi + GlBuffer.pointer], eax
	test eax, eax
	jz .end
	mov [esi + GlBuffer.pointer], eax
	mov dword [esi + GlBuffer.flushed], 0
	LoadVariable ecx, 0
	mov [esi + GlBuffer.capacity], ecx

.end:
	FrameEnd
	ret

global _BufferPushItem
_BufferPushItem:
	FrameBegin 0, 1, esi, edi

	LoadParam esi, 0
	mov eax, [esi + GlBuffer.num_items]
	cmp eax, [esi + GlBuffer.capacity]
	jb .proceed_to_push
	invoke_cdecl _BufferSizeGrow, esi
.proceed_to_push:
	; Calculate new item address
	mov ecx, [esi + GlBuffer.size_of_item]
	mov eax, ecx
	mul [esi + GlBuffer.num_items]
	test edx, edx
	jnz .fail
	add eax, [esi + GlBuffer.pointer]

	; Proceed to copy item data
	LoadParam esi, 1
	mov edi, eax
	rep movsb

	xor eax, eax
	LoadParam esi, 0
	mov [esi + GlBuffer.flushed], eax

	inc eax
	jmp .end
.fail:
	xor eax, eax
.end:
	FrameEnd
	ret

global _BufferPopItem
_BufferPopItem:
	FrameBegin 0, 0, esi, edi

	LoadParam esi, 0
	LoadParam edi, 1

	xor edx, edx
	mov eax, [esi + GlBuffer.num_items]
	cmp eax, edx
	jz .end

	test edi, edi
	jz .after_copy

	mov ecx, [esi + GlBuffer.size_of_item]
	mul ecx
	add eax, [esi + GlBuffer.pointer]
	mov esi, eax
	rep movsb

.after_copy:
	dec dword [esi + GlBuffer.num_items]

.end:
	FrameEnd
	ret

global _BufferFlush
_BufferFlush:
	FrameBegin 1, 3, esi, edi

	LoadParam esi, 0
	mov eax, [esi + GlBuffer.flushed]
	test eax, eax
	jnz .end

	mov eax, [esi + GlBuffer.capacity]
	cmp eax, [esi + GlBuffer.gl_buffer_cap]
	je .map

	mul dword [esi + GlBuffer.size_of_item]
	StoreVariable 0, eax

	lea edi, [esi + GlBuffer.gl_buffer]
	invoke_dll_stdcall glDeleteBuffers, 1, edi
	invoke_dll_stdcall glGenBuffers, 1, edi
	mov eax, [edi]
	mov edi, [esi + GlBuffer.gl_buffer_type]
	invoke_dll_stdcall glBindBuffer, edi, eax
	invoke_dll_stdcall glBufferData, edi, Variable(0), [esi + GlBuffer.pointer], [esi + GlBuffer.gl_buffer_usage]
	xor eax, eax
	invoke_dll_stdcall glBindBuffer, edi, eax
	jmp .flushed

.map:
	invoke_dll_stdcall glMapBuffer, [esi + GlBuffer.gl_buffer_type], GL_WRITE_ONLY
	invoke_dll_stdcall memcpy, eax, [esi + GlBuffer.pointer], Variable(0)
	invoke_dll_stdcall glUnmapBuffer, [esi + GlBuffer.gl_buffer_type]
	xor eax, eax

.flushed:
	inc eax
	mov [esi + GlBuffer.flushed], eax

.end:
	FrameEnd
	ret

global _BufferTrimExcess
_BufferTrimExcess:
	FrameBegin 0, 2, esi

	LoadParam esi, 0
	mov eax, [esi + GlBuffer.num_items]
	cmp eax, [esi + GlBuffer.capacity]
	je .success
	mul dword [esi + GlBuffer.size_of_item]

	invoke_cdecl _realloc, [esi + GlBuffer.pointer], eax
	mov [esi + GlBuffer.pointer], eax
	test eax, eax
	jz .failed

	mov eax, [esi + GlBuffer.num_items]
	mov [esi + GlBuffer.capacity], eax

	xor eax, eax
	mov [esi + GlBuffer.flushed], eax

.success:
	inc eax
	jmp .end

.failed:
	lea eax, [esi + GlBuffer.gl_buffer]
	invoke_dll_stdcall glDeleteBuffers, 1, eax

	xor eax, eax
	mov [esi + GlBuffer.gl_buffer], eax
	mov [esi + GlBuffer.gl_buffer_cap], eax
	mov [esi + GlBuffer.num_items], eax
	mov [esi + GlBuffer.capacity], eax

.end:
	FrameEnd
	ret

