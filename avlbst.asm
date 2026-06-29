%include "loaddll.inc"
%include "avlbst.inc"

; void *AVLKeyCopy(void *key, KeyCompareOps compops);
DefFunc _AVLKeyCopy
	FrameBegin 0
	mov eax, Param(1)
	invoke_cdecl [eax + KeyCompareOps.on_duplicate_key], Param(0)
	FrameEnd
	ret

; int _AVLKeyDelete(void *key, KeyCompareOps compops);
DefFunc _AVLKeyDelete
	FrameBegin 0
	mov eax, Param(1)
	invoke_cdecl [eax + KeyCompareOps.on_free_key], Param(0)
	FrameEnd
	ret

; AVLBST_Node *AVLNewNode(void *key, void* userdata, void(*on_free)(void *userdata), KeyCompareOps compops);
DefFunc _AVLNewNode
	FrameBegin 0, edi, ebx

	mov ebx, Param(3)

	invoke_cdecl _calloc, AVLBST_Node.size, 1
	mov edi, eax

	invoke_cdecl _AVLKeyCopy, Param(0), ebx
	mov [edi + AVLBST_Node.key], eax

	mov eax, Param(1)
	mov ecx, Param(2)
	mov edx, .ret_op
	test ecx, ecx
	cmovz ecx, edx
	mov [edi + AVLBST_Node.userdata], eax
	mov [edi + AVLBST_Node.on_free], ecx
	mov [edi + AVLBST_Node.keyops], ebx

	mov eax, edi

	FrameEnd
.ret_op:
	ret

; void AVLDestroyNode(AVLBST_Node *node);
DefFunc _AVLDestroyNode
	FrameBegin 0, ebx

	mov ebx, Param(0)
	invoke_cdecl _AVLKeyDelete, [ebx + AVLBST_Node.key], [ebx + AVLBST_Node.keyops]
	invoke_cdecl [ebx + AVLBST_Node.on_free], [ebx + AVLBST_Node.userdata]
	invoke_cdecl _free, ebx

	FrameEnd
	ret

; int AVLHeight(AVLBST_Node *n);
DefFunc _AVLHeight
	FrameBegin 0

	mov eax, Param(0)
	test eax, eax
	jz .end

	mov eax, [eax + AVLBST_Node.height]

.end:
	FrameEnd
	ret

; void AVLCalcHeight(AVLBST_Node *n);
DefFunc _AVLCalcHeight
	FrameBegin 1, ebx, esi

	mov ebx, Param(0)
	invoke_cdecl _AVLHeight, [ebx + AVLBST_Node.l_child]
	mov esi, eax

	invoke_cdecl _AVLHeight, [ebx + AVLBST_Node.r_child]

	cmp eax, esi
	cmovl eax, esi
	inc eax
	mov [ebx + AVLBST_Node.height], eax

	FrameEnd
	ret

; AVLBST_Node *AVLRol(AVLBST_Node *x);
DefFunc _AVLRol
	FrameBegin 0, esi, edi

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
DefFunc _AVLRor
	FrameBegin 0, esi, edi

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
DefFunc _AVLGetBalance
	FrameBegin 1, ebx, esi

	mov eax, Param(0)
	test eax, eax
	jz .end

	mov ebx, eax
	invoke_cdecl _AVLHeight, [ebx + AVLBST_Node.l_child]
	mov esi, eax
	invoke_cdecl _AVLHeight, [ebx + AVLBST_Node.r_child]
	mov edx, eax
	mov eax, esi
	sub eax, edx

.end:
	FrameEnd
	ret

; AVLBST_Node *AVLRotate(AVLBST_Node *x);
DefFunc _AVLRotate
	FrameBegin 0, esi

	mov esi, Param(0)
	invoke_cdecl _AVLGetBalance, esi
	cmp eax, 1
	jle .rtree

.ltree:
	invoke_cdecl _AVLGetBalance, [esi + AVLBST_Node.l_child]
	cmp eax, 0
	jge .next_0
	invoke_cdecl _AVLRol, [esi + AVLBST_Node.l_child]
	mov [esi + AVLBST_Node.l_child], eax
.next_0:
	invoke_cdecl _AVLRor, esi
	jmp .end
