	.text
	.def	@feat.00;
	.scl	3;
	.type	0;
	.endef
	.globl	@feat.00
.set @feat.00, 0
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
	.text
	.globl	MatrixRotationEuler
	.p2align	4, 0x90
MatrixRotationEuler:                    # @MatrixRotationEuler
.seh_proc MatrixRotationEuler
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	subq	$144, %rsp
	.seh_stackalloc 144
	movaps	%xmm12, 128(%rsp)               # 16-byte Spill
	.seh_savexmm %xmm12, 128
	movaps	%xmm11, 112(%rsp)               # 16-byte Spill
	.seh_savexmm %xmm11, 112
	movaps	%xmm10, 96(%rsp)                # 16-byte Spill
	.seh_savexmm %xmm10, 96
	movaps	%xmm9, 80(%rsp)                 # 16-byte Spill
	.seh_savexmm %xmm9, 80
	movaps	%xmm8, 64(%rsp)                 # 16-byte Spill
	.seh_savexmm %xmm8, 64
	movaps	%xmm7, 48(%rsp)                 # 16-byte Spill
	.seh_savexmm %xmm7, 48
	movaps	%xmm6, 32(%rsp)                 # 16-byte Spill
	.seh_savexmm %xmm6, 32
	.seh_endprologue
	movaps	%xmm2, %xmm6
	movaps	%xmm1, %xmm7
	movq	%rcx, %rsi
	xorps	%xmm8, %xmm8
	cvtss2sd	%xmm3, %xmm8
	movaps	%xmm8, %xmm0
	callq	cos
	xorps	%xmm9, %xmm9
	cvtsd2ss	%xmm0, %xmm9
	movaps	%xmm8, %xmm0
	callq	sin
	xorps	%xmm10, %xmm10
	cvtsd2ss	%xmm0, %xmm10
	movaps	__xmm@80000000800000008000000080000000(%rip), %xmm12 # xmm12 = [-0.0E+0,-0.0E+0,-0.0E+0,-0.0E+0]
	xorps	%xmm10, %xmm12
	cvtss2sd	%xmm6, %xmm6
	movaps	%xmm6, %xmm0
	callq	cos
	movaps	%xmm0, %xmm8
	movaps	%xmm6, %xmm0
	callq	sin
	movaps	%xmm0, %xmm6
	cvtss2sd	%xmm7, %xmm7
	movaps	%xmm7, %xmm0
	callq	cos
	xorps	%xmm11, %xmm11
	cvtsd2ss	%xmm0, %xmm11
	movaps	%xmm7, %xmm0
	callq	sin
	xorps	%xmm2, %xmm2
	cvtsd2ss	%xmm0, %xmm2
	movaps	%xmm9, %xmm1
	mulss	%xmm11, %xmm1
	movaps	%xmm9, %xmm0
	mulss	%xmm2, %xmm0
	movss	%xmm1, (%rsi)
	movl	$0, 12(%rsi)
	movss	%xmm12, 16(%rsi)
	movlhps	%xmm6, %xmm8                    # xmm8 = xmm8[0],xmm6[0]
	cvtpd2ps	%xmm8, %xmm1
	movapd	%xmm1, %xmm3
	mulss	%xmm10, %xmm3
	movapd	%xmm1, %xmm4
	shufps	$85, %xmm1, %xmm4               # xmm4 = xmm4[1,1],xmm1[1,1]
	mulss	%xmm4, %xmm10
	unpcklps	%xmm9, %xmm9                    # xmm9 = xmm9[0,0,1,1]
	mulps	%xmm1, %xmm9
	movaps	%xmm3, %xmm5
	mulss	%xmm11, %xmm5
	movaps	%xmm4, %xmm6
	mulss	%xmm2, %xmm6
	addss	%xmm5, %xmm6
	movaps	%xmm10, %xmm5
	mulss	%xmm11, %xmm5
	movaps	%xmm1, %xmm7
	mulss	%xmm2, %xmm7
	subss	%xmm7, %xmm5
	mulss	%xmm2, %xmm3
	mulss	%xmm11, %xmm4
	subss	%xmm4, %xmm3
	mulss	%xmm2, %xmm10
	mulss	%xmm11, %xmm1
	addss	%xmm10, %xmm1
	movss	%xmm6, 4(%rsi)
	movss	%xmm5, 8(%rsi)
	movlps	%xmm9, 20(%rsi)
	movl	$0, 28(%rsi)
	movss	%xmm0, 32(%rsi)
	movss	%xmm3, 36(%rsi)
	movss	%xmm1, 40(%rsi)
	xorps	%xmm0, %xmm0
	movups	%xmm0, 44(%rsi)
	movl	$1065353216, 60(%rsi)           # imm = 0x3F800000
	movaps	32(%rsp), %xmm6                 # 16-byte Reload
	movaps	48(%rsp), %xmm7                 # 16-byte Reload
	movaps	64(%rsp), %xmm8                 # 16-byte Reload
	movaps	80(%rsp), %xmm9                 # 16-byte Reload
	movaps	96(%rsp), %xmm10                # 16-byte Reload
	movaps	112(%rsp), %xmm11               # 16-byte Reload
	movaps	128(%rsp), %xmm12               # 16-byte Reload
	addq	$144, %rsp
	popq	%rsi
	retq
	.seh_endproc
                                        # -- End function
	.def	MatrixViewEuler;
	.scl	2;
	.type	32;
	.endef
	.globl	__xmm@3f800000000000000000000000000000 # -- Begin function MatrixViewEuler
	.section	.rdata,"dr",discard,__xmm@3f800000000000000000000000000000
	.p2align	4, 0x0
