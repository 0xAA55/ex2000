%include "common.inc"
%include "shader.inc"
%include "gl33.inc"
%include "assets.inc"
%include "strpool.inc"

segment .rdata
DefStr _STVertexShader, "Vertex"
DefStr _STGeometryShader, "Geometry"
DefStr _STFragmentShader, "Fragment"
DefStr _ShaderCompileError, "Shader compilation error"
DefStr _ShaderLinkageError, "Shader linkage error"

; int ShaderCreate(int program, int shader_type, char *shader_code, char **pp_out_infolog)
DefFunc _ShaderCreate
	FrameBegin
	NameParams %$Program, %$ShaderType, %$ShaderCode, %$PPOutInfoLog
	DefVars %$Shader, %$SourceLen, %$CompileStatus, %$InfoLogLen, %$InfoLogBuf

	invoke_stdcall glCreateShader, %$ShaderType
	mov %$Shader, eax

	invoke_cdecl strlen, %$ShaderCode
	mov %$SourceLen, eax

	invoke_stdcall glShaderSource, %$Shader, 1, & %$ShaderCode, &%$SourceLen
	invoke_stdcall glCompileShader, %$Shader
	invoke_stdcall glGetShaderiv, %$Shader, GL_COMPILE_STATUS, &%$CompileStatus

	mov eax, %$CompileStatus
	test eax, eax
	jnz .success

	invoke_stdcall glGetShaderiv, %$Shader, GL_INFO_LOG_LENGTH, &%$InfoLogLen
	mov eax, %$InfoLogLen
	inc eax
	invoke_cdecl _calloc, eax, 1
	mov %$InfoLogBuf, eax

	invoke_stdcall glGetShaderInfoLog, %$Shader, %$InfoLogLen, 0, eax
	invoke_stdcall glDeleteShader, %$Shader
	mov eax, %$PPOutInfoLog
	mov edx, %$InfoLogBuf
	mov [eax], edx

.failexit:
	xor eax, eax
	jmp .end
.success:
	invoke_stdcall glAttachShader, %$Program, %$Shader
	invoke_stdcall glDeleteShader, %$Shader
	xor eax, eax
	inc eax

.end:
	FrameEnd
	ret

; GLuint ProgramCreate(char *VertexShader, char *GeometryShader, char *FragmentShader);
DefFunc _ProgramCreate
	FrameBegin
	NameParams %$VS, %$GS, %$FS
	invoke_cdecl _ProgramCreateEx, GL_VERTEX_SHADER, %$VS, GL_GEOMETRY_SHADER, %$GS, GL_FRAGMENT_SHADER, %$FS,0
	FrameEnd
	ret

; GLuint _ProgramCreateEx(int shader_type, const char *shader_source, ...);
DefFunc _ProgramCreateEx
	FrameBegin ebx, esi, edi
	NameParams %$Args
	DefVars %$InfoLog, %$InfoLogLen, %$LinkStatus, %$ShaderType, %$ShaderTypeStr

	xor eax, eax
	mov ecx, %$Frame_NumLocals
	lea edi, Variable(0)
	rep stosd

	invoke_stdcall glCreateProgram
	mov ebx, eax

	lea esi, %$Args
.next_shader:
	lodsd
	test eax, eax
	jz .proceed_link
	mov %$ShaderType, eax
	cmp eax, GL_VERTEX_SHADER
	jz .is_vs
	cmp eax, GL_GEOMETRY_SHADER
	jz .is_gs
	cmp eax, GL_FRAGMENT_SHADER
	jz .is_fs
	GetAbsAddr ecx, _ShaderCompileError
	debug_msg "%s: Unknown shader type %d", ecx, %$ShaderType
	jmp .bad_end
.is_vs:
	GetAbsAddr ecx, _STVertexShader
	jmp .load_shader
.is_gs:
	GetAbsAddr ecx, _STGeometryShader
	jmp .load_shader
.is_fs:
	GetAbsAddr ecx, _STFragmentShader
.load_shader:
	mov %$ShaderTypeStr, ecx
	lodsd
	test eax, eax
	jz .next_shader
	invoke_cdecl _ShaderCreate, ebx, %$ShaderType, eax, & %$InfoLog
	test eax, eax
	jnz .next_shader
	GetAbsAddr ecx, _ShaderCompileError
	debug_msg "%s: %s Shader: %s", ecx, %$ShaderTypeStr, %$InfoLog
	jmp .bad_end
.proceed_link:

	invoke_stdcall glLinkProgram, ebx
	invoke_stdcall glGetProgramiv, ebx, GL_LINK_STATUS, &%$LinkStatus
	mov eax, %$LinkStatus
	test eax, eax
	jnz .good_link

	invoke_stdcall glGetProgramiv, ebx, GL_INFO_LOG_LENGTH, &%$InfoLogLen
	mov eax, %$InfoLogLen
	inc eax
	invoke_cdecl _calloc, eax, 1
	mov %$InfoLog, eax

	invoke_stdcall glGetProgramInfoLog, ebx, %$InfoLogLen, &%$InfoLogLen, %$InfoLog

	GetAbsAddr ecx, _ShaderLinkageError
	debug_msg "%s: %s", ecx, %$InfoLog
	jmp .bad_end

.bad_end:
	invoke_cdecl _free, %$InfoLog
	invoke_stdcall glDeleteProgram, ebx
	xor ebx, ebx

.good_link:
	mov eax, ebx

.end:
	FrameEnd
	ret

; void SceneLoadShaderProgram(_out_ GLuint *program, _in_ char *VertexShaderAssetPath, _in_ char *GeometryShaderAssetPath, _in_ char *FragmentShaderAssetPath);
DefFunc _SceneLoadShaderProgram
	FrameBegin esi
	NameParams %$PProgramOut, %$VSPath, %$GSPath, %$FSPath
	DefVars %$VSString, %$GSString, %$FSString

	mov esi, %$PProgramOut
	invoke_cdecl _AssetsQuery, %$VSPath, 0
	mov %$VSString, eax
	invoke_cdecl _AssetsQuery, %$GSPath, 0
	mov %$GSString, eax
	invoke_cdecl _AssetsQuery, %$FSPath, 0
	mov %$FSString, eax

	invoke_cdecl _ProgramCreate, %$VSString, %$GSString, %$FSString
	mov [esi], eax

	FrameEnd
	ret
