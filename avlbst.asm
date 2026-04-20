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

; AVLBST_Node *AVLRol(AVLBST_Node *x);
global _AVLRol
_AVLRol:
	FrameBegin 1, 1, esi, edi

	mov esi, Param(0)
	mov edi, [esi + AVLBST_Node.r_child]
	mov eax, [edi + AVLBST_Node.l_child]
	mov [edi + AVLBST_Node.l_child], esi
	mov [esi + AVLBST_Node.r_child], eax

	invoke_cdecl _AVLCalcHeight, esi
	invoke_cdecl _AVLCalcHeight, edi

	mov eax, edi

	FrameEnd
	ret

; AVLBST_Node *AVLRor(AVLBST_Node *x);
global _AVLRor
_AVLRor:
	FrameBegin 1, 1, esi, edi

	mov edi, Param(0)
	mov esi, [edi + AVLBST_Node.l_child]
	mov eax, [esi + AVLBST_Node.r_child]
	mov [esi + AVLBST_Node.r_child], edi
	mov [edi + AVLBST_Node.l_child], eax

	invoke_cdecl _AVLCalcHeight, esi
	invoke_cdecl _AVLCalcHeight, edi

	mov eax, esi

	FrameEnd
	ret

; int AVLGetBalance(AVLBST_Node *x);
global _AVLGetBalance
_AVLGetBalance:
	FrameBegin 1, 1, esi

	mov eax, Param(0)
	test eax, eax
	jz .end

	mov esi, eax
	invoke_cdecl _AVLHeight, [esi + AVLBST_Node.l_child]
	mov Variable(0), eax
	invoke_cdecl _AVLHeight, [esi + AVLBST_Node.r_child]
	mov edx, eax
	mov eax, Variable(0)
	sub eax, edx

.end:
	FrameEnd
	ret

; AVLBST_Node *AVLKeepBalanceOnInsert(AVLBST_Node *x, char *key);
global _AVLKeepBalanceOnInsert
_AVLKeepBalanceOnInsert:
	FrameBegin 1, 2, esi

	mov esi, Param(0)
	invoke_cdecl _AVLGetBalance, esi
	mov Variable(0), eax

	cmp eax, 1
	jle .next_0

	mov eax, [esi + AVLBST_Node.l_child]
	invoke_dll_cdecl strcmp, Param(1), [eax + AVLBST_Node.key]
	cmp eax, 0
	jge .next_0

	invoke_cdecl _AVLRor, esi
	jmp .end
.next_0:
	mov Variable(0), eax

	cmp eax, -1
	jge .next_1

	mov eax, [esi + AVLBST_Node.r_child]
	invoke_dll_cdecl strcmp, Param(1), [eax + AVLBST_Node.key]
	cmp eax, 0
	jle .next_1

	invoke_cdecl _AVLRol, esi
	jmp .end
.next_1:
	mov Variable(0), eax

	cmp eax, 1
	jle .next_2

	mov eax, [esi + AVLBST_Node.l_child]
	invoke_dll_cdecl strcmp, Param(1), [eax + AVLBST_Node.key]
	cmp eax, 0
	jle .next_2

	invoke_cdecl _AVLRol, [esi + AVLBST_Node.l_child]
	mov [esi + AVLBST_Node.l_child], eax

	invoke_cdecl _AVLRor, esi
	jmp .end
.next_2:
	mov Variable(0), eax

	cmp eax, 1
	jge .next_3

	mov eax, [esi + AVLBST_Node.r_child]
	invoke_dll_cdecl strcmp, Param(1), [eax + AVLBST_Node.key]
	cmp eax, 0
	jge .next_3

	invoke_cdecl _AVLRor, [esi + AVLBST_Node.r_child]
	mov [esi + AVLBST_Node.r_child], eax

	invoke_cdecl _AVLRol, esi
	jmp .end

.next_3:
	mov eax, esi

.end:
	FrameEnd
	ret












