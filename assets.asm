%include "avlbst.inc"
%define ASSETS_ASM 1
%include "assets.inc"

extern _calloc
extern _malloc
extern _realloc
extern _free

import_dll_func strlen
import_dll_func strcpy
import_dll_func strcmp
import_dll_func memset
import_dll_func memcpy

dll_func_group_start CabinetFunc
def_dll_func FDICreate
def_dll_func FDICopy
def_dll_func FDIDestroy
dll_func_group_end CabinetFunc

struc FileStruct
.file_pointer resd 1
.opened resd 1
.file_size resd 1
.file_capacity resd 1
.data resd 1
.size equ $ - FileStruct
endstruc

struc FDINOTIFICATION
.cb resd 1
.psz1 resd 1
.psz2 resd 1
.psz3 resd 1
.pv resd 1
.hf resd 1
.date resw 1
.time resw 1
.attrib resw 1
.set_id resw 1
.i_cabinet resw 1
.i_folder resw 1
.fdie resd 1
endstruc

%define FDIERROR_NONE 0
%define FDIERROR_CABINET_NOT_FOUND 1
%define FDIERROR_NOT_A_CABINET 2
%define FDIERROR_UNKNOWN_CABINET_VERSION 3
%define FDIERROR_CORRUPT_CABINET 4
%define FDIERROR_ALLOC_FAIL 5
%define FDIERROR_BAD_COMPR_TYPE 6
%define FDIERROR_MDI_FAIL 7
%define FDIERROR_TARGET_FILE 8
%define FDIERROR_RESERVE_MISMATCH 9
%define FDIERROR_WRONG_CABINET 10
%define FDIERROR_USER_ABORT 11
%define FDIERROR_EOF 12

%define MAX_CAB_OPEN_TIMES 4

segment .bss
global _AssetsCabPathName
_AssetsCabPathName resd 1
global _AssetsTree
_AssetsTree resd 1
global _AssetsCabFile
_AssetsCabFile:
.file_pointers resd MAX_CAB_OPEN_TIMES
.is_opened resb MAX_CAB_OPEN_TIMES
global _AssetsFDIERF
_AssetsFDIERF:
.oper resd 1
.type resd 1
.error resd 1

segment .rdata
global _AssetsCab
_AssetsCab:
incbin "out/assets.cab"
_AssetsCabSize equ $ - _AssetsCab
global _AssetsCabName
_AssetsCabName db "assets.cab", 0

segment .text
DefFunc _AssetsInitLoadDll
	FrameBegin 0, 0
	def_dll_and_load Cabinet, "cabinet.dll"
	dll_func_group_load Cabinet, CabinetFunc
	FrameEnd
	ret

DefFunc _AssetsFnOpen
	FrameBegin 0, 3, esi

	invoke_dll_cdecl strcmp, Param(0), _AssetsCabName
	test eax, eax
	jz .is_cab_file

	invoke_cdecl _AVLSearch, [_AssetsTree], Param(0)
	test eax, eax
	jnz .found

	invoke_cdecl _calloc, 1, FileStruct.size
	mov esi, eax
	mov [esi + FileStruct.opened], eax

	invoke_cdecl _AVLInsert, _AssetsTree, Param(0), esi
	mov eax, esi
	jmp .end
.found:
	xor edx, edx
	mov eax, [eax + AVLBST_Node.userdata]
	cmp [eax + FileStruct.opened], edx
	jnz .already_opened
	inc dword [eax + FileStruct.opened]
	mov [eax + FileStruct.file_pointer], edx
	push eax
	pop eax
	jmp .end
.already_opened:
.opened_too_many:
	int3
	jmp .already_opened
.is_cab_file:
	lea esi, [_AssetsCabFile.is_opened]
	mov ecx, MAX_CAB_OPEN_TIMES
	xor edx, edx
.next_file:
	lodsb
	test al, al
	jz .found_file
	inc edx
	loop .next_file
	jmp .opened_too_many
.found_file:
	xor eax, eax
	mov [_AssetsCabFile.file_pointers + edx * 4], eax
	inc al
	mov [_AssetsCabFile.is_opened + edx], al
	mov eax, edx
	inc eax
	jmp .end

.end:
	FrameEnd
	ret

DefFunc _AssetsTrimFileMemory
	FrameBegin 0, 2, esi

	mov esi, Param(0)
	mov eax, [esi + FileStruct.file_size]
	test eax, eax
	jz .is_empty_file
	inc eax ; Keep one extra byte for string assets
	cmp eax, [esi + FileStruct.file_capacity]
	jz .end

	mov [esi + FileStruct.file_capacity], eax
	invoke_cdecl _realloc, [esi + FileStruct.data], eax
	test eax, eax
	jz .fail_exit
	mov [esi + FileStruct.data], eax
	mov eax, [esi + FileStruct.data]
	add eax, [esi + FileStruct.file_size]
	mov byte [eax], 0
	jmp .end
.fail_exit:
	int3
	jmp .fail_exit
