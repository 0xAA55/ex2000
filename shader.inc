%ifndef _SHADER_INC_
%define _SHADER_INC_ 1

%include "gl33.inc"
%include "strpool.inc"

; void SceneLoadShaderProgram(_out_ GLuint *program, _in_ char *VertexShaderAssetPath, _in_ char *GeometryShaderAssetPath, _in_ char *FragmentShaderAssetPath);
extern _SceneLoadShaderProgram

; void SceneLoadShaderProgramEx(_out_ GLuint *program, int shader_type, const char *shader_source, ...);
extern _SceneLoadShaderProgramEx

; void SceneOnDisposeShaders();
extern _SceneOnDisposeShaders

%macro SceneLoadShaderProgram 4
	DefStr %%VSAssetsPath, %2
	DefStr %%GSAssetsPath, %3
	DefStr %%FSAssetsPath, %4

	%ifndef SHELLCODE
		invoke_cdecl _SceneLoadShaderProgram, %1, %%VSAssetsPath, %%GSAssetsPath, %%FSAssetsPath
	%else
		GetAbsAddr eax, ecx, edx, %%VSAssetsPath, %%GSAssetsPath, %%FSAssetsPath
		invoke_cdecl _SceneLoadShaderProgram, %1, eax, ecx, edx
	%endif
%endmacro

%macro SceneLoadShaderProgramEx 2+
	invoke_cdecl _SceneLoadShaderProgramEx, %1, %2, 0
%endmacro

%macro GetAttribLocation 2
	DefStr %%AttribName, %2

	%ifndef SHELLCODE
		invoke_dll_stdcall glGetAttribLocation, %1, %%AttribName
	%else
		GetAbsAddr eax, %%AttribName
		invoke_stdcall glGetAttribLocation, %1, eax
	%endif
%endmacro

%macro GetUniformLocation 2
	DefStr %%UniformName, %2

	%ifndef SHELLCODE
		invoke_dll_stdcall glGetUniformLocation, %1, %%UniformName
	%else
		GetAbsAddr eax, %%UniformName
		invoke_stdcall glGetUniformLocation, %1, eax
	%endif
%endmacro

%macro GetFragDataLocation 2
	DefStr %%FragDataName, %2

	%ifndef SHELLCODE
		invoke_dll_stdcall glGetFragDataLocation, %1, %%FragDataName
	%else
		GetAbsAddr eax, %%FragDataName
		invoke_stdcall glGetFragDataLocation, %1, eax
	%endif
%endmacro

%endif
