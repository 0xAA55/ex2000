%ifndef _AVLBST_INC_
%define _AVLBST_INC_ 1

;typedef struct KeyCompareOps_s
;{
;	int (*on_compare)(void *key1, void *key2);
;	void *(*on_duplicate_key)(void *key);
;	void (*on_free_key)(void *key);
;} KeyCompareOps;
struc KeyCompareOps
	.on_compare resd 1
	.on_duplicate_key resd 1
	.on_free_key resd 1
	.size equ $ - KeyCompareOps
endstruc

struc AVLBST_Node
	.key resd 1
	.l_child resd 1
	.r_child resd 1
	.height resd 1
	.userdata resd 1
	.on_free resd 1 ;void(*on_free)(void *userdata)
	.keyops resd 1
	.size equ $ - AVLBST_Node
endstruc

; AVLBST_Node* AVLInsert(AVLBST_Node **ppn, void *key, void *userdata, void(*on_free)(void *userdata), KeyCompareOps *compops);
; Returns the inserted node (new or existing) or NULL on failure.
; The key will be duplicated and `AVLBST_Node` owns the key.
; If key is already exist, free `userdata` and replace with new data
; if `ppn` is NULL, the function triggers int3 infinitely
extern _AVLInsert

; AVLBST_Node* AVLSearch(AVLBST_Node *n, void *key);
extern _AVLSearch

; int AVLRemove(AVLBST_Node **ppn, void *key);
; `node->userdata` is auto freed by `on_free()`
; `node->key` is auto freed by `keyops->on_free_key()`
extern _AVLRemove

; void AVLClear(AVLBST_Node **ppn);
extern _AVLClear

; AVLBST_Node *AVLBST_Min(AVLBST_Node *root);
extern _AVLBST_Min

extern _AVLOps_String
extern _AVLOps_Integer

; All of the `on_free()` or `on_free_key()` allows `NULL` to be used

%endif
