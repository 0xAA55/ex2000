%include "loaddll.inc"
%include "timer.inc"
%include "gl33.inc"
%include "buffer.inc"
%include "assets.inc"
%include "shader.inc"
%include "math.inc"

%define TerrainBorderLen 7

extern _hWnd
extern _hDC

def_dll Dwmapi, "dwmapi.dll"
def_dll_func DwmFlush

segment .bss
extern _BillboardVerticesBuffer
_BillboardVerticesBuffer:
	InstGlBuffer

extern _DrawBillboardVAO
_DrawBillboardVAO resd 1

extern _DrawTerrainVAO
_DrawTerrainVAO resd 1

extern _DrawProgressProgram
_DrawProgressProgram resd 1

extern _DrawBillboardProgram
_DrawBillboardProgram resd 1

extern _DrawTerrainProgram
_DrawTerrainProgram resd 1

extern _TerrainVerticesBuffer
_TerrainVerticesBuffer:
	InstGlBuffer

extern _TerrainIndicesBuffer
_TerrainIndicesBuffer:
	InstGlBuffer

extern _TerrainInstancesBuffer
_TerrainInstancesBuffer:
	InstGlBuffer

extern _PerlinNoiseTexture
_PerlinNoiseTexture resd 1

extern _PerlinNoiseTextureMipLinear
_PerlinNoiseTextureMipLinear resd 1

extern _Timer
_Timer:
	InstTimer

extern _ProgressProgramLocations
_ProgressProgramLocations:
	.Progress resd 1

extern _BillboardProgramLocations
_BillboardProgramLocations:
	.CameraMatrix resd 1
	.Aspect resd 1
	.FovY resd 1
	.Noise resd 1
	.Time resd 1

extern _TerrainProgramLocations
_TerrainProgramLocations:
	.ViewProj resd 1
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

extern _TerrainMesh
_TerrainMesh resd 1

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

extern _FovYCos
_FovYCos resd 1

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

extern _TerrainMapScalingVectorRCP
_TerrainMapScalingVectorRCP:
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
	at .volume, dd 0.6
	at .weight, dd 0.1
iend
istruc CurvePoint
	at .volume, dd 0.1
	at .weight, dd 0.6
iend
istruc CurvePoint
	at .volume, dd 0.3
	at .weight, dd 0.3
iend
.num_points equ ($ - _TerrainCurvePoints) / CurvePoint.size

extern _DefaultMovementSpeed
_DefaultMovementSpeed dd 100.0

extern _TerrainMapScaling
_TerrainMapScaling dd 500.0

extern _TerrainMapHeightAmplifier
_TerrainMapHeightAmplifier dd 200.0

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

%macro SceneLoadShaderProgram 4
	[segment .rdata]
	%%VSAssetsPath db %2, 0
	%%GSAssetsPath db %3, 0
	%%FSAssetsPath db %4, 0

	__SECT__
	invoke_cdecl _SceneLoadShaderProgram, %1, %%VSAssetsPath, %%GSAssetsPath, %%FSAssetsPath
%endmacro

%macro GetAttribLocation 2
	[segment .rdata]
	%%AttribName db %2, 0

	__SECT__
	invoke_dll_stdcall glGetAttribLocation, %1, %%AttribName
%endmacro

%macro GetUniformLocation 2
	[segment .rdata]
	%%UniformName db %2, 0

	__SECT__
	invoke_dll_stdcall glGetUniformLocation, %1, %%UniformName
%endmacro

; void SceneLoadShaderProgram(_out_ GLuint *program, _in_ char *VertexShaderAssetPath, _in_ char *GeometryShaderAssetPath, _in_ char *FragmentShaderAssetPath);
DefFunc _SceneLoadShaderProgram
	FrameBegin 3, 3, esi

	mov esi, Param(0)
	invoke_cdecl _AssetsQuery, Param(1), 0
	mov Variable(0), eax
	invoke_cdecl _AssetsQuery, Param(2), 0
	mov Variable(1), eax
	invoke_cdecl _AssetsQuery, Param(3), 0
	mov Variable(2), eax

	invoke_cdecl _ProgramCreate, Variable(0), Variable(1), Variable(2)
	mov [esi], eax

	FrameEnd
	ret

