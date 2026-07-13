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

extern _DrawBillboardProgram
_DrawBillboardProgram resd 1

extern _TerrainTexture
_TerrainTexture resd 1

extern _TerrainTextureMipLinear
_TerrainTextureMipLinear resd 1

extern _Timer
_Timer:
	InstTimer

extern _ProgressProgramLocations
_ProgressProgramLocations:
	.Progress resd 1

extern _BillboardProgramLocations
_BillboardProgramLocations:
	.CameraMatrix resd 1
	.CameraPosition resd 1
	.ProjMatrix resd 1
	.Time resd 1
	.Cloud resd 1
	.Terrain resd 1
	.TerrainHeight resd 1
	.TerrainScaling resd 1

extern _TerrainProgramLocations
_TerrainProgramLocations:
	.View resd 1
	.Proj resd 1
	.Time resd 1
	.Terrain resd 1

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
.l resd 1
.t resd 1
.r resd 1
.b resd 1

extern _WindowRect
_WindowRect:
.l resd 1
.t resd 1
.r resd 1
.b resd 1

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
	at .volume, dd 0.45
	at .weight, dd 0.1
iend
istruc CurvePoint
	at .volume, dd 0.1
	at .weight, dd 0.1
iend
istruc CurvePoint
	at .volume, dd 0.05
	at .weight, dd 0.2
iend
istruc CurvePoint
	at .volume, dd 0.1
	at .weight, dd 0.3
iend
istruc CurvePoint
	at .volume, dd 0.3
	at .weight, dd 0.3
iend
.num_points equ ($ - _TerrainCurvePoints) / CurvePoint.size

extern _DefaultMovementSpeed
_DefaultMovementSpeed dd 100.0

extern _TerrainMapScaling
_TerrainMapScaling dd 2000.0

extern _TerrainMapHeight
_TerrainMapHeight dd 200.0

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
	FrameBegin 0
	SceneLoadShaderProgram _DrawBillboardProgram, "assets\billboard.vsh", 0, "assets\terrain.fsh"
	test eax, eax
	jz .bad_end

	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_BillboardVerticesBuffer.gl_buffer]
	GetAttribLocation [_DrawBillboardProgram], "position"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindVertexArray, 0

	GetUniformLocation [_DrawBillboardProgram], "camorient"
	mov [_BillboardProgramLocations.CameraMatrix], eax
	GetUniformLocation [_DrawBillboardProgram], "proj"
	mov [_BillboardProgramLocations.ProjMatrix], eax
	GetUniformLocation [_DrawBillboardProgram], "campos"
	mov [_BillboardProgramLocations.CameraPosition], eax
	GetUniformLocation [_DrawBillboardProgram], "time"
	mov [_BillboardProgramLocations.Time], eax
	GetUniformLocation [_DrawBillboardProgram], "cloud"
	mov [_BillboardProgramLocations.Cloud], eax
	GetUniformLocation [_DrawBillboardProgram], "terrain"
	mov [_BillboardProgramLocations.Terrain], eax
	GetUniformLocation [_DrawBillboardProgram], "terrain_height"
	mov [_BillboardProgramLocations.TerrainHeight], eax
	GetUniformLocation [_DrawBillboardProgram], "terrain_scaling"
	mov [_BillboardProgramLocations.TerrainScaling], eax
	jmp .end
.bad_end:
	dec eax
	mov [_SceneLoadingProgress], eax

.end:
	FrameEnd
	ret

DefFunc _SceneLoad06
	FrameBegin 0
	FrameEnd
	ret

DefFunc _SceneLoad07
	FrameBegin 0
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

	invoke_dll_stdcall glDeleteProgram, [_DrawProgressProgram]
	invoke_dll_stdcall glDeleteProgram, [_DrawBillboardProgram]

	invoke_dll_stdcall glDeleteVertexArrays, 1, _DrawBillboardVAO

	invoke_dll_stdcall glDeleteTextures, 1, _TerrainTexture
	invoke_dll_stdcall glDeleteTextures, 1, _TerrainTextureMipLinear

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
	dd _DrawProgressProgram
	dd _DrawBillboardProgram
	dd _DrawBillboardVAO
	dd _TerrainTexture
	dd _TerrainTextureMipLinear
.num_set_to_NULL equ ($ - .set_to_NULL) / 4

