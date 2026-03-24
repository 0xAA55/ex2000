	.file	"matrot.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	_MatrixRotationEuler
	.def	_MatrixRotationEuler;	.scl	2;	.type	32;	.endef
_MatrixRotationEuler:
	push	ebx
	sub	esp, 136
	fld	DWORD PTR [esp+156]
	mov	ebx, DWORD PTR [esp+144]
	fstp	QWORD PTR [esp]
	call	_cos
	fstp	DWORD PTR [esp+48]
	fld	DWORD PTR [esp+156]
	fstp	QWORD PTR [esp]
	call	_sin
	fstp	DWORD PTR [esp+28]
	fld	DWORD PTR [esp+28]
	fst	DWORD PTR [esp+52]
	fchs
	fstp	DWORD PTR [esp+68]
	fld	DWORD PTR [esp+152]
	fstp	QWORD PTR [esp]
	call	_cos
	fstp	DWORD PTR [esp+40]
	fld	DWORD PTR [esp+152]
	fstp	QWORD PTR [esp]
	call	_sin
	fstp	DWORD PTR [esp+28]
	fld	DWORD PTR [esp+28]
	fst	DWORD PTR [esp+44]
	fchs
	fstp	DWORD PTR [esp+64]
	fld	DWORD PTR [esp+148]
	fstp	QWORD PTR [esp]
	call	_cos
	fstp	DWORD PTR [esp+28]
	fld	DWORD PTR [esp+148]
	fstp	QWORD PTR [esp]
	call	_sin
	fstp	DWORD PTR [esp+32]
	fld	DWORD PTR [esp+32]
	fst	DWORD PTR [esp+36]
	fchs
	fstp	DWORD PTR [esp+32]
	fldz
	fld	DWORD PTR [esp+52]
	fld	st(0)
	fmul	st, st(2)
	fld	DWORD PTR [esp+44]
	fmul	st, st(3)
	fld	DWORD PTR [esp+40]
	fld	st(0)
	fld	DWORD PTR [esp+48]
	fmul	st(1), st
	fxch	st(1)
	fadd	st, st(4)
	fadd	st, st(3)
	fadd	st, st(6)
	fstp	DWORD PTR [esp+80]
	fld	st(0)
	fmul	st, st(6)
	fadd	st(5), st
	fxch	st(5)
	fadd	st, st(6)
	fstp	DWORD PTR [esp+56]
	fld	st(1)
	fmul	st, st(6)
	fld	DWORD PTR [esp+64]
	fmulp	st(2), st
	fxch	st(1)
	fadd	st, st(4)
	fadd	st, st(1)
	fadd	st, st(6)
	fstp	DWORD PTR [esp+60]
	fxch	st(3)
	fadd	st, st(4)
	fadd	st, st(5)
	fstp	DWORD PTR [esp+84]
	fld	DWORD PTR [esp+68]
	fmul	st(1), st
	fxch	st(1)
	fadd	st, st(4)
	fadd	st, st(2)
	fadd	st, st(5)
	fstp	DWORD PTR [esp+72]
	fmul	st, st(4)
	fld	DWORD PTR [esp+48]
	fadd	st, st(1)
	fadd	st, st(5)
	fstp	DWORD PTR [esp+48]
	fld	DWORD PTR [esp+52]
	fmul	DWORD PTR [esp+44]
	fadd	st, st(4)
	fadd	st, st(3)
	fadd	st, st(5)
	fxch	st(1)
	faddp	st(4), st
	fxch	st(3)
	fadd	st, st(4)
	fstp	DWORD PTR [esp+76]
	fld	st(1)
	fadd	st, st(4)
	fld	st(0)
	fld	DWORD PTR [esp+44]
	faddp	st(2), st
	fxch	st(1)
	fadd	st, st(5)
	fstp	DWORD PTR [esp+68]
	fld	DWORD PTR [esp+64]
	fmul	st, st(5)
	fadd	st, st(5)
	fld	DWORD PTR [esp+40]
	fadd	st, st(1)
	fadd	st, st(6)
	fxch	st(2)
	faddp	st(3), st
	fxch	st(2)
	fadd	st, st(5)
	fstp	DWORD PTR [esp+52]
	fxch	st(1)
	faddp	st(2), st
	fxch	st(1)
	fadd	st, st(3)
	fstp	DWORD PTR [esp+64]
	fld	DWORD PTR [esp+56]
	fmul	st, st(3)
	fstp	DWORD PTR [esp+100]
	fld	DWORD PTR [esp+60]
	fmul	st, st(3)
	fstp	DWORD PTR [esp+104]
	fld	DWORD PTR [esp+84]
	fmul	st, st(3)
	fld	DWORD PTR [esp+80]
	fmul	st, st(4)
	fld	DWORD PTR [esp+48]
	fmul	st, st(5)
	fstp	DWORD PTR [esp+96]
	fxch	st(3)
	fst	DWORD PTR [esp+108]
	fmul	st, st(4)
	fstp	DWORD PTR [esp+124]
	fld	DWORD PTR [esp+76]
	fmul	st, st(4)
	fstp	DWORD PTR [esp+40]
	fld	DWORD PTR [esp+72]
	fmul	st, st(4)
	fstp	DWORD PTR [esp+44]
	fld	st(1)
	fmul	st, st(4)
	fstp	DWORD PTR [esp+120]
	fld	DWORD PTR [esp+68]
	fmul	st, st(4)
	fld	DWORD PTR [esp+28]
	fld	st(0)
	fmul	st, st(6)
	fstp	DWORD PTR [esp+88]
	fld	DWORD PTR [esp+36]
	fmul	st, st(6)
	fstp	DWORD PTR [esp+92]
	fld	DWORD PTR [esp+64]
	fmul	st, st(6)
	fstp	DWORD PTR [esp+112]
	fld	DWORD PTR [esp+52]
	fmul	st, st(6)
	fstp	DWORD PTR [esp+116]
	fld	DWORD PTR [esp+80]
	fadd	DWORD PTR [esp+100]
	fld	DWORD PTR [esp+104]
	faddp	st(1), st
	fadd	st, st(3)
	fstp	DWORD PTR [ebx]
	fmul	DWORD PTR [esp+56]
	fadd	st, st(4)
	fld	DWORD PTR [esp+60]
	fmul	DWORD PTR [esp+32]
	faddp	st(1), st
	fadd	st, st(2)
	fstp	DWORD PTR [ebx+4]
	fld	DWORD PTR [esp+56]
	fmul	DWORD PTR [esp+36]
	fadd	st, st(4)
	fld	DWORD PTR [esp+60]
	fmul	DWORD PTR [esp+28]
	faddp	st(1), st
	faddp	st(2), st
	fxch	st(1)
	fstp	DWORD PTR [ebx+8]
	fld	DWORD PTR [esp+100]
	faddp	st(3), st
	fxch	st(2)
	fadd	DWORD PTR [esp+104]
	fadd	DWORD PTR [esp+84]
	fstp	DWORD PTR [ebx+12]
	fld	DWORD PTR [esp+72]
	fadd	DWORD PTR [esp+96]
	fld	DWORD PTR [esp+124]
	fadd	st(1), st
	fxch	st(1)
	fadd	DWORD PTR [esp+40]
	fstp	DWORD PTR [ebx+16]
	fld	DWORD PTR [esp+28]
	fld	DWORD PTR [esp+48]
	fmul	st, st(1)
	fadd	DWORD PTR [esp+44]
	fld	DWORD PTR [esp+108]
	fld	DWORD PTR [esp+32]
	fmul	st, st(1)
	faddp	st(2), st
	fxch	st(1)
	fadd	DWORD PTR [esp+40]
	fstp	DWORD PTR [ebx+20]
	fld	DWORD PTR [esp+36]
	fmul	DWORD PTR [esp+48]
	fld	DWORD PTR [esp+44]
	faddp	st(1), st
	fxch	st(1)
	fmul	st, st(2)
	faddp	st(1), st
	fadd	DWORD PTR [esp+40]
	fstp	DWORD PTR [ebx+24]
	fld	DWORD PTR [esp+96]
	fadd	DWORD PTR [esp+44]
	faddp	st(2), st
	fxch	st(1)
	fadd	DWORD PTR [esp+76]
	fstp	DWORD PTR [ebx+28]
	fld	DWORD PTR [esp+68]
	fld	DWORD PTR [esp+120]
	fadd	st(1), st
	fxch	st(1)
	fadd	st, st(5)
	fstp	DWORD PTR [ebx+32]
	fld	DWORD PTR [esp+88]
	fadd	st, st(4)
	fld	DWORD PTR [esp+32]
	fmul	st, st(4)
	faddp	st(1), st
	fadd	st, st(5)
	fstp	DWORD PTR [ebx+36]
	fld	DWORD PTR [esp+92]
	fadd	st, st(4)
	fxch	st(3)
	fmul	st, st(2)
	faddp	st(3), st
	fxch	st(2)
	fadd	st, st(4)
	fstp	DWORD PTR [ebx+40]
	fxch	st(2)
	fadd	st, st(3)
	faddp	st(1), st
	fadd	st, st(2)
	fstp	DWORD PTR [ebx+44]
	fld	DWORD PTR [esp+52]
	fld	DWORD PTR [esp+112]
	fadd	st(1), st
	fxch	st(1)
	fadd	st, st(3)
	fstp	DWORD PTR [ebx+48]
	fld	DWORD PTR [esp+88]
	fld	DWORD PTR [esp+116]
	fadd	st(1), st
	fld	DWORD PTR [esp+32]
	fld	DWORD PTR [esp+64]
	fmul	st(1), st
	fxch	st(3)
	faddp	st(1), st
	fadd	st, st(5)
	fstp	DWORD PTR [ebx+52]
	fld	DWORD PTR [esp+92]
	fadd	st, st(1)
	fxch	st(4)
	fmulp	st(2), st
	fxch	st(1)
	faddp	st(3), st
	fxch	st(2)
	fadd	st, st(3)
	fstp	DWORD PTR [ebx+56]
	fxch	st(2)
	faddp	st(1), st
	faddp	st(1), st
	fadd	DWORD PTR LC1
	fstp	DWORD PTR [ebx+60]
	add	esp, 136
	pop	ebx
	ret
	.section .rdata,"dr"
	.align 4
LC1:
	.long	1065353216
	.ident	"GCC: (tdm-1) 10.3.0"
	.def	_cos;	.scl	2;	.type	32;	.endef
	.def	_sin;	.scl	2;	.type	32;	.endef
