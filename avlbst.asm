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
;char *AVLKeyCopy(char *key);
global _AVLKeyCopy
_AVLKeyCopy:
	FrameBegin 0, 2

	invoke_dll_cdecl strlen, Param(0)
	inc eax
	invoke_cdecl _malloc, eax
	invoke_dll_cdecl strcpy, eax, Param(0)

	FrameEnd
	ret

;void _AVLKeyDelete(char *key);
global _AVLKeyDelete
_AVLKeyDelete: jmp _free

;AVLBST_Node *AVLNewNode(char *key, size_t cb_userdata);
global _AVLNewNode
_AVLNewNode:
	FrameBegin 0, 2, edi

	mov eax, Param(1)
	add eax, AVLBST_Node.head_size
	invoke_cdecl _calloc, eax, 1
	mov edi, eax

	invoke_cdecl _AVLKeyCopy, Param(0)
	mov [edi + AVLBST_Node.key], eax

	mov eax, Param(1)
	mov [edi + AVLBST_Node.data_size], eax

	mov eax, edi

	FrameEnd
	ret

; int AVLMaxInt(int a, int b);
global _AVLMaxInt
_AVLMaxInt:
	FrameBegin 0, 0

	mov eax, Param(0)
	cmp eax, Param(1)
	jg .a_gt_b
	mov eax, Param(1)
.a_gt_b:
	FrameEnd
	ret

; int AVLHeight(AVLBST_Node *n);
global _AVLHeight
_AVLHeight:
	FrameBegin 0, 0

	mov eax, Param(0)
	test eax, eax
	jz .end

	mov eax, [eax + AVLBST_Node.height]

.end:
	FrameEnd
	ret

; void AVLCalcHeight(AVLBST_Node *n);
global _AVLCalcHeight
_AVLCalcHeight:
	FrameBegin 1, 2, esi

	mov esi, Param(0)
	invoke_cdecl _AVLHeight, [esi + AVLBST_Node.l_child]
	StoreVariable 0, eax

	invoke_cdecl _AVLHeight, [esi + AVLBST_Node.r_child]
	LoadVariable ecx, 0

	invoke_cdecl _AVLMaxInt, eax, ecx
	inc eax
	mov [esi + AVLBST_Node.height], eax

	FrameEnd
	ret

	FrameEnd
	ret