DefFunc _Scene
	FrameBegin 12, ebx, esi, edi
	AssignVars TimerValue32, DeltaTimeL, DeltaTimeH, DeltaTime32
	AssignVars KeyW, KeyS, KeyA, KeyD, KeySpace, KeyCtrl
	AssignVars CurMovementSpeed
	AssignVars FramesPerSec

	fld qword [_Timer.TimerVal]
	fstp qword DeltaTimeL
	invoke_cdecl _UpdateTimer, _Timer
	fst dword TimerValue32
	fsub qword DeltaTimeL
	fst qword DeltaTimeL
	fstp dword DeltaTime32

	invoke_dll_stdcall GetClientRect, [_hWnd], _ClientRect
	movq xmm0, [_ClientRect.l]
	movq xmm1, [_ClientRect.r]
	movq [_WindowRect.l], xmm0
	movq [_WindowRect.r], xmm1
	invoke_dll_stdcall ClientToScreen, [_hWnd], _WindowRect.l
	invoke_dll_stdcall ClientToScreen, [_hWnd], _WindowRect.r
	invoke_dll_stdcall GetCursorPos, _CursorPos

	invoke_dll_stdcall GetForegroundWindow
	cmp eax, [_hWnd]
	jnz .after_check_input
	cmp dword[_SceneLoadingProgress], _NumItemsToLoad
	jl .after_check_input
	invoke_dll_stdcall GetAsyncKeyState, 0x1B
	test eax, eax
	jnz .quit

[segment .rdata]
.keys_to_detect db 'WSAD', VK_SPACE, VK_CONTROL, 0
.num_keys_to_detect equ $ - .keys_to_detect
__SECT__
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

	movq xmm1, [_WindowRect.r]
	movq xmm0, [_CursorPos]
	paddd xmm1, [_WindowRect.l]
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
	mov eax, [_ClientRect.b]
	cmp eax, [_ClientRect.t]
	jbe .end_of_frame
	cvtsi2ss xmm0, [_ClientRect.r]
	cvtsi2ss xmm1, [_ClientRect.b]
	cvtsi2ss xmm2, [_ClientRect.l]
	cvtsi2ss xmm3, [_ClientRect.t]
	subss xmm0, xmm2
	subss xmm1, xmm3
	divss xmm0, xmm1
	movss [_Aspect], xmm0
	invoke_dll_stdcall glViewport, [_ClientRect.l], [_ClientRect.t], [_ClientRect.r], [_ClientRect.b]

	invoke_dll_stdcall glClearColor, 0, 0, 0, 0
	invoke_dll_stdcall glClearDepth, 1.0
	invoke_dll_stdcall glClear, GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT

	invoke_cdecl _SceneLoadProgressive
	mov ebx, _NumItemsToLoad
	cmp eax, ebx
	jz .loaded

	cmp eax, 0
	jl .quit

	invoke_dll_stdcall glUseProgram, [_DrawProgressProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	cvtsi2ss xmm0, [_SceneLoadingProgress]
	cvtsi2ss xmm1, ebx
	divss xmm0, xmm1
	invoke_dll_stdcall glUniform1f, [_ProgressProgramLocations.Progress], xmm0.x
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4

	jmp .end_of_frame
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

	invoke_dll_stdcall glEnable, GL_DEPTH_TEST
	invoke_dll_stdcall glDepthFunc, GL_LEQUAL

	invoke_dll_stdcall glUseProgram, [_DrawBillboardProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glUniformMatrix4fv, [_BillboardProgramLocations.CameraMatrix], 1, 0, _CameraMatrix
	invoke_dll_stdcall glUniformMatrix4fv, [_BillboardProgramLocations.ProjMatrix], 1, 0, _ProjectionMatrix
	invoke_dll_stdcall glUniform3fv, [_BillboardProgramLocations.CameraPosition], 1, _CameraPos
	invoke_dll_stdcall glUniform1f, [_BillboardProgramLocations.Time], TimerValue32
	invoke_dll_stdcall glUniform1f, [_BillboardProgramLocations.TerrainHeight], [_TerrainMapHeight]
	invoke_dll_stdcall glUniform1f, [_BillboardProgramLocations.TerrainScaling], [_TerrainMapScaling]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainTextureMipLinear]
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0 + 1
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_TerrainTexture]
	invoke_dll_stdcall glUniform1i, [_BillboardProgramLocations.Cloud], 0
	invoke_dll_stdcall glUniform1i, [_BillboardProgramLocations.Terrain], 1
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4
	invoke_dll_stdcall glBindVertexArray, 0
	invoke_dll_stdcall glUseProgram, 0

	fld1
	fdiv qword DeltaTimeL
	fstp dword FramesPerSec

	GLPrintfXY [_OGLFC], 0, 0, `FPS: %.1f, \t渲染耗时：%d us\n`, f2d FramesPerSec, [_LastFrameRenderTimeUs]

.end_of_frame:
	invoke_cdecl _SwapBuffers
	xor eax, eax
	inc eax
	jmp .end
.quit:
	xor eax, eax

.end:
	FrameEnd
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
	%undef CurMovementSpeed
	%undef FramesPerSec

DefFunc _SwapBuffers
	FrameBegin 0
	invoke_dll_stdcall wglSwapBuffers, [_hDC]

	invoke_cdecl _WaitForVBlank
	FrameEnd
	ret
