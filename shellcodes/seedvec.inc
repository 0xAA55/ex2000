
DefFunc _CreateSeedVector
	FrameBegin ebx
	DefVars %$AndVal

	mov ebx, Param(0)

	mov dword %$AndVal, 0x7FFF

	invoke_cdecl rand
	mov [ebx], eax

	fild dword [ebx]
	fidiv dword %$AndVal
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