.is_empty_file:
	invoke_cdecl _free, [esi + FileStruct.data]
	invoke_cdecl _calloc, 1, 1
	mov [esi + FileStruct.data], eax
	xor eax, eax
	mov [esi + FileStruct.file_size], eax
	inc eax
	mov [esi + FileStruct.file_capacity], eax

.end:
	FrameEnd
	ret

DefFunc _AssetsAssertFileIsOpened
	FrameBegin 0, 0

	mov eax, Param(0)
	test eax, eax
	jz .is_bad_condition
	cmp eax, MAX_CAB_OPEN_TIMES
	jle .is_cab_file
	cmp dword [eax + FileStruct.opened], 0
	jnz .end
.is_bad_condition:
	int3
	jmp .is_bad_condition

.is_cab_file:
	dec eax
	mov al, [_AssetsCabFile.is_opened + eax]
	test al, al
	jz .is_bad_condition

.end:
	FrameEnd
	ret

DefFunc _AssetsFnClose
	FrameBegin 0, 1, esi

	mov esi, Param(0)
	invoke_cdecl _AssetsAssertFileIsOpened, esi
	cmp esi, MAX_CAB_OPEN_TIMES
	jle .is_cab_file
	invoke_cdecl _AssetsTrimFileMemory, esi
	xor eax, eax
	mov [esi + FileStruct.opened], eax
	mov [esi + FileStruct.file_pointer], eax
	jmp .end
.is_cab_file:
	xor eax, eax
	dec esi
	mov [_AssetsCabFile.file_pointers + esi * 4], eax
	mov [_AssetsCabFile.is_opened + esi], al

.is_null_file:
.end:
	FrameEnd
	ret

DefFunc _AssetsFnRead
	FrameBegin 0, 3, esi

	mov esi, Param(0)
	invoke_cdecl _AssetsAssertFileIsOpened, esi
	cmp esi, MAX_CAB_OPEN_TIMES
	jle .is_cab_file

	mov eax, [esi + FileStruct.file_size]
	sub eax, [esi + FileStruct.file_pointer]
	jle .eof
	mov edx, Param(2)
	cmp eax, edx
	jle .proceed_file
	mov eax, edx
.proceed_file:
	mov Param(2), eax
	mov eax, [esi + FileStruct.data]
	add eax, Param(2)
	invoke_dll_cdecl memcpy, Param(1), eax, Param(2)
	mov eax, Param(2)
	add [esi + FileStruct.file_pointer], eax
	jmp .end

.is_cab_file:
	lea esi, [_AssetsCabFile.file_pointers + (esi - 1) * 4]
	mov eax, _AssetsCabSize
	sub eax, [esi]
	jle .eof
	mov edx, Param(2)
	cmp eax, edx
	jle .proceed_cab
	mov eax, edx
.proceed_cab:
	mov Param(2), eax
	mov eax, _AssetsCab
	add eax, [esi]
	invoke_dll_cdecl memcpy, Param(1), eax, Param(2)
	mov eax, Param(2)
	add [esi], eax
	jmp .end
.eof:
	xor eax, eax
	dec eax

.end:
	FrameEnd
	ret

; int AssetsFileGrowCapacity(FileStruct *f, size_t desired_minimal_capacity)
DefFunc _AssetsFileGrowCapacity
	FrameBegin 1, 3, esi

	mov esi, Param(0)
	mov eax, [esi + FileStruct.file_capacity]
	mov ecx, 2
	mov edx, ecx
	inc edx
	mul edx
	div ecx
	inc eax
	cmp eax, Param(1)
	jge .enough_size
	mov eax, Param(1)
.enough_size:
	mov Variable(0), eax
	invoke_cdecl _realloc, [esi + FileStruct.data], eax
	test eax, eax
	jz .failed
	mov [esi + FileStruct.data], eax
	mov ecx, Variable(0)
	add eax, [esi + FileStruct.file_capacity]
	sub ecx, [esi + FileStruct.file_capacity]
	jz .cleared
	invoke_dll_cdecl memset, eax, 0, ecx
.cleared:
	mov eax, Variable(0)
	mov [esi + FileStruct.file_capacity], eax
	jmp .end
.failed:
	invoke_cdecl _free, [esi + FileStruct.data]
	xor eax, eax
	mov [esi + FileStruct.data], eax
	mov [esi + FileStruct.file_size], eax
	mov [esi + FileStruct.file_capacity], eax

.end:
	FrameEnd
	ret

DefFunc _AssetsFnWrite
	FrameBegin 0, 3, esi

	mov esi, Param(0)
	invoke_cdecl _AssetsAssertFileIsOpened, esi
	cmp esi, MAX_CAB_OPEN_TIMES
	jle .is_cab_file

	mov eax, [esi + FileStruct.file_pointer]
	add eax, Param(2)
	cmp eax, [esi + FileStruct.file_capacity]
	jle .good_capacity
	invoke_cdecl _AssetsFileGrowCapacity, esi, eax
	test eax, eax
	jz .grow_fail
.good_capacity:
	mov eax, [esi + FileStruct.data]
	add eax, [esi + FileStruct.file_pointer]
	invoke_dll_cdecl memcpy, eax, Param(1), Param(2)
	mov eax, [esi + FileStruct.file_pointer]
	add eax, Param(2)
	mov [esi + FileStruct.file_pointer], eax
	cmp eax, [esi + FileStruct.file_size]
	jle .end
	mov [esi + FileStruct.file_size], eax
	mov eax, Param(2)
	jmp .end
