%include "loaddll.inc"
%include "avlbst.inc"
%include "lfu.inc"

struc FreqKey
	.freq resd 1
	.data_key resd 1 ;Not owned
	.data_keyops resd 1 ;Comparison
	.size equ $ - FreqKey
endstruc

struc DataNode
	.freq resd 1
	.userdata resd 1
	.on_free resd 1
	.size equ $ - DataNode
endstruc

; void FreeDataNode(DataNode *dn);
DefFunc _FreeDataNode
	FrameBegin 0, ebx

	mov ebx, Param(0)
	test ebx, ebx
	jz .end
	invoke_cdecl [ebx + DataNode.on_free], [ebx + DataNode.userdata]
	invoke_cdecl _free, ebx
.end:
	FrameEnd
	ret

; LfuCache *LfuCreate(int capacity, KeyCompareOps *user_ops);
DefFunc _LfuCreate
	FrameBegin 0, ebx

	invoke_cdecl _calloc, 1, LfuCache.size
	mov ebx, eax

	mov eax, Param(0)
	mov ecx, Param(1)
	mov [ebx + LfuCache.capacity], eax
	mov [ebx + LfuCache.user_keyops], ecx
	jecxz .bad

	mov eax, ebx
	FrameEnd
	ret
.bad:
	int3
	jmp .bad

; void LfuIncreaseFreq(LfuCache *cache, void *user_key, DataNode *dn);
DefFunc _LfuIncreaseFreq
	FrameBegin FreqKey.size / 4, ebx, esi, edi
	AssignVars _FreqKey

	mov ebx, Param(0)
	mov esi, Param(2)
	lea edi, _FreqKey

	mov eax, [esi + DataNode.freq]
	mov ecx, Param(1)
	mov edx, [ebx + LfuCache.user_keyops]
	mov [edi + FreqKey.freq], eax
	mov [edi + FreqKey.data_key], ecx
	mov [edi + FreqKey.data_keyops], edx
	invoke_cdecl _AVLRemove, &[ebx + LfuCache.freq_tree], edi

	inc dword[esi + DataNode.freq]

	mov eax, [esi + DataNode.freq]
	mov ecx, Param(1)
	mov edx, [ebx + LfuCache.user_keyops]
	mov [edi + FreqKey.freq], eax
	mov [edi + FreqKey.data_key], ecx
	mov [edi + FreqKey.data_keyops], edx
	invoke_cdecl _AVLInsert, &[ebx + LfuCache.freq_tree], edi, NULL, NULL, _FreqKeyOps

	FrameEnd
	ret
	%undef _FreqKey

; void* LfuGet(LfuCache *cache, void *key);
DefFunc _LfuGet
	FrameBegin 0, ebx, esi

	mov eax, Param(0)
	test eax, eax
	jz .end
	mov ebx, eax
	invoke_cdecl _AVLSearch, [ebx + LfuCache.data_tree], Param(1)
	test eax, eax
	jz .end
	mov esi, [eax + AVLBST_Node.userdata]
	invoke_cdecl _LfuIncreaseFreq, ebx, [eax + AVLBST_Node.key], esi
	mov eax, [esi + DataNode.userdata]
.end:
	FrameEnd
	ret

; void LfuPut(LfuCache *cache, void *key, void *value, void(*on_free)(void *userdata));
DefFunc _LfuPut
	FrameBegin FreqKey.size / 4, ebx, esi, edi
	AssignVars _FreqKey

	mov eax, Param(3)
	mov ecx, .ret_op
	test eax, eax
	cmovz eax, ecx
	mov Param(3), eax

	mov eax, Param(0)
	test eax, eax
	jz .end
	mov ebx, eax
	mov eax, [eax + LfuCache.capacity]
	test eax, eax
	jz .end
	invoke_cdecl _AVLSearch, [ebx + LfuCache.data_tree], Param(1)
	test eax, eax
	jz .insert
	mov esi, [eax + AVLBST_Node.userdata]
	mov edi, [eax + AVLBST_Node.key]
	invoke_cdecl [esi + DataNode.on_free], [esi + DataNode.userdata]
	mov eax, Param(2)
	mov ecx, Param(3)
	mov [esi + DataNode.userdata], eax
	mov [esi + DataNode.on_free], ecx
	invoke_cdecl _LfuIncreaseFreq, ebx, edi, esi
	jmp .end
