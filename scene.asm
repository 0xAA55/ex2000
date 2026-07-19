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

extern _hWnd
extern _hDC

segment .bss
extern _BillboardVerticesBuffer
_BillboardVerticesBuffer:
	InstGlBuffer

extern _DrawBillboardVAO
_DrawBillboardVAO resd 1

extern _DrawProgressProgram
_DrawProgressProgram resd 1

extern _DrawSceneProgram
_DrawSceneProgram resd 1

extern _DrawHDR2LDRProgram
_DrawHDR2LDRProgram resd 1

extern _DrawBlurProgram
_DrawBlurProgram resd 1

extern _TerrainTexture
_TerrainTexture resd 1

extern _TerrainTextureMipLinear
_TerrainTextureMipLinear resd 1

extern _RTTFramebuffer
_RTTFramebuffer resd 1

extern _HDRLensTexture
_HDRLensTexture resd 1

extern _HDRLensTextureSize
_HDRLensTextureSize:
	.w resw 1
	.h resw 1

extern _HDRBlurTexture
_HDRBlurTexture resd 1

extern _HDRBlurTextureSize
_HDRBlurTextureSize:
	.w resw 1
	.h resw 1

extern _RTTDepthBuffer
_RTTDepthBuffer resd 1

extern _RTTDepthBufferSize
_RTTDepthBufferSize:
	.w resw 1
	.h resw 1

extern _Timer
_Timer:
	InstTimer

extern _ProgressProgramLocations
_ProgressProgramLocations:
	.Progress resd 1

extern _DrawSceneProgramLocations
_DrawSceneProgramLocations:
	.CameraMatrix resd 1
	.CameraPosition resd 1
	.ProjMatrix resd 1
	.Time resd 1
	.Cloud resd 1
	.Terrain resd 1
	.TerrainHeight resd 1
	.TerrainScaling resd 1
	.SeaLevel resd 1
	.OutColor resd 1

extern _DrawBlurProgramLocations
_DrawBlurProgramLocations:
	.HDRTexture resd 1
	.OutColor resd 1

extern _DrawHDR2LDRProgramLocations
_DrawHDR2LDRProgramLocations:
	.BlurTexture resd 1
	.HDRTexture resd 1
	.OutColor resd 1

extern _MinPitch
_MinPitch resd 1

extern _MaxPitch
_MaxPitch resd 1

extern _NoiseBitmap
_NoiseBitmap resd 1

extern _TerrainBitmap
_TerrainBitmap resd 1

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

;int SceneInit();
DefFunc _SceneInit
	FrameBegin 0, ebx, esi

	invoke_cdecl _InitTimer, _Timer
	invoke_cdecl _VBlankInit

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

	SceneLoadShaderProgram _DrawProgressProgram, "assets\loading.vsh", 0, "assets\loading.fsh"
	test eax, eax
	jz .end

	invoke_cdecl _InitBuffer, _BillboardVerticesBuffer, GL_ARRAY_BUFFER, GL_STATIC_DRAW, 2, _BillBoardVertices.num / 2, _BillBoardVertices

	invoke_dll_stdcall glGenVertexArrays, 1, _DrawBillboardVAO
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_BillboardVerticesBuffer.gl_buffer]
	GetAttribLocation [_DrawProgressProgram], "position"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, 0
	invoke_dll_stdcall glBindVertexArray, 0

	GetUniformLocation [_DrawProgressProgram], "progress"
	mov [_ProgressProgramLocations.Progress], eax

	invoke_cdecl _OGLFC_Create, [_hDC], 12
	mov [_OGLFC], eax

	invoke_cdecl _HRSleepInit

	mov dword [_CameraPos + Vector.y], __?float32?__(200.0)

	xor eax, eax
	mov [_SceneLoadingProgress], eax
	mov al, 1
.end:
	FrameEnd
	ret

DefFunc _SceneLoad00
	FrameBegin 0
	invoke_cdecl _GenMultiLayerPerlinAltitude, 1024, 1.0f, 7, 200.0f
	mov [_NoiseBitmap], eax
	FrameEnd
	ret

DefFunc _SceneLoad01
	FrameBegin 0
	invoke_cdecl _DuplicateBitMap, [_NoiseBitmap]
	mov [_TerrainBitmap], eax
	FrameEnd
	ret

