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
	.globl	__xmm@00000000000000008000000080000000
	.section	.rdata,"dr",discard,__xmm@00000000000000008000000080000000
	.p2align	4, 0x0
__xmm@00000000000000008000000080000000:
	.long	0x80000000                      # float -0
	.long	0x80000000                      # float -0
	.long	0x00000000                      # float 0
	.long	0x00000000                      # float 0
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
	sub	rsp, 368
	.seh_stackalloc 368
	movaps	xmmword ptr [rsp + 352], xmm15  # 16-byte Spill
	.seh_savexmm xmm15, 352
	movaps	xmmword ptr [rsp + 336], xmm14  # 16-byte Spill
	.seh_savexmm xmm14, 336
	movaps	xmmword ptr [rsp + 320], xmm13  # 16-byte Spill
	.seh_savexmm xmm13, 320
	movaps	xmmword ptr [rsp + 304], xmm12  # 16-byte Spill
	.seh_savexmm xmm12, 304
	movaps	xmmword ptr [rsp + 288], xmm11  # 16-byte Spill
	.seh_savexmm xmm11, 288
	movaps	xmmword ptr [rsp + 272], xmm10  # 16-byte Spill
	.seh_savexmm xmm10, 272
	movaps	xmmword ptr [rsp + 256], xmm9   # 16-byte Spill
	.seh_savexmm xmm9, 256
	movaps	xmmword ptr [rsp + 240], xmm8   # 16-byte Spill
	.seh_savexmm xmm8, 240
	movaps	xmmword ptr [rsp + 224], xmm7   # 16-byte Spill
	.seh_savexmm xmm7, 224
	movaps	xmmword ptr [rsp + 208], xmm6   # 16-byte Spill
	.seh_savexmm xmm6, 208
	.seh_endprologue
	movaps	xmm6, xmm2
	movaps	xmm7, xmm1
	mov	rsi, rcx
	xorps	xmm8, xmm8
	cvtss2sd	xmm8, xmm3
	movaps	xmm0, xmm8
	call	cos
	xorps	xmm11, xmm11
	cvtsd2ss	xmm11, xmm0
	movaps	xmm0, xmm8
	call	sin
	xorps	xmm9, xmm9
	cvtsd2ss	xmm9, xmm0
	movaps	xmm0, xmmword ptr [rip + __xmm@80000000800000008000000080000000] # xmm0 = [-0.0E+0,-0.0E+0,-0.0E+0,-0.0E+0]
	xorps	xmm0, xmm9
	movaps	xmmword ptr [rsp + 192], xmm0   # 16-byte Spill
	cvtss2sd	xmm6, xmm6
	movaps	xmm0, xmm6
	call	cos
	xorps	xmm8, xmm8
	cvtsd2ss	xmm8, xmm0
	movaps	xmm0, xmm6
	call	sin
	cvtsd2ss	xmm0, xmm0
	movaps	xmmword ptr [rsp + 64], xmm0    # 16-byte Spill
	xorps	xmm6, xmm6
	cvtss2sd	xmm6, xmm7
	movaps	xmm0, xmm6
	call	cos
	cvtsd2ss	xmm0, xmm0
	movaps	xmmword ptr [rsp + 32], xmm0    # 16-byte Spill
	movaps	xmm0, xmm6
	call	sin
	xorps	xmm7, xmm7
	cvtsd2ss	xmm7, xmm0
	xorps	xmm4, xmm4
	movaps	xmm13, xmm9
	mulss	xmm13, xmm4
	movaps	xmm14, xmm13
	addss	xmm14, xmm11
	addss	xmm14, xmm4
	movaps	xmm10, xmm9
	mulss	xmm10, xmm8
	movaps	xmm12, xmm11
	movaps	xmm6, xmm11
	mulss	xmm12, xmm4
	addss	xmm10, xmm12
	movss	xmm11, dword ptr [rip + __real@80000000] # xmm11 = [-0.0E+0,0.0E+0,0.0E+0,0.0E+0]
	movaps	xmm1, xmm9
	movaps	xmm5, xmm12
	movaps	xmmword ptr [rsp + 96], xmm12   # 16-byte Spill
	subss	xmm5, xmm9
	movaps	xmm15, xmm6
	mulss	xmm15, xmm8
	movaps	xmmword ptr [rsp + 128], xmm8   # 16-byte Spill
	mulss	xmm9, xmm11
	addss	xmm15, xmm9
	movaps	xmm3, xmmword ptr [rsp + 64]    # 16-byte Reload
	mulss	xmm6, xmm3
	addss	xmm6, xmm9
	movaps	xmmword ptr [rsp + 160], xmm6   # 16-byte Spill
	movaps	xmm2, xmm3
	mulss	xmm2, xmm11
	addss	xmm10, xmm2
	movaps	xmm9, xmm2
	addss	xmm10, xmm4
	movaps	xmm6, xmm10
	mulss	xmm6, xmm4
	movaps	xmm2, xmm14
	movaps	xmm0, xmm7
	movaps	xmmword ptr [rsp + 80], xmm7    # 16-byte Spill
	mulss	xmm2, xmm7
	movaps	xmm7, xmm6
	subss	xmm7, xmm2
	mulss	xmm1, xmm3
	movaps	xmm11, xmm3
	addss	xmm1, xmm12
	movaps	xmm12, xmm8
	mulss	xmm12, xmm4
	addss	xmm1, xmm12
	movaps	xmmword ptr [rsp + 144], xmm12  # 16-byte Spill
	addss	xmm1, xmm4
	movaps	xmm8, xmm1
	movaps	xmm2, xmmword ptr [rsp + 32]    # 16-byte Reload
	mulss	xmm8, xmm2
	addss	xmm8, xmm7
	movaps	xmm7, xmm14
	mulss	xmm7, xmm4
	addss	xmm7, xmm6
	movaps	xmm3, xmm1
	mulss	xmm3, xmm4
	addss	xmm3, xmm7
	addss	xmm15, xmm9
	movaps	xmmword ptr [rsp + 112], xmm15  # 16-byte Spill
	movaps	xmm15, xmm12
	addss	xmm15, xmm4
	addss	xmm9, xmm15
	movaps	xmmword ptr [rsp + 48], xmm9    # 16-byte Spill
	subss	xmm15, xmm11
	movaps	xmm9, xmm15
	mulss	xmm9, xmm4
	mulss	xmm2, xmm4
	movaps	xmm12, xmm2
	addss	xmm12, xmm9
	movss	xmm7, dword ptr [rip + __real@80000000] # xmm7 = [-0.0E+0,0.0E+0,0.0E+0,0.0E+0]
	mulss	xmm7, xmm0
	movaps	xmm11, xmm7
	addss	xmm11, xmm9
	addss	xmm9, xmm4
	unpcklps	xmm11, xmm9                     # xmm11 = xmm11[0],xmm9[0],xmm11[1],xmm9[1]
	movaps	xmm9, xmmword ptr [rsp + 48]    # 16-byte Reload
	addss	xmm9, xmm4
	movaps	xmmword ptr [rsp + 48], xmm9    # 16-byte Spill
	mulss	xmm9, xmm4
	addss	xmm2, xmm9
	movaps	xmmword ptr [rsp + 176], xmm2   # 16-byte Spill
	addss	xmm7, xmm9
	addss	xmm9, xmm4
	unpcklps	xmm7, xmm9                      # xmm7 = xmm7[0],xmm9[0],xmm7[1],xmm9[1]
	unpcklps	xmm6, xmm10                     # xmm6 = xmm6[0],xmm10[0],xmm6[1],xmm10[1]
	xorps	xmm0, xmm0
	movaps	xmm2, xmmword ptr [rsp + 32]    # 16-byte Reload
	movss	xmm0, xmm2                      # xmm0 = xmm2[0],xmm0[1,2,3]
	unpcklps	xmm14, xmm14                    # xmm14 = xmm14[0,0,1,1]
	mulps	xmm14, xmm0
	addps	xmm14, xmm6
	unpcklps	xmm1, xmm1                      # xmm1 = xmm1[0,0,1,1]
	xorps	xmm2, xmm2
	movaps	xmm9, xmmword ptr [rsp + 80]    # 16-byte Reload
	movss	xmm2, xmm9                      # xmm2 = xmm9[0],xmm2[1,2,3]
	movaps	xmmword ptr [rsp + 32], xmm2    # 16-byte Spill
	mulps	xmm1, xmm2
	addps	xmm1, xmm14
	movaps	xmm2, xmmword ptr [rsp + 96]    # 16-byte Reload
	addss	xmm13, xmm2
	addss	xmm13, xmm4
	addss	xmm3, xmm13
	mulss	xmm13, xmm4
	addss	xmm8, xmm13
	unpcklps	xmm13, xmm13                    # xmm13 = xmm13[0,0,1,1]
	addps	xmm13, xmm1
	movlps	qword ptr [rsi], xmm13
	movss	dword ptr [rsi + 8], xmm8
	movss	dword ptr [rsi + 12], xmm3
	unpcklps	xmm2, xmmword ptr [rsp + 160]   # 16-byte Folded Reload
                                        # xmm2 = xmm2[0],mem[0],xmm2[1],mem[1]
	movaps	xmm6, xmm2
	movaps	xmm2, xmmword ptr [rsp + 192]   # 16-byte Reload
	movaps	xmm3, xmmword ptr [rsp + 128]   # 16-byte Reload
	unpcklps	xmm2, xmm3                      # xmm2 = xmm2[0],xmm3[0],xmm2[1],xmm3[1]
	xorps	xmm1, xmm1
	mulps	xmm2, xmm1
	addps	xmm2, xmm6
	movaps	xmm6, xmmword ptr [rsp + 64]    # 16-byte Reload
	mulss	xmm6, xmm4
	movaps	xmm10, xmm2
	shufps	xmm10, xmm6, 4                  # xmm10 = xmm10[0,1],xmm6[0,0]
	shufps	xmm5, xmm2, 212                 # xmm5 = xmm5[0,1],xmm2[1,3]
	shufps	xmm5, xmm2, 82                  # xmm5 = xmm5[2,0],xmm2[1,1]
	xorps	xmm8, xmm8
	shufps	xmm8, xmm3, 4                   # xmm8 = xmm8[0,1],xmm3[0,0]
	addps	xmm10, xmmword ptr [rip + __xmm@00000000000000008000000080000000]
	movaps	xmm2, xmmword ptr [rsp + 112]   # 16-byte Reload
	addss	xmm2, xmm4
	addps	xmm8, xmm10
	movhlps	xmm10, xmm10                    # xmm10 = xmm10[1,1]
	addss	xmm10, dword ptr [rsp + 144]    # 16-byte Folded Reload
	movaps	xmm3, xmm2
	movaps	xmm14, xmm2
	mulss	xmm3, xmm4
	addps	xmm5, xmm1
	movaps	xmm2, xmm5
	shufps	xmm2, xmm5, 85                  # xmm2 = xmm2[1,1],xmm5[1,1]
	movaps	xmm6, xmm2
	movaps	xmm13, xmm9
	mulss	xmm6, xmm9
	movaps	xmm9, xmm3
	subss	xmm9, xmm6
	unpcklps	xmm9, xmm3                      # xmm9 = xmm9[0],xmm3[0],xmm9[1],xmm3[1]
	mulps	xmm5, xmm0
	addps	xmm5, xmm9
	unpcklps	xmm12, xmm15                    # xmm12 = xmm12[0],xmm15[0],xmm12[1],xmm15[1]
	movlhps	xmm5, xmm12                     # xmm5 = xmm5[0],xmm12[0]
	movq	xmm6, xmm13                     # xmm6 = xmm13[0],zero
	xorps	xmm9, xmm9
	shufps	xmm9, xmm6, 132                 # xmm9 = xmm9[0,1],xmm6[0,2]
	mulps	xmm9, xmm8
	addps	xmm9, xmm5
	movss	xmm5, dword ptr [rip + __real@80000000] # xmm5 = [-0.0E+0,0.0E+0,0.0E+0,0.0E+0]
	movaps	xmm6, xmm8
	movlhps	xmm6, xmm5                      # xmm6 = xmm6[0],xmm5[0]
	shufps	xmm6, xmm5, 226                 # xmm6 = xmm6[2,0],xmm5[2,3]
	addps	xmm6, xmm9
	unpcklps	xmm3, xmm14                     # xmm3 = xmm3[0],xmm14[0],xmm3[1],xmm14[1]
	mulps	xmm2, xmm0
	addps	xmm2, xmm3
	movaps	xmm3, xmm8
	shufps	xmm3, xmm8, 85                  # xmm3 = xmm3[1,1],xmm8[1,1]
	movaps	xmm5, xmmword ptr [rsp + 32]    # 16-byte Reload
	mulps	xmm3, xmm5
	addps	xmm3, xmm2
	addss	xmm10, xmm4
	mulss	xmm4, xmm8
	unpcklps	xmm4, xmm4                      # xmm4 = xmm4[0,0,1,1]
	addps	xmm4, xmm3
	movlps	qword ptr [rsi + 16], xmm4
	movups	xmmword ptr [rsi + 24], xmm6
	shufps	xmm8, xmm10, 10                 # xmm8 = xmm8[2,2],xmm10[0,0]
	unpcklps	xmm10, xmm10                    # xmm10 = xmm10[0,0,1,1]
	mulps	xmm10, xmm0
	movaps	xmm4, xmm0
	movlhps	xmm4, xmm5                      # xmm4 = xmm4[0],xmm5[0]
	mulps	xmm4, xmm8
	movaps	xmm0, xmmword ptr [rsp + 176]   # 16-byte Reload
	unpcklps	xmm0, xmmword ptr [rsp + 48]    # 16-byte Folded Reload
                                        # xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
	movlhps	xmm11, xmm0                     # xmm11 = xmm11[0],xmm0[0]
	addps	xmm11, xmm4
	addps	xmm11, xmm1
	movups	xmmword ptr [rsi + 40], xmm11
	addps	xmm10, xmm7
	addps	xmm10, xmmword ptr [rip + __xmm@00000000000000003f80000000000000]
	movlps	qword ptr [rsi + 56], xmm10
	movaps	xmm6, xmmword ptr [rsp + 208]   # 16-byte Reload
	movaps	xmm7, xmmword ptr [rsp + 224]   # 16-byte Reload
	movaps	xmm8, xmmword ptr [rsp + 240]   # 16-byte Reload
	movaps	xmm9, xmmword ptr [rsp + 256]   # 16-byte Reload
	movaps	xmm10, xmmword ptr [rsp + 272]  # 16-byte Reload
	movaps	xmm11, xmmword ptr [rsp + 288]  # 16-byte Reload
	movaps	xmm12, xmmword ptr [rsp + 304]  # 16-byte Reload
	movaps	xmm13, xmmword ptr [rsp + 320]  # 16-byte Reload
	movaps	xmm14, xmmword ptr [rsp + 336]  # 16-byte Reload
	movaps	xmm15, xmmword ptr [rsp + 352]  # 16-byte Reload
	.seh_startepilogue
	add	rsp, 368
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
