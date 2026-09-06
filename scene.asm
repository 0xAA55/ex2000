%include "loaddll.inc"
%include "timer.inc"
%include "vblank.inc"
%include "gl33.inc"
%include "buffer.inc"
%include "assets.inc"
%include "shader.inc"
%include "math.inc"
%include "fontgl.inc"
%include "hrsleep.inc"
%include "shellcode.inc"
%include "scene.inc"

extern _hWnd
extern _hDC

%define DefExp extern
InstExp
%undef DefExp

segment .bss
extern _CurTextureQuality
_CurTextureQuality resd 1

extern _BillboardVerticesBuffer
_BillboardVerticesBuffer:
	InstGlBuffer

extern _DrawBillboardVAO
_DrawBillboardVAO resd 1

extern _TerrainTexture
_TerrainTexture resd 1

extern _TerrainTextureMipLinear
_TerrainTextureMipLinear resd 1

extern _TerrainConeTexture
_TerrainConeTexture resd 1

extern _DrawTerrainFBO
extern _DrawTerrainHalfSizeFBO
extern _DrawWaterFBO
extern _DrawWaterHalfSizeFBO
extern _CompositeFBO
extern _HDRBlurFBO

_FirstFBO:
_DrawTerrainFBO resd 1
_DrawTerrainHalfSizeFBO resd 1
_DrawWaterFBO resd 1
_DrawWaterHalfSizeFBO resd 1
_CompositeFBO resd 1
_HDRBlurFBO resd 1
_NumFBOs equ ($ - _FirstFBO) / 4

extern _CompositeDepthBuffer
_CompositeDepthBuffer resd 1

extern _CompositeHalfSizeDepthBuffer
_CompositeHalfSizeDepthBuffer resd 1

extern _SSTextures
extern _SSHalfSizeTextures

_SSTextures:
	InstSSTextures

_SSHalfSizeTextures:
	InstSSTextures

extern _HDRLensTexture
_HDRLensTexture resd 1

extern _HDRBlurTexture
_HDRBlurTexture resd 1

extern _RTTBufferSize
_RTTBufferSize:
	.w resw 1
	.h resw 1

extern _Timer
_Timer:
	InstTimer

extern _DrawProgressProgram
_DrawProgressProgram resd 1

extern _DrawTerrainProgram
_DrawTerrainProgram resd 1

extern _DrawWaterProgram
_DrawWaterProgram resd 1

extern _DrawCompositeProgram
_DrawCompositeProgram resd 1

extern _DrawHDR2LDRProgram
_DrawHDR2LDRProgram resd 1

extern _DrawBlurProgram
_DrawBlurProgram resd 1

extern _ProgressProgramLocations
_ProgressProgramLocations:
	.Progress resd 1

extern _DrawTerrainProgramLocations
_DrawTerrainProgramLocations:
	InstDrawTerrainProgramLocations

extern _DrawWaterProgramLocations
_DrawWaterProgramLocations:
	InstDrawWaterProgramLocations

extern _DrawCompositeProgramLocations
_DrawCompositeProgramLocations:
	InstDrawCompositeProgramLocations

extern _DrawBlurProgramLocations
_DrawBlurProgramLocations:
	InstDrawBlurProgramLocations

extern _DrawHDR2LDRProgramLocations
_DrawHDR2LDRProgramLocations:
	InstDrawHDR2LDRProgramLocations

extern _MinPitch
_MinPitch resd 1

extern _MaxPitch
_MaxPitch resd 1

extern _NoiseBitmap
_NoiseBitmap resd 1

extern _TerrainBitmap
_TerrainBitmap resd 1

extern _TerrainConeBitmap
_TerrainConeBitmap resd 1

extern _SceneLoadingProgress
_SceneLoadingProgress resd 1

extern _CameraYaw
_CameraYaw resd 1

extern _CameraPitch
_CameraPitch resd 1

extern _Aspect
_Aspect resd 1

extern _FovY
_FovY resd 1

extern _SeaLevel
_SeaLevel resd 1

extern _OGLFC
_OGLFC resd 1

extern _DayTime
_DayTime resd 1

extern _VBlankData
_VBlankData:
	InstVBlankData

segment .bss
alignb 16
extern _ModelMatrix
_ModelMatrix:
	InstMatrix

extern _ViewProjMatrix
_ViewProjMatrix:
	InstMatrix

extern _CameraMatrix
_CameraMatrix:
	InstMatrix

extern _CameraViewMatrix
_CameraViewMatrix:
	InstMatrix

extern _ProjectionMatrix
_ProjectionMatrix:
	InstMatrix

extern _MovementSpeed
_MovementSpeed:
	InstVector

extern _CameraPos
_CameraPos:
	InstVector

extern _SunPosition
_SunPosition:
	InstVector

extern _TerrainMapScalingVector
_TerrainMapScalingVector:
	InstVector

extern _ClientRect
_ClientRect:
	InstRECT

extern _WindowRect
_WindowRect:
	InstRECT

extern _WindowCenter
_WindowCenter:
.x resd 1
.y resd 1

extern _CursorPos
_CursorPos:
.x resd 1
.y resd 1