DefFunc _SceneLoad02
	FrameBegin 0, ebx
	mov ebx, [_TerrainBitmap]
	invoke_cdecl _FloatMapCurve, ebx, _TerrainCurvePoints, _TerrainCurvePoints.num_points
	FrameEnd
	ret

DefFunc _SceneLoad03
	FrameBegin 0, ebx
	mov ebx, [_TerrainBitmap]
	invoke_dll_stdcall glGenTextures, 1, _TerrainTexture
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainTexture]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_R32F, [ebx + BitMap.border_len], [ebx + BitMap.border_len], 0, GL_RED, GL_FLOAT, [ebx + BitMap.data]
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0
	invoke_cdecl _DestroyBitMap, ebx
	xor eax, eax
	mov [_TerrainBitmap], eax
	FrameEnd
	ret

DefFunc _SceneLoad04
	FrameBegin 0, ebx
	mov ebx, [_NoiseBitmap]
	invoke_dll_stdcall glGenTextures, 1, _TerrainTextureMipLinear
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainTextureMipLinear]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_R32F, [ebx + BitMap.border_len], [ebx + BitMap.border_len], 0, GL_RED, GL_FLOAT, [ebx + BitMap.data]
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke_dll_stdcall glGenerateMipmap, GL_TEXTURE_2D
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0
	invoke_cdecl _DestroyBitMap, ebx
	xor eax, eax
	mov [_NoiseBitmap], eax
	FrameEnd
	ret

DefFunc _SceneLoad05
	FrameBegin 0, ebx, edi
	mov ebx, _DrawSceneProgram
	SceneLoadShaderProgram ebx, "assets\billboard.vsh", 0, "assets\terrain.fsh"
	test eax, eax
	jz .bad_end

	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_BillboardVerticesBuffer.gl_buffer]
	GetAttribLocation [ebx], "position"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindVertexArray, 0

	GetUniformLocation [ebx], "camorient"
	mov [_DrawSceneProgramLocations.CameraMatrix], eax
	GetUniformLocation [ebx], "proj"
	mov [_DrawSceneProgramLocations.ProjMatrix], eax
	GetUniformLocation [ebx], "campos"
	mov [_DrawSceneProgramLocations.CameraPosition], eax
	GetUniformLocation [ebx], "time"
	mov [_DrawSceneProgramLocations.Time], eax
	GetUniformLocation [ebx], "cloud"
	mov [_DrawSceneProgramLocations.Cloud], eax
	GetUniformLocation [ebx], "terrain"
	mov [_DrawSceneProgramLocations.Terrain], eax
	GetUniformLocation [ebx], "terrain_height"
	mov [_DrawSceneProgramLocations.TerrainHeight], eax
	GetUniformLocation [ebx], "terrain_scaling"
	mov [_DrawSceneProgramLocations.TerrainScaling], eax
	GetUniformLocation [ebx], "sea_level"
	mov [_DrawSceneProgramLocations.SeaLevel], eax

	GetFragDataLocation [ebx], "color"
	mov [_DrawSceneProgramLocations.OutColor], eax

	jmp .end
.bad_end:
	dec eax
	mov [_SceneLoadingProgress], eax
.end:
	FrameEnd
	ret

DefFunc _SceneLoad06
	FrameBegin 0, ebx, edi
	invoke_dll_stdcall glGenFramebuffers, 1, _RTTFramebuffer
	mov ebx, _DrawBlurProgram
	SceneLoadShaderProgram ebx, "assets\billboard.vsh", 0, "assets\blur.fsh"
	test eax, eax
	jz .bad_end

	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_BillboardVerticesBuffer.gl_buffer]
	GetAttribLocation [ebx], "position"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindVertexArray, 0

	GetUniformLocation [ebx], "hdr_texture"
	mov [_DrawBlurProgramLocations.HDRTexture], eax

	GetFragDataLocation [ebx], "color"
	mov [_DrawBlurProgramLocations.OutColor], eax

	jmp .end
.bad_end:
	dec eax
	mov [_SceneLoadingProgress], eax
.end:
	FrameEnd
	ret

