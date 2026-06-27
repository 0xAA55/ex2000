%include "loaddll.inc"
%include "gl33.inc"
%include "buffer.inc"

extern _malloc
extern _realloc
extern _free
import_dll_func memcpy
import_dll_func memset

DefFunc _InitBuffer ;pointer to GlBuffer, buffer type, buffer usage, item_size, capacity, data(or_null)
	FrameBegin 2, ebx, edi
	NameParams BufferInst, BufType, BufUsage, BufItemSize, BufCapacity, BufData
	AssignVars CBSize, NumData

	xor eax, eax
	mov NumData, eax
	mov ecx, GlBuffer.size / 4
	mov ebx, BufferInst
	mov edi, ebx
	rep stosd

	mov eax, BufItemSize
	mul dword BufCapacity
	mov CBSize, eax

	invoke_cdecl _malloc, eax
	mov [ebx + GlBuffer.pointer], eax

	invoke_dll_stdcall glGenBuffers, 1, &[ebx + GlBuffer.gl_buffer]

	mov eax, BufData
	test eax, eax
	jz .after_copy
	invoke_dll_cdecl memcpy, [ebx + GlBuffer.pointer], BufData, CBSize
	mov eax, BufCapacity
	mov NumData, eax
.after_copy:
	mov edi, BufType

	invoke_dll_stdcall glBindBuffer, edi, [ebx + GlBuffer.gl_buffer]
	invoke_dll_stdcall glBufferData, edi, CBSize, BufData, BufUsage
	invoke_dll_stdcall glBindBuffer, edi, 0

	mov eax, BufCapacity
	mov ecx, BufItemSize
	mov edx, BufUsage
	mov [ebx + GlBuffer.capacity], eax
	mov [ebx + GlBuffer.gl_buffer_cap], eax
	mov [ebx + GlBuffer.gl_buffer_type], edi
	mov eax, NumData
	mov [ebx + GlBuffer.size_of_item], ecx
	mov [ebx + GlBuffer.gl_buffer_usage], edx
	mov [ebx + GlBuffer.num_items], eax
	xor eax, eax
	inc eax
	mov [ebx + GlBuffer.flushed], eax

.end:
	FrameEnd
	ret
	%undef BufferInst
	%undef BufType
	%undef BufUsage
	%undef BufItemSize
	%undef BufCapacity
	%undef BufData
	%undef GLObject
	%undef CBSize
	%undef NumData

DefFunc _DeInitBuffer
	FrameBegin 0, edi

	LoadParam edi, 0
	invoke_cdecl _free, [edi + GlBuffer.pointer]

	cmp dword [edi + GlBuffer.gl_buffer], 0
	jz .end

	lea eax, [edi + GlBuffer.gl_buffer]
	invoke_dll_stdcall glDeleteBuffers, 1, eax

.end:
	xor eax, eax
	mov ecx, GlBuffer.size / 4
	rep stosd

	FrameEnd
	ret

DefFunc _BufferSizeGrow
	FrameBegin 1, esi

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
	FrameBegin 0, esi, edi

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
	mul dword [esi + GlBuffer.num_items]
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
	inc dword[esi + GlBuffer.num_items]

	inc eax
	jmp .end
.fail:
	xor eax, eax
.end:
	FrameEnd
	ret

DefFunc _BufferPopItem
	FrameBegin 0, esi, edi

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

DefFunc _BufferClear
	FrameBegin 0
	xor eax, eax
	mov edx, Param(0)
	mov [edx + GlBuffer.num_items], eax
	FrameEnd
	ret

DefFunc _BufferFlush
	FrameBegin 0, ebx, esi, edi

	LoadParam esi, 0
	mov eax, [esi + GlBuffer.flushed]
	test eax, eax
	jnz .end

.reentry:
	mov eax, [esi + GlBuffer.capacity]
	test eax, eax
	jnz .check_glbuffer_size
.no_cap:
	mov ecx, [esi + GlBuffer.gl_buffer_cap]
	inc eax
	cmp eax, ecx
	cmovb eax, ecx
	mov [esi + GlBuffer.capacity], eax
	mul dword[esi + GlBuffer.size_of_item]
	invoke_cdecl _realloc, [esi + GlBuffer.pointer], eax
	mov [esi + GlBuffer.pointer], eax
	jmp .reentry

.check_glbuffer_size:
	cmp eax, [esi + GlBuffer.gl_buffer_cap]
	je .map
	mov [esi + GlBuffer.gl_buffer_cap], eax
	mul dword[esi + GlBuffer.size_of_item]
	mov ebx, eax
	mov edi, [esi + GlBuffer.gl_buffer_type]
	invoke_dll_stdcall glBindBuffer, edi, eax
	invoke_dll_stdcall glBufferData, edi, ebx, [esi + GlBuffer.pointer], [esi + GlBuffer.gl_buffer_usage]
	invoke_dll_stdcall glBindBuffer, edi, 0
	xor eax, eax
	jmp .flushed

.map:
	mul dword[esi + GlBuffer.size_of_item]
	mov ebx, eax
	mov edi, [esi + GlBuffer.gl_buffer_type]
	invoke_dll_stdcall glBindBuffer, edi, [esi + GlBuffer.gl_buffer]
	invoke_dll_stdcall glMapBuffer, edi, GL_WRITE_ONLY
	invoke_dll_cdecl memcpy, eax, [esi + GlBuffer.pointer], ebx
	invoke_dll_stdcall glUnmapBuffer, edi
	invoke_dll_stdcall glBindBuffer, edi, 0
	xor eax, eax

.flushed:
	inc eax
	mov [esi + GlBuffer.flushed], eax

.end:
	FrameEnd
	ret

DefFunc _BufferTrimExcess
	FrameBegin 0, esi

	LoadParam esi, 0
	mov eax, [esi + GlBuffer.num_items]
	cmp eax, [esi + GlBuffer.capacity]
	je .success
	xor ecx, ecx
	mov [esi + GlBuffer.flushed], ecx
	inc ecx
	test eax, eax
	cmovz eax, ecx
	mov [esi + GlBuffer.capacity], eax
	mul dword [esi + GlBuffer.size_of_item]
	invoke_cdecl _realloc, [esi + GlBuffer.pointer], eax
	mov [esi + GlBuffer.pointer], eax

.success:
	inc eax
	jmp .end

.end:
	FrameEnd
	ret

DefFunc _BufferResize
	FrameBegin 0, esi

	LoadParam esi, 0
	LoadParam eax, 1
	cmp eax, [esi + GlBuffer.capacity]
	jbe .change_size

	mov [esi + GlBuffer.capacity], eax
	mul dword [esi + GlBuffer.size_of_item]
	invoke_cdecl _realloc, [esi + GlBuffer.pointer], eax

.change_size: ;eax = new size
	mov [esi + GlBuffer.num_items], eax

	jmp .end

.end:
	FrameEnd
	ret
