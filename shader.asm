%include "loaddll.inc"
%include "shader.inc"
%include "gl33.inc"
%include "assets.inc"

extern _calloc
extern _free

import_dll_func strlen

segment .rdata
extern _ShaderTypes
extern _ST_Vertex_Shader
extern _ST_Geometry_Shader
extern _ST_Fragment_Shader
extern _ST_Offsets

_ShaderTypes dd GL_VERTEX_SHADER, GL_GEOMETRY_SHADER, GL_FRAGMENT_SHADER
_ST_Vertex_Shader db "Vertex", 0
_ST_Geometry_Shader db "Geometry", 0
_ST_Fragment_Shader db "Fragment", 0
_ST_Offsets db 0, _ST_Geometry_Shader - _ST_Vertex_Shader, _ST_Fragment_Shader - _ST_Vertex_Shader

; int ShaderCreate(int program, int shader_type, char *shader_code, char **pp_out_infolog)
DefFunc _ShaderCreate
	FrameBegin
	NameParams %$Program, %$ShaderType, %$ShaderCode, %$PPOutInfoLog
	DefVars %$Shader, %$SourceLen, %$CompileStatus, %$InfoLogLen, %$InfoLogBuf

	invoke_dll_stdcall glCreateShader, %$ShaderType
	mov %$Shader, eax

	invoke_dll_cdecl strlen, %$ShaderCode
	mov %$SourceLen, eax

	invoke_dll_stdcall glShaderSource, %$Shader, 1, & %$ShaderCode, &%$SourceLen
	invoke_dll_stdcall glCompileShader, %$Shader
	invoke_dll_stdcall glGetShaderiv, %$Shader, GL_COMPILE_STATUS, &%$CompileStatus

	mov eax, %$CompileStatus
	test eax, eax
	jnz .success

	invoke_dll_stdcall glGetShaderiv, %$Shader, GL_INFO_LOG_LENGTH, &%$InfoLogLen
	mov eax, %$InfoLogLen
	inc eax
	invoke_cdecl _calloc, eax, 1
	mov %$InfoLogBuf, eax

	invoke_dll_stdcall glGetShaderInfoLog, %$Shader, %$InfoLogLen, 0, eax
	invoke_dll_stdcall glDeleteShader, %$Shader
	mov eax, %$PPOutInfoLog
	mov edx, %$InfoLogBuf
	mov [eax], edx

.failexit:
	xor eax, eax
	jmp .end
.success:
	invoke_dll_stdcall glAttachShader, %$Program, %$Shader
	invoke_dll_stdcall glDeleteShader, %$Shader
	xor eax, eax
	inc eax

.end:
	FrameEnd
	ret

; GLuint ProgramCreate(char *VertexShader, char *GeometryShader, char *FragmentShader);
DefFunc _ProgramCreate
	FrameBegin esi, edi
	NameParams %$VertexShader, %$GeometryShader, %$FragmentShader
	DefVars %$ECXHome, %$Program, %$InfoLog, %$InfoLogLen, %$LinkStatus, %$ShaderType, %$FormatBuffer

	mov eax, %$VertexShader
	or eax, %$GeometryShader
	or eax, %$FragmentShader
	jz .bad_param

	xor eax, eax
	mov %$InfoLog, eax
	mov edi, eax

	invoke_dll_stdcall glCreateProgram
	mov %$Program, eax

	mov ecx, 3
	mov esi, _ST_Offsets
	dec edi
.add_shaders:
	inc edi
	mov %$ECXHome, ecx

	xor eax, eax
	lodsb
	add eax, _ST_Vertex_Shader
	mov %$ShaderType, eax

	mov eax, Param(edi)
	test eax, eax
	jz .skip_shader

	invoke_cdecl _ShaderCreate, %$Program, [_ShaderTypes + edi * 4], eax, &%$InfoLog
	test eax, eax
	jnz .skip_shader
	debug_msg "Shader compilation error :%s Shader: %s", %$ShaderType, %$InfoLog
	jmp .bad_end
.skip_shader:
	mov ecx, %$ECXHome
	dec ecx
	jnz .add_shaders

	invoke_dll_stdcall glLinkProgram, %$Program
	invoke_dll_stdcall glGetProgramiv, %$Program, GL_LINK_STATUS, &%$LinkStatus
	mov eax, %$LinkStatus
	test eax, eax
	jnz .good_link

	invoke_dll_stdcall glGetProgramiv, %$Program, GL_INFO_LOG_LENGTH, &%$InfoLogLen
	mov eax, %$InfoLogLen
	inc eax
	invoke_cdecl _calloc, eax, 1
	mov %$InfoLog, eax

	invoke_dll_stdcall glGetProgramInfoLog, %$Program, %$InfoLogLen, &%$InfoLogLen, %$InfoLog

	debug_msg "Shader linkage error: %s", %$InfoLog
	jmp .bad_end

.good_link:
	mov eax, %$Program
	jmp .end

.bad_param:
	int3
	jmp .bad_param

.bad_end:
	invoke_cdecl _free, %$InfoLog
	invoke_dll_stdcall glDeleteProgram, %$Program
	xor eax, eax

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