DefFunc _SceneLoad07
	FrameBegin 0, ebx, edi
	invoke_dll_stdcall glGenFramebuffers, 1, _RTTFramebuffer
	mov ebx, _DrawHDR2LDRProgram
	SceneLoadShaderProgram ebx, "assets\billboard.vsh", 0, "assets\hdr2ldr.fsh"
	test eax, eax
	jz .bad_end

	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_BillboardVerticesBuffer.gl_buffer]
	GetAttribLocation [ebx], "position"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindVertexArray, 0

	GetUniformLocation [ebx], "blur_texture"
	mov [_DrawHDR2LDRProgramLocations.BlurTexture], eax
	GetUniformLocation [ebx], "hdr_texture"
	mov [_DrawHDR2LDRProgramLocations.HDRTexture], eax

	GetFragDataLocation [ebx], "color"
	mov [_DrawHDR2LDRProgramLocations.OutColor], eax

	jmp .end
.bad_end:
	dec eax
	mov [_SceneLoadingProgress], eax
.end:
	FrameEnd
	ret

DefFunc _SceneLoad08
	FrameBegin 0
	FrameEnd
	ret

DefFunc _SceneLoad09
	FrameBegin 0
	FrameEnd
	ret

DefFunc _SceneLoad0A
	FrameBegin 0
	FrameEnd
	ret

DefFunc _SceneLoad0B
	FrameBegin 0
	FrameEnd
	ret

DefFunc _SceneLoadProgressive
	FrameBegin 0, ebx

	mov ebx, [_SceneLoadingProgress]
	cmp ebx, 0
	jl .end
	cmp ebx, _NumItemsToLoad
	jge .end
.load:
	invoke_cdecl [.load_sequence + ebx * 4]
	cmp eax, 0
	jl .end
	inc ebx
	mov [_SceneLoadingProgress], ebx
.end:
	mov eax, [_SceneLoadingProgress]
	FrameEnd
	ret
segment .rdata
.load_sequence:
	dd _SceneLoad00
	dd _SceneLoad01
	dd _SceneLoad02
	dd _SceneLoad03
	dd _SceneLoad04
	dd _SceneLoad05
	dd _SceneLoad06
	dd _SceneLoad07
	dd _SceneLoad08
	dd _SceneLoad09
	dd _SceneLoad0A
	dd _SceneLoad0B
extern _NumItemsToLoad
_NumItemsToLoad equ ($ - .load_sequence) / 4

DefFunc _SceneUnload
	FrameBegin 0, esi

	invoke_cdecl _HRSleepDeInit
	invoke_cdecl _VBlankDeInit

	invoke_cdecl _DeInitBuffer, _BillboardVerticesBuffer
	invoke_cdecl _DestroyBitMap, [_TerrainBitmap]

	invoke_cdecl _OGLFC_Destroy, [_OGLFC]

	invoke_dll_stdcall glDeleteFramebuffers, 1, _RTTFramebuffer
	invoke_dll_stdcall glDeleteRenderbuffers, 1, _RTTDepthBuffer

	invoke_dll_stdcall glDeleteTextures, 1, _TerrainTexture
	invoke_dll_stdcall glDeleteTextures, 1, _TerrainTextureMipLinear
	invoke_dll_stdcall glDeleteTextures, 1, _HDRLensTexture
	invoke_dll_stdcall glDeleteTextures, 1, _HDRBlurTexture

	invoke_dll_stdcall glDeleteProgram, [_DrawProgressProgram]
	invoke_dll_stdcall glDeleteProgram, [_DrawSceneProgram]
	invoke_dll_stdcall glDeleteProgram, [_DrawBlurProgram]
	invoke_dll_stdcall glDeleteProgram, [_DrawHDR2LDRProgram]

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
	dd _OGLFC
	dd _RTTFramebuffer
	dd _RTTDepthBuffer
	dd _DrawProgressProgram
	dd _DrawSceneProgram
	dd _DrawBlurProgram
	dd _DrawHDR2LDRProgram
	dd _DrawBillboardVAO
	dd _TerrainTexture
	dd _TerrainTextureMipLinear
	dd _HDRLensTexture
	dd _HDRBlurTexture
.num_set_to_NULL equ ($ - .set_to_NULL) / 4

