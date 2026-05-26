%include "common.inc"

DefFunc _CreateSeedVector
	FrameBegin 0, 2, ebx

	invoke_cdecl _aligned_malloc, 16, 16
	mov ebx, eax

	mov eax, 1
	lock xadd [_counter], eax
	mov [esp], eax
	fild dword [esp]
	fsincos
	fadd
	fstp dword [esp]
	call [_addr_of_srand]
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

DefFunc _DestroySeedVector
	FrameBegin 0, 1

	invoke_cdecl _aligned_free, Param(0)

	FrameEnd
	ret