;int SceneInit();
DefFunc _SceneInit
	FrameBegin 0, 6, ebx, esi

	invoke_cdecl _InitTimer, _Timer

	mov eax, [_addr_of_wglSwapInterval]
	test eax, eax
	jz .no_swap_interval

	invoke_dll_stdcall wglSwapInterval, 1
	jmp .load_scene
.no_swap_interval:
	load_dll Dwmapi
	test eax, eax
	jz .no_dwmflush

	load_dll_func Dwmapi, DwmFlush
	test eax, eax
	jz .no_dwmflush
	jmp .load_scene
.no_dwmflush:
	mov dword [_addr_of_DwmFlush], _FakeDwmFlush
.load_scene:
	fldpi
	fdiv dword [_2.0f]
	fst dword [_MaxPitch]
	fchs
	fstp dword [_MinPitch]

	fild word [_FovDegree]
	fidiv word [_PiDegree]
	fldpi
	fmul
	fst dword [_FovY]
	fcos
	fstp dword [_FovYCos]

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

	xor eax, eax
	mov [_SceneLoadingProgress], eax
	mov al, 1
.end:
	FrameEnd
	ret

DefFunc _FakeDwmFlush
	xor eax, eax
	ret

DefFunc _SceneLoad00
	FrameBegin 0, 0
	movss xmm0, [_TerrainMapScaling]
	shufps xmm0, xmm0, 0
	movaps [_TerrainMapScalingVector], xmm0
	rcpps xmm0, xmm0
	movaps [_TerrainMapScalingVectorRCP], xmm0
	FrameEnd
	ret

DefFunc _SceneLoad01
	FrameBegin 0, 3
	invoke_cdecl _GenMultiLayerPerlinAltitude, 1024, 1.0f, 8
	mov [_NoiseBitmap], eax
	FrameEnd
	ret

DefFunc _SceneLoad02
	FrameBegin 0, 1
	invoke_cdecl _DuplicateFloatMap, [_NoiseBitmap]
	mov [_TerrainBitmap], eax
	FrameEnd
	ret

DefFunc _SceneLoad03
	FrameBegin 0, 3
	invoke_cdecl _FloatMapCurve, [_TerrainBitmap], _TerrainCurvePoints, _TerrainCurvePoints.num_points
	FrameEnd
	ret

DefFunc _SceneLoad04
	FrameBegin 0, 3
	invoke_cdecl _AltitudeToTerrain, [_TerrainBitmap], [_TerrainMapHeightAmplifier], [_TerrainMapScaling]
	mov [_TerrainMesh], eax
	FrameEnd
	ret

DefFunc _SceneLoad05
	FrameBegin 0, 0, ebx
	mov ebx, [_NoiseBitmap]
	invoke_dll_stdcall glGenTextures, 1, _PerlinNoiseTexture
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_PerlinNoiseTexture]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_R32F, [ebx + FloatMap.border_len], [ebx + FloatMap.border_len], 0, GL_RED, GL_FLOAT, [ebx + FloatMap.data]
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0
	FrameEnd
	ret

DefFunc _SceneLoad06
	FrameBegin 0, 1, ebx
	mov ebx, [_NoiseBitmap]
	invoke_dll_stdcall glGenTextures, 1, _PerlinNoiseTextureMipLinear
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_PerlinNoiseTextureMipLinear]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_R32F, [ebx + FloatMap.border_len], [ebx + FloatMap.border_len], 0, GL_RED, GL_FLOAT, [ebx + FloatMap.data]
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke_dll_stdcall glGenerateMipmap, GL_TEXTURE_2D
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, 0
	invoke_cdecl _DestroyFloatMap, ebx
	xor eax, eax
	mov [_NoiseBitmap], eax
	FrameEnd
	ret

