%ifndef _FRAME_INC_
%define _FRAME_INC_ 1

; %define Frame_UseEBP

%macro FrameBegin 2-3+
	%assign Frame_NumVariables %1
	%assign Frame_NumReservedParams %2
	%assign Frame_NumLocals Frame_NumVariables + Frame_NumReservedParams
	%assign ESP_BIAS 0
	%ifdef Frame_UseEBP
		push ebp
		mov ebp, esp
	%endif
	%if %0 > 2
		%define Frame_SavedRegs %3
		FramePush Frame_SavedRegs
	%else
		%ifdef Frame_SavedRegs
			%undef Frame_SavedRegs
		%endif
	%endif
	%if Frame_NumLocals != 0
		sub esp, Frame_NumLocals * 4
	%endif
%endmacro

%macro FrameEnd 0
	%if Frame_NumLocals != 0
		add esp, Frame_NumLocals * 4
	%endif
	%ifdef Frame_SavedRegs
		FramePop Frame_SavedRegs
	%endif
	%ifdef Frame_UseEBP
		pop ebp
	%endif
%endmacro

%ifdef Frame_UseEBP
	%define AddrOfParam(x) (ebp + (x + 2) * 4)
	%define AddrOfVariable(x) (ebp - (x) * 4)
	%define AddrOfCallParam(x) (esp + (x) * 4)
%else
	%define AddrOfParam(x) (esp + ESP_BIAS + (Frame_NumLocals + (x) + 1) * 4)
	%define AddrOfVariable(x) (esp + ESP_BIAS + (Frame_NumReservedParams + (x)) * 4)
	%define AddrOfCallParam(x) (esp + (x) * 4)
%endif
%define Param(x) [AddrOfParam(x)]
%define Variable(x) [AddrOfVariable(x)]
%define CallParam(x) [AddrOfCallParam(x)]

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

%macro StoreParamW 2
	mov word Param(%1), %2
%endmacro

%macro StoreParamB 2
	mov byte Param(%1), %2
%endmacro

%macro LoadVariable 2
	%if %2 < Frame_NumVariables
		mov %1, Variable(%2)
	%else
		%error Bad variable index %2
	%endif
%endmacro

%macro StoreVariable 2
	%if %1 < Frame_NumVariables
		mov dword Variable(%1), %2
	%else
		%error Bad variable index %1
	%endif
%endmacro

%macro StoreVariableW 2
	%if %1 < Frame_NumVariables
		mov word Variable(%1), %2
	%else
		%error Bad variable index %1
	%endif
%endmacro

%macro StoreVariableB 2
	%if %1 < Frame_NumVariables
		mov byte Variable(%1), %2
	%else
		%error Bad variable index %1
	%endif
%endmacro

%define IsPassReg(reg) (%isidn(reg, eax) || %isidn(reg, ecx) || %isidn(reg, edx))
%define IsRegUsedForPass(reg) (%substr(PassRegUsed, 1, 3) == %str(reg) || %substr(PassRegUsed, 4, 3) == %str(reg) || %substr(PassRegUsed, 7, 3) == %str(reg))
%define IsRegAvoidForPass(reg) (%substr(PassRegAvoid, 1, 3) == %str(reg) || %substr(PassRegAvoid, 4, 3) == %str(reg) || %substr(PassRegAvoid, 7, 3) == %str(reg))
%define IsNoRegAvailableForPass (IsRegAvoidForPass(eax) && IsRegAvoidForPass(ecx) && IsRegAvoidForPass(edx))

%macro AddRegUsedForPass 1
	%ifndef PassRegUsed
		%define PassRegUsed %str(%1)
	%elif (IsRegUsedForPass(eax) && %1 != eax) || (IsRegUsedForPass(ecx) && %1 != ecx) || (IsRegUsedForPass(edx) && %1 != edx)
		%define PassRegUsed %strcat(PassRegUsed, %str(%1))
	%endif
%endmacro

%macro AddRegAvoidForPass 1
	%ifndef PassRegAvoid
		%define PassRegAvoid %str(%1)
	%elif (IsRegAvoidForPass(eax) && %1 != eax) || (IsRegAvoidForPass(ecx) && %1 != ecx) || (IsRegAvoidForPass(edx) && %1 != edx)
		%define PassRegAvoid %strcat(PassRegAvoid, %str(%1))
	%endif
%endmacro

%macro RemoveRegAvoidForPass 1
	%ifdef PassRegAvoid
		%if %substr(PassRegAvoid, 1, 3) == %str(%1)
			%substr PassRegAvoid PassRegAvoid 4
		%elif %substr(PassRegAvoid, 4, 3) == %str(%1)
			%define PassRegAvoid %strcat(%substr(PassRegAvoid, 1, 3), %substr(PassRegAvoid, 7))
		%elif %substr(PassRegAvoid, 7, 3) == %str(%1)
			%substr PassRegAvoid PassRegAvoid 1, 6
		%endif
		%if %strlen(PassRegAvoid) == 0
			%undef PassRegAvoid
		%endif
	%endif
%endmacro

%macro ResetPassReg 0
	%ifdef PassReg
		%undef PassReg
	%endif
	%ifdef PassRegUsed
		%undef PassRegUsed
	%endif
	%ifdef PassRegAvoid
		%undef PassRegAvoid
	%endif
%endmacro

%macro RotatePassReg 0
	%if IsNoRegAvailableForPass
		%error No registers available to store address reference parameters to pass
	%endif
	%rep 4
		%ifndef PassReg
			%define PassReg eax
		%elif PassReg == eax
			%undef PassReg
			%define PassReg ecx
		%elif PassReg == ecx
			%undef PassReg
			%define PassReg edx
		%else
			%undef PassReg
			%define PassReg eax
		%endif
		%if !IsRegAvoidForPass(PassReg)
			AddRegUsedForPass PassReg
			%exitrep
		%endif
	%endrep
%endmacro

%macro PrepParam 2
	%if %1 < Frame_NumReservedParams
		%if %substr(%str(%2), 1, 1) == "["
			RotatePassReg
			mov PassReg, %2
			mov CallParam(%1), PassReg
		%else
			%if IsPassReg(%2)
				%if IsRegUsedForPass(%2)
					%error Register %2 was used for pass address reference parameters, here it was consumed by automatic allocating register.
				%else
					RemoveRegAvoidForPass %2
				%endif
			%endif
			mov dword CallParam(%1), %2
		%endif
	%else
		%error Bad param index %1
	%endif
%endmacro

%macro PrepStdCallParam 1-*
	%assign PrevBias ESP_BIAS
	%rep %0
		%rotate -1
		push %1
		%assign ESP_BIAS ESP_BIAS + 4
	%endrep
%endmacro

%macro AfterStdCall 0
	%assign ESP_BIAS PrevBias
%endmacro

%endif