.rtree:
	cmp eax, -1
	jge .btree
	invoke_cdecl _AVLGetBalance, [esi + AVLBST_Node.r_child]
	cmp eax, 0
	jle .next_1
	invoke_cdecl _AVLRor, [esi + AVLBST_Node.r_child]
	mov [esi + AVLBST_Node.r_child], eax
.next_1:
	invoke_cdecl _AVLRol, esi
	jmp .end
.btree:
	mov eax, esi
	jmp .end

.end:
	FrameEnd
	ret

; AVLBST_Node *AVLInsertRecursive(AVLBST_Node *n, char *key, void *userdata, void(*on_free)(void *userdata), KeyCompareOps compops);
DefFunc _AVLInsertRecursive
	FrameBegin 0, ebx, esi, edi

	mov ebx, Param(4)

	mov eax, Param(0)
	test eax, eax
	jnz .next_0

	invoke_cdecl _AVLNewNode, Param(1), Param(2), Param(3), ebx
	jmp .end
.next_0:

	mov esi, eax
	invoke_cdecl [ebx + KeyCompareOps.on_compare], Param(1), [esi + AVLBST_Node.key]
	cmp eax, 0
	jz .equal
	jg .next_1

	invoke_cdecl _AVLInsertRecursive, [esi + AVLBST_Node.l_child], Param(1), Param(2), Param(3), ebx
	mov [esi + AVLBST_Node.l_child], eax

	jmp .next_2
.next_1:
	invoke_cdecl _AVLInsertRecursive, [esi + AVLBST_Node.r_child], Param(1), Param(2), Param(3), ebx
	mov [esi + AVLBST_Node.r_child], eax

.next_2:
	invoke_cdecl _AVLCalcHeight, esi
	invoke_cdecl _AVLRotate, esi
	jmp .end

.equal:
	mov edi, Param(3)
	invoke_cdecl edi, [esi + AVLBST_Node.userdata]
	mov eax, Param(2)
	mov [esi + AVLBST_Node.userdata], eax
	mov [esi + AVLBST_Node.on_free], edi
	mov [esi + AVLBST_Node.keyops], ebx

.finish:
	mov eax, esi

.end:
	FrameEnd
	ret

; int AVLInsert(AVLBST_Node **ppn, char *key, void *userdata, void(*on_free)(void *userdata), KeyCompareOps compops);
DefFunc _AVLInsert
	FrameBegin 0, esi

	mov eax, Param(0)
	test eax, eax
	jnz .next_0
.bad_param:
	int3
	jmp .bad_param
.next_0:
	mov esi, eax
	invoke_cdecl _AVLInsertRecursive, [esi], Param(1), Param(2), Param(3), Param(4)
	test eax, eax
	jz .end
	mov [esi], eax
	xor eax, eax
	inc eax
.end:
	FrameEnd
	ret

; AVLBST_Node* AVLRemoveRecursive(AVLBST_Node *n, char *key)
DefFunc _AVLRemoveRecursive
	FrameBegin 2, ebx, esi, edi

	mov eax, Param(0)
	test eax, eax
	jz .end

	mov ebx, [eax + AVLBST_Node.keyops]

	mov esi, eax
	invoke_cdecl [ebx + KeyCompareOps.on_compare], Param(1), [esi + AVLBST_Node.key]
	cmp eax, 0
	jz .equal
	jg .key_gt
	invoke_cdecl _AVLRemoveRecursive, [esi + AVLBST_Node.l_child], Param(1)
	mov [esi + AVLBST_Node.l_child], eax
	jmp .after_remove
.key_gt:
	invoke_cdecl _AVLRemoveRecursive, [esi + AVLBST_Node.r_child], Param(1)
	mov [esi + AVLBST_Node.r_child], eax
	jmp .after_remove
.equal:
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
	invoke_cdecl _AVLDestroyNode, esi
	mov esi, eax
	jmp .after_remove
.no_child:
	invoke_cdecl _AVLDestroyNode, esi
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
	xor eax, eax
	mov ecx, [edi + AVLBST_Node.userdata]
	mov Variable(0), ecx
	mov [edi + AVLBST_Node.userdata], eax
	invoke_cdecl _AVLKeyCopy, [edi + AVLBST_Node.key], [edi + AVLBST_Node.keyops]
	mov Variable(1), eax
	invoke_cdecl _AVLRemoveRecursive, [esi + AVLBST_Node.r_child], eax
	mov [esi + AVLBST_Node.r_child], eax
	mov eax, Variable(0)
	mov [esi + AVLBST_Node.userdata], eax
	invoke_cdecl _AVLKeyDelete, [esi + AVLBST_Node.key], [esi + AVLBST_Node.keyops]
	mov ecx, Variable(1)
	mov [esi + AVLBST_Node.key], ecx