segment .rdata
extern _TerrainCurvePoints
_TerrainCurvePoints:
istruc CurvePoint
	at .volume, dd 0.45 ;Deep pit
	at .weight, dd 0.1
iend
istruc CurvePoint
	at .volume, dd 0.1 ;Slope to the pit
	at .weight, dd 0.1
iend
istruc CurvePoint
	at .volume, dd 0.05 ;Seabed
	at .weight, dd 0.2
iend
istruc CurvePoint
	at .volume, dd 0.1 ;Shore
	at .weight, dd 0.3
iend
istruc CurvePoint
	at .volume, dd 0.3 ;Mountains
	at .weight, dd 0.3
iend
.num_points equ ($ - _TerrainCurvePoints) / CurvePoint.size

extern _DefaultMovementSpeed
_DefaultMovementSpeed dd 100.0

extern _TerrainMapScaling
_TerrainMapScaling dd 2000.0

extern _TerrainMapHeight
_TerrainMapHeight dd 200.0

extern _CurveToSeaLevel
_CurveToSeaLevel dd 0.62

extern _FovDegree
_FovDegree dw 60
extern _PiDegree
_PiDegree dw 180

extern _BillBoardVertices
_BillBoardVertices:
	db 0, 0
	db 1, 0
	db 0, 1
	db 1, 1
.num equ $ - _BillBoardVertices

segment .rdata
extern _StrBestQuality
extern _StrMidQuality
extern _StrLowQuality
extern _StrWorstQuality
_StrBestQuality db '高', 0
_StrMidQuality db '中', 0
_StrLowQuality db '低', 0
_StrWorstQuality db '最低', 0
extern _PtrStrQualities
_PtrStrQualities:
	dd _StrWorstQuality
	dd _StrLowQuality
	dd _StrMidQuality
	dd _StrBestQuality

;int SceneInit();
DefFunc _SceneInit
	FrameBegin ebx, esi

	invoke_cdecl _InitTimer, _Timer
	invoke_cdecl _VBlankInit, _VBlankData
	invoke_cdecl _SceneLoadInitProgress

	mov byte[_CurTextureQuality], 3

	fldpi
	fdiv dword [_2.0f]
	fst dword [_MaxPitch]
	fchs
	fstp dword [_MinPitch]

	fild word [_FovDegree]
	fidiv word [_PiDegree]
	fldpi
	fmul
	fstp dword [_FovY]

	fld dword [_TerrainMapHeight]
	fmul dword [_CurveToSeaLevel]
	fstp dword [_SeaLevel]

	mov ebx, _DrawProgressProgram
	SceneLoadShaderProgram ebx, \
		GL_VERTEX_SHADER, str "assets\loading.vsh", \
		GL_FRAGMENT_SHADER, str "assets\loading.fsh"
	test eax, eax
	jz .end

	invoke_cdecl _InitBuffer, _BillboardVerticesBuffer, GL_ARRAY_BUFFER, GL_STATIC_DRAW, 2, _BillBoardVertices.num / 2, _BillBoardVertices

	invoke_dll_stdcall glGenVertexArrays, 1, _DrawBillboardVAO
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_BillboardVerticesBuffer.gl_buffer]
	GetAttribLocation [ebx], "position"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, 0
	invoke_dll_stdcall glBindVertexArray, 0

	GetUniformLocation [ebx], "progress"
	mov [_ProgressProgramLocations.Progress], eax

	invoke_dll_stdcall glGenFramebuffers, _NumFBOs, _FirstFBO

	invoke_cdecl _OGLFC_Create, [_hDC], 12
	mov [_OGLFC], eax

	mov dword [_CameraPos + Vector.y], __float32__(200.0)

	xor eax, eax
	mov [_SceneLoadingProgress], eax
	mov al, 1
.end:
	FrameEnd
	ret

DefFunc _SceneLoad00
	FrameBegin
	invoke_cdecl _GenMultiLayerPerlinAltitude, 1024, 1.0f, 7, 200.0f, 0
	mov [_NoiseBitmap], eax
	FrameEnd
	ret

DefFunc _SceneLoad01
	FrameBegin ebx
	invoke_cdecl _DuplicateBitMap, [_NoiseBitmap]
	mov ebx, eax
	mov [_TerrainBitmap], eax
	invoke_cdecl _FloatMapCurve, ebx, _TerrainCurvePoints, _TerrainCurvePoints.num_points
	FrameEnd
	ret

DefFunc _SceneLoad02
	FrameBegin
	invoke_cdecl _ConeMapGen, [_TerrainBitmap], 0
	mov [_TerrainConeBitmap], eax
	FrameEnd
	ret

