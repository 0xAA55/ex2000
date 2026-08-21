%define DefFuncTextSeg .code

%include "common.inc"

%macro DefImp 1
	segment DefFuncTextSeg
	extern %1
	%1: db 0xE9, 0xE9, 0xE9, 0xE9, 0xE9
%endmacro

%macro DefExp 1
	segment DefFuncTextSeg
	extern %1
	dd %1 - 0x70001000
%endmacro

%include "shellcode.inc"

InstImpFull
InstExp

%unmacro DefImp 1
%unmacro DefExp 1

%macro DefImp 1
.%1 resb 5
%endmacro

%macro DefExp 1
.%1 resd 1
%endmacro

struc SCHead
.imports:
	InstImpFull

.exports:
	InstExp

.last_ptr:
	.size equ $ - SCHead
endstruc

DefFunc _ShellcodeInit
	FrameBegin
	invoke_cdecl _TlsInit
	invoke_cdecl _LfuInit
	invoke_cdecl _HRSleepInit
	FrameEnd
	ret

DefFunc _ShellcodeDeInit
	FrameBegin
	invoke_cdecl _HRSleepDeInit
	invoke_cdecl _TlsDeInit
	FrameEnd
	ret
