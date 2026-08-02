%include "common.inc"

DefFunc _RaymarchTerrainAltitude
	FrameBegin esi, edi
	NameParams %$HeightMap, %$ConeMap, %$TerrainHeight, %$TerrainSize
	NameParams %$NumIter
	NameParams %$StartX, %$StartY, %$StartZ
	NameParams %$DirX, %$DirY, %$DirZ
	NameParams %$MaxDist, %$RetDist
	DefVars %$PosX, %$PosY, %$PosZ, %$PosW
	DefVars %$VecX, %$VecY, %$VecZ, %$VecW
	DefVars %$Sampled, %$Dist, %$Zero
	DefVars %$CurAltHeight, %$TerrainSizeRCP, %$ConeMultVal

	xor eax, eax
	mov ecx, %$Frame_NumLocals
	lea edi, Variable(0)
	rep stosd

	xor esi, esi
	mov edi, %$RetDist

	rcpss xmm0, %$TerrainSize
	movss xmm1, %$DirX
	movss xmm2, %$DirZ
	movss %$TerrainSizeRCP, xmm0
	mulss xmm1, xmm1
	mulss xmm2, xmm2
	mulss xmm0, %$TerrainHeight
	addss xmm1, xmm2
	sqrtss xmm1, xmm1
	mulss xmm0, xmm1
	movss %$ConeMultVal, xmm0

	movss xmm0, %$StartY
	ucomiss xmm0, %$TerrainHeight
	jbe .proceed_raymarch

	movss xmm0, %$TerrainHeight
	movss xmm1, %$DirY
	subss xmm0, %$StartY
	divss xmm0, xmm1
	movss %$Dist, xmm0

	ucomiss xmm1, %$Zero
	jb .proceed_raymarch
.too_far:
	mov eax, %$MaxDist
	stosd
	xor eax, eax
	jmp .end
.proceed_raymarch:
	movss xmm6, %$TerrainSizeRCP
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

	invoke_cdecl _SampleFloatMap, %$HeightMap, %$VecX, %$VecZ, & %$Sampled
	movss xmm0, %$Sampled
	movss xmm1, [_0.01f]
	mulss xmm0, %$TerrainHeight
	movss %$CurAltHeight, xmm0
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
	invoke_cdecl _SampleFloatMap, %$ConeMap, %$VecX, %$VecZ, & %$Sampled
	movss xmm0, %$PosY
	movss xmm1, %$Sampled
	subss xmm0, %$CurAltHeight
	mulss xmm1, %$ConeMultVal
	subss xmm1, %$DirY
	divss xmm0, xmm1
	ucomiss xmm0, %$Zero
	jb .too_far
	addss xmm0, %$Dist
	ucomiss xmm0, %$MaxDist
	ja .too_far
	movss %$Dist, xmm0

	inc esi
	cmp esi, %$NumIter
	jb .proceed_raymarch

	movss xmm0, %$Dist
	ucomiss xmm0, %$MaxDist
	jb .return_dist
	jmp .too_far

.end:
	FrameEnd
	ret