DefFunc _SceneLoad03
	FrameBegin ebx
	mov ebx, [_TerrainBitmap]
	invoke_dll_stdcall glGenTextures, 1, _TerrainTexture
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainTexture]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_R32F, [ebx + BitMap.border_len], [ebx + BitMap.border_len], 0, GL_RED, GL_FLOAT, [ebx + BitMap.data]
	invoke_cdecl _InitTexRepeatLinear, GL_TEXTURE_2D
	mov ebx, [_NoiseBitmap]
	invoke_dll_stdcall glGenTextures, 1, _TerrainTextureMipLinear
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainTextureMipLinear]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_R32F, [ebx + BitMap.border_len], [ebx + BitMap.border_len], 0, GL_RED, GL_FLOAT, [ebx + BitMap.data]
	invoke_cdecl _InitTexRepeatLinearMipmap, GL_TEXTURE_2D
	invoke_cdecl _DestroyBitMap, ebx
	xor eax, eax
	mov [_NoiseBitmap], eax
	mov ebx, [_TerrainConeBitmap]
	invoke_dll_stdcall glGenTextures, 1, _TerrainConeTexture
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainConeTexture]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_R32F, [ebx + BitMap.border_len], [ebx + BitMap.border_len], 0, GL_RED, GL_FLOAT, [ebx + BitMap.data]
	invoke_cdecl _InitTexRepeatLinear, GL_TEXTURE_2D
	FrameEnd
	ret

DefFunc _SceneLoad04
	FrameBegin
	mov dword[_DayTime], __float32__(0.3333)
	invoke_cdecl _SceneLoadDrawTerrainProgram, _DrawTerrainProgram, _DrawTerrainProgramLocations, [_DrawBillboardVAO], [_BillboardVerticesBuffer.gl_buffer]
	test eax, eax
	jz .bad_end
	invoke_cdecl _SceneLoadDrawWaterProgram, _DrawWaterProgram, _DrawWaterProgramLocations, [_DrawBillboardVAO], [_BillboardVerticesBuffer.gl_buffer]
	test eax, eax
	jz .bad_end
	invoke_cdecl _SceneLoadDrawCompositeProgram, _DrawCompositeProgram, _DrawCompositeProgramLocations, [_DrawBillboardVAO], [_BillboardVerticesBuffer.gl_buffer]
	test eax, eax
	jz .bad_end
	invoke_cdecl _SceneLoadDrawBlurProgram, _DrawBlurProgram, _DrawBlurProgramLocations, [_DrawBillboardVAO], [_BillboardVerticesBuffer.gl_buffer]
	test eax, eax
	invoke_cdecl _SceneLoadDrawHDR2LDRProgram, _DrawHDR2LDRProgram, _DrawHDR2LDRProgramLocations, [_DrawBillboardVAO], [_BillboardVerticesBuffer.gl_buffer]
	test eax, eax
	jz .bad_end
	jmp .end
.bad_end:
	dec eax
	mov [_SceneLoadingProgress], eax
.end:
	FrameEnd
	ret

DefFunc _SceneLoad05
	FrameBegin
	FrameEnd
	ret

DefFunc _SceneLoad06
	FrameBegin
	FrameEnd
	ret

DefFunc _SceneLoad07
	FrameBegin
	FrameEnd
	ret

DefFunc _SceneLoad08
	FrameBegin
	FrameEnd
	ret

DefFunc _SceneLoad09
	FrameBegin
	FrameEnd
	ret

DefFunc _SceneLoad0A
	FrameBegin
	FrameEnd
	ret

DefFunc _SceneLoad0B
	FrameBegin
	FrameEnd
	ret

DefFunc _SceneLoadProgressive
	FrameBegin ebx

	mov ebx, [_SceneLoadingProgress]
	cmp ebx, 0
	jl .end
	cmp ebx, _NumItemsToLoad
	jge .end
.load:
	invoke_cdecl [_SceneLoadProgress.load_sequences + ebx * 4]
	cmp eax, 0
	jl .end
	inc ebx
	mov [_SceneLoadingProgress], ebx
.end:
	mov eax, [_SceneLoadingProgress]
	FrameEnd
	ret

extern _SceneLoadProgress
_SceneLoadProgress:
segment .bss
.load_sequences:
segment .rdata
.loadseq_materials:

%assign num_loadseq 0
%assign num_loadseq_mat 0
%macro insert_loadseq 2
	%assign num_loadseq num_loadseq + %1
	%assign num_loadseq_mat num_loadseq_mat + 1
segment .rdata
	db %1
	dd %2
segment .bss
	resd %1
%endmacro

insert_loadseq 0x01, _SceneLoad00
insert_loadseq 0x01, _SceneLoad01
insert_loadseq 0x01, _SceneLoad02
insert_loadseq 0x01, _SceneLoad03
insert_loadseq 0x01, _SceneLoad04
insert_loadseq 0x01, _SceneLoad05
insert_loadseq 0x01, _SceneLoad06
insert_loadseq 0x01, _SceneLoad07
insert_loadseq 0x01, _SceneLoad08
insert_loadseq 0x01, _SceneLoad09
insert_loadseq 0x01, _SceneLoad0A
insert_loadseq 0x01, _SceneLoad0B
extern _NumItemsToLoad
_NumItemsToLoad equ num_loadseq

DefFunc _SceneLoadInitProgress
	FrameBegin esi, edi

	xor ecx, ecx
	mov edx, ecx
	mov esi, _SceneLoadProgress.loadseq_materials
	mov edi, _SceneLoadProgress.load_sequences
