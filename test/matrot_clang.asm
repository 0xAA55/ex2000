	.def	@feat.00;
	.scl	3;
	.type	0;
	.endef
	.globl	@feat.00
@feat.00 = 0
	.intel_syntax noprefix
	.file	"matrot.c"
	.def	MatrixRotationEuler;
	.scl	2;
	.type	32;
	.endef
	.globl	__xmm@80000000800000008000000080000000 # -- Begin function MatrixRotationEuler
	.section	.rdata,"dr",discard,__xmm@80000000800000008000000080000000
	.p2align	4, 0x0
__xmm@80000000800000008000000080000000:
	.long	0x80000000                      # float -0
	.long	0x80000000                      # float -0
	.long	0x80000000                      # float -0
	.long	0x80000000                      # float -0
	.globl	__real@80000000
	.section	.rdata,"dr",discard,__real@80000000
	.p2align	2, 0x0
__real@80000000:
	.long	0x80000000                      # float -0
	.globl	__xmm@00000000000000003f80000000000000
	.section	.rdata,"dr",discard,__xmm@00000000000000003f80000000000000
	.p2align	4, 0x0
__xmm@00000000000000003f80000000000000:
	.long	0x00000000                      # float 0
	.long	0x3f800000                      # float 1
	.zero	4
	.zero	4
	.text
	.globl	MatrixRotationEuler
	.p2align	4
