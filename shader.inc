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
	invoke_cdecl _SceneLoadShaderProgram, %1, %%VSAssetsPath, %%GSAssetsPath, %%FSAssetsPath
%endmacro

%macro GetAttribLocation 2
	[segment .rdata]
	%%AttribName db %2, 0

	__SECT__
	invoke_dll_stdcall glGetAttribLocation, %1, %%AttribName
%endmacro

%macro GetUniformLocation 2
	[segment .rdata]
	%%UniformName db %2, 0

	__SECT__
	invoke_dll_stdcall glGetUniformLocation, %1, %%UniformName
%endmacro

%endif
