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

%macro SceneLoadShaderProgramEx 2-*
	%if (%0 & 1) == 0
		%error Usage: SceneLoadShaderProgramEx out_program, shader_type, shader_path, ...
		%exitmacro
	%endif
	Push 0
	%assign %%IsPath 1
	%assign %%Index 0
	%rep %0 - 1
		%rotate -1
		%if %%IsPath
			DefStr %%AssetPath%[%%Index], %1
			%ifndef SHELLCODE
				Push %%AssetPath%[%%Index]
			%else
				GetAbsAddr eax, %%AssetPath%[%%Index]
				Push eax
			%endif
			%assign %%IsPath 0
		%else
			Push %1
			%assign %%IsPath 1
		%endif
		%assign %%Index %%Index + 1
	%endrep
	%rotate -1
	Push %1
	call _SceneLoadShaderProgramEx
	add esp, (%0 + 1) * 4
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
