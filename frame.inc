; %define Frame_UseEBP

%macro FrameBegin 2
	%assign Frame_NumVariables %1
	%assign Frame_NumReservedParams %2
	%assign Frame_NumLocals Frame_NumVariables + Frame_NumReservedParams
	%assign ESP_BIAS 0
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
	%define CallParam(x) [ebp - (Frame_NumVariables + Frame_NumReservedParams - 1 - x) * 4]
%else
	%define Param(x) [esp + ESP_BIAS + (Frame_NumLocals + x + 1) * 4]
	%define Variable(x) [esp + ESP_BIAS + (Frame_NumReservedParams + x) * 4]
	%define CallParam(x) [esp + ESP_BIAS + x * 4]
%endif

%macro FramePush 1-*
	%rep %0
		push %1
		%assign ESP_BIAS ESP_BIAS + 4
		%rotate 1
	%endrep
%endmacro

%macro FramePop 1-*
	%rep %0
		%rotate -1
		pop %1
		%assign ESP_BIAS ESP_BIAS - 4
	%endrep
%endmacro

%macro FramePushA 0
	pushad
	%assign ESP_BIAS ESP_BIAS + 4 * 8
%endmacro

%macro FramePopA 0
	popad
	%assign ESP_BIAS ESP_BIAS - 4 * 8
%endmacro

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

%macro PrepStdCallParam 1-*
	%assign PrevBias ESP_BIAS
	%rep %0
		push %1
		%assign ESP_BIAS ESP_BIAS + 4
		%rotate 1
	%endrep
%endmacro

%macro AfterStdCall 0
	%assign ESP_BIAS PrevBias
%endmacro
