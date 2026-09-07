%include "common.inc"
%include "gl33.inc"
%include "scene.inc"
%include "shader.inc"

DefFunc _InitTexRepeatLinear
	FrameBegin ebx
	NameParams %$Target
	mov ebx, %$Target
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_WRAP_S, GL_REPEAT
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_WRAP_T, GL_REPEAT
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_MIN_FILTER, GL_LINEAR
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke_stdcall glBindTexture, ebx, 0
	FrameEnd
	ret

DefFunc _InitTexRepeatLinearMipmap
	FrameBegin ebx
	NameParams %$Target
	mov ebx, %$Target
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_WRAP_S, GL_REPEAT
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_WRAP_T, GL_REPEAT
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke_stdcall glGenerateMipmap, ebx
	invoke_stdcall glBindTexture, ebx, 0
	FrameEnd
	ret

DefFunc _InitTexRenderTarget
	FrameBegin ebx
	NameParams %$Target
	mov ebx, %$Target
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR
	invoke_stdcall glTexParameteri, ebx, GL_TEXTURE_MAG_FILTER, GL_LINEAR
	invoke_stdcall glBindTexture, ebx, 0
	FrameEnd
	ret

DefFunc _InitRGBA32FBufferTexture
	FrameBegin ebx
	NameParams %$SaveTo, %$Width, %$Height

	mov ebx, %$SaveTo
	invoke_cdecl _DeleteTexture, ebx
	invoke_stdcall glGenTextures, 1, ebx
	invoke_stdcall glBindTexture, GL_TEXTURE_2D, [ebx]
	invoke_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_RGBA32F, %$Width, %$Height, 0, GL_RGBA, GL_FLOAT, NULL

	FrameEnd
	ret

DefFunc _InitRGBA8BufferTexture
	FrameBegin ebx
	NameParams %$SaveTo, %$Width, %$Height

	mov ebx, %$SaveTo
	invoke_cdecl _DeleteTexture, ebx
	invoke_stdcall glGenTextures, 1, ebx
	invoke_stdcall glBindTexture, GL_TEXTURE_2D, [ebx]
	invoke_stdcall glTexImage2D, GL_TEXTURE_2D, 0, GL_RGBA, %$Width, %$Height, 0, GL_RGBA, GL_UNSIGNED_INT, NULL

	FrameEnd
	ret

DefFunc _InitDepthBuffer
	FrameBegin ebx
	NameParams %$SaveTo, %$Width, %$Height

	mov ebx, %$SaveTo
	invoke_cdecl _DeleteRenderbuffer, ebx
	invoke_stdcall glGenRenderbuffers, 1, ebx
	invoke_stdcall glBindRenderbuffer, GL_RENDERBUFFER, [ebx]
	invoke_stdcall glRenderbufferStorage, GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, %$Width, %$Height
	invoke_stdcall glBindRenderbuffer, GL_RENDERBUFFER, 0

	FrameEnd
	ret

DefFunc _DeleteTexture
	FrameBegin ebx
	NameParams %$PtrToDel
	mov ebx, %$PtrToDel
	invoke_stdcall glDeleteTextures, 1, ebx
	xor eax, eax
	mov [ebx], eax
	FrameEnd
	ret

DefFunc _DeleteProgram
	FrameBegin ebx
	NameParams %$PtrToDel
	mov ebx, %$PtrToDel
	invoke_stdcall glDeleteProgram, [ebx]
	xor eax, eax
	mov [ebx], eax
	FrameEnd
	ret

DefFunc _DeleteRenderbuffer
	FrameBegin ebx
	NameParams %$PtrToDel
	mov ebx, %$PtrToDel
	invoke_stdcall glDeleteRenderbuffers, 1, ebx
	xor eax, eax
	mov [ebx], eax
	FrameEnd
	ret