DefFunc _Scene
[segment .rdata]
.keys_to_detect db 'WSAD', VK_SPACE, VK_CONTROL, VK_ESCAPE, 0
.num_keys_to_detect equ $ - .keys_to_detect
__SECT__

	FrameBegin 19, ebx, esi, edi
	AssignVars TimerValue32, DeltaTimeL, DeltaTimeH, DeltaTime32 ;4
	AssignVars KeyW, KeyS, KeyA, KeyD, KeySpace, KeyCtrl, KeyEscape ;7
	AssignVars VPWidth, VPHeight, VPSize, VPWidthLow, VPHeightLow, VPSizeLow ;6
	AssignVars CurMovementSpeed, FramesPerSec ;2

	xor eax, eax
	mov ecx, Frame_NumLocals
	lea edi, TimerValue32
	rep stosd

	fld qword [_Timer.TimerVal]
	fstp qword DeltaTimeL
	invoke_cdecl _UpdateTimer, _Timer
	fst dword TimerValue32
	fsub qword DeltaTimeL
	fst qword DeltaTimeL
	fstp dword DeltaTime32

	invoke_dll_stdcall GetClientRect, [_hWnd], _ClientRect
	movq xmm0, [_ClientRect.left]
	movq xmm1, [_ClientRect.right]
	movq [_WindowRect.left], xmm0
	movq [_WindowRect.right], xmm1
	invoke_dll_stdcall ClientToScreen, [_hWnd], _WindowRect.left
	invoke_dll_stdcall ClientToScreen, [_hWnd], _WindowRect.right
	invoke_dll_stdcall GetCursorPos, _CursorPos

	invoke_dll_stdcall GetForegroundWindow
	cmp eax, [_hWnd]
	jnz .after_check_input
	mov esi, .keys_to_detect
	lea edi, KeyW
.loop_check_keys:
	xor eax, eax
	lodsb
	test eax, eax
	jz .after_check_keys
	invoke_dll_stdcall GetAsyncKeyState, eax
	stosd
	jmp .loop_check_keys
.after_check_keys:
	cmp dword KeyEscape, 0
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
	mov eax, [_ClientRect.bottom]
	cmp eax, [_ClientRect.top]
	jbe .end_after_swap_buffers

	mov ebx, _HDRLensTexture
	mov eax, [_ClientRect.right]
	mov ecx, [_ClientRect.bottom]
	sub eax, [_ClientRect.left]
	sub ecx, [_ClientRect.top]
	cvtsi2ss xmm0, eax
	cvtsi2ss xmm1, ecx
	mov VPWidth, eax
	mov VPHeight, ecx
	divss xmm0, xmm1
	movss [_Aspect], xmm0
	shl ecx, 16
	or eax, ecx
	mov VPSize, eax
	xor edx, edx
	inc edx
	mov eax, VPWidth
	mov ecx, VPHeight
	shr eax, 2
	shr ecx, 2
	cmp eax, edx
	cmovb eax, edx
	cmp ecx, edx
	cmovb ecx, edx
	mov VPWidthLow, eax
	mov VPHeightLow, ecx
	shl ecx, 16
	or eax, ecx
	mov VPSizeLow, eax
	mov eax, VPSize
	cmp eax, [_HDRLensTextureSize]
	jz .hdr_texture_size_good

	invoke_dll_stdcall glDeleteTextures, 1, ebx
	xor eax, eax
	mov [ebx], eax

.hdr_texture_size_good:
	cmp dword[ebx], 0
	jnz .hdr_texture_good

	invoke_dll_stdcall glGenTextures, 1, ebx
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [ebx]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_RGBA32F, VPWidth, VPHeight, 0, GL_RGBA, GL_FLOAT, NULL
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0

	mov eax, VPSize
	mov [_HDRLensTextureSize], eax

.hdr_texture_good:
	mov eax, VPSize
	mov ebx, _RTTDepthBuffer
	cmp eax, [_RTTDepthBufferSize]
	jz .depth_buffer_size_good

	invoke_dll_stdcall glDeleteRenderbuffers, 1, ebx
	xor eax, eax
	mov [ebx], eax

.depth_buffer_size_good:
	cmp dword[ebx], 0
	jnz .depth_buffer_good

	invoke_dll_stdcall glGenRenderbuffers, 1, ebx
	invoke_dll_stdcall glBindRenderbuffer, GL_RENDERBUFFER, [ebx]
	invoke_dll_stdcall glRenderbufferStorage, GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, VPWidth, VPHeight
	invoke_dll_stdcall glBindRenderbuffer, GL_RENDERBUFFER, 0

	mov eax, VPSize
	mov [_RTTDepthBufferSize], eax

.depth_buffer_good:
	mov eax, VPSizeLow
	mov ebx, _HDRBlurTexture
	cmp eax, [_HDRBlurTextureSize]
	jz .hdr_blur_texture_size_good

	invoke_dll_stdcall glDeleteTextures, 1, ebx
	xor eax, eax
	mov [ebx], eax