.loop_setseq:
	mov cl, [esi]
	mov eax, [esi + 1]
	add esi, 5
	rep stosd
	inc edx
	cmp edx, num_loadseq_mat
	jb .loop_setseq

	FrameEnd
	ret

DefFunc _SceneUnload
	FrameBegin esi

	invoke_cdecl _VBlankDeInit, _VBlankData

	invoke_cdecl _DeInitBuffer, _BillboardVerticesBuffer
	invoke_cdecl _DestroyBitMap, [_TerrainBitmap]
	invoke_cdecl _DestroyBitMap, [_TerrainConeBitmap]

	invoke_cdecl _OGLFC_Destroy, [_OGLFC]

	invoke_dll_stdcall glDeleteFramebuffers, _NumFBOs, _FirstFBO

	invoke_cdecl _DeleteRenderbuffer, _CompositeDepthBuffer
	invoke_cdecl _DeleteRenderbuffer, _CompositeHalfSizeDepthBuffer

	invoke_cdecl _DeleteTexture, _TerrainTexture
	invoke_cdecl _DeleteTexture, _TerrainTextureMipLinear
	invoke_cdecl _DeleteTexture, _TerrainConeTexture
	invoke_cdecl _DeInitSSTextureSets, _SSTextures
	invoke_cdecl _DeInitSSTextureSets, _SSHalfSizeTextures
	invoke_cdecl _DeleteTexture, _HDRLensTexture
	invoke_cdecl _DeleteTexture, _HDRBlurTexture

	invoke_cdecl _SceneOnDisposeShaders

	invoke_cdecl _DeleteProgram, _DrawProgressProgram
	invoke_cdecl _DeleteProgram, _DrawTerrainProgram
	invoke_cdecl _DeleteProgram, _DrawWaterProgram
	invoke_cdecl _DeleteProgram, _DrawCompositeProgram
	invoke_cdecl _DeleteProgram, _DrawBlurProgram
	invoke_cdecl _DeleteProgram, _DrawHDR2LDRProgram

	invoke_dll_stdcall glDeleteVertexArrays, 1, _DrawBillboardVAO

	xor edx, edx
	mov ecx, .num_set_to_NULL
	mov esi, .set_to_NULL
.loop_set_to_NULL:
	lodsd
	mov [eax], edx
	dec ecx
	jnz .loop_set_to_NULL

	FrameEnd
	ret
[segment .rdata]
.set_to_NULL:
	dd _TerrainBitmap
	dd _TerrainConeBitmap
	dd _OGLFC
	dd _DrawTerrainFBO
	dd _DrawTerrainHalfSizeFBO
	dd _DrawWaterFBO
	dd _DrawWaterHalfSizeFBO
	dd _CompositeFBO
	dd _DrawBillboardVAO
.num_set_to_NULL equ ($ - .set_to_NULL) / 4

DefFunc _Scene_OnKeyDown
	FrameBegin
	NameParams %$KeyCode

	mov eax, %$KeyCode
	cmp eax, VK_PAGEUP
	jz .pageup
	cmp eax, VK_PAGEDN
	jz .pagedn
	jmp .end
.pageup:
	mov eax, [_CurTextureQuality]
	inc eax
	and eax, 3
	mov [_CurTextureQuality], eax
	jmp .end
.pagedn:
	mov eax, [_CurTextureQuality]
	dec eax
	and eax, 3
	mov [_CurTextureQuality], eax
	jmp .end
.end:
	FrameEnd
	ret

DefFunc _Scene_OnKeyUp
	FrameBegin
	NameParams %$KeyCode

	FrameEnd
	ret

DefFunc _Scene
	FrameBegin ebx, esi, edi
	DefVars %$TimerValue32, %$DeltaTimeL, %$DeltaTimeH, %$DeltaTime32
	DefVars %$VPSize
	DefVars %$VPWidth, %$VPHeight
	DefVars %$VPWidthHalf, %$VPHeightHalf
	DefVars %$VPWidthLow, %$VPHeightLow
	DefVars %$CurMovementSpeed, %$FramesPerSec