MatrixRotationEuler:                    # @MatrixRotationEuler
.seh_proc MatrixRotationEuler
# %bb.0:
	push	rsi
	.seh_pushreg rsi
	sub	rsp, 240
	.seh_stackalloc 240
	movaps	xmmword ptr [rsp + 224], xmm15  # 16-byte Spill
	.seh_savexmm xmm15, 224
	movaps	xmmword ptr [rsp + 208], xmm14  # 16-byte Spill
	.seh_savexmm xmm14, 208
	movaps	xmmword ptr [rsp + 192], xmm13  # 16-byte Spill
	.seh_savexmm xmm13, 192
	movaps	xmmword ptr [rsp + 176], xmm12  # 16-byte Spill
	.seh_savexmm xmm12, 176
	movaps	xmmword ptr [rsp + 160], xmm11  # 16-byte Spill
	.seh_savexmm xmm11, 160
	movaps	xmmword ptr [rsp + 144], xmm10  # 16-byte Spill
	.seh_savexmm xmm10, 144
	movaps	xmmword ptr [rsp + 128], xmm9   # 16-byte Spill
	.seh_savexmm xmm9, 128
	movaps	xmmword ptr [rsp + 112], xmm8   # 16-byte Spill
	.seh_savexmm xmm8, 112
	movaps	xmmword ptr [rsp + 96], xmm7    # 16-byte Spill
	.seh_savexmm xmm7, 96
	movaps	xmmword ptr [rsp + 80], xmm6    # 16-byte Spill
	.seh_savexmm xmm6, 80
	.seh_endprologue
	movaps	xmm6, xmm2
	movaps	xmm8, xmm1
	mov	rsi, rcx
	xorps	xmm7, xmm7
	cvtss2sd	xmm7, xmm3
	movaps	xmm0, xmm7
	call	cos
	xorps	xmm15, xmm15
	cvtsd2ss	xmm15, xmm0
	movaps	xmm0, xmm7
	call	sin
	xorps	xmm10, xmm10
	cvtsd2ss	xmm10, xmm0
	movaps	xmm9, xmm10
	xorps	xmm9, xmmword ptr [rip + __xmm@80000000800000008000000080000000]
	xorps	xmm7, xmm7
	cvtss2sd	xmm7, xmm6
	movaps	xmm0, xmm7
	call	cos
	movaps	xmm6, xmm0
	movaps	xmm0, xmm7
	call	sin
	movaps	xmm7, xmm0
	cvtss2sd	xmm8, xmm8
	movaps	xmm0, xmm8
	call	cos
	xorps	xmm11, xmm11
	cvtsd2ss	xmm11, xmm0
	movaps	xmm0, xmm8
	call	sin
	xorps	xmm1, xmm1
	movaps	xmm12, xmm10
	mulss	xmm12, xmm1
	movaps	xmm3, xmm15
	mulss	xmm3, xmm1
	movaps	xmm13, xmm3
	addss	xmm13, xmm10
	movaps	xmm2, xmm3
	addss	xmm2, xmm12
	movaps	xmmword ptr [rsp + 64], xmm2    # 16-byte Spill
	movaps	xmm8, xmm15
	subss	xmm8, xmm12
	movlhps	xmm6, xmm7                      # xmm6 = xmm6[0],xmm7[0]
	cvtpd2ps	xmm4, xmm6
	movapd	xmm6, xmm4
	shufps	xmm6, xmm4, 85                  # xmm6 = xmm6[1,1],xmm4[1,1]
	movaps	xmm14, xmm15
	mulss	xmm14, xmm4
	addss	xmm14, xmm12
	mulss	xmm15, xmm6
	subss	xmm12, xmm15
	unpcklps	xmm10, xmm9                     # xmm10 = xmm10[0],xmm9[0],xmm10[1],xmm9[1]
	movaps	xmm5, xmm4
	shufps	xmm5, xmm4, 225                 # xmm5 = xmm5[1,0],xmm4[2,3]
	mulps	xmm5, xmm10
	movaps	xmm7, xmm3
	shufps	xmm7, xmm3, 0                   # xmm7 = xmm7[0,0],xmm3[0,0]
	addps	xmm7, xmm5
	xorps	xmm5, xmm5
	movaps	xmm2, xmm4
	mulps	xmm2, xmm5
	addps	xmm2, xmm7
	unpcklps	xmm3, xmm7                      # xmm3 = xmm3[0],xmm7[0],xmm3[1],xmm7[1]
	movaps	xmm7, xmm6
	mulss	xmm7, xmm1
	unpcklps	xmm9, xmm4                      # xmm9 = xmm9[0],xmm4[0],xmm9[1],xmm4[1]
	mulps	xmm9, xmm5
	addps	xmm9, xmm3
	xorps	xmm5, xmm5
	subss	xmm5, xmm7
	movaps	xmm10, xmm4
	addss	xmm4, xmm5
	shufps	xmm9, xmm4, 4                   # xmm9 = xmm9[0,1],xmm4[0,0]
	xorps	xmm4, xmm4
	cvtsd2ss	xmm4, xmm0
	addss	xmm13, xmm1
	addss	xmm14, xmm7
	mulss	xmm10, xmm1
	addss	xmm12, xmm10
	addss	xmm5, xmm10
	addss	xmm10, xmm1
	addss	xmm6, xmm10
	addss	xmm10, xmm7
	movaps	xmm0, xmm13
	mulss	xmm0, xmm1
	movaps	xmm3, xmm13
	movaps	xmm15, xmm11
	mulss	xmm3, xmm11
	addss	xmm14, xmm1
	movaps	xmm7, xmm0
	addss	xmm7, xmm14
	mulss	xmm14, xmm1
	addss	xmm3, xmm14
	unpcklps	xmm7, xmm3                      # xmm7 = xmm7[0],xmm3[0],xmm7[1],xmm3[1]
	movaps	xmmword ptr [rsp + 48], xmm7    # 16-byte Spill
	mulss	xmm13, xmm4
	movaps	xmm11, xmm4
	addss	xmm12, xmm1
	addss	xmm13, xmm14
	movaps	xmm4, xmm12
	mulss	xmm4, xmm15
	addss	xmm4, xmm13
	addss	xmm14, xmm0
	movaps	xmm3, xmm12
	mulss	xmm3, xmm1
	addss	xmm3, xmm14
	addss	xmm8, xmm1
	movaps	xmm0, xmm8
	mulss	xmm0, xmm1
	movaps	xmm14, xmm8
	mulss	xmm14, xmm15
	xorps	xmm7, xmm7
	addps	xmm2, xmm7
	movaps	xmm13, xmm2
	shufps	xmm13, xmm2, 85                 # xmm13 = xmm13[1,1],xmm2[1,1]
	movaps	xmm7, xmm0
	addss	xmm7, xmm13
	mulss	xmm13, xmm1
	addss	xmm14, xmm13
	unpcklps	xmm7, xmm14                     # xmm7 = xmm7[0],xmm14[0],xmm7[1],xmm14[1]
	movaps	xmmword ptr [rsp + 32], xmm11   # 16-byte Spill
	mulss	xmm8, xmm11
	addss	xmm13, xmm8
	unpcklps	xmm13, xmm0                     # xmm13 = xmm13[0],xmm0[0],xmm13[1],xmm0[1]
	xorps	xmm14, xmm14
	movss	xmm14, xmm15                    # xmm14 = xmm15[0],xmm14[1,2,3]
	mulps	xmm2, xmm14
	addps	xmm2, xmm13
	mulss	xmm15, xmm1
	addss	xmm6, xmm1
	movaps	xmm8, xmm6
	mulss	xmm8, xmm1
	movaps	xmm0, xmm8
	addss	xmm0, xmm15
	unpcklps	xmm6, xmm0                      # xmm6 = xmm6[0],xmm0[0],xmm6[1],xmm0[1]
	movlhps	xmm2, xmm6                      # xmm2 = xmm2[0],xmm6[0]
	movaps	xmm6, xmmword ptr [rip + __xmm@80000000800000008000000080000000] # xmm6 = [-0.0E+0,-0.0E+0,-0.0E+0,-0.0E+0]
	xorps	xmm6, xmm11
	xorps	xmm0, xmm0
	addps	xmm9, xmm0
	movq	xmm0, xmm6                      # xmm0 = xmm6[0],zero
	movaps	xmm11, xmm6
	xorps	xmm13, xmm13
	shufps	xmm13, xmm0, 36                 # xmm13 = xmm13[0,1],xmm0[2,0]
	mulps	xmm13, xmm9
	addps	xmm13, xmm2
	movss	xmm2, dword ptr [rip + __real@80000000] # xmm2 = [-0.0E+0,0.0E+0,0.0E+0,0.0E+0]
	movaps	xmm6, xmm9
	movlhps	xmm6, xmm2                      # xmm6 = xmm6[0],xmm2[0]
	shufps	xmm6, xmm2, 226                 # xmm6 = xmm6[2,0],xmm2[2,3]
	addps	xmm6, xmm13
	unpcklps	xmm12, xmm12                    # xmm12 = xmm12[0,0,1,1]
	xorps	xmm2, xmm2
	shufps	xmm0, xmm2, 226                 # xmm0 = xmm0[2,0],xmm2[2,3]
	xorps	xmm13, xmm13
	mulps	xmm12, xmm0
	addps	xmm12, xmmword ptr [rsp + 48]   # 16-byte Folded Reload
	movaps	xmm2, xmmword ptr [rsp + 64]    # 16-byte Reload
	addss	xmm2, xmm1
	addss	xmm3, xmm2
	mulss	xmm2, xmm1
	addss	xmm4, xmm2
	unpcklps	xmm2, xmm2                      # xmm2 = xmm2[0,0,1,1]
	addps	xmm2, xmm12
	movlps	qword ptr [rsi], xmm2
	movss	dword ptr [rsi + 8], xmm4
	movss	dword ptr [rsi + 12], xmm3
	movaps	xmm2, xmm9
	shufps	xmm2, xmm9, 85                  # xmm2 = xmm2[1,1],xmm9[1,1]
	mulps	xmm2, xmm0
	movaps	xmm3, xmmword ptr [rsp + 32]    # 16-byte Reload
	mulss	xmm3, xmm1
	addss	xmm10, xmm1
	addss	xmm5, xmm1
	addps	xmm2, xmm7
	movaps	xmm0, xmm10
	mulss	xmm0, xmm1
	mulss	xmm1, xmm9
	unpcklps	xmm1, xmm1                      # xmm1 = xmm1[0,0,1,1]
	addps	xmm1, xmm2
	movlps	qword ptr [rsi + 16], xmm1
	movups	xmmword ptr [rsi + 24], xmm6
	xorps	xmm1, xmm1
	movss	xmm1, xmm3                      # xmm1 = xmm3[0],xmm1[1,2,3]
	xorps	xmm2, xmm2
	movss	xmm2, xmm11                     # xmm2 = xmm11[0],xmm2[1,2,3]
	shufps	xmm9, xmm5, 10                  # xmm9 = xmm9[2,2],xmm5[0,0]
	unpcklps	xmm5, xmm5                      # xmm5 = xmm5[0,0,1,1]
	mulps	xmm5, xmm14
	shufps	xmm14, xmm2, 20                 # xmm14 = xmm14[0,1],xmm2[1,0]
	mulps	xmm14, xmm9
	addss	xmm15, xmm0
	unpcklps	xmm10, xmm15                    # xmm10 = xmm10[0],xmm15[0],xmm10[1],xmm15[1]
	unpcklps	xmm8, xmm8                      # xmm8 = xmm8[0,0,1,1]
	addps	xmm8, xmm1
	movlhps	xmm8, xmm10                     # xmm8 = xmm8[0],xmm10[0]
	addps	xmm8, xmm14
	addps	xmm8, xmm13
	movups	xmmword ptr [rsi + 40], xmm8
	unpcklps	xmm0, xmm0                      # xmm0 = xmm0[0,0,1,1]
	addps	xmm0, xmm1
	addps	xmm5, xmm0
	addps	xmm5, xmmword ptr [rip + __xmm@00000000000000003f80000000000000]
	movlps	qword ptr [rsi + 56], xmm5
	movaps	xmm6, xmmword ptr [rsp + 80]    # 16-byte Reload
	movaps	xmm7, xmmword ptr [rsp + 96]    # 16-byte Reload
	movaps	xmm8, xmmword ptr [rsp + 112]   # 16-byte Reload
	movaps	xmm9, xmmword ptr [rsp + 128]   # 16-byte Reload
	movaps	xmm10, xmmword ptr [rsp + 144]  # 16-byte Reload
	movaps	xmm11, xmmword ptr [rsp + 160]  # 16-byte Reload
	movaps	xmm12, xmmword ptr [rsp + 176]  # 16-byte Reload
	movaps	xmm13, xmmword ptr [rsp + 192]  # 16-byte Reload
	movaps	xmm14, xmmword ptr [rsp + 208]  # 16-byte Reload
	movaps	xmm15, xmmword ptr [rsp + 224]  # 16-byte Reload
	.seh_startepilogue
	add	rsp, 240
	pop	rsi
	.seh_endepilogue
	ret
	.seh_endproc
                                        # -- End function
	.section	.debug$S,"dr"
	.p2align	2, 0x0
	.long	4                               # Debug section magic
	.long	241
	.long	.Ltmp1-.Ltmp0                   # Subsection size
.Ltmp0:
	.short	.Ltmp3-.Ltmp2                   # Record length
.Ltmp2:
	.short	4353                            # Record kind: S_OBJNAME
	.long	0                               # Signature
	.byte	0                               # Object name
	.p2align	2, 0x0
.Ltmp3:
	.short	.Ltmp5-.Ltmp4                   # Record length
.Ltmp4:
	.short	4412                            # Record kind: S_COMPILE3
	.long	0                               # Flags and language
	.short	208                             # CPUType
	.short	22                              # Frontend version
	.short	1
	.short	1
	.short	0
	.short	22011                           # Backend version
	.short	0
	.short	0
	.short	0
	.asciz	"clang version 22.1.1 (https://github.com/llvm/llvm-project fef02d48c08db859ef83f84232ed78bd9d1c323a)" # Null-terminated compiler version string
	.p2align	2, 0x0
.Ltmp5:
.Ltmp1:
	.p2align	2, 0x0
	.addrsig
	.globl	_fltused
