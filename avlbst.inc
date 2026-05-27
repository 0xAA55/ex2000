%ifndef _AVLBST_INC_
%define _AVLBST_INC_ 1

struc AVLBST_Node
.key resd 1
.l_child resd 1
.r_child resd 1
.height resd 1
.userdata resd 1
.on_free resd 1 ;void(*on_free)(void *userdata)
.size equ $ - AVLBST_Node
endstruc

extern _AVLKeyCopy
extern _AVLKeyDelete

; int AVLInsert(AVLBST_Node **ppn, char *key, void *userdata, void(*on_free)(void *userdata));
extern _AVLInsert

; AVLBST_Node* AVLSearch(AVLBST_Node *n, char *key);
extern _AVLSearch

; int AVLRemove(AVLBST_Node **ppn, char *key);
extern _AVLRemove

; void AVLClear(AVLBST_Node **ppn);
extern _AVLClear

%endif
