%ifndef _SHELLCODE_COMMON_INC_
%define _SHELLCODE_COMMON_INC_ 1

%define DefFuncTextSeg .code

%include "loaddll.inc"
%include "math.inc"

%define SHELLCODE 1

%macro DefImp 1
extern %1
%endmacro

%macro DefExp 1
extern %1
%endmacro

%include "shellcode.inc"

InstImpFull
InstExp

%unmacro DefImp 1
%unmacro DefExp 1

%endif
