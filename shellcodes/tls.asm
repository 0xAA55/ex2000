%include "common.inc"
%include "tls.inc"

struc TlsMetadata
	.TlsIndex resd 1
	.TlsCallbackList resd 1
	.TlsCallbackListSize resd 1
	.TlsCallbackListCap resd 1
endstruc

segment .data
align 4

_TlsMetadata:
istruc TlsMetadata
	at .TlsIndex, dd 0
	at .TlsCallbackList, dd 0
	at .TlsCallbackListSize, dd 0
	at .TlsCallbackListCap, dd 0
iend

DefFunc _TlsInit
	FrameBegin ebx
	GetAbsAddr ebx, _TlsMetadata

	invoke_stdcall TlsAlloc
	mov [ebx + TlsMetadata.TlsIndex], eax

	xor eax, eax
	mov al, 64
	mov [ebx + TlsMetadata.TlsCallbackListCap], eax
	invoke_cdecl _malloc, &[eax * 4]
	mov [ebx + TlsMetadata.TlsCallbackList], eax

	FrameEnd
	ret

DefFunc _TlsDeInit
	FrameBegin ebx
	GetAbsAddr ebx, _TlsMetadata

	invoke_cdecl _free, [ebx + TlsMetadata.TlsCallbackList]
	invoke_stdcall TlsFree, [ebx + TlsMetadata.TlsIndex]

	xor eax, eax
	mov [ebx + TlsMetadata.TlsCallbackList], eax
	mov [ebx + TlsMetadata.TlsCallbackListSize], eax
	mov [ebx + TlsMetadata.TlsCallbackListCap], eax
	dec eax
	mov [ebx + TlsMetadata.TlsIndex], eax

	FrameEnd
	ret

DefFunc _TlsRegisterCallback
	FrameBegin ebx, esi
	NameParams %$NewCB
	GetAbsAddr ebx, _TlsMetadata

	mov ecx, %$NewCB
	mov edx, [ebx + TlsMetadata.TlsCallbackListCap]
	mov eax, [ebx + TlsMetadata.TlsCallbackListSize]
	cmp eax, edx
	jb .have_room
	lea eax, [edx * 3]
	shr eax, 1
	inc eax
	mov [ebx + TlsMetadata.TlsCallbackListCap], eax
	invoke_cdecl _realloc, [ebx + TlsMetadata.TlsCallbackList], &[eax * 4]
	mov [ebx + TlsMetadata.TlsCallbackList], eax
	mov eax, [ebx + TlsMetadata.TlsCallbackListSize]
.have_room:
	mov esi, [ebx + TlsMetadata.TlsCallbackList]
	mov [esi + eax * 4], ecx
	inc dword[ebx + TlsMetadata.TlsCallbackListSize]

	FrameEnd
	ret

DefFunc _TlsInvokeCallbacks
	FrameBegin ebx, esi, edi
	NameParams %$What
	GetAbsAddr ebx, _TlsMetadata

	mov esi, [ebx + TlsMetadata.TlsCallbackList]
	xor edi, edi
.loop_call:
	cmp edi, [ebx + TlsMetadata.TlsCallbackListSize]
	jae .quit_loop
	lodsd
	invoke_cdecl eax, %$What
	inc edi
	jmp .loop_call
.quit_loop:

	FrameEnd
	ret