DefFunc _InitSSTextureSets
	FrameBegin ebx, esi, edi
	NameParams %$Textures, %$VPWidth, %$VPHeight

	mov ebx, %$Textures
	mov esi, %$VPWidth
	mov edi, %$VPHeight
	invoke_cdecl _InitRGBA32FBufferTexture, &[ebx + SSTextures.NormalDist], esi, edi
	invoke_cdecl _InitTexRenderTarget, GL_TEXTURE_2D
	invoke_cdecl _InitRGBA8BufferTexture, &[ebx + SSTextures.Diffuse], esi, edi
	invoke_cdecl _InitTexRenderTarget, GL_TEXTURE_2D
	invoke_cdecl _InitRGBA8BufferTexture, &[ebx + SSTextures.Specular], esi, edi
	invoke_cdecl _InitTexRenderTarget, GL_TEXTURE_2D
	invoke_cdecl _InitRGBA32FBufferTexture, &[ebx + SSTextures.Emissive], esi, edi
	invoke_cdecl _InitTexRenderTarget, GL_TEXTURE_2D
	invoke_cdecl _InitRGBA32FBufferTexture, &[ebx + SSTextures.Scatter], esi, edi
	invoke_cdecl _InitTexRenderTarget, GL_TEXTURE_2D

	FrameEnd
	ret

DefFunc _DeInitSSTextureSets
	FrameBegin ebx
	NameParams %$Textures

	mov ebx, %$Textures

	invoke_cdecl _DeleteTexture, & [ebx + SSTextures.NormalDist]
	invoke_cdecl _DeleteTexture, & [ebx + SSTextures.Diffuse]
	invoke_cdecl _DeleteTexture, & [ebx + SSTextures.Specular]
	invoke_cdecl _DeleteTexture, & [ebx + SSTextures.Emissive]
	invoke_cdecl _DeleteTexture, & [ebx + SSTextures.Scatter]

	FrameEnd
	ret

DefFunc _SetupSSFBOOutputs
	FrameBegin ebx, esi, edi
	NameParams %$SSTextureSet, %$FirstOutput
	DefSizedVar %$Attachments, 32 * 4

	lea ebx, %$Attachments
	mov esi, %$FirstOutput
	xor edi, edi
.loop_set_ss_outputs:
	lodsd
	add eax, GL_COLOR_ATTACHMENT0
	mov [ebx + edi * 4], eax
	mov edx, %$SSTextureSet
	invoke_stdcall glFramebufferTexture2D, GL_DRAW_FRAMEBUFFER, eax, GL_TEXTURE_2D, [edx + edi * 4], 0
	inc edi
	cmp edi, SSTextures.NumTextures
	jb .loop_set_ss_outputs

	invoke_stdcall glDrawBuffers, edi, ebx

	FrameEnd
	ret

DefFunc _SetupSSTextureMipmaps
	FrameBegin esi, edi
	NameParams %$SSTextureSet

	mov esi, %$SSTextureSet
	xor edi, edi
.loop_gen_mipmaps:
	lodsd
	invoke_stdcall glBindTexture, GL_TEXTURE_2D, eax
	invoke_stdcall glGenerateMipmap, GL_TEXTURE_2D
	inc edi
	cmp edi, SSTextures.NumTextures
	jb .loop_gen_mipmaps

	invoke_stdcall glBindTexture, GL_TEXTURE_2D, 0

	FrameEnd
	ret

DefFunc _SetupSSTextureShaderInput
	FrameBegin ebx, esi, edi
	NameParams %$SSTextureSet, %$Location

	mov ebx, %$SSTextureSet
	mov esi, %$Location
	xor edi, edi
.loop_setup:
	invoke_stdcall glActiveTexture, &[GL_TEXTURE0 + esi + edi]
	invoke_stdcall glBindTexture, GL_TEXTURE_2D, [ebx + edi * 4]
	inc edi
	cmp edi, SSTextures.NumTextures
	jb .loop_setup

	FrameEnd
	ret

