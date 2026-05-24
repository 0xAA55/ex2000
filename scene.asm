%include "loaddll.inc"
%include "timer.inc"
%include "gl33.inc"
%include "buffer.inc"
%include "assets.inc"
%include "shader.inc"
%include "math.inc"

extern _hWnd
extern _hDC

def_dll Dwmapi, "dwmapi.dll"
def_dll_func DwmFlush

import_dll_func Sleep
import_dll_func GetCursorPos
import_dll_func SetCursorPos
import_dll_func ShowCursor
import_dll_func GetWindowRect
import_dll_func GetClientRect
import_dll_func GetAsyncKeyState
import_dll_func GetForegroundWindow

extern _calloc
extern _realloc
extern _free
import_dll_func memcpy
import_dll_func strcpy
import_dll_func strlen
import_dll_func strcat
import_dll_func snprintf

segment .bss
extern _BillboardVerticesBuffer
_BillboardVerticesBuffer resb GlBuffer.size
extern _DrawBillboardVAO
_DrawBillboardVAO resd 1
extern _DrawTerrainVAO
_DrawTerrainVAO resd 1
extern _DrawBillboardProgram
_DrawBillboardProgram resd 1
extern _DrawTerrainProgram
_DrawTerrainProgram resd 1
extern _TerrainVerticesBuffer
_TerrainVerticesBuffer resb GlBuffer.size
extern _TerrainIndicesBuffer
_TerrainIndicesBuffer resb GlBuffer.size
extern _PerlinNoiseTexture
_PerlinNoiseTexture resd 1
extern _PerlinNoiseTextureMipLinear
_PerlinNoiseTextureMipLinear resd 1
extern _Timer
_Timer resb Timer.size
extern _BillboardProgramLocations
_BillboardProgramLocations:
.CameraMatrix resd 1
.Aspect resd 1
.FovY resd 1
.Noise resd 1
.Time resd 1
extern _TerrainProgramLocations
_TerrainProgramLocations:
.Transform resd 1
.Time resd 1
.Terrain resd 1
extern _MinPitch
_MinPitch resd 1
extern _MaxPitch
_MaxPitch resd 1

segment .bss
alignb 16
extern _ModelMatrix
_ModelMatrix resb Matrix.size
extern _TransformMatrix
_TransformMatrix resb Matrix.size
extern _CameraMatrix
_CameraMatrix resb Matrix.size
extern _CameraViewMatrix
_CameraViewMatrix resb Matrix.size
extern _ProjectionMatrix
_ProjectionMatrix resb Matrix.size
extern _CameraPos
_CameraPos resb Vector.size
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

segment .rdata
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
	segment .rdata
	%%VSAssetsPath db %2, 0
	%%GSAssetsPath db %3, 0
	%%FSAssetsPath db %4, 0

	segment .text
	invoke_cdecl _SceneLoadShaderProgram, %1, %%VSAssetsPath, %%GSAssetsPath, %%FSAssetsPath
%endmacro

%macro GetAttribLocation 2+
	segment .rdata
	%%AttribName db %2, 0

	segment .text
	invoke_dll_stdcall glGetAttribLocation, %1, %%AttribName
%endmacro

%macro GetUniformLocation 2+
	segment .rdata
	%%UniformName db %2, 0

	segment .text
	invoke_dll_stdcall glGetUniformLocation, %1, %%UniformName
%endmacro

