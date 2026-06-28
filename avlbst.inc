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
	.keyops resb KeyCompareOps.size
	.size equ $ - AVLBST_Node
endstruc

extern _AVLKeyCopy
extern _AVLKeyDelete

; int AVLInsert(AVLBST_Node **ppn, void *key, void *userdata, void(*on_free)(void *userdata), KeyCompareOps compops);
extern _AVLInsert

; AVLBST_Node* AVLSearch(AVLBST_Node *n, void *key);
extern _AVLSearch

; int AVLRemove(AVLBST_Node **ppn, void *key);
extern _AVLRemove

; void AVLClear(AVLBST_Node **ppn);
extern _AVLClear

extern _AVLOps_String
extern _AVLOps_Integer

%endif
