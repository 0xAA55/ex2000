%include "loaddll.inc"
%include "gl33.inc"
%include "buffer.inc"

; void InitBuffer(GlBuffer *p_buffer, GLenum buffer_type, GLenum buffer_usage, size_t item_size, size_t capacity, void *pointer_to_data_or_null);
DefFunc _InitBuffer
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
	test edx, edx
	jz .good
.bad:
	int3
	jmp .bad
.good:
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

; void DeInitBuffer(GlBuffer *p_buffer);
DefFunc _DeInitBuffer
	FrameBegin 0, edi

	mov edi, Param(0)
	invoke_cdecl _free, [edi + GlBuffer.pointer]

	lea eax, [edi + GlBuffer.gl_buffer]
	invoke_dll_stdcall glDeleteBuffers, 1, eax

.end:
	xor eax, eax
	mov ecx, GlBuffer.size / 4
	rep stosd

	FrameEnd
	ret

; void BufferCleanNewMemory(GlBuffer *p_buffer, size_t old_cap, size_t new_cap)
DefFunc _BufferCleanNewMemory
	FrameBegin 0, ebx, esi

	mov ebx, Param(0)
	mov eax, Param(1)
	mov ecx, Param(2)
	mov esi, [ebx + GlBuffer.size_of_item]
	sub ecx, eax
	jbe .end
	mul esi
	mov edi, eax
	mov eax, ecx
	add edi, [ebx + GlBuffer.pointer]
	mul esi
	invoke_dll_cdecl memset, edi, 0, eax
.end:
	FrameEnd
	ret

DefFunc _BufferSizeGrow
	FrameBegin 2, ebx, esi, edi
	AssignVars _NewCap, _OldCap

	mov ebx, Param(0)
	mov esi, [ebx + GlBuffer.size_of_item]
	mov eax, [ebx + GlBuffer.capacity]
	mov _OldCap, eax
	mov ecx, 3
	mul ecx
	dec ecx
	div ecx
	inc eax
	mov _NewCap, eax
	mul esi
	test edx, edx
	jz .good
.bad:
	int3
	jmp .bad
.good:
	invoke_cdecl _realloc, [ebx + GlBuffer.pointer], eax
	mov [ebx + GlBuffer.pointer], eax
	invoke_cdecl _BufferCleanNewMemory, ebx, _OldCap, _NewCap
	xor eax, eax
	mov ecx, _NewCap
	mov [ebx + GlBuffer.flushed], eax
	mov [ebx + GlBuffer.capacity], ecx
	inc eax

.end:
	FrameEnd
	ret
	%undef _NewCap
	%undef _OldCap

; void BufferPushItem(GlBuffer *p_buffer, void *item);
DefFunc _BufferPushItem
	FrameBegin 0, esi, edi

	mov esi, Param(0)
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
	mov esi, Param(1)
	mov edi, eax
	rep movsb

	mov esi, Param(0)
	mov [esi + GlBuffer.flushed], ecx
	inc dword[esi + GlBuffer.num_items]
.end:
	FrameEnd
	ret

; void BufferPopItem(GlBuffer *p_buffer, void *item_or_null);
DefFunc _BufferPopItem
	FrameBegin 0, ebx, esi, edi

	mov ebx, Param(0)
	mov edi, Param(1)

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
	FrameBegin 0
	xor eax, eax
	mov edx, Param(0)
	mov [edx + GlBuffer.num_items], eax
	FrameEnd
	ret

; void BufferFlush(GlBuffer *p_buffer);
DefFunc _BufferFlush
	FrameBegin 0, ebx, esi, edi

	mov ebx, Param(0)

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
	invoke_dll_stdcall glBindBuffer, edi, [ebx + GlBuffer.gl_buffer]
	invoke_dll_stdcall glBufferData, edi, esi, [ebx + GlBuffer.pointer], [ebx + GlBuffer.gl_buffer_usage]
	invoke_dll_stdcall glBindBuffer, edi, 0
	xor eax, eax
	jmp .flushed

.map:
	mov edi, [ebx + GlBuffer.gl_buffer_type]
	invoke_dll_stdcall glBindBuffer, edi, [ebx + GlBuffer.gl_buffer]
	invoke_dll_stdcall glMapBuffer, edi, GL_WRITE_ONLY
	invoke_dll_cdecl memcpy, eax, [ebx + GlBuffer.pointer], esi
	invoke_dll_stdcall glUnmapBuffer, edi
	invoke_dll_stdcall glBindBuffer, edi, 0
	xor eax, eax

.flushed:
	inc eax
	mov [ebx + GlBuffer.flushed], eax

.end:
	FrameEnd
	ret

; void BufferTrimExcess(GlBuffer *p_buffer);
DefFunc _BufferTrimExcess
	FrameBegin 0, ebx

	mov ebx, Param(0)
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
	FrameBegin 1, ebx

	mov ebx, Param(0)
	mov eax, Param(1)
	mov ecx, [ebx + GlBuffer.capacity]
	cmp eax, ecx
	jbe .change_size_only
	mov Variable(0), ecx

	mov [ebx + GlBuffer.capacity], eax
	mov [ebx + GlBuffer.num_items], eax
	mul dword[ebx + GlBuffer.size_of_item]
	invoke_cdecl _realloc, [ebx + GlBuffer.pointer], eax
	mov [ebx + GlBuffer.pointer], eax
	mov dword[ebx + GlBuffer.flushed], 0
	invoke_cdecl _BufferCleanNewMemory, ebx, Variable(0), [ebx + GlBuffer.capacity]
	jmp .end

.change_size_only: ;eax = new size
	mov [ebx + GlBuffer.num_items], eax

.end:
	FrameEnd
	ret