DefFunc _SceneLoadDrawProgressProgram
	FrameBegin ebx, esi, edi
	NameParams %$PtrToDrawProgressProgram, %$DrawProgressProgramLocations, %$DrawBillboardVAO, %$DrawBillboardVBO

	mov ebx, %$PtrToDrawProgressProgram
	SceneLoadShaderProgram ebx, \
		GL_VERTEX_SHADER, str "assets\loading.vsh", \
		GL_FRAGMENT_SHADER, str "assets\loading.fsh"
	test eax, eax
	jz .bad_end

	mov ebx, [ebx]

	invoke_stdcall glBindVertexArray, %$DrawBillboardVAO
	invoke_stdcall glBindBuffer, GL_ARRAY_BUFFER, %$DrawBillboardVBO
	GetAttribLocation ebx, "position"
	mov edi, eax
	invoke_stdcall glEnableVertexAttribArray, edi
	invoke_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_stdcall glBindVertexArray, 0

	mov esi, %$DrawProgressProgramLocations

	GetUniformLocation ebx, "progress"
	mov [esi + DrawProgressProgramLocations.Progress], eax

	mov eax, ebx
.bad_end:
	FrameEnd
	ret

DefFunc _SceneLoadDrawTerrainProgram
	FrameBegin ebx, esi, edi
	NameParams %$PtrToDrawTerrainProgram, %$DrawTerrainProgramLocations, %$DrawBillboardVAO, %$DrawBillboardVBO

	mov ebx, %$PtrToDrawTerrainProgram
	SceneLoadShaderProgram ebx, \
		GL_VERTEX_SHADER, str "assets\billboard.vsh", \
		GL_FRAGMENT_SHADER, str "assets\ray.fsh", \
		GL_FRAGMENT_SHADER, str "assets\ssample.fsh", \
		GL_FRAGMENT_SHADER, str "assets\terrain.fsh", \
		GL_FRAGMENT_SHADER, str "assets\terrain_out.fsh"
	test eax, eax
	jz .bad_end

	mov ebx, [ebx]

	invoke_stdcall glBindVertexArray, %$DrawBillboardVAO
	invoke_stdcall glBindBuffer, GL_ARRAY_BUFFER, %$DrawBillboardVBO
	GetAttribLocation ebx, "position"
	mov edi, eax
	invoke_stdcall glEnableVertexAttribArray, edi
	invoke_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_stdcall glBindVertexArray, 0

	mov esi, %$DrawTerrainProgramLocations

	GetUniformLocation ebx, "camorient"
	mov [esi + DrawTerrainProgramLocations.CameraMatrix], eax
	GetUniformLocation ebx, "proj"
	mov [esi + DrawTerrainProgramLocations.ProjMatrix], eax
	GetUniformLocation ebx, "campos"
	mov [esi + DrawTerrainProgramLocations.CameraPosition], eax
	GetUniformLocation ebx, "render_distance"
	mov [esi + DrawTerrainProgramLocations.RenderDistance], eax
	GetUniformLocation ebx, "terrain_altmap"
	mov [esi + DrawTerrainProgramLocations.TerrainAltitudeMap], eax
	GetUniformLocation ebx, "terrain_conemap"
	mov [esi + DrawTerrainProgramLocations.TerrainConeMap], eax
	GetUniformLocation ebx, "terrain_height"
	mov [esi + DrawTerrainProgramLocations.TerrainHeight], eax
	GetUniformLocation ebx, "terrain_scaling"
	mov [esi + DrawTerrainProgramLocations.TerrainScaling], eax
	GetUniformLocation ebx, "texture_quality"
	mov [esi + DrawTerrainProgramLocations.TextureQuality], eax

	GetFragDataLocation ebx, "out_normal_dist"
	mov [esi + DrawTerrainProgramLocations.OutNormalDist], eax
	GetFragDataLocation ebx, "out_diffuse"
	mov [esi + DrawTerrainProgramLocations.OutDiffuse], eax
	GetFragDataLocation ebx, "out_specular"
	mov [esi + DrawTerrainProgramLocations.OutSpecular], eax
	GetFragDataLocation ebx, "out_emissive"
	mov [esi + DrawTerrainProgramLocations.OutEmissive], eax
	GetFragDataLocation ebx, "out_scatter"
	mov [esi + DrawTerrainProgramLocations.OutScatter], eax

	mov eax, ebx
