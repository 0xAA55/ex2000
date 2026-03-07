; %define Frame_UseEBP

%macro FrameBegin 2
	%assign Frame_NumVariables %1
	%assign Frame_NumReservedParams %2
	%assign Frame_NumLocals Frame_NumVariables + Frame_NumReservedParams
	%ifdef Frame_UseEBP
		push ebp
		mov ebp, esp
	%endif
	%if Frame_NumLocals != 0
		sub esp, Frame_NumLocals * 4
	%endif
%endmacro

%macro FrameEnd 0
	%if Frame_NumLocals != 0
		add esp, Frame_NumLocals * 4
	%endif
	%ifdef Frame_UseEBP
		pop ebp
	%endif
%endmacro

%ifdef Frame_UseEBP
	%define Param(x) [ebp + (x + 2) * 4]
	%define Variable(x) [ebp - x * 4]
	%define CallParam(x) [ebp - (Frame_NumVariables + x) * 4]
%else
	%define Param(x) [esp + (Frame_NumLocals + x + 1) * 4]
	%define Variable(x) [esp + (Frame_NumReservedParams + x) * 4]
	%define CallParam(x) [esp + x * 4]
%endif

%macro LoadParam 2
	mov %1, Param(%2)
%endmacro

%macro StoreParam 2
	mov dword Param(%1), %2
%endmacro

%macro LoadVariable 2
	%if %2 < Frame_NumVariables
		mov %1, Variable(%2)
	%else
		%error Bad variable index
	%endif
%endmacro

%macro StoreVariable 2
	%if %1 < Frame_NumVariables
		mov dword Variable(%1), %2
	%else
		%error Bad variable index
	%endif
%endmacro

%macro PrepParam 2
	%if %1 < Frame_NumReservedParams
		mov dword CallParam(%1), %2
	%else
		%error Bad param index
	%endif
%endmacro
