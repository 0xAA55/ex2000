%include "loaddll.inc"
%include "avlbst.inc"

; void *AVLKeyCopy(void *key, KeyCompareOps compops);
DefFunc _AVLKeyCopy
	FrameBegin
	NameParams %$Key, %$CompOps
	mov eax, %$CompOps
	invoke_cdecl [eax + KeyCompareOps.on_duplicate_key], %$Key
	FrameEnd
	ret

; int _AVLKeyDelete(void *key, KeyCompareOps compops);
DefFunc _AVLKeyDelete
	FrameBegin
	NameParams %$Key, %$CompOps
	mov eax, %$CompOps
	invoke_cdecl [eax + KeyCompareOps.on_free_key], %$Key
	FrameEnd
	ret

; AVLBST_Node *AVLNewNode(void *key, void* userdata, void(*on_free)(void *userdata), KeyCompareOps compops);
DefFunc _AVLNewNode
	FrameBegin edi, ebx
	NameParams %$Key, %$Userdata, %$OnFree, %$CompOps

	mov ebx, %$CompOps

	invoke_cdecl _calloc, AVLBST_Node.size, 1
	mov edi, eax

	invoke_cdecl _AVLKeyCopy, %$Key, ebx
	mov [edi + AVLBST_Node.key], eax

	mov eax, %$Userdata
	mov ecx, %$OnFree
	mov edx, .ret_op
	test ecx, ecx
	cmovz ecx, edx
	mov [edi + AVLBST_Node.userdata], eax
	mov [edi + AVLBST_Node.on_free], ecx
	mov [edi + AVLBST_Node.keyops], ebx
	inc dword[edi + AVLBST_Node.height]

	mov eax, edi

	FrameEnd
.ret_op:
	ret

; void AVLDestroyNode(AVLBST_Node *node);
DefFunc _AVLDestroyNode
	FrameBegin ebx
	NameParams %$Node

	mov ebx, %$Node
	invoke_cdecl _AVLKeyDelete, [ebx + AVLBST_Node.key], [ebx + AVLBST_Node.keyops]
	invoke_cdecl [ebx + AVLBST_Node.on_free], [ebx + AVLBST_Node.userdata]
	invoke_cdecl _free, ebx

	FrameEnd
	ret

; int AVLHeight(AVLBST_Node *n);
DefFunc _AVLHeight
	FrameBegin
	NameParams %$Node

	mov eax, %$Node
	test eax, eax
	jz .end

	mov eax, [eax + AVLBST_Node.height]

.end:
	FrameEnd
	ret

; void AVLCalcHeight(AVLBST_Node *n);
DefFunc _AVLCalcHeight
	FrameBegin ebx, esi
	NameParams %$Node

	mov ebx, %$Node
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
	FrameBegin esi, edi
	NameParams %$Node

	mov esi, %$Node
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
	FrameBegin esi, edi
	NameParams %$Node

	mov edi, %$Node
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
	FrameBegin ebx, esi
	NameParams %$Node

	mov eax, %$Node
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
	FrameBegin esi
	NameParams %$Node

	mov esi, %$Node
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

; AVLBST_Node *AVLInsertRecursive(AVLBST_Node *n, char *key, void *userdata, void(*on_free)(void *userdata), KeyCompareOps compops, AVLBST_Node **pInserted);
DefFunc _AVLInsertRecursive
	FrameBegin ebx, esi, edi
	NameParams %$Node, %$Key, %$Userdata, %$OnFree, %$CompOps, %$PPInserted

	mov ebx, %$CompOps

	mov eax, %$Node
	test eax, eax
	jnz .next_0

	invoke_cdecl _AVLNewNode, %$Key, %$Userdata, %$OnFree, ebx
	; Save inserted node
	mov edx, %$PPInserted
	mov [edx], eax
	jmp .end
.next_0:

	mov esi, eax
	invoke_cdecl [ebx + KeyCompareOps.on_compare], %$Key, [esi + AVLBST_Node.key]
	cmp eax, 0
	jz .equal
	jg .next_1

	invoke_cdecl _AVLInsertRecursive, [esi + AVLBST_Node.l_child], %$Key, %$Userdata, %$OnFree, ebx, %$PPInserted
	mov [esi + AVLBST_Node.l_child], eax

	jmp .next_2
