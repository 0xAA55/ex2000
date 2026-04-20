%define AVLBST_ASM
%include "avlbst.inc"

extern _malloc
extern _calloc
extern _free

import_dll_func strlen
import_dll_func strcpy
import_dll_func strcmp
import_dll_func memcpy

segment .text
;char *AVLKeyCopy(char *key)
global _AVLKeyCopy
_AVLKeyCopy:
	FrameBegin 0, 2

	invoke_dll_cdecl strlen, Param(0)
	inc eax
	invoke_cdecl _malloc, eax
	invoke_dll_cdecl strcpy, eax, Param(0)

	FrameEnd
	ret

global _AVLKeyDelete
_AVLKeyDelete： jmp _free

;int AVLInsert(AVLBST_Inst **ppavlbst, char *key, size_t cb_userdata);
global _AVLInsert
_AVLInsert:
	FrameBegin 0, 2, edi

	mov eax, Param(2)
	add eax, AVLBST_Inst.head_size
	invoke_cdecl _malloc, eax
	mov edi, eax

	invoke_cdecl _AVLKeyCopy, Param(1)
	mov [edi + AVLBST_Inst.key], eax


	FrameEnd
	ret