segment .text
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
	FrameBegin 1, 6, ebx, esi
	AssignVars Location

	PrepParam 0, _Timer
	call _InitTimer

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
	invoke_cdecl _MathInit

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

	invoke_cdecl _GenMultiLayerPerlinAltitude, 1024, __?float32?__(1.0), 8
	mov ebx, eax
	invoke_cdecl _AltitudeToTerrain, ebx, __?float32?__(10.0), __?float32?__(100.0)
	mov esi, eax
	invoke_dll_stdcall glGenTextures, 1, _PerlinNoiseTexture
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_PerlinNoiseTexture]
	invoke_dll_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_R32F, [ebx + FloatMap.border_len], [ebx + FloatMap.border_len], 0, GL_RED, GL_FLOAT, [ebx + FloatMap.data]
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR
	invoke_dll_stdcall glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
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

	SceneLoadShaderProgram _DrawBillboardProgram, "assets\skybill.vsh", 0, "assets\skybill.fsh"
	test eax, eax
	jz .end

	SceneLoadShaderProgram _DrawTerrainProgram, "assets\terrain.vsh", 0, "assets\terrain.fsh"
	test eax, eax
	jz .end

	invoke_cdecl _InitBuffer, _BillboardVerticesBuffer, GL_ARRAY_BUFFER, GL_STATIC_DRAW, 2, _BillBoardVertices.num / 2, _BillBoardVertices
	invoke_cdecl _InitBuffer, _TerrainVerticesBuffer, GL_ARRAY_BUFFER, GL_STATIC_DRAW, SimpleVertex.size, [esi + SimpleMesh.num_vertices], [esi + SimpleMesh.vertices]
	invoke_cdecl _InitBuffer, _TerrainIndicesBuffer, GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW, 4, [esi + SimpleMesh.num_indices], [esi + SimpleMesh.indices]
	invoke_cdecl _free, esi

	invoke_dll_stdcall glGenVertexArrays, 1, _DrawBillboardVAO
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_BillboardVerticesBuffer + GlBuffer.gl_buffer]
	GetAttribLocation [_DrawBillboardProgram], "position"
	mov Location, eax
	invoke_dll_stdcall glEnableVertexAttribArray, Location
	invoke_dll_stdcall glVertexAttribPointer, Location, 2, GL_BYTE, 0, 2, 0
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, 0
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

	invoke_dll_stdcall glGenVertexArrays, 1, _DrawTerrainVAO
	invoke_dll_stdcall glBindVertexArray, [_DrawTerrainVAO]
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, [_TerrainVerticesBuffer + GlBuffer.gl_buffer]
	GetAttribLocation [_DrawTerrainProgram], "position"
	mov Location, eax
	invoke_dll_stdcall glEnableVertexAttribArray, Location
	invoke_dll_stdcall glVertexAttribPointer, Location, 3, GL_FLOAT, 0, SimpleVertex.size, SimpleVertex.position
	GetAttribLocation [_DrawTerrainProgram], "normal"
	mov Location, eax
	invoke_dll_stdcall glEnableVertexAttribArray, Location
	invoke_dll_stdcall glVertexAttribPointer, Location, 3, GL_FLOAT, 0, SimpleVertex.size, SimpleVertex.normal
	GetAttribLocation [_DrawTerrainProgram], "uv"
	mov Location, eax
	invoke_dll_stdcall glEnableVertexAttribArray, Location
	invoke_dll_stdcall glVertexAttribPointer, Location, 2, GL_FLOAT, 0, SimpleVertex.size, SimpleVertex.uv
	invoke_dll_stdcall glBindBuffer, GL_ARRAY_BUFFER, 0
	invoke_dll_stdcall glBindVertexArray, 0

	GetUniformLocation [_DrawTerrainProgram], "transform"
	mov [_TerrainProgramLocations.Transform], eax
	GetUniformLocation [_DrawTerrainProgram], "time"
	mov [_TerrainProgramLocations.Time], eax
	GetUniformLocation [_DrawTerrainProgram], "terrain"
	mov [_TerrainProgramLocations.Terrain], eax

	mov eax, 1
.end:
	FrameEnd
	ret
	%undef Location

DefFunc _FakeDwmFlush
	xor eax, eax
	ret

DefFunc _Scene
	FrameBegin 1, 5
	AssignVars TimerValue

	invoke_cdecl _UpdateTimer, _Timer

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
	invoke_dll_stdcall GetAsyncKeyState, 0x1B
	test eax, eax
	jnz .quit

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
	addps xmm2, xmm0
	movd eax, xmm2
	cmp eax, [_Pi_P]
	jle .pi_p
	subss xmm2, [_2Pi]
	movd eax, xmm2