.next_1:
	invoke_cdecl _AVLInsertRecursive, [esi + AVLBST_Node.r_child], %$Key, %$Userdata, %$OnFree, ebx, %$PPInserted
	mov [esi + AVLBST_Node.r_child], eax

.next_2:
	invoke_cdecl _AVLCalcHeight, esi
	invoke_cdecl _AVLRotate, esi
	jmp .end

.equal:
	invoke_cdecl [esi + AVLBST_Node.on_free], [esi + AVLBST_Node.userdata]
	mov eax, %$Userdata
	mov ecx, %$OnFree
	mov [esi + AVLBST_Node.userdata], eax
	mov [esi + AVLBST_Node.on_free], ecx
	; Save existing node as the inserted node
	mov edx, %$PPInserted
	mov [edx], esi

.finish:
	mov eax, esi

.end:
	FrameEnd
	ret

; AVLBST_Node* AVLInsert(AVLBST_Node **ppn, char *key, void *userdata, void(*on_free)(void *userdata), KeyCompareOps compops);
DefFunc _AVLInsert
	FrameBegin esi
	NameParams %$PPNode, %$Key, %$Userdata, %$OnFree, %$CompOps
	DefVars %$Found

	mov eax, %$PPNode
	test eax, eax
	jnz .next_0
.bad_param:
	int3
	jmp .bad_param
.next_0:
	mov esi, eax
	mov eax, %$OnFree
	mov ecx, .ret_op
	test eax, eax
	cmovz eax, ecx
	invoke_cdecl _AVLInsertRecursive, [esi], %$Key, %$Userdata, eax, %$CompOps, & %$Found
	test eax, eax
	jz .end
	mov [esi], eax
	mov eax, %$Found
.end:
	FrameEnd
.ret_op:
	ret

; AVLBST_Node* AVLRemoveRecursive(AVLBST_Node *n, char *key, int *found)
DefFunc _AVLRemoveRecursive
	FrameBegin ebx, esi, edi
	NameParams %$Node, %$Key, %$PFound
	DefVars %$KeyBackup, %$Userdata

	mov eax, %$Node
	test eax, eax
	jz .end

	mov ebx, [eax + AVLBST_Node.keyops]

	mov esi, eax
	invoke_cdecl [ebx + KeyCompareOps.on_compare], %$Key, [esi + AVLBST_Node.key]
	cmp eax, 0
	jz .equal
	jg .key_gt
	invoke_cdecl _AVLRemoveRecursive, [esi + AVLBST_Node.l_child], %$Key, %$PFound
	mov [esi + AVLBST_Node.l_child], eax
	jmp .after_remove
.key_gt:
	invoke_cdecl _AVLRemoveRecursive, [esi + AVLBST_Node.r_child], %$Key, %$PFound
	mov [esi + AVLBST_Node.r_child], eax
	jmp .after_remove
.equal:
	mov eax, %$PFound
	mov byte[eax], 1

	mov eax, [esi + AVLBST_Node.l_child]
	test eax, eax
	jz .no_lchild
	mov eax, [esi + AVLBST_Node.r_child]
	test eax, eax
	jz .no_rchild
	jmp .2child
.no_lchild:
	mov eax, [esi + AVLBST_Node.r_child]
	test eax, eax
	jz .no_child
	jmp .get_child
.no_rchild:
	mov eax, [esi + AVLBST_Node.l_child]
.get_child:
	mov ebx, eax
	invoke_cdecl _AVLDestroyNode, esi
	mov esi, ebx
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
	mov %$Userdata, ecx
	mov [edi + AVLBST_Node.userdata], eax
	invoke_cdecl _AVLKeyCopy, [edi + AVLBST_Node.key], [edi + AVLBST_Node.keyops]
	mov %$KeyBackup, eax
	invoke_cdecl _AVLRemoveRecursive, [esi + AVLBST_Node.r_child], eax, %$PFound
	mov [esi + AVLBST_Node.r_child], eax
	invoke_cdecl [esi + AVLBST_Node.on_free], [esi + AVLBST_Node.userdata]
	mov eax, %$Userdata
	mov [esi + AVLBST_Node.userdata], eax
	invoke_cdecl _AVLKeyDelete, [esi + AVLBST_Node.key], [esi + AVLBST_Node.keyops]
	mov ecx, %$KeyBackup
	mov [esi + AVLBST_Node.key], ecx

