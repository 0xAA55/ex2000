%include "common.inc"
%include "shader.inc"
%include "gl33.inc"
%include "assets.inc"
%include "avlbst.inc"

segment .bss
_ShadersTree resd 1

DefStr _STVertexShader, "Vertex"
DefStr _STGeometryShader, "Geometry"
DefStr _STFragmentShader, "Fragment"
DefStr _ShaderCompileError, "Shader compilation error"
DefStr _ShaderLinkageError, "Shader linkage error"

; const char *GetShaderTypeString(int shader_type);
DefFunc _GetShaderTypeString
	FrameBegin
	NameParams %$ShaderType

	mov eax, %$ShaderType
	cmp eax, GL_VERTEX_SHADER
	jz .is_vs
	cmp eax, GL_GEOMETRY_SHADER
	jz .is_gs
	cmp eax, GL_FRAGMENT_SHADER
	jz .is_fs
	xor eax, eax
	jmp .end
.is_vs:
	GetAbsAddr eax, _STVertexShader
	jmp .end
.is_gs:
	GetAbsAddr eax, _STGeometryShader
	jmp .end
.is_fs:
	GetAbsAddr eax, _STFragmentShader
.end:
	FrameEnd
	ret

; int ShaderCreate(int shader_type, char *shader_code)
DefFunc _ShaderCreate
	FrameBegin ebx, esi
	NameParams %$ShaderType, %$ShaderCode
	DefVars %$SourceLen, %$CompileStatus, %$InfoLogLen

	invoke_stdcall glCreateShader, %$ShaderType
	mov esi, eax

	invoke_cdecl strlen, %$ShaderCode
	mov %$SourceLen, eax

	invoke_stdcall glShaderSource, esi, 1, & %$ShaderCode, &%$SourceLen
	invoke_stdcall glCompileShader, esi
	invoke_stdcall glGetShaderiv, esi, GL_COMPILE_STATUS, &%$CompileStatus

	mov eax, %$CompileStatus
	test eax, eax
	jnz .success

	invoke_stdcall glGetShaderiv, esi, GL_INFO_LOG_LENGTH, &%$InfoLogLen
	mov eax, %$InfoLogLen
	invoke_cdecl _calloc, &[eax + 1], 1
	mov ebx, eax

	invoke_stdcall glGetShaderInfoLog, esi, %$InfoLogLen, 0, eax
	invoke_stdcall glDeleteShader, esi

	invoke_cdecl _GetShaderTypeString, %$ShaderType
	GetAbsAddr ecx, _ShaderCompileError
	debug_msg "%s: %s Shader: %s", ecx, eax, ebx
	invoke_cdecl _free, ebx

	xor eax, eax
	jmp .end
.success:
	mov eax, esi

.end:
	FrameEnd
	ret

; GLuint _ProgramLink(int program);
DefFunc _ProgramLink
	FrameBegin ebx, esi
	NameParams %$Program, %$PPOutInfoLog
	DefVars %$InfoLogLen, %$LinkStatus

	mov esi, %$Program
	invoke_stdcall glLinkProgram, esi
	invoke_stdcall glGetProgramiv, esi, GL_LINK_STATUS, &%$LinkStatus
	cmp dword %$LinkStatus, 0
	jnz .good_link

	invoke_stdcall glGetProgramiv, esi, GL_INFO_LOG_LENGTH, &%$InfoLogLen
	mov eax, %$InfoLogLen
	invoke_cdecl _calloc, &[eax + 1], 1
	mov ebx, eax

	invoke_stdcall glGetProgramInfoLog, esi, %$InfoLogLen, &%$InfoLogLen, ebx
	GetAbsAddr ecx, _ShaderLinkageError
	debug_msg "%s: %s", ecx, ebx
	invoke_cdecl _free, ebx

.good_link:
	mov eax, %$LinkStatus

	FrameEnd
	ret

; GLuint ProgramCreate(size_t num_shaders, int *shaders);
DefFunc _ProgramCreate
	FrameBegin ebx, esi, edi
	NameParams %$NumShaders, %$Shaders

	invoke_stdcall glCreateProgram
	mov ebx, eax

	mov esi, %$Shaders
	xor edi, edi
.attach_shaders:
	lodsd
	test eax, eax
	jz .skipped
	invoke_stdcall glAttachShader, ebx, eax