.hdr_blur_texture_size_good:
	cmp dword[ebx], 0
	jnz .hdr_blur_texture_good

	invoke_dll_stdcall glGenTextures, 1, ebx
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [ebx]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_RGBA32F, VPWidthLow, VPHeightLow, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0

	mov eax, VPSizeLow
	mov [_HDRBlurTextureSize], eax

.hdr_blur_texture_good:
	invoke_cdecl _SceneLoadProgressive
	mov ebx, _NumItemsToLoad
	cmp eax, ebx
	jz .loaded

	cmp eax, 0
	jl .quit

	invoke_dll_stdcall glViewport, [_ClientRect.left], [_ClientRect.top], [_ClientRect.right], [_ClientRect.bottom]
	call .clear_buffers

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
	invoke_cdecl _MatrixRotationEuler, _CameraMatrix, [_CameraYaw], [_CameraPitch], 0
	invoke_cdecl _MatrixViewEuler, _CameraViewMatrix, _CameraPos, [_CameraYaw], [_CameraPitch], 0
	invoke_cdecl _MatrixProjection, _ProjectionMatrix, [_FovY], [_Aspect], 0.1f, 2000.0f

	xor eax, eax
	mov edx, eax
	dec eax
	movaps xmm0, [_MovementSpeed]
	movss xmm1, DeltaTime32
	mulss xmm1, [_DefaultMovementSpeed]
	addss xmm1, xmm1
	shufps xmm1, xmm1, 0
	movaps xmm2, [_CameraMatrix + Matrix.z]
	movaps xmm3, [_CameraMatrix + Matrix.x]
	movaps xmm4, [_F0100]
	mulps xmm2, xmm1
	mulps xmm3, xmm1
	mulps xmm4, xmm1
	test eax, KeyW
	jz .no_w
	subps xmm0, xmm2
.no_w:
	test eax, KeyS
	jz .no_s
	addps xmm0, xmm2
.no_s:
	test eax, KeyA
	jz .no_a
	subps xmm0, xmm3
.no_a:
	test eax, KeyD
	jz .no_d
	addps xmm0, xmm3
.no_d:
	test eax, KeySpace
	jz .no_space
	addps xmm0, xmm4
.no_space:
	test eax, KeyCtrl
	jz .no_ctrl
	subps xmm0, xmm4
.no_ctrl:
	movaps [_MovementSpeed], xmm0
	invoke_cdecl _VectorLength, &CurMovementSpeed, _MovementSpeed, 3
	mov eax, __?float32?__(0.00001)
	movss xmm1, CurMovementSpeed
	movd xmm2, eax
	ucomiss xmm1, xmm2
	jbe .no_decel
	movaps xmm0, [_MovementSpeed]
	shufps xmm1, xmm1, 0
	rcpps xmm1, xmm1
	mulps xmm0, xmm1 ;xmm0 = normalize(_MovementSpeed)
	movss xmm1, CurMovementSpeed
	xorps xmm2, xmm2
	movss xmm3, [_DefaultMovementSpeed]
	mulss xmm3, DeltaTime32
	subss xmm1, xmm3
	maxps xmm1, xmm2
	shufps xmm1, xmm1, 0 ;xmm1 = CurSpeed - DefSpeed * DeltaTime
	mulps xmm0, xmm1 ;xmm0 = NormalizedSpeed * xmm1
	movaps [_MovementSpeed], xmm0
	movss xmm1, DeltaTime32
	shufps xmm1, xmm1, 0
	mulps xmm0, xmm1
	addps xmm0, [_CameraPos]
	movaps [_CameraPos], xmm0
	jmp .finished_decel
.no_decel:
	xorps xmm0, xmm0
	movaps [_MovementSpeed], xmm0
