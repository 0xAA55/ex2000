%include "avlbst.inc"
%define ASSETS_ASM 1
%include "assets.inc"

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

segment .bss
global _AssetsCabPathName
_AssetsCabPathName resd 1
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
global _AssetsInit
_AssetsInit:
	FrameBegin 0, 0
	def_dll_and_load Cabinet, "cabinet.dll"
	dll_func_group_load Cabinet, CabinetFunc
	FrameEnd
	ret