.bad_end:
	FrameEnd
	ret

DefFunc _SceneLoadDrawWaterProgram
	FrameBegin ebx, esi, edi
	NameParams %$PtrToDrawWaterProgram, %$DrawWaterProgramLocations, %$DrawBillboardVAO, %$DrawBillboardVBO

	mov ebx, %$PtrToDrawWaterProgram
	SceneLoadShaderProgram ebx, \
		GL_VERTEX_SHADER, str "assets\billboard.vsh", \
		GL_FRAGMENT_SHADER, str "assets\ray.fsh", \
		GL_FRAGMENT_SHADER, str "assets\ssample.fsh", \
		GL_FRAGMENT_SHADER, str "assets\terrain.fsh", \
		GL_FRAGMENT_SHADER, str "assets\water.fsh", \
		GL_FRAGMENT_SHADER, str "assets\water_out.fsh"
	test eax, eax
	jz .bad_end

	mov ebx, [ebx]

	invoke_stdcall glBindVertexArray,  %$DrawBillboardVAO
	invoke_stdcall glBindBuffer, GL_ARRAY_BUFFER, %$DrawBillboardVBO
	GetAttribLocation ebx, "position"
	mov edi, eax
	invoke_stdcall glEnableVertexAttribArray, edi
	invoke_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_stdcall glBindVertexArray, 0

	mov esi, %$DrawWaterProgramLocations

	GetUniformLocation ebx, "camorient"
	mov [esi + DrawWaterProgramLocations.CameraMatrix], eax
	GetUniformLocation ebx, "proj"
	mov [esi + DrawWaterProgramLocations.ProjMatrix], eax
	GetUniformLocation ebx, "campos"
	mov [esi + DrawWaterProgramLocations.CameraPosition], eax
	GetUniformLocation ebx, "time"
	mov [esi + DrawWaterProgramLocations.Time], eax
	GetUniformLocation ebx, "render_distance"
	mov [esi + DrawWaterProgramLocations.RenderDistance], eax
	GetUniformLocation ebx, "terrain_altmap"
	mov [esi + DrawWaterProgramLocations.TerrainAltitudeMap], eax
	GetUniformLocation ebx, "terrain_conemap"
	mov [esi + DrawWaterProgramLocations.TerrainConeMap], eax
	GetUniformLocation ebx, "terrain_height"
	mov [esi + DrawWaterProgramLocations.TerrainHeight], eax
	GetUniformLocation ebx, "terrain_scaling"
	mov [esi + DrawWaterProgramLocations.TerrainScaling], eax
	GetUniformLocation ebx, "texture_quality"
	mov [esi + DrawWaterProgramLocations.TextureQuality], eax
	GetUniformLocation ebx, "sea_level"
	mov [esi + DrawWaterProgramLocations.SeaLevel], eax
	GetUniformLocation ebx, "sea_wave_height"
	mov [esi + DrawWaterProgramLocations.SeaWaveHeight], eax
	GetUniformLocation ebx, "sea_wave_size"
	mov [esi + DrawWaterProgramLocations.SeaWaveSize], eax
	GetUniformLocation ebx, "terrain_normal_depth"
	mov [esi + DrawWaterProgramLocations.SSTerrainNormalDepth], eax

	GetFragDataLocation ebx, "out_normal_dist"
	mov [esi + DrawWaterProgramLocations.OutNormalDist], eax
	GetFragDataLocation ebx, "out_diffuse"
	mov [esi + DrawWaterProgramLocations.OutDiffuse], eax
	GetFragDataLocation ebx, "out_specular"
	mov [esi + DrawWaterProgramLocations.OutSpecular], eax
	GetFragDataLocation ebx, "out_emissive"
	mov [esi + DrawWaterProgramLocations.OutEmissive], eax
	GetFragDataLocation ebx, "out_scatter"
	mov [esi + DrawWaterProgramLocations.OutScatter], eax

	mov eax, ebx