DefFunc _SceneLoad07
	FrameBegin 0, 4
	SceneLoadShaderProgram _DrawBillboardProgram, "assets\skybill.vsh", 0, "assets\skybill.fsh"
	mov ecx, [_SceneLoadingProgress]
	xor edx, edx
	dec edx
	test eax, eax
	cmovz ecx, edx
	mov [_SceneLoadingProgress], ecx
	jz .end

	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_BillboardVerticesBuffer.gl_buffer]
	GetAttribLocation [_DrawBillboardProgram], "position"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindVertexArray, 0

	GetUniformLocation [_DrawBillboardProgram], "camera"
	mov [_BillboardProgramLocations.CameraMatrix], eax
	GetUniformLocation [_DrawBillboardProgram], "aspect"
	mov [_BillboardProgramLocations.Aspect], eax
	GetUniformLocation [_DrawBillboardProgram], "fovy"
	mov [_BillboardProgramLocations.FovY], eax
	GetUniformLocation [_DrawBillboardProgram], "noise"
	mov [_BillboardProgramLocations.Noise], eax
	GetUniformLocation [_DrawBillboardProgram], "time"
	mov [_BillboardProgramLocations.Time], eax

.end:
	FrameEnd
	ret

DefFunc _SceneLoad08
	FrameBegin 0, 6, ebx
	mov ebx, [_TerrainMesh]
	invoke_cdecl _InitBuffer, _TerrainVerticesBuffer, GL_ARRAY_BUFFER, GL_STATIC_DRAW, SimpleVertex.size, [ebx + SimpleMesh.num_vertices], [ebx + SimpleMesh.vertices]
	invoke_cdecl _InitBuffer, _TerrainIndicesBuffer, GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW, 4, [ebx + SimpleMesh.num_indices], [ebx + SimpleMesh.indices]
	invoke_cdecl _free, ebx
	invoke_cdecl _InitBuffer, _TerrainInstancesBuffer, GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW, Matrix.size, TerrainBorderLen * TerrainBorderLen, NULL
	xor eax, eax
	mov [_TerrainMesh], eax
	FrameEnd
	ret

DefFunc _SceneLoad09
	FrameBegin 0, 4, edi, ebx
	SceneLoadShaderProgram _DrawTerrainProgram, "assets\terrain.vsh", 0, "assets\terrain.fsh"
	mov ecx, [_SceneLoadingProgress]
	xor edx, edx
	dec edx
	test eax, eax
	cmovz ecx, edx
	mov [_SceneLoadingProgress], ecx
	jz .end
	invoke_dll_stdcall glGenVertexArrays, 1, _DrawTerrainVAO
	invoke_dll_stdcall glBindVertexArray, [_DrawTerrainVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_TerrainVerticesBuffer.gl_buffer]
	GetAttribLocation [_DrawTerrainProgram], "position"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 3, GL_FLOAT, 0, SimpleVertex.size, SimpleVertex.position
	GetAttribLocation [_DrawTerrainProgram], "normal"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 3, GL_FLOAT, 0, SimpleVertex.size, SimpleVertex.normal
	GetAttribLocation [_DrawTerrainProgram], "uv"
	mov edi, eax
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	invoke_dll_stdcall glVertexAttribPointer, edi, 2, GL_FLOAT, 0, SimpleVertex.size, SimpleVertex.uv
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_TerrainInstancesBuffer.gl_buffer]
	GetAttribLocation [_DrawTerrainProgram], "transform"
	mov edi, eax
	xor ebx, ebx
