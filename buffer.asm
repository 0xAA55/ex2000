%include "loaddll.inc"
%include "frame.inc"
%include "timer.inc"
%include "gl33.inc"

%define BUFFER_ASM
%include "buffer.inc"

extern _malloc
extern _realloc
extern _free

segment .text
global _InitBuffer
_InitBuffer: ;pointer to GlBuffer, buffer type, buffer usage, item_size, num_items
	%define PRM_INST 0
	%define PRM_BUF_TYPE 1
	%define PRM_BUF_USAGE 2
	%define PRM_ITEM_SIZE 3
	%define PRM_NUM_ITEMS 4
	%define VAR_GLOBJ 0
	%define VAR_CBSIZE 1
	%define VAR_ESI_HOME 2
	%define VAR_EDI_HOME 3
	FrameBegin 5, 1

	StoreVariable VAR_ESI_HOME, esi
	StoreVariable VAR_EDI_HOME, edi
	StoreVariable VAR_GLOBJ, 0

	xor eax, eax
	mov ecx, GlBuffer.size / 4
	LoadParam esi, PRM_INST
	mov edi, esi
	rep stosd

	LoadParam eax, PRM_ITEM_SIZE
	mul dword Param(PRM_NUM_ITEMS)
	StoreVariable VAR_CBSIZE, eax
	PrepParam 0, eax
	call _malloc
	mov [esi + GlBuffer.pointer], eax

	lea eax, Variable(VAR_GLOBJ)
	PrepStdCallParam 1, eax
	invoke_dll_func glGenBuffers
	AfterStdCall

	cmp dword [esi + GlBuffer.pointer], 0
	jz .failexit
	cmp dword Variable(VAR_GLOBJ), 0
	jz .failexit

	mov edi, Param(PRM_BUF_TYPE)

	PrepStdCallParam edi, Variable(VAR_GLOBJ)
	invoke_dll_func glBindBuffer
	AfterStdCall

	mov eax, Variable(VAR_CBSIZE)
	PrepStdCallParam edi, eax, 0, Param(PRM_BUF_USAGE)
	invoke_dll_func glBufferData
	AfterStdCall

	PrepStdCallParam edi, 0
	invoke_dll_func glBindBuffer
	AfterStdCall

	xor eax, eax
	mov [esi + GlBuffer.num_items], eax
	LoadParam ecx, PRM_NUM_ITEMS
	mov [esi + GlBuffer.capacity], ecx
	mov [esi + GlBuffer.gl_buffer_size], ecx
	mov [esi + GlBuffer.gl_buffer_type], edi
	LoadParam edx, PRM_ITEM_SIZE
	mov [esi + GlBuffer.size_of_item], edx
	LoadVariable eax, VAR_GLOBJ
	mov [esi + GlBuffer.gl_buffer], eax

	xor eax, eax
	inc eax
	jmp .end
.failexit:
	PrepParam 0, esi
	call _DeInitBuffer

	xor eax, eax
.end:
	LoadVariable esi, VAR_ESI_HOME
	LoadVariable edi, VAR_EDI_HOME
	FrameEnd
	%undef PRM_INST
	%undef PRM_BUF_TYPE
	%undef PRM_BUF_USAGE
	%undef PRM_ITEM_SIZE
	%undef PRM_NUM_ITEMS
	%undef VAR_GLOBJ
	%undef VAR_CBSIZE
	%undef VAR_ESI_HOME
	%undef VAR_EDI_HOME
	ret

global _DeInitBuffer
_DeInitBuffer:
	FrameBegin 2, 1
	StoreVariable 0, edi

	LoadParam edi, 0
	mov eax, [edi + GlBuffer.pointer]
	PrepParam 0, eax
	call _free

	cmp dword [edi + GlBuffer.gl_buffer], 0
	jz .end

	lea eax, [edi + GlBuffer.gl_buffer]
	PrepStdCallParam 1, eax
	invoke_dll_func glDeleteBuffers
	AfterStdCall

.end:
	mov ecx, GlBuffer.size / 4
	rep stosd

	LoadVariable edi, 0
	FrameEnd
	ret