.skipped:
	inc edi
	cmp edi, %$NumShaders
	jb .attach_shaders

	invoke_cdecl _ProgramLink, ebx
	test eax, eax
	jnz .good_link

.bad_end:
	invoke_stdcall glDeleteProgram, ebx
	xor ebx, ebx

.good_link:
	mov eax, ebx

	FrameEnd
	ret

; void _SceneOnTreeNodeFree(int shader_obj);
DefFunc _SceneOnTreeNodeFree
	FrameBegin
	NameParams %$ShaderObj
	invoke_stdcall glDeleteShader, %$ShaderObj
	FrameEnd
	ret

; GLuint SceneQueryShader(int shader_type, const char *shader_asset_path)
DefFunc _SceneQueryShader
	FrameBegin ebx
	NameParams %$ShaderType, %$ShaderAssetPath
	DefVars %$ShaderObj
	GetAbsAddr ebx, _ShadersTree

	invoke_cdecl strlen, %$ShaderAssetPath
	test eax, eax
	jz .end
	invoke_cdecl _AVLSearch, [ebx], %$ShaderAssetPath
	test eax, eax
	jnz .found
	invoke_cdecl _AssetsQuery, %$ShaderAssetPath, 0
	test eax, eax
	jz .not_found
	invoke_cdecl _ShaderCreate, %$ShaderType, eax
	test eax, eax
	jz .fail_exit
	mov %$ShaderObj, eax

	invoke_cdecl _Get_AVLOps_String
	GetAbsAddr ecx, _SceneOnTreeNodeFree
	invoke_cdecl _AVLInsert, ebx, %$ShaderAssetPath, %$ShaderObj, ecx, eax
	jmp .found
.not_found:
	invoke_cdecl _GetShaderTypeString, %$ShaderType
	debug_msg "%s Shader not found: %s", eax, %$ShaderAssetPath
.fail_exit:
	xor eax, eax
	jmp .end
.found:
	mov eax, [eax + AVLBST_Node.userdata]
.end:
	FrameEnd
	ret

; void SceneOnDisposeShaders()
DefFunc _SceneOnDisposeShaders
	FrameBegin ebx
	GetAbsAddr ebx, _ShadersTree
	invoke_cdecl _AVLClear, ebx
	FrameEnd
	ret

; void SceneLoadShaderProgram(_out_ GLuint *program, _in_ char *VertexShaderAssetPath, _in_ char *GeometryShaderAssetPath, _in_ char *FragmentShaderAssetPath);
DefFunc _SceneLoadShaderProgram
	FrameBegin ebx, esi
	NameParams %$PProgramOut, %$VSPath, %$GSPath, %$FSPath
	DefVars %$VSObj, %$GSObj, %$FSObj

	invoke_stdcall glCreateProgram
	mov ebx, eax
	mov esi, %$PProgramOut
	invoke_cdecl _SceneQueryShader, GL_VERTEX_SHADER, %$VSPath
	mov %$VSObj, eax
	invoke_cdecl _SceneQueryShader, GL_GEOMETRY_SHADER, %$GSPath
	mov %$GSObj, eax
	invoke_cdecl _SceneQueryShader, GL_FRAGMENT_SHADER, %$FSPath
	mov %$FSObj, eax
	invoke_cdecl _ProgramCreate, 3, & %$VSObj
	mov [esi], eax

	FrameEnd
	ret

; void SceneLoadShaderProgramEx(_out_ GLuint *program, int shader_type, const char *shader_asset_path, ...);
DefFunc _SceneLoadShaderProgramEx
	FrameBegin ebx, esi, edi
	NameParams %$PProgramOut, %$Args
	DefVars %$ShaderType, %$NumShaders

	xor eax, eax
	lea esi, %$Args
	mov %$NumShaders, eax
	mov ebx, %$PProgramOut
	mov edi, esi
.loop_translate_path:
	lodsd
	test eax, eax
	jz .proceed_compile
	mov %$ShaderType, eax
	lodsd
	test eax, eax
	jz .loop_translate_path
	invoke_cdecl _SceneQueryShader, %$ShaderType, eax
	stosd
	inc dword %$NumShaders
	jmp .loop_translate_path
.proceed_compile:

	invoke_cdecl _ProgramCreate, %$NumShaders, & %$Args
	mov [ebx], eax

	FrameEnd
	ret
