%ifndef _SHELLCODE_COMMON_INC_
%define _SHELLCODE_COMMON_INC_ 1

%define DefFuncTextSeg .code

%include "loaddll.inc"
%include "math.inc"

%define SHELLCODE 1

%macro GetAbsAddr 2-*
	call %%label
	%%label:
	pOp %1
	%if %0 == 2
		add %1, %2 - %%label
	%elif %0 == 4
		lea %2, [%1 + %4 - %%label]
		add %1, %3 - %%label
	%elif %0 == 6
		lea %2, [%1 + %5 - %%label]
		lea %3, [%1 + %6 - %%label]
		add %1, %4 - %%label
	%elif %0 == 8
		lea %2, [%1 + %6 - %%label]
		lea %3, [%1 + %7 - %%label]
		lea %4, [%1 + %8 - %%label]
		add %1, %5 - %%label
	%else
		%error Bad usage of `GetAbsAddr`
	%endif
%endmacro

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
