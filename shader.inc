%ifndef _SHADER_INC_
%define _SHADER_INC_ 1

%include "gl33.inc"

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
	%ifndef SHELLCODE
		invoke_dll_stdcall glGetAttribLocation, %1, str %2
	%else
		invoke_stdcall glGetAttribLocation, %1, str %2
	%endif
%endmacro

%macro GetUniformLocation 2
	%ifndef SHELLCODE
		invoke_dll_stdcall glGetUniformLocation, %1, str %2
	%else
		invoke_stdcall glGetUniformLocation, %1, str %2
	%endif
%endmacro

%macro GetFragDataLocation 2
	%ifndef SHELLCODE
		invoke_dll_stdcall glGetFragDataLocation, %1, str %2
	%else
		invoke_stdcall glGetFragDataLocation, %1, str %2
	%endif
%endmacro

%endif
