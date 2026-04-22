%include "avlbst.inc"
%define ASSETS_ASM 1
%include "assets.inc"

dll_func_group_start CabinetFunc
def_dll_func FDICreate
def_dll_func FDICopy
def_dll_func FDIDestroy
dll_func_group_end CabinetFunc

segment .text
global _AssetsInit
_AssetsInit:
	FrameBegin 0, 0
	def_dll_and_load Cabinet, "cabinet.dll"
	dll_func_group_load Cabinet, CabinetFunc
	FrameEnd
	ret


segment .rdata
global _AssetsCab
_AssetsCab:
incbin "out/assets.cab"
_AssetsCabSize equ $ - _AssetsCab