.after_remove:
	invoke_cdecl _AVLCalcHeight, esi
	invoke_cdecl _AVLRotate, esi

.end:
	FrameEnd
	ret

; int AVLRemove(AVLBST_Node **ppn, char *key);
DefFunc _AVLRemove
	FrameBegin 0, esi


	mov eax, Param(0)
	test eax, eax
	jnz .next_1
.bad_param:
	int3
	jmp .bad_param
.next_1:
	mov esi, eax
	invoke_cdecl _AVLRemoveRecursive, [esi], Param(1)
	test eax, eax
	jz .end
	mov [esi], eax
	xor eax, eax
	inc eax
.end:
	FrameEnd
.return:
	ret


; AVLBST_Node* AVLSearch(AVLBST_Node *n, char *key);
DefFunc _AVLSearch
	FrameBegin 0, ebx, esi

	mov eax, Param(0)
	test eax, eax
	jz .end
	mov esi, eax
	mov ebx, [eax + AVLBST_Node.keyops]

.doloop:
	invoke_cdecl [ebx + KeyCompareOps.on_compare], Param(1), [esi + AVLBST_Node.key]
	cmp eax, 0
	jz .wend
	jl .lt
	mov esi, [esi + AVLBST_Node.r_child]
	jmp .while
.lt:
	mov esi, [esi + AVLBST_Node.l_child]
.while:
	test esi, esi
	jnz .doloop
.wend:
	mov eax, esi
.end:
	FrameEnd
	ret

; void AVLClearRecursive(AVLBST_Node *n);
DefFunc _AVLClearRecursive
	FrameBegin 0, ebx, esi, edi

	mov eax, Param(0)
	test eax, eax
	jz .end
	mov ebx, eax
	mov esi, [ebx + AVLBST_Node.l_child]
	mov edi, [ebx + AVLBST_Node.r_child]
	invoke_cdecl _AVLDestroyNode, ebx
	invoke_cdecl _AVLClearRecursive, esi
	invoke_cdecl _AVLClearRecursive, edi

.end:
	FrameEnd
	ret

; void AVLClear(AVLBST_Node **ppn);
DefFunc _AVLClear
	FrameBegin 0, esi

	mov esi, Param(0)
	invoke_cdecl _AVLClearRecursive, [esi]
	xor eax, eax
	mov [esi], eax

	FrameEnd
.return:
	ret

DefFunc _AVLDupStringKey
	FrameBegin 0
	invoke_dll_cdecl strlen, Param(0)
	inc eax
	invoke_cdecl _malloc, eax
	invoke_dll_cdecl strcpy, eax, Param(0)
	FrameEnd
	ret

DefFunc _AVLDupIntegerKey
	FrameBegin 0
	mov eax, Param(0)
	FrameEnd
	ret

DefFunc _AVLCmpStringKey
	FrameBegin 0
	invoke_dll_cdecl strcmp, Param(0), Param(1)
	FrameEnd
	ret

DefFunc _AVLCmpIntegerKey
	FrameBegin 0
	mov eax, Param(0)
	sub eax, Param(1)
	FrameEnd
	ret

DefFunc _AVLFreeStringKey
	FrameBegin 0
	invoke_cdecl _free, Param(0)
	FrameEnd
DefFunc _AVLFreeIntegerKey
	ret

segment .rdata
extern _AVLOps_String
_AVLOps_String:
istruc KeyCompareOps
	at .on_compare, dd _AVLCmpStringKey
	at .on_duplicate_key, dd _AVLDupStringKey
	at .on_free_key, dd _AVLFreeStringKey
iend

extern _AVLOps_Integer
_AVLOps_Integer:
istruc KeyCompareOps
	at .on_compare, dd _AVLCmpIntegerKey
	at .on_duplicate_key, dd _AVLDupIntegerKey
	at .on_free_key, dd _AVLFreeIntegerKey
iend
