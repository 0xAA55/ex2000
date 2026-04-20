%ifndef _AVLBST_INC_
%define _AVLBST_INC_ 1

%include "loaddll.inc"

struc AVLBST_Node
.key resd 1
.l_child resd 1
.r_child resd 1
.prev resd 1
.next resd 1
.height resd 1
.data_size resd 1
.head_size equ $ - AVLBST_Node
.data:
endstruc

%ifndef AVLBST_ASM
extern _AVLKeyCopy
extern _AVLKeyDelete
extern _AVLInsert
extern _AVLSearch
%endif

%endif