[segment .rdata]
.keys_to_detect db 'WSAD', VK_SPACE, VK_CONTROL, VK_ESCAPE, 0
.num_keys_to_detect equ $ - .keys_to_detect
__SECT__
	DefVars %$KeyW, %$KeyS, %$KeyA, %$KeyD, %$KeySpace, %$KeyCtrl, %$KeyEscape

	xor eax, eax
	mov ecx, %$Frame_NumLocals
	lea edi, Variable(0)
	rep stosd

	fld qword [_Timer.TimerVal]
	fstp qword %$DeltaTimeL
	invoke_cdecl _UpdateTimer, _Timer
	fst dword %$TimerValue32
	fsub qword %$DeltaTimeL
	fst qword %$DeltaTimeL
	fstp dword %$DeltaTime32

	invoke_dll_stdcall GetClientRect, [_hWnd], _ClientRect
	movq xmm0, [_ClientRect.left]
	movq xmm1, [_ClientRect.right]
	movq [_WindowRect.left], xmm0
	movq [_WindowRect.right], xmm1
	invoke_dll_stdcall ClientToScreen, [_hWnd], _WindowRect.left
	invoke_dll_stdcall ClientToScreen, [_hWnd], _WindowRect.right
	invoke_dll_stdcall GetCursorPos, _CursorPos

	mov eax, [_ClientRect.bottom]
	cmp eax, [_ClientRect.top]
	jbe .end_after_swap_buffers

	mov eax, [_ClientRect.right]
	mov ecx, [_ClientRect.bottom]
	sub eax, [_ClientRect.left]
	sub ecx, [_ClientRect.top]
	cvtsi2ss xmm0, eax
	cvtsi2ss xmm1, ecx
	mov %$VPWidth, eax
	mov %$VPHeight, ecx
	divss xmm0, xmm1
	movss [_Aspect], xmm0
	shl ecx, 16
	or eax, ecx
	mov %$VPSize, eax
	xor edx, edx
	inc edx
	mov eax, %$VPWidth
	mov ecx, %$VPHeight
	shr eax, 1
	shr ecx, 1
	cmp eax, edx
	cmovb eax, edx
	cmp ecx, edx
	cmovb ecx, edx
	mov %$VPWidthHalf, eax
	mov %$VPHeightHalf, ecx
	shr eax, 1
	shr ecx, 1
	cmp eax, edx
	cmovb eax, edx
	cmp ecx, edx
	cmovb ecx, edx
	mov %$VPWidthLow, eax
	mov %$VPHeightLow, ecx

	invoke_cdecl _SceneLoadProgressive
	mov ebx, _NumItemsToLoad
	cmp eax, ebx
	jz .loaded

	cmp eax, 0
	jl .quit

	invoke_dll_stdcall glViewport, [_ClientRect.left], [_ClientRect.top], [_ClientRect.right], [_ClientRect.bottom]
	invoke_cdecl _Scene_clear_color

	invoke_dll_stdcall glUseProgram, [_DrawProgressProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	cvtsi2ss xmm0, [_SceneLoadingProgress]
	cvtsi2ss xmm1, ebx
	divss xmm0, xmm1
	invoke_dll_stdcall glUniform1f, [_ProgressProgramLocations.Progress], xmm0.x
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4

	invoke_cdecl _SwapBuffersNoVSync
	jmp .end_after_swap_buffers
.loaded:

	invoke_dll_stdcall GetForegroundWindow
	cmp eax, [_hWnd]
	jnz .after_check_input
	mov esi, .keys_to_detect
	lea edi, %$KeyW
.loop_check_keys:
	xor eax, eax
	lodsb
	test eax, eax
	jz .after_check_keys
	invoke_dll_stdcall GetAsyncKeyState, eax
	stosd
	jmp .loop_check_keys
.after_check_keys:
	cmp dword %$KeyEscape, 0
	jnz .quit

	movq xmm1, [_WindowRect.right]
	movq xmm0, [_CursorPos]
	paddd xmm1, [_WindowRect.left]
	movq xmm2, [_CameraYaw]
	psrad xmm1, 1
	movq xmm3, [_point_001_vector]
	movq [_WindowCenter.x], xmm1
	cvtdq2ps xmm0, xmm0
	cvtdq2ps xmm1, xmm1
	subps xmm0, xmm1
	mulps xmm0, xmm3
	subps xmm2, xmm0
	ucomiss xmm2, [_Pi_P]
	jbe .pi_p
	subss xmm2, [_2Pi]
.pi_p:
	ucomiss xmm2, [_Pi_N]
	jae .pi_n
	addss xmm2, [_2Pi]
.pi_n:
	movq [_CameraYaw], xmm2
	movss xmm0, [_CameraPitch]
	maxss xmm0, [_MinPitch]
	minss xmm0, [_MaxPitch]
	movss [_CameraPitch], xmm0

	invoke_dll_stdcall SetCursorPos, [_WindowCenter.x], [_WindowCenter.y]
.after_check_input:

	mov eax, %$VPSize
	cmp eax, [_RTTBufferSize]
	jz .rtt_size_good

	invoke_cdecl _DeleteRenderbuffer, _CompositeDepthBuffer
	invoke_cdecl _DeleteRenderbuffer, _CompositeHalfSizeDepthBuffer

	invoke_cdecl _InitSSTextureSets, _SSTextures, %$VPWidth, %$VPHeight
	invoke_cdecl _InitSSTextureSets, _SSHalfSizeTextures, %$VPWidthHalf, %$VPHeightHalf

	invoke_cdecl _InitRGBA32FBufferTexture, _HDRLensTexture, %$VPWidth, %$VPHeight
	invoke_cdecl _InitTexRenderTarget, GL_TEXTURE_2D
	invoke_cdecl _InitRGBA32FBufferTexture, _HDRBlurTexture, %$VPWidthLow, %$VPHeightLow
	invoke_cdecl _InitTexRenderTarget, GL_TEXTURE_2D

	invoke_cdecl _InitDepthBuffer, _CompositeDepthBuffer, %$VPWidth, %$VPHeight
	invoke_cdecl _InitDepthBuffer, _CompositeHalfSizeDepthBuffer, %$VPWidthHalf, %$VPHeightHalf

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_DrawTerrainFBO]
	invoke_cdecl _SetupSSFBOOutputs, _SSTextures, _DrawTerrainProgramLocations.first_output
	invoke_dll_stdcall glFramebufferRenderbuffer, GL_DRAW_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, [_CompositeDepthBuffer]
	invoke_cdecl _Scene_check_fbo
	test eax, eax
	jz .quit

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_DrawWaterFBO]
	invoke_cdecl _SetupSSFBOOutputs, _SSTextures, _DrawWaterProgramLocations.first_output
	invoke_dll_stdcall glFramebufferRenderbuffer, GL_DRAW_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, [_CompositeDepthBuffer]
	invoke_cdecl _Scene_check_fbo
	test eax, eax
	jz .quit

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_DrawTerrainHalfSizeFBO]
	invoke_cdecl _SetupSSFBOOutputs, _SSHalfSizeTextures, _DrawTerrainProgramLocations.first_output
	invoke_dll_stdcall glFramebufferRenderbuffer, GL_DRAW_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, [_CompositeHalfSizeDepthBuffer]
	invoke_cdecl _Scene_check_fbo
	test eax, eax
	jz .quit

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_DrawWaterHalfSizeFBO]
	invoke_cdecl _SetupSSFBOOutputs, _SSHalfSizeTextures, _DrawWaterProgramLocations.first_output
	invoke_dll_stdcall glFramebufferRenderbuffer, GL_DRAW_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, [_CompositeHalfSizeDepthBuffer]
	invoke_cdecl _Scene_check_fbo
	test eax, eax
	jz .quit

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_CompositeFBO]
	mov eax, [_DrawCompositeProgramLocations.OutColor]
	add eax, GL_COLOR_ATTACHMENT0
	invoke_dll_stdcall glFramebufferTexture2D, GL_DRAW_FRAMEBUFFER, eax, GL_TEXTURE_2D, [_HDRLensTexture], 0
	invoke_dll_stdcall glFramebufferRenderbuffer, GL_DRAW_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, [_CompositeDepthBuffer]
	invoke_cdecl _Scene_check_fbo
	test eax, eax
	jz .quit

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_HDRBlurFBO]
	mov eax, [_DrawBlurProgramLocations.OutColor]
	add eax, GL_COLOR_ATTACHMENT0
	invoke_dll_stdcall glFramebufferTexture2D, GL_DRAW_FRAMEBUFFER, eax, GL_TEXTURE_2D, [_HDRBlurTexture], 0
	invoke_cdecl _Scene_check_fbo
	test eax, eax
	jz .quit

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, 0

	mov eax, %$VPSize
	mov [_RTTBufferSize], eax
