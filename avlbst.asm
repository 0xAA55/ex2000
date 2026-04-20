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

;AVLBST_Node *AVLNewNode(char *key, void* cb_userdata);
global _AVLNewNode
_AVLNewNode:
	FrameBegin 0, 2, edi

	invoke_cdecl _calloc, AVLBST_Node.size, 1
	mov edi, eax

	invoke_cdecl _AVLKeyCopy, Param(0)
	mov [edi + AVLBST_Node.key], eax

	mov eax, Param(1)
	mov [edi + AVLBST_Node.userdata], eax

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

; AVLBST_Node *AVLRotate(AVLBST_Node *x, char *key);
global _AVLRotate
_AVLRotate:
	FrameBegin 1, 2, esi

	mov esi, Param(0)
	invoke_cdecl _AVLGetBalance, esi
	cmp eax, 1
	jle .rtree

.ltree:
	invoke_cdecl _AVLGetBalance, [esi + AVLBST_Node.l_child]
	cmp eax, 0
	jl .next_0
	invoke_cdecl _AVLRor, esi
	jmp .end
.next_0:
	invoke_cdecl _AVLRol, [esi + AVLBST_Node.l_child]
	mov [esi + AVLBST_Node.l_child], eax
	invoke_cdecl _AVLRor, esi
	jmp .end
.rtree:
	cmp eax, -1
	jge .btree
	invoke_cdecl _AVLGetBalance, [esi + AVLBST_Node.r_child]
	cmp eax, 0
	jg .next_1
	invoke_cdecl _AVLRol, esi
	jmp .end
.next_1:
	invoke_cdecl _AVLRor, [esi + AVLBST_Node.r_child]
	mov [esi + AVLBST_Node.r_child], eax
	invoke_cdecl _AVLRol, esi
	jmp .end
.btree:
	mov eax, esi
	jmp .end

.end:
	FrameEnd
	ret

; AVLBST_Node *AVLInsertRecursive(AVLBST_Node *n, char *key, void *userdata);
global _AVLInsertRecursive
_AVLInsertRecursive:
	FrameBegin 0, 3, esi

	mov eax, Param(0)
	test eax, eax
	jnz .next_0

	invoke_cdecl _AVLNewNode, Param(1), Param(2)
	jmp .end
.next_0:

	mov esi, eax
	invoke_dll_cdecl strcmp, Param(1), [esi + AVLBST_Node.key]
	cmp eax, 0
	jz .end
	jg .next_1

	invoke_cdecl _AVLInsertRecursive, [esi + AVLBST_Node.l_child], Param(1), Param(2)
	mov [esi + AVLBST_Node.l_child], eax

	jmp .next_2
.next_1:
	invoke_cdecl _AVLInsertRecursive, [esi + AVLBST_Node.r_child], Param(1), Param(2)
	mov [esi + AVLBST_Node.r_child], eax

.next_2:
	invoke_cdecl _AVLCalcHeight, esi
	invoke_cdecl _AVLRotate, esi, Param(1)
	jmp .end

.finish:
	mov eax, esi

.end:
	FrameEnd
	ret

; int AVLInsert(AVLBST_Node **ppn, char *key, void *userdata);
global _AVLInsert
_AVLInsert:
	FrameBegin 0, 3, esi

	mov eax, Param(0)
	test eax, eax
	jnz .next_0
.bad_param:
	int3
	jmp .bad_param
.next_0:
	mov esi, eax
	invoke_cdecl _AVLInsertRecursive, [esi], Param(1), Param(2)
	test eax, eax
	jz .end
	mov [esi], eax
	xor eax, eax
	inc eax
.end:
	FrameEnd
	ret

; AVLBST_Node* AVLRemoveRecursive(AVLBST_Node *n, char *key, void(*on_free)(void *userdata))
global _AVLRemoveRecursive
_AVLRemoveRecursive:
	FrameBegin 1, 3, esi, edi

	mov eax, Param(0)
	test eax, eax
	jz .end

	mov esi, eax
	invoke_dll_cdecl strcmp, Param(1), [esi + AVLBST_Node.key]
	cmp eax, 0
	jz .equal
	jg .key_gt
	invoke_cdecl _AVLRemoveRecursive, [esi + AVLBST_Node.l_child], Param(1), Param(2)
	mov [esi + AVLBST_Node.l_child], eax
	jmp .after_remove
.key_gt:
	invoke_cdecl _AVLRemoveRecursive, [esi + AVLBST_Node.r_child], Param(1), Param(2)
	mov [esi + AVLBST_Node.r_child], eax
	jmp .after_remove
.equal:
	invoke_cdecl _free, [esi + AVLBST_Node.key]
	invoke_cdecl Param(2), [esi + AVLBST_Node.userdata]
	xor eax, eax
	mov [esi + AVLBST_Node.key], eax
	mov [esi + AVLBST_Node.userdata], eax

	mov eax, [esi + AVLBST_Node.l_child]
	and eax, [esi + AVLBST_Node.r_child]
	jnz .2child

	mov eax, [esi + AVLBST_Node.l_child]
	test eax, eax
	jnz .get_child
	mov eax, [esi + AVLBST_Node.r_child]
	test eax, eax
	jz .no_child
.get_child:
	invoke_cdecl _free, esi
	mov esi, eax
	jmp .after_remove
.no_child:
	invoke_cdecl _free, esi
	xor eax, eax
	jmp .end
.2child:
	xor eax, eax
	mov edi, [esi + AVLBST_Node.r_child]
.while:
	mov edx, [edi + AVLBST_Node.l_child]
	cmp edx, eax
	jz .wend
	mov edi, edx
	jmp .while
.wend:
	mov eax, [edi + AVLBST_Node.userdata]
	mov Variable(0), eax
	xor eax, eax
	mov [edi + AVLBST_Node.userdata], eax
	invoke_cdecl _AVLKeyCopy, [edi + AVLBST_Node.key]
	mov [esi + AVLBST_Node.key], eax
	invoke_cdecl _AVLRemoveRecursive, [esi + AVLBST_Node.r_child], eax, Param(2)
	mov [esi + AVLBST_Node.r_child], eax
	mov eax, Variable(0)
	mov [esi + AVLBST_Node.userdata], eax

.after_remove:
	invoke_cdecl _AVLCalcHeight, esi
	invoke_cdecl _AVLRotate, esi

.end:
	FrameEnd
	ret

; int AVLRemove(AVLBST_Node **ppn, char *key, void(*on_free)(void *userdata));
global _AVLRemove
_AVLRemove:
	FrameBegin 0, 3, esi

	mov eax, Param(0)
	test eax, eax
	jnz .next_0
.bad_param:
	int3
	jmp .bad_param
.next_0:
	mov esi, eax
	invoke_cdecl _AVLRemoveRecursive, [esi], Param(1), Param(2)
	test eax, eax
	jz .end
	mov [esi], eax
	xor eax, eax
	inc eax
.end:
	FrameEnd
	ret


; AVLBST_Node* AVLSearch(AVLBST_Node *n, char *key);
global _AVLSearch
_AVLSearch:
	FrameBegin 0, 2, esi

	mov esi, Param(0)

.doloop:
	invoke_dll_cdecl strcmp, [esi + AVLBST_Node.key], Param(1)
	cmp eax, 0
	jz .end
	jg .gt
	mov esi, [esi + AVLBST_Node.l_child]
	jmp .while
.gt:
	mov esi, [esi + AVLBST_Node.r_child]
.while:
	test esi, esi
	jz .end
	jmp .doloop

.end:
	mov eax, esi
	FrameEnd
	ret
