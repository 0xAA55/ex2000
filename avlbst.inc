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
extern _AVLInsert
extern _AVLSearch
extern _AVLRemove
extern _AVLClear
%endif

%endif
