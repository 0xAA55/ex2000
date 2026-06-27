%include "common.inc"

DefFunc _CreateSeedVector
	FrameBegin 0, ebx

	mov ebx, Param(0)

	invoke_dll_cdecl rand
	mov [ebx], eax

	fild dword [ebx]
	fidiv dword [_Rand4AndVal]
	fldpi
	fldpi
	fadd
	fmul
	fst dword [ebx]
	fld st0
	fsincos
	fstp dword [ebx + 4]
	fstp dword [ebx + 8]
	fsincos
	fadd
	fstp dword [ebx + 12]

	mov eax, ebx
	FrameEnd
	ret
