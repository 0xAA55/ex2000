%ifndef _SHADER_INC_
%define _SHADER_INC_ 1

%include "gl33.inc"

; GLuint ProgramCreate(char *VertexShader, char *GeometryShader, char *FragmentShader);
extern _ProgramCreate

; void SceneLoadShaderProgram(_out_ GLuint *program, _in_ char *VertexShaderAssetPath, _in_ char *GeometryShaderAssetPath, _in_ char *FragmentShaderAssetPath);
extern _SceneLoadShaderProgram

%macro SceneLoadShaderProgram 4
	[segment .rdata]
	%%VSAssetsPath db %2, 0
	%%GSAssetsPath db %3, 0
	%%FSAssetsPath db %4, 0

	__SECT__
	%ifndef SHELLCODE
		invoke_cdecl _SceneLoadShaderProgram, %1, %%VSAssetsPath, %%GSAssetsPath, %%FSAssetsPath
	%else
		GetAbsAddr eax, ecx, edx, %%VSAssetsPath, %%GSAssetsPath, %%FSAssetsPath
		invoke_cdecl _SceneLoadShaderProgram, %1, eax, ecx, edx
	%endif
%endmacro

%macro GetAttribLocation 2
	[segment .rdata]
	%%AttribName db %2, 0

	__SECT__
	%ifndef SHELLCODE
		invoke_dll_stdcall glGetAttribLocation, %1, %%AttribName
	%else
		GetAbsAddr eax, %%AttribName
		invoke_stdcall glGetAttribLocation, %1, eax
	%endif
%endmacro

%macro GetUniformLocation 2
	[segment .rdata]
	%%UniformName db %2, 0

	__SECT__
	%ifndef SHELLCODE
		invoke_dll_stdcall glGetUniformLocation, %1, %%UniformName
	%else
		GetAbsAddr eax, %%UniformName
		invoke_stdcall glGetUniformLocation, %1, eax
	%endif
%endmacro

%macro GetFragDataLocation 2
	[segment .rdata]
	%%FragDataName db %2, 0

	__SECT__
	%ifndef SHELLCODE
		invoke_dll_stdcall glGetFragDataLocation, %1, %%FragDataName
	%else
		GetAbsAddr eax, %%FragDataName
		invoke_stdcall glGetFragDataLocation, %1, eax
	%endif
%endmacro

%endif