.is_cab_file:
.grow_fail:
	int3
	jmp .is_cab_file

.end:
	FrameEnd
	ret

DefFunc _AssetsFnSeek
	FrameBegin 0, 1, esi

	mov esi, Param(0)
	invoke_cdecl _AssetsAssertFileIsOpened, esi
	cmp esi, MAX_CAB_OPEN_TIMES
	jle .is_cab_file

	mov eax, Param(2)
	cmp eax, 0
	jz .seek_set
	cmp eax, 1
	jz .seek_cur
	cmp eax, 2
	jz .seek_end
.bad_seek:
	int3
	jmp .bad_seek
.seek_set:
	mov eax, Param(1)
	mov [esi + FileStruct.file_pointer], eax
	jmp .end
.seek_cur:
	mov eax, [esi + FileStruct.file_pointer]
	add eax, Param(1)
	mov [esi + FileStruct.file_pointer], eax
	jmp .end
.seek_end:
	mov eax, [esi + FileStruct.file_size]
	add eax, Param(1)
	mov [esi + FileStruct.file_pointer], eax
	jmp .end
.is_null_file:
	int3
	jmp .is_null_file

.is_cab_file:
	lea esi, [_AssetsCabFile.file_pointers + (esi - 1) * 4]
	mov eax, Param(2)
	cmp eax, 0
	jz .cab_seek_set
	cmp eax, 1
	jz .cab_seek_cur
	cmp eax, 2
	jz .cab_seek_end
.cab_bad_seek:
	int3
	jmp .cab_bad_seek
.cab_seek_set:
	mov eax, Param(1)
	mov [esi], eax
	jmp .end
.cab_seek_cur:
	mov eax, [esi]
	add eax, Param(1)
	mov [esi], eax
	jmp .end
.cab_seek_end:
	mov eax, _AssetsCabSize
	add eax, Param(1)
	mov [esi], eax

.end:
	FrameEnd
	ret

DefFunc _AssetsFnOnNotify
	FrameBegin 0, 1, esi

	mov eax, Param(0)
	mov esi, Param(1)
	cmp eax, 0
	jz .cab_info
	cmp eax, 1
	jz .partial_file
	cmp eax, 2
	jz .copy_file
	cmp eax, 3
	jz .close_file
	cmp eax, 4
	jz .next_cab
	cmp eax, 5
	jz .enumerate
.bad_call:
	xor eax, eax
	dec eax
	jmp .end

.copy_file:
	invoke_cdecl _AssetsFnOpen, [esi + FDINOTIFICATION.psz1]
	jmp .end
.close_file:
	invoke_cdecl _AssetsFnClose, [esi + FDINOTIFICATION.hf]
	inc eax
	jmp .end
.enumerate:
.cab_info:
.partial_file:
.next_cab:
	xor eax, eax
.end:
	FrameEnd
	ret

;DefFunc _AssetsShow
;	FrameBegin 0, 1, esi
;
;	mov esi, Param(0)
;	test esi, esi
;	jz .end
;	debug_msg "key: %s, height: %d", [esi + AVLBST_Node.key], [esi + AVLBST_Node.height]
;
;	invoke_cdecl _AssetsShow, [esi + AVLBST_Node.l_child]
;	invoke_cdecl _AssetsShow, [esi + AVLBST_Node.r_child]
;
;.end:
;	FrameEnd
;	ret

DefFunc _AssetsInit
	FrameBegin 1, 9

	invoke_cdecl _AssetsInitLoadDll

	invoke_dll_cdecl FDICreate, _malloc, _free, _AssetsFnOpen, _AssetsFnRead, _AssetsFnWrite, _AssetsFnClose, _AssetsFnSeek, -1, _AssetsFDIERF
	mov Variable(0), eax

	invoke_dll_cdecl FDICopy, Variable(0), _AssetsCabName, _AssetsCabPathName, 0, _AssetsFnOnNotify, 0, 0
	test eax, eax
	jnz .noerror
	debug_msg "ERF: oper: %d, type: %d, error: %d", [_AssetsFDIERF.oper], [_AssetsFDIERF.type], [_AssetsFDIERF.error]
.noerror:
	invoke_dll_cdecl FDIDestroy, Variable(0)

	;invoke_cdecl _AssetsShow, [_AssetsTree]

	mov eax, [_AssetsFDIERF.error]
	FrameEnd
	ret

DefFunc _AssetsQuery
	FrameBegin 0, 2

	invoke_cdecl _AVLSearch, [_AssetsTree], Param(0)
	test eax, eax
	jz .end
	mov eax, [eax + AVLBST_Node.userdata]

	mov edx, Param(1)
	test edx, edx
	jz .return_ptr
	mov ecx, [eax + FileStruct.file_size]
	mov [edx], ecx
.return_ptr:
	mov eax, [eax + FileStruct.data]

.end:
	FrameEnd
	ret
