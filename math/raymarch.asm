%include "common.inc"

DefFunc _RaymarchTerrainAltitude
	FrameBegin ebx, esi, edi
	NameParams %$Map, %$TerrainHeight, %$TerrainSize
	NameParams %$NumIter
	NameParams %$StartX, %$StartY, %$StartZ
	NameParams %$DirX, %$DirY, %$DirZ
	NameParams %$MaxDist, %$RetDist
	DefVars %$Sampled, %$Dist, %$LastDir, %$IsHit, %$StepMod, %$Zero
	DefVars %$PosX, %$PosY, %$PosZ, %$PosW
	DefVars %$VecX, %$VecY, %$VecZ, %$VecW

	xor eax, eax
	mov ecx, %$Frame_NumLocals
	lea edi, Variable(0)
	rep stosd

	mov eax, [_2.0f]
	mov %$StepMod, eax

	mov ebx, %$Map
	xor esi, esi
	mov edi, %$RetDist

	movss xmm0, %$StartY
	ucomiss xmm0, %$TerrainHeight
	jbe .proceed_raymarch

	movss xmm0, %$TerrainHeight
	movss xmm1, %$DirY
	subss xmm0, %$StartY
	divss xmm0, xmm1
	movss %$Dist, xmm0

	ucomiss xmm1, [_ZeroVector]
	jb .proceed_raymarch
.too_far:
	mov eax, %$MaxDist
	stosd
	xor eax, eax
	jmp .end
.proceed_raymarch:
	rcpss xmm6, %$TerrainSize
	movups xmm0, %$StartX
	movss xmm2, %$Dist
	movups xmm1, %$DirX
	shufps xmm6, xmm6, 0 ;1/Size
	shufps xmm2, xmm2, 0 ;Dist
	mulps xmm2, xmm1 ;Dir * Dist
	addps xmm2, xmm0 ;Start + Dir * Dist
	movups %$PosX, xmm2
	mulps xmm2, xmm6
	movups %$VecX, xmm2

	invoke_cdecl _SampleFloatMap, ebx, %$VecX, %$VecZ, & %$Sampled
	movss xmm0, %$Sampled
	mulss xmm0, %$TerrainHeight
	ucomiss xmm0, %$PosY
	jb .penetrated
	movss xmm1, [_0.01f]
	addss xmm1, xmm0
	ucomiss xmm1, %$PosY
	jb .not_hit
.return_dist:
	mov eax, %$Dist
	stosd
	xor eax, eax
	inc eax
	jmp .end
.not_hit:
	movss xmm1, %$PosY
	movss xmm3, %$Dist
	subss xmm1, xmm0
	divss xmm1, %$StepMod
	addss xmm1, xmm3
	movss %$Dist, xmm1
	ucomiss xmm1, %$MaxDist
	jae .too_far
	xor eax, eax
	cmp %$LastDir, eax
	jz .next_loop
	mov %$LastDir, eax
.inc_step_mod:
	movss xmm0, %$StepMod
	addss xmm0, [_F1111]
	movss %$StepMod, xmm0
	jmp .next_loop
.penetrated:
	mov byte %$IsHit, 1
	movss xmm1, %$Dist
	subss xmm0, %$PosY
	divss xmm0, %$StepMod
	subss xmm1, xmm0
	movss %$Dist, xmm1
	ucomiss xmm1, %$Zero
	ja .above_surface
.return_zero:
	xor eax, eax
	stosd
	jmp .end
.above_surface:
	movss xmm0, %$StepMod
	ucomiss xmm0, [_F8888]
	jae .return_dist
	cmp dword %$LastDir, 0
	jnz .next_loop
	inc dword %$LastDir
	jmp .inc_step_mod
.next_loop:
	inc esi
	cmp esi, %$NumIter
	jb .proceed_raymarch
	movss xmm0, %$Dist
	ucomiss xmm0, %$MaxDist
	jb .return_dist

	mov eax, %$IsHit
	test eax, eax
	jz .too_far
	jmp .return_dist

.end:
	FrameEnd
	ret