.pi_p:
	cmp eax, [_Pi_N]
	jge .pi_n
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
	jbe .skip_frame
	fild dword [_ClientRect.r]
	fidiv dword [_ClientRect.b]
	fstp dword [_Aspect]
	fld qword [_Timer + Timer.TimerVal]
	fstp dword TimerValue
	invoke_dll_stdcall glViewport, [_ClientRect.l], [_ClientRect.t], [_ClientRect.r], [_ClientRect.b]

	invoke_dll_stdcall glClearColor, 0, 0, 0, 0
	invoke_dll_stdcall glClear, GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT

	invoke_cdecl _MatrixRotationEuler, _CameraMatrix, [_CameraYaw], [_CameraPitch], 0
	invoke_cdecl _MatrixEulerTranslated, _ModelMatrix, NULL, 0, 0, 0
	invoke_cdecl _MatrixViewEuler, _CameraViewMatrix, _CameraPos, [_CameraYaw], [_CameraPitch], 0
	invoke_cdecl _MatrixProjection, _ProjectionMatrix, [_FovY], [_Aspect], __?float32?__(0.1), __?float32?__(1000.0)
	invoke_cdecl _MatrixMultiply, _TransformMatrix, _ModelMatrix, _CameraViewMatrix
	invoke_cdecl _MatrixMultiplyTo, _TransformMatrix, _ProjectionMatrix

	invoke_dll_stdcall glDisable, GL_DEPTH_TEST

	invoke_dll_stdcall glUseProgram, [_DrawBillboardProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawBillboardVAO]
	invoke_dll_stdcall glUniformMatrix4fv, [_BillboardProgramLocations.CameraMatrix], 1, 0, _CameraMatrix
	invoke_dll_stdcall glUniform1f, [_BillboardProgramLocations.Aspect], [_Aspect]
	invoke_dll_stdcall glUniform1f, [_BillboardProgramLocations.FovY], [_FovYCos]
	invoke_dll_stdcall glUniform1f, [_BillboardProgramLocations.Time], TimerValue
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_PerlinNoiseTextureMipLinear]
	invoke_dll_stdcall glUniform1i, [_BillboardProgramLocations.Noise], 0
	invoke_dll_stdcall glDrawArrays, GL_TRIANGLE_STRIP, 0, 4

	invoke_dll_stdcall glEnable, GL_DEPTH_TEST
	;invoke_dll_stdcall glPolygonMode, GL_FRONT_AND_BACK, GL_LINE

	invoke_dll_stdcall glUseProgram, [_DrawTerrainProgram]
	invoke_dll_stdcall glBindVertexArray, [_DrawTerrainVAO]
	invoke_dll_stdcall glUniformMatrix4fv, [_TerrainProgramLocations.Transform], 1, 1, _TransformMatrix
	invoke_dll_stdcall glUniform1f, [_TerrainProgramLocations.Time], TimerValue
	invoke_dll_stdcall glActiveTexture, GL_TEXTURE0
	invoke_dll_stdcall glBindTexture, GL_TEXTURE_2D, [_PerlinNoiseTextureMipLinear]
	invoke_dll_stdcall glUniform1i, [_TerrainProgramLocations.Terrain], 0
	invoke_dll_stdcall glBindBuffer, GL_ELEMENT_ARRAY_BUFFER, [_TerrainIndicesBuffer + GlBuffer.gl_buffer]
	invoke_dll_stdcall glDrawElements, GL_TRIANGLES, [_TerrainIndicesBuffer + GlBuffer.num_items], GL_UNSIGNED_INT, 0
	invoke_dll_stdcall glBindBuffer, GL_ELEMENT_ARRAY_BUFFER, [_TerrainIndicesBuffer + GlBuffer.gl_buffer]
	invoke_dll_stdcall glBindVertexArray, 0
	invoke_dll_stdcall glUseProgram, 0

	;invoke_dll_stdcall glPolygonMode, GL_FRONT_AND_BACK, GL_FILL
.skip_frame:
	invoke_cdecl _SwapBuffers
	xor eax, eax
	inc eax
	jmp .end
.quit:
	xor eax, eax

.end:
	FrameEnd
	ret
	%undef TimerValue

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
