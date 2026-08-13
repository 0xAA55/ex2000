%ifndef _SHELLCODE_COMMON_INC_
%define _SHELLCODE_COMMON_INC_ 1

bits 32

%include "frame.inc"
%include "math.inc"

%define StackSegmentAttrib nobits
%define StackSegmentIsBss 1
[warning -pp-macro-redef-multi]
%unmacro extern 1-*
%macro extern 1-*
%endmacro
[warning +pp-macro-redef-multi]

%include "shellcode.inc"

%define DefImp extern
%define DefExp extern

InstImpFull
InstExp

%undef DefImp
%undef DefExp

%endif