.loop_set_mat:
	invoke_dll_stdcall glEnableVertexAttribArray, edi
	mov eax, ebx
	shl eax, 4
	invoke_dll_stdcall glVertexAttribPointer, edi, 4, GL_FLOAT, 0, Matrix.size, eax
	invoke_dll_stdcall glVertexAttribDivisor, edi, 1
	inc ebx
	inc edi
	cmp bl, 4
	jb .loop_set_mat
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, 0
	invoke_dll_stdcall glBindVertexArray, 0

	GetUniformLocation [_DrawTerrainProgram], "view_proj"
	mov [_TerrainProgramLocations.ViewProj], eax
	GetUniformLocation [_DrawTerrainProgram], "time"
	mov [_TerrainProgramLocations.Time], eax
	GetUniformLocation [_DrawTerrainProgram], "terrain"
	mov [_TerrainProgramLocations.Terrain], eax
.end:
	FrameEnd
	ret

DefFunc _SceneLoad0A
	FrameBegin 0, 0
	mov dword [_CameraPos + Vector.y], __?float32?__(100.0)
	FrameEnd
	ret

DefFunc _SceneLoad0B
	FrameBegin 0, 0

	FrameEnd
	ret

DefFunc _SceneLoadProgressive
	FrameBegin 0, 0, ebx

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
	FrameBegin 0, 5, ebx

	xor ebx, ebx

	invoke_cdecl _DestroyFloatMap, [_TerrainBitmap]
	invoke_cdecl _DeInitBuffer, _TerrainVerticesBuffer
	invoke_cdecl _DeInitBuffer, _TerrainIndicesBuffer
	invoke_cdecl _DeInitBuffer, _TerrainInstancesBuffer
	invoke_cdecl _DeInitBuffer, _BillboardVerticesBuffer

	mov [_TerrainBitmap], ebx

	FrameEnd
	ret

DefFunc _Scene
	FrameBegin 11, 5, ebx, esi, edi
	AssignVars TimerValue32, DeltaTimeL, DeltaTimeH, DeltaTime32
	AssignVars KeyW, KeyS, KeyA, KeyD, KeySpace, KeyCtrl
	AssignVars CurMovementSpeed

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
	fild dword [_ClientRect.r]
	fidiv dword [_ClientRect.b]
	fstp dword [_Aspect]
	invoke_dll_stdcall glViewport, [_ClientRect.l], [_ClientRect.t], [_ClientRect.r], [_ClientRect.b]

	invoke_dll_stdcall glClearColor, 0, 0, 0, 0
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
	invoke_cdecl _MatrixEulerTranslated, _ModelMatrix, NULL, 0, 0, 0
	invoke_cdecl _MatrixViewEuler, _CameraViewMatrix, _CameraPos, [_CameraYaw], [_CameraPitch], 0
	invoke_cdecl _MatrixProjection, _ProjectionMatrix, [_FovY], [_Aspect], 0.1f, 1000.0f
	invoke_cdecl _MatrixMultiply, _ViewProjMatrix, _CameraViewMatrix, _ProjectionMatrix

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

	invoke_dll_stdcall glDisable, GL_DEPTH_TEST

	invoke_dll_stdcall glUseProgram, [_DrawBillboardProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glUniformMatrix4fv, [_BillboardProgramLocations.CameraMatrix], 1, 0, _CameraMatrix
	invoke_dll_stdcall glUniform1f, [_BillboardProgramLocations.Aspect], [_Aspect]
	invoke_dll_stdcall glUniform1f, [_BillboardProgramLocations.FovY], [_FovYCos]
	invoke_dll_stdcall glUniform1f, [_BillboardProgramLocations.Time], TimerValue32
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_PerlinNoiseTextureMipLinear]
	invoke_dll_stdcall glUniform1i, [_BillboardProgramLocations.Noise], 0
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4
	invoke_dll_stdcall glBindVertexArray, 0
	invoke_dll_stdcall glUseProgram, 0

	invoke_dll_stdcall glEnable, GL_DEPTH_TEST
	;invoke_dll_stdcall glPolygonMode, GL_FRONT_AND_BACK, GL_LINE

	invoke_cdecl _BufferResize, _TerrainInstancesBuffer, TerrainBorderLen * TerrainBorderLen
	xor eax, eax
	mov ebx, [_TerrainInstancesBuffer.pointer]
	mov [_TerrainInstancesBuffer.flushed], eax

	movaps xmm0, [_CameraPos]
	movaps xmm7, [_TerrainMapScalingVector]
	andps xmm0, [_UF0F0]
	andps xmm7, [_UF0F0]
	mulps xmm0, [_TerrainMapScalingVectorRCP]
	cmp dword[_HaveSSE41], 0
	jnz .with_sse41
	cvttps2dq xmm1, xmm0
	cvtdq2ps xmm6, xmm1
	movaps xmm3, xmm0
	xorps xmm4, xmm4
	movaps xmm5, xmm0
	cmpps xmm3, xmm6, _MM_CMP_NEQ_
	cmpps xmm5, xmm4, _MM_CMP_LT_
	andps xmm3, xmm5
	movaps xmm4, [_F1111]
	andps xmm4, xmm3
	subps xmm6, xmm4
	jmp .prep_instance_buffer
