%include "loaddll.inc"
%include "gl33.inc"
%include "buffer.inc"

; void InitBuffer(GlBuffer *p_buffer, GLenum buffer_type, GLenum buffer_usage, size_t item_size, size_t capacity, void *pointer_to_data_or_null);
DefFunc _InitBuffer
	FrameBegin ebx, edi
	NameParams %$BufferInst, %$BufType, %$BufUsage, %$BufItemSize, %$BufCapacity, %$BufData
	DefVars %$CBSize, %$NumData

	xor eax, eax
	mov %$NumData, eax
	mov ecx, GlBuffer.size / 4
	mov ebx, %$BufferInst
	mov edi, ebx
	rep stosd

	mov eax, %$BufItemSize
	mul dword %$BufCapacity
	test edx, edx
	jz .good
.bad:
	int3
	jmp .bad
.good:
	mov %$CBSize, eax

	invoke_cdecl _malloc, eax
	mov [ebx + GlBuffer.pointer], eax

	invoke_stdcall glGenBuffers, 1, &[ebx + GlBuffer.gl_buffer]

	mov eax, %$BufData
	test eax, eax
	jz .after_copy
	invoke_cdecl memcpy, [ebx + GlBuffer.pointer], %$BufData, %$CBSize
	mov eax, %$BufCapacity
	mov %$NumData, eax
.after_copy:
	mov edi, %$BufType

	invoke_stdcall glBindBuffer, edi, [ebx + GlBuffer.gl_buffer]
	invoke_stdcall glBufferData, edi, %$CBSize, %$BufData, %$BufUsage
	invoke_stdcall glBindBuffer, edi, 0

	mov eax, %$BufCapacity
	mov ecx, %$BufItemSize
	mov edx, %$BufUsage
	mov [ebx + GlBuffer.capacity], eax
	mov [ebx + GlBuffer.gl_buffer_cap], eax
	mov [ebx + GlBuffer.gl_buffer_type], edi
	mov eax, %$NumData
	mov [ebx + GlBuffer.size_of_item], ecx
	mov [ebx + GlBuffer.gl_buffer_usage], edx
	mov [ebx + GlBuffer.num_items], eax
	xor eax, eax
	inc eax
	mov [ebx + GlBuffer.flushed], eax

.end:
	FrameEnd
	ret

; void DeInitBuffer(GlBuffer *p_buffer);
DefFunc _DeInitBuffer
	FrameBegin edi
	NameParams %$Buffer

	mov edi, %$Buffer
	invoke_cdecl _free, [edi + GlBuffer.pointer]

	lea eax, [edi + GlBuffer.gl_buffer]
	invoke_stdcall glDeleteBuffers, 1, eax

.end:
	xor eax, eax
	mov ecx, GlBuffer.size / 4
	rep stosd

	FrameEnd
	ret

; void BufferCleanNewMemory(GlBuffer *p_buffer, size_t old_cap, size_t new_cap)
DefFunc _BufferCleanNewMemory
	FrameBegin ebx, esi
	NameParams %$Buffer, %$OldCap, %$NewCap

	mov ebx, %$Buffer
	mov eax, %$OldCap
	mov ecx, %$NewCap
	mov esi, [ebx + GlBuffer.size_of_item]
	sub ecx, eax
	jbe .end
	mul esi
	mov edi, eax
	mov eax, ecx
	add edi, [ebx + GlBuffer.pointer]
	mul esi
	invoke_cdecl memset, edi, 0, eax
.end:
	FrameEnd
	ret

DefFunc _BufferSizeGrow
	FrameBegin ebx, esi, edi
	NameParams %$Buffer
	DefVars %$NewCap, %$OldCap

	mov ebx, %$Buffer
	mov esi, [ebx + GlBuffer.size_of_item]
	mov eax, [ebx + GlBuffer.capacity]
	mov %$OldCap, eax
	mov ecx, 3
	mul ecx
	dec ecx
	div ecx
	inc eax
	mov %$NewCap, eax
	mul esi
	test edx, edx
	jz .good
.bad:
	int3
	jmp .bad
.good:
	invoke_cdecl _realloc, [ebx + GlBuffer.pointer], eax
	mov [ebx + GlBuffer.pointer], eax
	invoke_cdecl _BufferCleanNewMemory, ebx, %$OldCap, %$NewCap
	xor eax, eax
	mov ecx, %$NewCap
	mov [ebx + GlBuffer.flushed], eax
	mov [ebx + GlBuffer.capacity], ecx
	inc eax

.end:
	FrameEnd
	ret

; void BufferPushItem(GlBuffer *p_buffer, void *item);
DefFunc _BufferPushItem
	FrameBegin esi, edi
	NameParams %$Buffer, %$Item

	mov esi, %$Buffer
	mov eax, [esi + GlBuffer.num_items]
	cmp eax, [esi + GlBuffer.capacity]
	jb .proceed_to_push
	invoke_cdecl _BufferSizeGrow, esi
