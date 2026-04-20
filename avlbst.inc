%ifndef _AVLBST_INC_
%define _AVLBST_INC_ 1

%include "loaddll.inc"

struc AVLBST_Node
.key resd 1
.l_child resd 1
.r_child resd 1
.prev resd 1
.next resd 1
.data:
endstruc

%ifndef AVLBST_ASM
extern _AVLKeyCopy
extern _AVLKeyDelete
extern _AVLInsert
%endif

%endif
