%ifndef _SHADER_INC_
%define _SHADER_INC_ 1

%include "gl33.inc"

; void SceneLoadShaderProgram(_out_ GLuint *program, int shader_type, const char *shader_source, ...);
extern _SceneLoadShaderProgram

; void SceneOnDisposeShaders();
extern _SceneOnDisposeShaders

%macro SceneLoadShaderProgram 2+
	invoke_cdecl _SceneLoadShaderProgram, %1, %2, 0
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