.proceed_to_push:
	; Calculate new item address
	mov ecx, [esi + GlBuffer.size_of_item]
	mov eax, ecx
	mul dword[esi + GlBuffer.num_items]
	add eax, [esi + GlBuffer.pointer]

	; Proceed to copy item data
	mov esi, %$Item
	mov edi, eax
	rep movsb

	mov esi, %$Buffer
	mov [esi + GlBuffer.flushed], ecx
	inc dword[esi + GlBuffer.num_items]
.end:
	FrameEnd
	ret

; void BufferPopItem(GlBuffer *p_buffer, void *item_or_null);
DefFunc _BufferPopItem
	FrameBegin ebx, esi, edi
	NameParams %$Buffer, %$ItemOrNull

	mov ebx, %$Buffer
	mov edi, %$ItemOrNull

	xor edx, edx
	mov eax, [ebx + GlBuffer.num_items]
	cmp eax, edx
	jz .end

	test edi, edi
	jz .after_copy

	dec eax
	mov ecx, [ebx + GlBuffer.size_of_item]
	mul ecx
	add eax, [ebx + GlBuffer.pointer]
	mov esi, eax
	rep movsb

.after_copy:
	dec dword [ebx + GlBuffer.num_items]

.end:
	FrameEnd
	ret

; void BufferClear(GlBuffer *p_buffer);
DefFunc _BufferClear
	FrameBegin
	NameParams %$Buffer
	xor eax, eax
	mov edx, %$Buffer
	mov [edx + GlBuffer.num_items], eax
	FrameEnd
	ret

; void BufferFlush(GlBuffer *p_buffer);
DefFunc _BufferFlush
	FrameBegin ebx, esi, edi
	NameParams %$Buffer

	mov ebx, %$Buffer

	cmp dword[ebx + GlBuffer.flushed], 0
	jnz .end

	mov eax, [ebx + GlBuffer.capacity]
	test eax, eax
	jz .flushed
	push eax
	mul dword[ebx + GlBuffer.size_of_item]
	test edx, edx
	jz .good
.bad:
	int3
	jmp .bad
.good:
	mov esi, eax
	pop eax
	cmp eax, [ebx + GlBuffer.gl_buffer_cap]
	je .map
	mov [ebx + GlBuffer.gl_buffer_cap], eax
	mov edi, [ebx + GlBuffer.gl_buffer_type]
	invoke_stdcall glBindBuffer, edi, [ebx + GlBuffer.gl_buffer]
	invoke_stdcall glBufferData, edi, esi, [ebx + GlBuffer.pointer], [ebx + GlBuffer.gl_buffer_usage]
	invoke_stdcall glBindBuffer, edi, 0
	xor eax, eax
	jmp .flushed

.map:
	mov edi, [ebx + GlBuffer.gl_buffer_type]
	invoke_stdcall glBindBuffer, edi, [ebx + GlBuffer.gl_buffer]
	invoke_stdcall glMapBuffer, edi, GL_WRITE_ONLY
	invoke_cdecl memcpy, eax, [ebx + GlBuffer.pointer], esi
	invoke_stdcall glUnmapBuffer, edi
	invoke_stdcall glBindBuffer, edi, 0
	xor eax, eax

.flushed:
	inc eax
	mov [ebx + GlBuffer.flushed], eax

.end:
	FrameEnd
	ret

; void BufferTrimExcess(GlBuffer *p_buffer);
DefFunc _BufferTrimExcess
	FrameBegin ebx
	NameParams %$Buffer

	mov ebx, %$Buffer
	mov eax, [ebx + GlBuffer.num_items]
	cmp eax, [ebx + GlBuffer.capacity]
	je .end
	xor ecx, ecx
	mov [ebx + GlBuffer.flushed], ecx
	inc ecx
	test eax, eax
	cmovz eax, ecx
	mov [ebx + GlBuffer.capacity], eax
	mul dword [ebx + GlBuffer.size_of_item]
	invoke_cdecl _realloc, [ebx + GlBuffer.pointer], eax
	mov [ebx + GlBuffer.pointer], eax

.end:
	FrameEnd
	ret

; void BufferResize(GlBuffer *p_buffer, size_t new_num_items);
DefFunc _BufferResize
	FrameBegin ebx
	NameParams %$Buffer, %$NumNewItems
	DefVars %$OldCap

	mov ebx, %$Buffer
	mov eax, %$NumNewItems
	mov ecx, [ebx + GlBuffer.capacity]
	cmp eax, ecx
	jbe .change_size_only
	mov %$OldCap, ecx

	mov [ebx + GlBuffer.capacity], eax
	mov [ebx + GlBuffer.num_items], eax
	mul dword[ebx + GlBuffer.size_of_item]
	invoke_cdecl _realloc, [ebx + GlBuffer.pointer], eax
	mov [ebx + GlBuffer.pointer], eax
	mov dword[ebx + GlBuffer.flushed], 0
	invoke_cdecl _BufferCleanNewMemory, ebx, %$OldCap, [ebx + GlBuffer.capacity]
	jmp .end

.change_size_only: ;eax = new size
	mov [ebx + GlBuffer.num_items], eax

.end:
	FrameEnd
	ret