.insert:
	mov eax, [ebx + LfuCache.current_size]
	cmp eax, [ebx + LfuCache.capacity]
	jb .after_removal

	invoke_cdecl _AVLBST_Min, [ebx + LfuCache.freq_tree]
	test eax, eax
	jnz .good
.bad:
	int3
	jmp .bad
.good:
	mov esi, [eax + AVLBST_Node.key]
	lea edi, _FreqKey
	mov eax, [esi + FreqKey.freq]
	mov ecx, [esi + FreqKey.data_key]
	mov edx, [ebx + LfuCache.user_keyops]
	mov [edi + FreqKey.freq], eax
	mov [edi + FreqKey.data_key], ecx
	mov [edi + FreqKey.data_keyops], edx

	invoke_cdecl _AVLRemove, &[ebx + LfuCache.freq_tree], edi
	invoke_cdecl _AVLRemove, &[ebx + LfuCache.data_tree], [edi + FreqKey.data_key]

	dec dword[ebx + LfuCache.current_size]

.after_removal:
	invoke_cdecl _malloc, DataNode.size
	mov esi, eax
	mov eax, Param(2)
	mov ecx, Param(3)
	mov dword[esi + DataNode.freq], 1
	mov [esi + DataNode.userdata], eax
	mov [esi + DataNode.on_free], ecx

	invoke_cdecl _AVLInsert, &[ebx + LfuCache.data_tree], Param(1), esi, _FreeDataNode, [ebx + LfuCache.user_keyops]
	test eax, eax
	jz .bad
	lea edi, _FreqKey
	mov eax, [eax + AVLBST_Node.key]
	mov ecx, [ebx + LfuCache.user_keyops]
	mov dword[edi + FreqKey.freq], 1
	mov [edi + FreqKey.data_key], eax
	mov [edi + FreqKey.data_keyops], ecx
	invoke_cdecl _AVLInsert, &[ebx + LfuCache.freq_tree], edi, NULL, NULL, _FreqKeyOps
	inc dword[ebx + LfuCache.current_size]

.end:
	FrameEnd
.ret_op:
	ret
	%undef _FreqKey

; void LfuDestroy(LfuCache *cache)
DefFunc _LfuDestroy
	FrameBegin 0, ebx

	mov ebx, Param(0)
	test ebx, ebx
	jz .end

	invoke_cdecl _AVLClear, &[ebx + LfuCache.freq_tree]
	invoke_cdecl _AVLClear, &[ebx + LfuCache.data_tree]
	invoke_cdecl _free, ebx

.end:
	FrameEnd
	ret

; int FreqKeyCompare(FreqKey *a, FreqKey *b);
DefFunc _FreqKeyCompare
	FrameBegin 0, esi, edi

	mov esi, Param(0)
	mov edi, Param(1)

	xor eax, eax
	mov ecx, [esi + FreqKey.freq]
	cmp ecx, [edi + FreqKey.freq]
	jl .lt
	jg .gt

	mov eax, [esi + FreqKey.data_keyops]
	invoke_cdecl [eax + KeyCompareOps.on_compare], [esi + FreqKey.data_key], [edi + FreqKey.data_key]

	jmp .end
.lt:
	dec eax
	jmp .end
.gt:
	inc eax
.end:
	FrameEnd
	ret

; FreqKey *FreqKeyDuplicate(FreqKey *key);
DefFunc _FreqKeyDuplicate
	FrameBegin 0, esi, edi

	mov esi, Param(0)
	invoke_cdecl _malloc, FreqKey.size
	mov edi, eax

	mov eax, [esi + FreqKey.freq]
	mov ecx, [esi + FreqKey.data_key]
	mov edx, [esi + FreqKey.data_keyops]
	mov [edi + FreqKey.freq], eax
	mov [edi + FreqKey.data_key], ecx
	mov [edi + FreqKey.data_keyops], edx

	mov eax, edi
	FrameEnd
	ret

; void FreqKeyFree(FreqKey *key);
DefFunc _FreqKeyFree
	jmp _free

segment .rdata
extern _FreqKeyOps
_FreqKeyOps:
istruc KeyCompareOps
	at .on_compare, dd _FreqKeyCompare
	at .on_duplicate_key, dd _FreqKeyDuplicate
	at .on_free_key, dd _FreqKeyFree
iend