.bad_end:
	FrameEnd
	ret

DefFunc _SceneLoadDrawCompositeProgram
	FrameBegin ebx, esi, edi
	NameParams %$PtrToDrawCompositeProgram, %$DrawCompositeProgramLocations, %$DrawBillboardVAO, %$DrawBillboardVBO

	mov ebx, %$PtrToDrawCompositeProgram
	SceneLoadShaderProgram ebx, \
		GL_VERTEX_SHADER, str "assets\billboard.vsh", \
		GL_FRAGMENT_SHADER, str "assets\ray.fsh", \
		GL_FRAGMENT_SHADER, str "assets\composite.fsh"
	test eax, eax
	jz .bad_end

	mov ebx, [ebx]

	invoke_stdcall glBindVertexArray, %$DrawBillboardVAO
	invoke_stdcall glBindBuffer, GL_ARRAY_BUFFER, %$DrawBillboardVBO
	GetAttribLocation ebx, "position"
	mov edi, eax
	invoke_stdcall glEnableVertexAttribArray, edi
	invoke_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_stdcall glBindVertexArray, 0

	mov esi, %$DrawCompositeProgramLocations

	GetUniformLocation ebx, "camorient"
	mov [esi + DrawCompositeProgramLocations.CameraMatrix], eax
	GetUniformLocation ebx, "proj"
	mov [esi + DrawCompositeProgramLocations.ProjMatrix], eax
	GetUniformLocation ebx, "campos"
	mov [esi + DrawCompositeProgramLocations.CameraPosition], eax
	GetUniformLocation ebx, "sunpos"
	mov [esi + DrawCompositeProgramLocations.SunPosition], eax
	GetUniformLocation ebx, "render_distance"
	mov [esi + DrawCompositeProgramLocations.RenderDistance], eax
	GetUniformLocation ebx, "normal_distance"
	mov [esi + DrawCompositeProgramLocations.TexSSNormalDist], eax
	GetUniformLocation ebx, "diffuse"
	mov [esi + DrawCompositeProgramLocations.TexSSDiffuse], eax
	GetUniformLocation ebx, "specular"
	mov [esi + DrawCompositeProgramLocations.TexSSSpecular], eax
	GetUniformLocation ebx, "emissive"
	mov [esi + DrawCompositeProgramLocations.TexSSEmissive], eax
	GetUniformLocation ebx, "scatter"
	mov [esi + DrawCompositeProgramLocations.TexSSScatter], eax

	GetFragDataLocation ebx, "color"
	mov [esi + DrawCompositeProgramLocations.OutColor], eax

	mov eax, ebx
.bad_end:
	FrameEnd
	ret

DefFunc _SceneLoadDrawBlurProgram
	FrameBegin ebx, esi, edi
	NameParams %$PtrToDrawBlurProgram, %$DrawBlurProgramLocations, %$DrawBillboardVAO, %$DrawBillboardVBO

	mov ebx, %$PtrToDrawBlurProgram
	SceneLoadShaderProgram ebx, \
		GL_VERTEX_SHADER, str "assets\billboard.vsh", \
		GL_FRAGMENT_SHADER, str "assets\blur.fsh"
	test eax, eax
	jz .bad_end

	mov ebx, [ebx]

	invoke_stdcall glBindVertexArray, %$DrawBillboardVAO
	invoke_stdcall glBindBuffer, GL_ARRAY_BUFFER, %$DrawBillboardVBO
	GetAttribLocation ebx, "position"
	mov edi, eax
	invoke_stdcall glEnableVertexAttribArray, edi
	invoke_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_stdcall glBindVertexArray, 0

	mov esi, %$DrawBlurProgramLocations

	GetUniformLocation ebx, "hdr_texture"
	mov [esi + DrawBlurProgramLocations.HDRTexture], eax

	GetFragDataLocation ebx, "color"
	mov [esi + DrawBlurProgramLocations.OutColor], eax

	mov eax, ebx
