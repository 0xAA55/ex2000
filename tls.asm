%include "loaddll.inc"
%include "tls.inc"

segment .bss
extern _TlsIndex
extern _TlsCallbackList
extern _TlsCallbackListSize
extern _TlsCallbackListCap
_TlsIndex resd 1
_TlsCallbackList resd 1
_TlsCallbackListSize resd 1
_TlsCallbackListCap resd 1

DefFunc _TlsInit
	FrameBegin 0

	invoke_dll_stdcall TlsAlloc
	mov [_TlsIndex], eax

	xor eax, eax
	mov al, 64
	mov [_TlsCallbackListCap], eax
	invoke_cdecl _malloc, &[eax * 4]
	mov [_TlsCallbackList], eax

	FrameEnd
	ret

DefFunc _TlsDeInit
	FrameBegin 0

	invoke_cdecl _free, [_TlsCallbackList]
	invoke_dll_stdcall TlsFree, [_TlsIndex]

	xor eax, eax
	mov [_TlsCallbackList], eax
	mov [_TlsCallbackListSize], eax
	mov [_TlsCallbackListCap], eax
	dec eax
	mov [_TlsIndex], eax

	FrameEnd
	ret

DefFunc _TlsRegisterCallback
	FrameBegin 0, ebx

	mov ecx, Param(0)
	mov edx, [_TlsCallbackListCap]
	mov eax, [_TlsCallbackListSize]
	cmp eax, edx
	jb .have_room
	lea eax, [edx * 3]
	shr eax, 1
	inc eax
	mov [_TlsCallbackListCap], eax
	invoke_cdecl _realloc, [_TlsCallbackList], &[eax * 4]
	mov [_TlsCallbackList], eax
	mov eax, [_TlsCallbackListSize]
.have_room:
	mov ebx, [_TlsCallbackList]
	mov [ebx + eax * 4], ecx
	inc dword[_TlsCallbackListSize]

	FrameEnd
	ret

DefFunc _TlsInvokeCallbacks
	FrameBegin 0, ebx, esi, edi

	mov esi, [_TlsCallbackList]
	xor edi, edi
	mov ebx, Param(0)
.loop_call:
	cmp edi, [_TlsCallbackListSize]
	jae .quit_loop
	lodsd
	invoke_cdecl eax, ebx
	inc edi
	jmp .loop_call
.quit_loop:

	FrameEnd
	ret
