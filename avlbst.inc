%ifndef _AVLBST_INC_
%define _AVLBST_INC_ 1

%include "loaddll.inc"

struc AVLBST_Node
.key resd 1
.l_child resd 1
.r_child resd 1
.height resd 1
.userdata resd 1
.size equ $ - AVLBST_Node
endstruc

%ifndef AVLBST_ASM
extern _AVLKeyCopy
extern _AVLKeyDelete

; int AVLInsert(AVLBST_Node **ppn, char *key, void *userdata);
extern _AVLInsert

; AVLBST_Node* AVLSearch(AVLBST_Node *n, char *key);
extern _AVLSearch

; int AVLRemove(AVLBST_Node **ppn, char *key, void(*on_free)(void *userdata));
extern _AVLRemove

; void AVLClear(AVLBST_Node **ppn, void(*on_free)(void *userdata));
extern _AVLClear
%endif

%endif