.rtt_size_good:

	invoke_cdecl _MatrixRotationEuler, _CameraMatrix, [_CameraYaw], [_CameraPitch], 0
	invoke_cdecl _MatrixViewEuler, _CameraViewMatrix, _CameraPos, [_CameraYaw], [_CameraPitch], 0
	invoke_cdecl _MatrixProjection, _ProjectionMatrix, [_FovY], [_Aspect], 0.1f, 2000.0f

	xor eax, eax
	mov edx, eax
	dec eax
	movaps xmm0, [_MovementSpeed]
	movss xmm1, %$DeltaTime32
	mulss xmm1, [_DefaultMovementSpeed]
	addss xmm1, xmm1
	shufps xmm1, xmm1, 0
	movaps xmm2, [_CameraMatrix + Matrix.z]
	movaps xmm3, [_CameraMatrix + Matrix.x]
	movaps xmm4, [_F0100]
	mulps xmm2, xmm1
	mulps xmm3, xmm1
	mulps xmm4, xmm1
	test eax, %$KeyW
	jz .no_w
	subps xmm0, xmm2
.no_w:
	test eax, %$KeyS
	jz .no_s
	addps xmm0, xmm2
.no_s:
	test eax, %$KeyA
	jz .no_a
	subps xmm0, xmm3
.no_a:
	test eax, %$KeyD
	jz .no_d
	addps xmm0, xmm3
.no_d:
	test eax, %$KeySpace
	jz .no_space
	addps xmm0, xmm4
.no_space:
	test eax, %$KeyCtrl
	jz .no_ctrl
	subps xmm0, xmm4
.no_ctrl:
	movaps [_MovementSpeed], xmm0
	invoke_cdecl _VectorLength, &%$CurMovementSpeed, _MovementSpeed, 3
	mov eax, __float32__(0.00001)
	movss xmm1, %$CurMovementSpeed
	movd xmm2, eax
	ucomiss xmm1, xmm2
	jbe .no_decel
	movaps xmm0, [_MovementSpeed]
	shufps xmm1, xmm1, 0
	rcpps xmm1, xmm1
	mulps xmm0, xmm1 ;xmm0 = normalize(_MovementSpeed)
	movss xmm1, %$CurMovementSpeed
	xorps xmm2, xmm2
	movss xmm3, [_DefaultMovementSpeed]
	mulss xmm3, %$DeltaTime32
	subss xmm1, xmm3
	maxps xmm1, xmm2
	shufps xmm1, xmm1, 0 ;xmm1 = CurSpeed - DefSpeed * DeltaTime
	mulps xmm0, xmm1 ;xmm0 = NormalizedSpeed * xmm1
	movaps [_MovementSpeed], xmm0
	movss xmm1, %$DeltaTime32
	shufps xmm1, xmm1, 0
	mulps xmm0, xmm1
	addps xmm0, [_CameraPos]
	movaps [_CameraPos], xmm0
	jmp .finished_decel