.with_sse41:
	roundps xmm6, xmm0, _MM_ROUND_DOWN_
.prep_instance_buffer:
	movaps xmm0, [_F1000]
	movaps xmm1, [_F0100]
	movaps xmm2, [_F0010]
	xorps xmm4, xmm4
	xorps xmm5, xmm5

	mov eax, (-TerrainBorderLen / 2) & 0xFFFFFFFF
	xor esi, esi
.terrain_loopy:
	mov ecx, eax
	add ecx, esi
	xor edi, edi
.terrain_loopx:
	mov edx, eax
	add edx, edi
	cvtsi2ss xmm4, ecx
	cvtsi2ss xmm5, edx
	movaps xmm3, xmm6
	shufps xmm4, xmm5, _MM_SHUFFLE(1, 0, 1, 0)
	addps xmm3, xmm4
	mulps xmm3, xmm7
	addps xmm3, [_F0001]

	movups [ebx + Matrix.x], xmm0
	movups [ebx + Matrix.y], xmm1
	movups [ebx + Matrix.z], xmm2
	movups [ebx + Matrix.w], xmm3
	add ebx, Matrix.size

	inc edi
	cmp edi, TerrainBorderLen
	jl .terrain_loopx

	inc esi
	cmp esi, TerrainBorderLen
	jl .terrain_loopy

	invoke_cdecl _BufferFlush, _TerrainInstancesBuffer

	invoke_dll_stdcall glUseProgram, [_DrawTerrainProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawTerrainVAO]
	invoke_dll_stdcall glUniformMatrix4fv, [_TerrainProgramLocations.ViewProj], 1, 0, _ViewProjMatrix
	invoke_dll_stdcall glUniform1f, [_TerrainProgramLocations.Time], TimerValue32
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_PerlinNoiseTextureMipLinear]
	invoke_dll_stdcall glUniform1i, [_TerrainProgramLocations.Terrain], 0
	invoke_dll_stdcall glBindBuffer, GL_ELEMENT_ARRAY_BUFFER, [_TerrainIndicesBuffer.gl_buffer]
	invoke_dll_stdcall glDrawElementsInstanced, GL_TRIANGLES, [_TerrainIndicesBuffer.num_items], GL_UNSIGNED_INT, 0, [_TerrainInstancesBuffer + GlBuffer.num_items]
	invoke_dll_stdcall glBindBuffer, GL_ELEMENT_ARRAY_BUFFER, [_TerrainIndicesBuffer.gl_buffer]
	invoke_dll_stdcall glBindVertexArray, 0
	invoke_dll_stdcall glUseProgram, 0

	;invoke_dll_stdcall glPolygonMode, GL_FRONT_AND_BACK, GL_FILL

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

DefFunc _SwapBuffers
	FrameBegin 0, 0
	mov eax, [_addr_of_wglSwapInterval]
	test eax, eax
	jnz .swap_buffers

	invoke_dll_stdcall DwmFlush

.swap_buffers:
	invoke_dll_stdcall wglSwapBuffers, [_hDC]
	FrameEnd
	ret