.after_remove:
	invoke_cdecl _AVLCalcHeight, esi
	invoke_cdecl _AVLRotate, esi

.end:
	FrameEnd
	ret

; int AVLRemove(AVLBST_Node **ppn, char *key);
DefFunc _AVLRemove
	FrameBegin esi
	NameParams %$PPNode, %$Key
	DefVars %$Found

	xor eax, eax
	mov %$Found, eax

	mov eax, %$PPNode
	test eax, eax
	jnz .next_1
.bad_param:
	int3
	jmp .bad_param
.next_1:
	mov esi, eax
	invoke_cdecl _AVLRemoveRecursive, [esi], %$Key, & %$Found
	mov [esi], eax
	mov eax, %$Found
	FrameEnd
.return:
	ret

; void AVLIterate(AVLBST_Node *root, void *context, void(on_iter)(void *key, void *userdata, void *context));
DefFunc _AVLIterate
	FrameBegin ebx, esi, edi
	NameParams %$Root, %$Context, %$OnIter

	mov ebx, %$Root
	test ebx, ebx
	jz .end

	mov esi, %$Context
	mov edi, %$OnIter

	invoke_cdecl _AVLIterate, [ebx + AVLBST_Node.l_child], esi, edi
	invoke_cdecl edi, [ebx + AVLBST_Node.key], [ebx + AVLBST_Node.userdata], esi
	invoke_cdecl _AVLIterate, [ebx + AVLBST_Node.r_child], esi, edi

.end:
	FrameEnd
	ret

; AVLBST_Node* AVLSearch(AVLBST_Node *n, char *key);
DefFunc _AVLSearch
	FrameBegin ebx, esi
	NameParams %$Node, %$Key

	mov eax, %$Node
	test eax, eax
	jz .end
	mov esi, eax
	mov ebx, [eax + AVLBST_Node.keyops]

.doloop:
	invoke_cdecl [ebx + KeyCompareOps.on_compare], %$Key, [esi + AVLBST_Node.key]
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
	FrameBegin ebx, esi, edi
	NameParams %$Node

	mov eax, %$Node
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
	FrameBegin esi
	NameParams %$PPNode

	mov esi, %$PPNode
	invoke_cdecl _AVLClearRecursive, [esi]
	xor eax, eax
	mov [esi], eax

	FrameEnd
.return:
	ret

; AVLBST_Node *AVLBST_Min(AVLBST_Node *root);
DefFunc _AVLBST_Min
	FrameBegin
	NameParams %$Root

	mov eax, %$Root
	test eax, eax
	jz .end

.loop_left:
	mov ecx, [eax + AVLBST_Node.l_child]
	test ecx, ecx
	cmovnz eax, ecx
	jnz .loop_left

.end:
	FrameEnd
	ret

DefFunc _AVLDupStringKey
	FrameBegin
	NameParams %$Key
	invoke_dll_cdecl strlen, %$Key
	inc eax
	invoke_cdecl _malloc, eax
	invoke_dll_cdecl strcpy, eax, %$Key
	FrameEnd
	ret

DefFunc _AVLDupIntegerKey
	FrameBegin
	NameParams %$Key
	mov eax, %$Key
	FrameEnd
	ret

DefFunc _AVLCmpStringKey
	FrameBegin
	NameParams %$Key1, %$Key2
	invoke_dll_cdecl strcmp, %$Key1, %$Key2
	FrameEnd
	ret

DefFunc _AVLCmpIntegerKey
	FrameBegin
	NameParams %$Key1, %$Key2
	mov eax, %$Key1
	sub eax, %$Key2
	FrameEnd
	ret

DefFunc _AVLFreeStringKey
	FrameBegin
	NameParams %$Key
	invoke_cdecl _free, %$Key
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

DefFunc _Get_AVLOps_String
	mov eax, _AVLOps_String
	ret

DefFunc _Get_AVLOps_Integer
	mov eax, _AVLOps_Integer
	ret