.bad_end:
	FrameEnd
	ret

DefFunc _SceneLoadDrawHDR2LDRProgram
	FrameBegin ebx, esi, edi
	NameParams %$PtrToDrawDR2LDRProgram, %$DrawDR2LDRProgramLocations, %$DrawBillboardVAO, %$DrawBillboardVBO

	mov ebx, %$PtrToDrawDR2LDRProgram
	SceneLoadShaderProgram ebx, \
		GL_VERTEX_SHADER, str "assets\billboard.vsh", \
		GL_FRAGMENT_SHADER, str "assets\hdr2ldr.fsh"
	test eax, eax
	jz .bad_end

	mov ebx, [ebx]

	invoke_stdcall glBindVertexArray, %$DrawBillboardVAO
	invoke_stdcall glBindBuffer, GL_ARRAY_BUFFER, %$DrawBillboardVBO
	GetAttribLocation ebx, "position"
	mov edi, eax
	invoke_stdcall glEnableVertexAttribArray, edi
	invoke_stdcall glVertexAttribPointer, edi, 2, GL_BYTE, 0, 2, 0
	invoke_stdcall glBindVertexArray, 0

	mov esi, %$DrawDR2LDRProgramLocations

	GetUniformLocation ebx, "blur_texture"
	mov [esi + DrawHDR2LDRProgramLocations.BlurTexture], eax
	GetUniformLocation ebx, "hdr_texture"
	mov [esi + DrawHDR2LDRProgramLocations.HDRTexture], eax

	GetFragDataLocation ebx, "color"
	mov [esi + DrawHDR2LDRProgramLocations.OutColor], eax

	mov eax, ebx
.bad_end:
	FrameEnd
	ret

DefFunc _Scene_check_fbo
	FrameBegin
	invoke_stdcall glCheckFramebufferStatus, GL_DRAW_FRAMEBUFFER
	cmp eax, GL_FRAMEBUFFER_COMPLETE
	jne .fbo_not_complete
	xor eax, eax
	inc eax
	jmp .check_fbo_ret
.fbo_not_complete:
	debug_msg `glCheckFramebufferStatus() returns %d`, eax
	xor eax, eax
.check_fbo_ret:
	FrameEnd
	ret

DefFunc _Scene_clear_color
	FrameBegin
	invoke_stdcall glClearColor, 0, 0, 0, 0
	invoke_stdcall glClearDepth, 1.0
	invoke_stdcall glClear, GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
	FrameEnd
	ret

DefFunc _Scene_clear_buffers
	FrameBegin edi

	invoke_stdcall glClearBufferfv, GL_COLOR, 0, label .clear_nd
	invoke_stdcall glClearBufferfv, GL_COLOR, 1, label .clear_zeroes
	invoke_stdcall glClearBufferfv, GL_COLOR, 2, label .clear_zeroes
	invoke_stdcall glClearBufferfv, GL_COLOR, 3, label .clear_zeroes
	invoke_stdcall glClearBufferfv, GL_COLOR, 4, label .clear_ones
	invoke_stdcall glClearDepth, 1.0
	invoke_stdcall glClear, GL_DEPTH_BUFFER_BIT
	FrameEnd
	ret
[segment .data]
	.clear_nd dd 0, 0, 0, FLT_MAX
	.clear_zeroes dd 0, 0, 0, 0
	.clear_ones dd __float32__(1.0), __float32__(1.0), __float32__(1.0), __float32__(1.0)
