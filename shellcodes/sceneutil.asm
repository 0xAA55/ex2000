%include "common.inc"
%include "gl33.inc"
%include "scene.inc"

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