__xmm@3f800000000000000000000000000000:
	.long	0x00000000                      # float 0
	.long	0x00000000                      # float 0
	.long	0x00000000                      # float 0
	.long	0x3f800000                      # float 1
	.text
	.globl	MatrixViewEuler
	.p2align	4, 0x90
MatrixViewEuler:                        # @MatrixViewEuler
.seh_proc MatrixViewEuler
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	subq	$200, %rsp
	.seh_stackalloc 200
	movaps	%xmm15, 176(%rsp)               # 16-byte Spill
	.seh_savexmm %xmm15, 176
	movaps	%xmm14, 160(%rsp)               # 16-byte Spill
	.seh_savexmm %xmm14, 160
	movaps	%xmm13, 144(%rsp)               # 16-byte Spill
	.seh_savexmm %xmm13, 144
	movaps	%xmm12, 128(%rsp)               # 16-byte Spill
	.seh_savexmm %xmm12, 128
	movaps	%xmm11, 112(%rsp)               # 16-byte Spill
	.seh_savexmm %xmm11, 112
	movaps	%xmm10, 96(%rsp)                # 16-byte Spill
	.seh_savexmm %xmm10, 96
	movaps	%xmm9, 80(%rsp)                 # 16-byte Spill
	.seh_savexmm %xmm9, 80
	movaps	%xmm8, 64(%rsp)                 # 16-byte Spill
	.seh_savexmm %xmm8, 64
	movaps	%xmm7, 48(%rsp)                 # 16-byte Spill
	.seh_savexmm %xmm7, 48
	movaps	%xmm6, 32(%rsp)                 # 16-byte Spill
	.seh_savexmm %xmm6, 32
	.seh_endprologue
	movaps	%xmm3, %xmm7
	movaps	%xmm2, %xmm6
	movq	%rdx, %rdi
	movq	%rcx, %rsi
	movss	256(%rsp), %xmm0                # xmm0 = mem[0],zero,zero,zero
	xorps	%xmm8, %xmm8
	cvtss2sd	%xmm0, %xmm8
	movaps	%xmm8, %xmm0
	callq	cos
	xorps	%xmm9, %xmm9
	cvtsd2ss	%xmm0, %xmm9
	movaps	%xmm8, %xmm0
	callq	sin
	xorps	%xmm8, %xmm8
	cvtsd2ss	%xmm0, %xmm8
	movaps	__xmm@80000000800000008000000080000000(%rip), %xmm12 # xmm12 = [-0.0E+0,-0.0E+0,-0.0E+0,-0.0E+0]
	movaps	%xmm8, %xmm10
	xorps	%xmm12, %xmm10
	cvtss2sd	%xmm7, %xmm7
	movaps	%xmm7, %xmm0
	callq	cos
	xorps	%xmm11, %xmm11
	cvtsd2ss	%xmm0, %xmm11
	movaps	%xmm7, %xmm0
	callq	sin
	xorps	%xmm7, %xmm7
	cvtsd2ss	%xmm0, %xmm7
	cvtss2sd	%xmm6, %xmm6
	movaps	%xmm6, %xmm0
	callq	cos
	xorps	%xmm13, %xmm13
	cvtsd2ss	%xmm0, %xmm13
	movaps	%xmm6, %xmm0
	callq	sin
	xorps	%xmm14, %xmm14
	cvtsd2ss	%xmm0, %xmm14
	movaps	%xmm8, %xmm0
	mulss	%xmm11, %xmm0
	movaps	%xmm8, %xmm6
	mulss	%xmm7, %xmm6
	movaps	%xmm9, %xmm2
	mulss	%xmm11, %xmm2
	movaps	%xmm9, %xmm1
	mulss	%xmm7, %xmm1
	movaps	%xmm9, %xmm3
	mulss	%xmm13, %xmm3
	movaps	%xmm0, %xmm5
	mulss	%xmm13, %xmm5
	movaps	%xmm7, %xmm4
	mulss	%xmm14, %xmm4
	addss	%xmm5, %xmm4
	movaps	%xmm6, %xmm5
	mulss	%xmm13, %xmm5
	movaps	%xmm11, %xmm15
	mulss	%xmm14, %xmm15
	subss	%xmm15, %xmm5
	mulss	%xmm14, %xmm9
	mulss	%xmm14, %xmm0
	mulss	%xmm13, %xmm7
	subss	%xmm7, %xmm0
	mulss	%xmm14, %xmm6
	mulss	%xmm13, %xmm11
	addss	%xmm6, %xmm11
	movss	(%rdi), %xmm14                  # xmm14 = mem[0],zero,zero,zero
	movss	4(%rdi), %xmm7                  # xmm7 = mem[0],zero,zero,zero
	movaps	%xmm14, %xmm6
	mulss	%xmm3, %xmm6
	movaps	%xmm7, %xmm15
	mulss	%xmm4, %xmm15
	addss	%xmm6, %xmm15
	movss	8(%rdi), %xmm6                  # xmm6 = mem[0],zero,zero,zero
	movaps	%xmm6, %xmm13
	mulss	%xmm5, %xmm13
	addss	%xmm15, %xmm13
	xorps	%xmm12, %xmm13
	movaps	%xmm7, %xmm15
	mulss	%xmm2, %xmm15
	mulss	%xmm14, %xmm8
	subss	%xmm15, %xmm8
	movaps	%xmm6, %xmm15
	mulss	%xmm1, %xmm15
	subss	%xmm15, %xmm8
	mulss	%xmm9, %xmm14
	mulss	%xmm0, %xmm7
	addss	%xmm14, %xmm7
	mulss	%xmm11, %xmm6
	addss	%xmm7, %xmm6
	xorps	%xmm12, %xmm6
	movss	%xmm3, (%rsi)
	movss	%xmm10, 4(%rsi)
	movss	%xmm9, 8(%rsi)
	movss	%xmm13, 12(%rsi)
	movss	%xmm4, 16(%rsi)
	movss	%xmm2, 20(%rsi)
	movss	%xmm0, 24(%rsi)
	movss	%xmm8, 28(%rsi)
	movss	%xmm5, 32(%rsi)
	movss	%xmm1, 36(%rsi)
	movss	%xmm11, 40(%rsi)
	movss	%xmm6, 44(%rsi)
	movaps	__xmm@3f800000000000000000000000000000(%rip), %xmm0 # xmm0 = [0.0E+0,0.0E+0,0.0E+0,1.0E+0]
	movups	%xmm0, 48(%rsi)
	movaps	32(%rsp), %xmm6                 # 16-byte Reload
	movaps	48(%rsp), %xmm7                 # 16-byte Reload
	movaps	64(%rsp), %xmm8                 # 16-byte Reload
	movaps	80(%rsp), %xmm9                 # 16-byte Reload
	movaps	96(%rsp), %xmm10                # 16-byte Reload
	movaps	112(%rsp), %xmm11               # 16-byte Reload
	movaps	128(%rsp), %xmm12               # 16-byte Reload
	movaps	144(%rsp), %xmm13               # 16-byte Reload
	movaps	160(%rsp), %xmm14               # 16-byte Reload
	movaps	176(%rsp), %xmm15               # 16-byte Reload
	addq	$200, %rsp
	popq	%rdi
	popq	%rsi
	retq
	.seh_endproc
                                        # -- End function
	.addrsig
	.globl	_fltused
