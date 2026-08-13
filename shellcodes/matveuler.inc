
DefFunc _MatrixViewEuler
	FrameBegin ebx, esi, edi
	NameParams %$Out, %$Pos, %$Yaw, %$Pitch, %$Roll
	DefSizedVar %$MatrixBuffer, 0x20 + Matrix.size

	mov edi, %$Out
	lea esi, Variable(4)
	and esi, 0xFFFFFFF0
	lea ebx, [esi + Matrix.size]

	mov eax, %$Pos
	mov ecx, __?float32?__(-1.0)
	movups xmm0, [eax]
	movd xmm1, ecx
	shufps xmm1, xmm1, 0
	mulps xmm0, xmm1
	movaps [ebx], xmm0

	invoke_cdecl _MatrixRotationEuler, esi, %$Yaw, %$Pitch, %$Roll
	invoke_cdecl _MatrixTranspose, edi, esi
	invoke_cdecl _VectorDot, &[edi + Matrix.wx], &[esi + Matrix.x], ebx, 3
	invoke_cdecl _VectorDot, &[edi + Matrix.wy], &[esi + Matrix.y], ebx, 3
	invoke_cdecl _VectorDot, &[edi + Matrix.wz], &[esi + Matrix.z], ebx, 3

	FrameEnd
	ret
