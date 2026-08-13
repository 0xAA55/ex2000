%ifndef _SHELLCODE_COMMON_INC_
%define _SHELLCODE_COMMON_INC_ 1

bits 32

%include "loaddll.inc"
%include "math.inc"

%define _MM_CMP_EQ_    0x00
%define _MM_CMP_LT_    0x01
%define _MM_CMP_LE_    0x02
%define _MM_CMP_UNORD_ 0x03
%define _MM_CMP_NEQ_   0x04
%define _MM_CMP_GE_    0x05
%define _MM_CMP_GT_    0x06
%define _MM_CMP_ORD_   0x07

%define _MM_SHUFFLE(fp3,fp2,fp1,fp0) (((fp3) << 6) | ((fp2) << 4) | ((fp1) << 2) | ((fp0)))

%define StackSegmentAttrib nobits
%define StackSegmentIsBss 1
[warning -pp-macro-redef-multi]
%unmacro extern 1-*
%macro extern 1-*
%endmacro
[warning +pp-macro-redef-multi]

%endif
