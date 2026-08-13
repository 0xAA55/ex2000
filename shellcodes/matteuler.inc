%include "common.inc"

DefFunc _MatrixEulerTranslated
	FrameBegin edi
	NameParams %$Out, %$Translation, %$Yaw, %$Pitch, %$Roll

	mov edi, %$Out
	invoke_cdecl _MatrixRotationEuler, edi, %$Yaw, %$Pitch, %$Roll
	mov ecx, %$Translation
	jecxz .end
	mov eax, 0xFFFFFFFF
	movaps xmm0, [ecx]
	movd xmm1, eax
	shufps xmm1, xmm1, _MM_SHUFFLE(1, 0, 0, 0)
	andps xmm0, xmm1
	addps xmm0, [edi + Matrix.w]
	movaps [edi + Matrix.w], xmm0

.end:
	FrameEnd
	ret