.finished_decel:

	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, [_RTTFramebuffer]
	mov eax, [_DrawSceneProgramLocations.OutColor]
	add eax, GL_COLOR_ATTACHMENT0
	invoke_dll_stdcall glFramebufferTexture2D, GL_DRAW_FRAMEBUFFER, eax, GL_TEXTURE_2D, [_HDRLensTexture], 0
	invoke_dll_stdcall glFramebufferRenderbuffer, GL_DRAW_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, [_RTTDepthBuffer]
	call .check_fbo

	invoke_dll_stdcall glViewport, 0, 0, VPWidth, VPHeight
	call .clear_buffers

	invoke_dll_stdcall glEnable, GL_DEPTH_TEST
	invoke_dll_stdcall glDepthFunc, GL_LEQUAL
	invoke_dll_stdcall glUseProgram, [_DrawSceneProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glUniformMatrix4fv, [_DrawSceneProgramLocations.CameraMatrix], 1, 0, _CameraMatrix
	invoke_dll_stdcall glUniformMatrix4fv, [_DrawSceneProgramLocations.ProjMatrix], 1, 0, _ProjectionMatrix
	invoke_dll_stdcall glUniform3fv, [_DrawSceneProgramLocations.CameraPosition], 1, _CameraPos
	invoke_dll_stdcall glUniform1f, [_DrawSceneProgramLocations.Time], TimerValue32
	invoke_dll_stdcall glUniform1f, [_DrawSceneProgramLocations.TerrainHeight], [_TerrainMapHeight]
	invoke_dll_stdcall glUniform1f, [_DrawSceneProgramLocations.TerrainScaling], [_TerrainMapScaling]
	invoke_dll_stdcall glUniform1f, [_DrawSceneProgramLocations.SeaLevel], [_SeaLevel]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainTextureMipLinear]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 1
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainTexture]
	invoke_dll_stdcall glUniform1i, [_DrawSceneProgramLocations.Cloud], 0
	invoke_dll_stdcall glUniform1i, [_DrawSceneProgramLocations.Terrain], 1
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4
	invoke_dll_stdcall glBindVertexArray, 0

	invoke_dll_stdcall glFinish
	invoke_dll_stdcall glDisable, GL_DEPTH_TEST

	mov eax, [_DrawBlurProgramLocations.OutColor]
	add eax, GL_COLOR_ATTACHMENT0
	invoke_dll_stdcall glFramebufferTexture2D, GL_DRAW_FRAMEBUFFER, eax, GL_TEXTURE_2D, [_HDRBlurTexture], 0
	call .check_fbo
	invoke_dll_stdcall glViewport, 0, 0, VPWidthLow, VPHeightLow
	call .clear_buffers

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

	invoke_dll_stdcall glFinish
	invoke_dll_stdcall glBindFramebuffer, GL_DRAW_FRAMEBUFFER, 0
	invoke_dll_stdcall glViewport, [_ClientRect.left], [_ClientRect.top], [_ClientRect.right], [_ClientRect.bottom]
	call .clear_buffers

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

	fld1
	fdiv qword DeltaTimeL
	fstp dword FramesPerSec

	GLPrintfXY [_OGLFC], 0, 0, `FPS: %.1f, \tVSYNC: %d us\t渲染耗时：%d us\n`, f2d FramesPerSec, [_VBlankWithDelayTimeUsedUs], [_LastFrameRenderTimeUs]

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
.check_fbo:
	invoke_dll_stdcall glCheckFramebufferStatus, GL_DRAW_FRAMEBUFFER
	cmp eax, GL_FRAMEBUFFER_COMPLETE
	jz .fbo_good
	debug_msg `glCheckFramebufferStatus() returns %d`, eax
	pop eax
	jmp .quit
.fbo_good:
	ret
.clear_buffers:
	invoke_dll_stdcall glClearColor, 0, 0, 0, 0
	invoke_dll_stdcall glClearDepth, 1.0
	invoke_dll_stdcall glClear, GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
	ret
	%undef TimerValue32
	%undef DeltaTimeL
	%undef DeltaTimeH
	%undef DeltaTime32
	%undef KeyW
	%undef KeyS
	%undef KeyA
	%undef KeyD
	%undef KeySpace
	%undef KeyCtrl
	%undef KeyEscape
	%undef VPWidth
	%undef VPHeight
	%undef VPSize
	%undef VPWidthLow
	%undef VPHeightLow
	%undef VPSizeLow
	%undef CurMovementSpeed
	%undef FramesPerSec

DefFunc _SwapBuffersNoVSync
	FrameBegin 0
	invoke_dll_stdcall wglSwapBuffers, [_hDC]
	FrameEnd
	ret

DefFunc _SwapBuffers
	FrameBegin 0
	invoke_cdecl _SwapBuffersNoVSync
	invoke_cdecl _WaitForVBlank
	FrameEnd
	ret
