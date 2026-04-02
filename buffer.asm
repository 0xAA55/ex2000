%include "loaddll.inc"
%include "gl33.inc"

%define BUFFER_ASM
%include "buffer.inc"

extern _malloc
extern _realloc
extern _free
import_dll_func memcpy
import_dll_func memset

segment .text
DefFunc _InitBuffer ;pointer to GlBuffer, buffer type, buffer usage, item_size, capacity, data(or_null)
	FrameBegin 3, 3, esi, edi
	NameParams BufferInst, BufType, BufUsage, BufItemSize, BufCapacity, BufData
	AssignVars GLObject, CBSize, NumData

	xor eax, eax
	mov NumData, eax
	mov GLObject, eax
	mov ecx, GlBuffer.size / 4
	mov esi, BufferInst
	mov edi, esi
	rep stosd

	mov eax, BufItemSize
	mul dword BufCapacity
	test edx, edx
	jnz .failexit
	mov CBSize, eax

	invoke_cdecl _malloc, eax
	mov [esi + GlBuffer.pointer], eax

	lea eax, GLObject
	invoke_dll_stdcall glGenBuffers, 1, eax

	cmp dword [esi + GlBuffer.pointer], 0
	jz .failexit
	cmp dword GLObject, 0
	jz .failexit

	mov eax, BufData
	test eax, eax
	jz .after_copy
	invoke_dll_cdecl memcpy, [esi + GlBuffer.pointer], BufData, CBSize
	mov eax, BufCapacity
	mov NumData, eax
.after_copy:
	mov edi, BufType

	invoke_dll_stdcall glBindBuffer, edi, GLObject
	invoke_dll_stdcall glBufferData, edi, CBSize, BufData, BufUsage
	invoke_dll_stdcall glBindBuffer, edi, 0

	xor eax, eax
	mov ecx, BufCapacity
	mov edx, BufItemSize
	mov [esi + GlBuffer.flushed], eax
	mov eax, GLObject
	mov [esi + GlBuffer.capacity], ecx
	mov [esi + GlBuffer.gl_buffer_cap], ecx
	mov ecx, BufUsage
	mov [esi + GlBuffer.gl_buffer_type], edi
	mov [esi + GlBuffer.size_of_item], edx
	mov edx, NumData
	mov [esi + GlBuffer.gl_buffer], eax
	mov [esi + GlBuffer.gl_buffer_usage], ecx
	mov [esi + GlBuffer.num_items], edx

	xor eax, eax
	inc eax
	jmp .end
.failexit:
	PrepParam 0, esi
	call _DeInitBuffer

	xor eax, eax
.end:
	FrameEnd
	ret
	%undef BufferInst
	%undef BufType
	%undef BufUsage
	%undef BufItemSize
	%undef BufCapacity
	%undef GLObject
	%undef CBSize

DefFunc _DeInitBuffer
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

DefFunc _BufferSizeGrow
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
	xor eax, eax
	inc eax

.end:
	FrameEnd
	ret

DefFunc _BufferPushItem
	FrameBegin 0, 1, esi, edi

	LoadParam esi, 0
	mov eax, [esi + GlBuffer.num_items]
	cmp eax, [esi + GlBuffer.capacity]
	jb .proceed_to_push
	invoke_cdecl _BufferSizeGrow, esi
	test eax, eax
	jz .fail
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

DefFunc _BufferPopItem
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

DefFunc _BufferFlush
	FrameBegin 0, 3, ebx, esi, edi

	LoadParam esi, 0
	mov eax, [esi + GlBuffer.flushed]
	test eax, eax
	jnz .end

	mov eax, [esi + GlBuffer.capacity]
	cmp eax, [esi + GlBuffer.gl_buffer_cap]
	je .map

	mul dword [esi + GlBuffer.size_of_item]
	mov ebx, eax
	test eax, eax
	jz .empty

	lea edi, [esi + GlBuffer.gl_buffer]
	invoke_dll_stdcall glDeleteBuffers, 1, edi
	invoke_dll_stdcall glGenBuffers, 1, edi
	mov eax, [edi]
	mov edi, [esi + GlBuffer.gl_buffer_type]
	invoke_dll_stdcall glBindBuffer, edi, eax
	invoke_dll_stdcall glBufferData, edi, ebx, [esi + GlBuffer.pointer], [esi + GlBuffer.gl_buffer_usage]
	xor eax, eax
	invoke_dll_stdcall glBindBuffer, edi, eax
	mov eax, [esi + GlBuffer.capacity]
	mov [esi + GlBuffer.gl_buffer_cap], eax
	xor eax, eax
	jmp .flushed
.empty:
	lea edi, [esi + GlBuffer.gl_buffer]
	invoke_dll_stdcall glDeleteBuffers, 1, edi
	xor eax, eax
	mov [edi], eax
	mov [esi + GlBuffer.gl_buffer_cap], eax
	jmp .flushed

.map:
	test eax, eax ; Check if capacity is zero
	jz .empty
	invoke_dll_stdcall glMapBuffer, [esi + GlBuffer.gl_buffer_type], GL_WRITE_ONLY
	invoke_dll_cdecl memcpy, eax, [esi + GlBuffer.pointer], ebx
	invoke_dll_stdcall glUnmapBuffer, [esi + GlBuffer.gl_buffer_type]
	xor eax, eax

.flushed:
	inc eax
	mov [esi + GlBuffer.flushed], eax

.end:
	FrameEnd
	ret

DefFunc _BufferTrimExcess
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
	invoke_cdecl _free, [esi + GlBuffer.pointer]

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

DefFunc _BufferResize
	FrameBegin 0, 2, esi

	LoadParam esi, 0
	LoadParam eax, 1
	cmp eax, [esi + GlBuffer.capacity]
	jbe .change_size

	mul dword [esi + GlBuffer.size_of_item]
	test edx, edx
	jnz .failed

	invoke_cdecl _realloc, [esi + GlBuffer.pointer], eax
	test eax, eax
	jz .failed

	LoadParam eax, 1
	mov [esi + GlBuffer.capacity], eax

.change_size: ;eax = new size
	mov [esi + GlBuffer.num_items], eax

	jmp .end
.failed:
	xor eax, eax

.end:
	FrameEnd
	ret
