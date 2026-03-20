%ifndef _VECTOR_INC_
%define _VECTOR_INC_ 1

struc Vector
	.pointer resd 1
	.num_items resd 1
	.capacity resd 1
	.size_of_item resd 1
	.on_new_item resd 1
	.on_del_item resd 1
	.on_copy_item resd 1
	.userdata resd 1
	.size equ $ - .pointer
endstruc

%endif
