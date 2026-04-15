%define SHADER_ASM 1
%include "shader.inc"
%include "gl33.inc"

extern _calloc
extern _free

import_dll_func strlen

segment .text
; int ShaderCreate(int program, int shader_type, char *shader_code, char **pp_out_infolog)
DefFunc _ShaderCreate
	FrameBegin 5, 2
	AssignVars _Shader, _SourceLen, _CompileStatus, _InfoLogLen, _InfoLogBuf

	invoke_dll_stdcall glCreateShader, Param(1)
	mov _Shader, eax

	invoke_dll_cdecl strlen, Param(2)
	mov _SourceLen, eax

	invoke_dll_stdcall glShaderSource, _Shader, 1, &Param(2), &_SourceLen
	invoke_dll_stdcall glCompileShader, _Shader
	invoke_dll_stdcall glGetShaderiv, _Shader, GL_COMPILE_STATUS, &_CompileStatus

	mov eax, _CompileStatus
	test eax, eax
	jnz .success

	invoke_dll_stdcall glGetShaderiv, _Shader, GL_INFO_LOG_LENGTH, &_InfoLogLen
	mov eax, _InfoLogLen
	inc eax
	invoke_cdecl _calloc, eax, 1
	mov _InfoLogBuf, eax

	invoke_dll_stdcall glGetShaderInfoLog, _Shader, _InfoLogLen, 0, eax
	invoke_dll_stdcall glDeleteShader, _Shader
	mov eax, Param(3)
	mov edx, _InfoLogBuf
	mov [eax], edx

.failexit:
	xor eax, eax
	jmp .end
.success:
	invoke_dll_stdcall glAttachShader, Param(0), _Shader
	invoke_dll_stdcall glDeleteShader, _Shader
	xor eax, eax
	inc eax

.end:
	FrameEnd
	ret
	%undef _Shader
	%undef _SourceLen
	%undef _CompileStatus
	%undef _InfoLogLen
	%undef _InfoLogBuf

DefFunc _ProgramCreate
	FrameBegin 6, 4
	AssignVars _PRG, _InfoLog, _InfoLogLen, _LinkStatus, _ShaderType, _FormatBuffer

	mov eax, Param(0)
	or eax, Param(1)
	or eax, Param(2)
	jz .bad_param

	xor eax, eax
	mov _InfoLog, eax

	invoke_dll_stdcall glCreateProgram
	mov _PRG, eax

	mov eax, Param(0)
	test eax, eax
	jz .skip_vs

	mov dword _ShaderType, _ST_Vertex_Shader
	invoke_cdecl _ShaderCreate, _PRG, GL_VERTEX_SHADER, eax, &_InfoLog
	cmp eax, eax
	jz .bad_compile

.skip_vs:
	mov eax, Param(1)
	test eax, eax
	jz .skip_gs

	mov dword _ShaderType, _ST_Geometry_Shader
	invoke_cdecl _ShaderCreate, _PRG, GL_GEOMETRY_SHADER, eax, &_InfoLog
	cmp eax, eax
	jz .bad_compile

.skip_gs:
	mov eax, Param(2)
	test eax, eax
	jz .skip_fs

	mov dword _ShaderType, _ST_Fragment_Shader
	invoke_cdecl _ShaderCreate, _PRG, GL_FRAGMENT_SHADER, eax, &_InfoLog
	cmp eax, eax
	jz .bad_compile

.skip_fs:
	invoke_dll_stdcall glLinkProgram, _PRG
	invoke_dll_stdcall glGetProgramiv, _PRG, GL_LINK_STATUS, &_LinkStatus
	mov eax, _LinkStatus
	test eax, eax
	jz .bad_link

	mov eax, _PRG
	jmp .end

.bad_compile:
	debug_msg "Error occurs while compiling %s: %s", _ShaderType, _InfoLog
	invoke_cdecl _free, _InfoLog
	jmp .bad_end

.bad_link:
	invoke_dll_stdcall glGetProgramiv, _PRG, GL_INFO_LOG_LENGTH, &_InfoLogLen
	mov eax, _InfoLogLen
	inc eax
	invoke_cdecl _calloc, eax, 1
	mov _InfoLog, eax

	invoke_dll_stdcall glGetProgramInfoLog, _PRG, _InfoLogLen, &_InfoLogLen, _InfoLog

	debug_msg "Error occurs while linking the shader program: %s", _InfoLog
	invoke_cdecl _free, _InfoLog

.bad_end:
	invoke_dll_stdcall glDeleteProgram, _PRG
	xor eax, eax

.end:
	FrameEnd
	ret
.bad_param:
	int3
	%undef _PRG
	%undef _InfoLog
	%undef _InfoLogLen
	%undef _LinkStatus
	%undef _ShaderType
	%undef _FormatBuffer

segment .rdata
_ST_Vertex_Shader db "Vertex Shader", 0
_ST_Geometry_Shader db "Geometry Shader", 0
_ST_Fragment_Shader db "Fragment Shader", 0