.no_decel:
	xorps xmm0, xmm0
	movaps [_MovementSpeed], xmm0
.finished_decel:

	mov eax, __float32__(229.18311805) ; 12 * 60 / pi
	movd xmm1, eax
	movss xmm0, %$DeltaTime32
	divss xmm0, xmm1
	addss xmm0, [_DayTime]
	movss [_DayTime], xmm0

	fld dword[_DayTime]
	fsincos
	fstp dword[_SunPosition.z]
	fstp dword[_SunPosition.y]
	mov dword[_SunPosition.x], __float32__(0.4)

	invoke_cdecl _VectorNormal, _SunPosition, _SunPosition, 3

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_DrawTerrainFBO]
	invoke_dll_stdcall glViewport, 0, 0, %$VPWidth, %$VPHeight
	invoke_cdecl _Scene_clear_buffers

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_DrawTerrainHalfSizeFBO]
	invoke_dll_stdcall glViewport, 0, 0, %$VPWidthHalf, %$VPHeightHalf
	invoke_cdecl _Scene_clear_buffers

	invoke_dll_stdcall glEnable, GL_DEPTH_TEST
	invoke_dll_stdcall glDepthFunc, GL_LEQUAL

	invoke_dll_stdcall glUseProgram, [_DrawTerrainProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glUniformMatrix4fv, [_DrawTerrainProgramLocations.CameraMatrix], 1, 0, _CameraMatrix
	invoke_dll_stdcall glUniformMatrix4fv, [_DrawTerrainProgramLocations.ProjMatrix], 1, 0, _ProjectionMatrix
	invoke_dll_stdcall glUniform3fv, [_DrawTerrainProgramLocations.CameraPosition], 1, _CameraPos
	invoke_dll_stdcall glUniform1f, [_DrawTerrainProgramLocations.RenderDistance], 3000.0f
	invoke_dll_stdcall glUniform1f, [_DrawTerrainProgramLocations.TerrainHeight], [_TerrainMapHeight]
	invoke_dll_stdcall glUniform1f, [_DrawTerrainProgramLocations.TerrainScaling], [_TerrainMapScaling]
	invoke_dll_stdcall glUniform1i, [_DrawTerrainProgramLocations.TextureQuality], [_CurTextureQuality]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainTexture]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 1
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainConeTexture]
	invoke_dll_stdcall glUniform1i, [_DrawTerrainProgramLocations.TerrainAltitudeMap], 0
	invoke_dll_stdcall glUniform1i, [_DrawTerrainProgramLocations.TerrainConeMap], 1
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4
	invoke_dll_stdcall glBindVertexArray, 0

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_DrawWaterHalfSizeFBO]
	invoke_dll_stdcall glViewport, 0, 0, %$VPWidthHalf, %$VPHeightHalf

	invoke_dll_stdcall glUseProgram, [_DrawWaterProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glUniformMatrix4fv, [_DrawWaterProgramLocations.CameraMatrix], 1, 0, _CameraMatrix
	invoke_dll_stdcall glUniformMatrix4fv, [_DrawWaterProgramLocations.ProjMatrix], 1, 0, _ProjectionMatrix
	invoke_dll_stdcall glUniform3fv, [_DrawWaterProgramLocations.CameraPosition], 1, _CameraPos
	invoke_dll_stdcall glUniform1f, [_DrawWaterProgramLocations.Time], %$TimerValue32
	invoke_dll_stdcall glUniform1f, [_DrawWaterProgramLocations.RenderDistance], 3000.0f
	invoke_dll_stdcall glUniform1f, [_DrawWaterProgramLocations.TerrainHeight], [_TerrainMapHeight]
	invoke_dll_stdcall glUniform1f, [_DrawWaterProgramLocations.TerrainScaling], [_TerrainMapScaling]
	invoke_dll_stdcall glUniform1i, [_DrawWaterProgramLocations.TextureQuality], [_CurTextureQuality]
	invoke_dll_stdcall glUniform1f, [_DrawWaterProgramLocations.SeaLevel], 120.0f
	invoke_dll_stdcall glUniform1f, [_DrawWaterProgramLocations.SeaWaveHeight], 1.0f
	invoke_dll_stdcall glUniform1f, [_DrawWaterProgramLocations.SeaWaveSize], 1.0f
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainTexture]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 1
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainConeTexture]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 2
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_SSHalfSizeTextures.NormalDist]
	invoke_dll_stdcall glUniform1i, [_DrawWaterProgramLocations.TerrainAltitudeMap], 0
	invoke_dll_stdcall glUniform1i, [_DrawWaterProgramLocations.TerrainConeMap], 1
	invoke_dll_stdcall glUniform1i, [_DrawWaterProgramLocations.SSTerrainNormalDepth], 2
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4
	invoke_dll_stdcall glBindVertexArray, 0
	invoke_dll_stdcall glDisable, GL_DEPTH_TEST

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_CompositeFBO]
	invoke_dll_stdcall glViewport, 0, 0, %$VPWidth, %$VPHeight
	invoke_cdecl _Scene_clear_color

	invoke_cdecl _SetupSSTextureMipmaps, _SSTextures
	invoke_cdecl _SetupSSTextureMipmaps, _SSHalfSizeTextures

	invoke_dll_stdcall glUseProgram, [_DrawCompositeProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glUniformMatrix4fv, [_DrawCompositeProgramLocations.CameraMatrix], 1, 0, _CameraMatrix
	invoke_dll_stdcall glUniformMatrix4fv, [_DrawCompositeProgramLocations.ProjMatrix], 1, 0, _ProjectionMatrix
	invoke_dll_stdcall glUniform3fv, [_DrawCompositeProgramLocations.CameraPosition], 1, _CameraPos
	invoke_dll_stdcall glUniform3fv, [_DrawCompositeProgramLocations.SunPosition], 1, _SunPosition
	invoke_dll_stdcall glUniform1f, [_DrawCompositeProgramLocations.RenderDistance], 3000.0f
	invoke_cdecl _SetupSSTextureShaderInput, _SSHalfSizeTextures, 0
	invoke_dll_stdcall glUniform1i, [_DrawCompositeProgramLocations.TexSSNormalDist], 0
	invoke_dll_stdcall glUniform1i, [_DrawCompositeProgramLocations.TexSSDiffuse], 1
	invoke_dll_stdcall glUniform1i, [_DrawCompositeProgramLocations.TexSSSpecular], 2
	invoke_dll_stdcall glUniform1i, [_DrawCompositeProgramLocations.TexSSEmissive], 3
	invoke_dll_stdcall glUniform1i, [_DrawCompositeProgramLocations.TexSSScatter], 4
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4
	invoke_dll_stdcall glBindVertexArray, 0
	invoke_dll_stdcall glUseProgram, 0

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_HDRBlurFBO]
	invoke_dll_stdcall glViewport, 0, 0, %$VPWidthLow, %$VPHeightLow
	invoke_cdecl _Scene_clear_color

	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_HDRLensTexture]
	invoke_dll_stdcall glGenerateMipmap, GL_TEXTURE_2D
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0

	invoke_dll_stdcall glUseProgram, [_DrawBlurProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_HDRLensTexture]
	invoke_dll_stdcall glUniform1i, [_DrawBlurProgramLocations.HDRTexture], 0
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4
	invoke_dll_stdcall glBindVertexArray, 0
	invoke_dll_stdcall glUseProgram, 0

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, 0
	invoke_dll_stdcall glViewport, [_ClientRect.left], [_ClientRect.top], [_ClientRect.right], [_ClientRect.bottom]
	invoke_cdecl _Scene_clear_color

	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_HDRBlurTexture]
	invoke_dll_stdcall glGenerateMipmap, GL_TEXTURE_2D
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0

	invoke_dll_stdcall glUseProgram, [_DrawHDR2LDRProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_HDRBlurTexture]
	invoke_dll_stdcall glUniform1i, [_DrawHDR2LDRProgramLocations.BlurTexture], 0
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 1
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_HDRLensTexture]
	invoke_dll_stdcall glUniform1i, [_DrawHDR2LDRProgramLocations.HDRTexture], 1
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4
	invoke_dll_stdcall glBindVertexArray, 0
	invoke_dll_stdcall glUseProgram, 0

	invoke_dll_stdcall glGetError
	test eax, eax
	jz .no_error
	debug_msg "glGetError() == %p", eax
	jmp .quit
.no_error:

	fld1
	fdiv qword %$DeltaTimeL
	fstp dword %$FramesPerSec

	GLPrintfXY [_OGLFC], 0, 0, `FPS: %.1f, \tVSYNC: %lld us\t渲染耗时：%lld us`, \
		f2d %$FramesPerSec, \
		qw [_VBlankData.VBlankWithDelayTimeUsedUs], \
		qw [_VBlankData.LastFrameRenderTimeUs]
	mov eax, [_CurTextureQuality]
	GLPrintfXY [_OGLFC], 0, 20, `质量：%s。按 Page Up 切换质量。`, [_PtrStrQualities + eax * 4]

.end_of_frame:
	invoke_cdecl _SwapBuffers
.end_after_swap_buffers:
	xor eax, eax
	inc eax
	jmp .end
.quit:
	xor eax, eax

.end:
	FrameEnd
	ret

DefFunc _SwapBuffersNoVSync
	FrameBegin
	invoke_dll_stdcall wglSwapBuffers, [_hDC]
	FrameEnd
	ret

DefFunc _SwapBuffers
	FrameBegin
	invoke_cdecl _SwapBuffersNoVSync
	invoke_cdecl _WaitForVBlank, _VBlankData, [_hWnd]
	FrameEnd
	ret
