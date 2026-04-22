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

segment .bss
global _AssetsCabPathName
_AssetsCabPathName resd 1
global _AssetsCabFile
_AssetsCabFile:
.file_pointer resd 1
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
global _AssetsCabErrorString
_AssetsCabErrorString:
.e00 db "none", 0
.e01 db "cabinet not found", 0
.e02 db "not a cabinet", 0
.e03 db "unknown cabinet version", 0
.e04 db "corrupt cabinet", 0
.e05 db "alloc fail", 0
.e06 db "bad compr type", 0
.e07 db "MDI fail", 0
.e08 db "target file", 0
.e09 db "reserve mismatch", 0
.e10 db "wrong cabinet", 0
.e11 db "user abort", 0
.e12 db "EOF", 0
global _AssetsCabErrors
_AssetsCabErrors:
dd _AssetsCabErrorString.e00
dd _AssetsCabErrorString.e01
dd _AssetsCabErrorString.e02
dd _AssetsCabErrorString.e03
dd _AssetsCabErrorString.e04
dd _AssetsCabErrorString.e05
dd _AssetsCabErrorString.e06
dd _AssetsCabErrorString.e07
dd _AssetsCabErrorString.e08
dd _AssetsCabErrorString.e09
dd _AssetsCabErrorString.e10
dd _AssetsCabErrorString.e11
dd _AssetsCabErrorString.e12

segment .text
global _AssetsInit
_AssetsInit:
	FrameBegin 0, 0
	def_dll_and_load Cabinet, "cabinet.dll"
	dll_func_group_load Cabinet, CabinetFunc
	FrameEnd
	ret



