%ifndef _SHADER_INC_
%define _SHADER_INC_ 1

%include "loaddll.inc"


%ifndef SHADER_ASM
; GLuint ProgramCreate(char *VertexShader, char *GeometryShader, char *FragmentShader);
extern _ProgramCreate

%endif

%endif
