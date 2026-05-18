%ifndef _FRAME_INC_
%define _FRAME_INC_ 1

; %define Frame_UseEBP
; %define INVOKE_CHECK

%macro DefFunc 1
	%define CurFuncName %1
	extern %1
	%1:
%endmacro

%macro FrameBegin 2-3+
	%assign Frame_NumVariables %1
	%assign Frame_NumReservedParams %2
	%assign Frame_NumLocals Frame_NumVariables + Frame_NumReservedParams
	%assign Frame_NumSavedRegs 0
	%ifdef Frame_UseEBP
		push ebp
		mov ebp, esp
	%endif
	%if %0 > 2
		%define Frame_SavedRegs %3
		FrameSaveRegs Frame_SavedRegs
	%else
		%ifdef Frame_SavedRegs
			%undef Frame_SavedRegs
		%endif
	%endif
	%if Frame_NumLocals != 0
		sub esp, Frame_NumLocals * 4
	%endif
	%assign CurVarIndex 0
	%assign CurPrmIndex 0
%endmacro

%ifdef Frame_UseEBP
	%define AddrOfParam(x) (ebp + (x + 2) * 4)
%else
	%define AddrOfParam(x) (esp + (Frame_NumSavedRegs + Frame_NumLocals + (x) + 1) * 4)
%endif
%define AddrOfVariable(x) (esp + (Frame_NumReservedParams + (x)) * 4)
%define AddrOfCallParam(x) (esp + (x) * 4)
%define Param(x) [AddrOfParam(x)]
%define Variable(x) [AddrOfVariable(x)]
%define CallParam(x) [AddrOfCallParam(x)]

%macro AssignVars 1-*
	%rep %0
		%define %1 Variable(%[CurVarIndex])
		%assign CurVarIndex CurVarIndex + 1
		%rotate 1
	%endrep
%endmacro

%macro NameParams 1-*
	%rep %0
		%define %1 Param(%[CurPrmIndex])
		%assign CurPrmIndex CurPrmIndex + 1
		%rotate 1
	%endrep
%endmacro

%macro FrameEnd 0
	%if Frame_NumLocals != 0
		add esp, Frame_NumLocals * 4
	%endif
	%ifdef Frame_SavedRegs
		FrameStoreRegs Frame_SavedRegs
	%endif
	%ifdef Frame_UseEBP
		pop ebp
	%endif
%endmacro

%macro FrameSaveRegs 1-*
	%rep %0
		%if %substr(%str(%1), 1, 3) == "xmm"
			sub esp, 16
			movups [esp], %1
			%assign Frame_NumSavedRegs Frame_NumSavedRegs + 4
		%elif %substr(%str(%1), 1, 6) == "ss_xmm"
			sub esp, 4
			movups [esp], %tok(%substr(%str(%1), 4))
			%assign Frame_NumSavedRegs Frame_NumSavedRegs + 1
		%else
			push %1
			%assign Frame_NumSavedRegs Frame_NumSavedRegs + 1
		%endif
		%rotate 1
	%endrep
%endmacro

%macro FrameStoreRegs 1-*
	%rep %0
		%rotate -1
		%if %substr(%str(%1), 1, 3) == "xmm"
			movups %1, [esp]
			add esp, 16
			%assign Frame_NumSavedRegs Frame_NumSavedRegs - 4
		%elif %substr(%str(%1), 1, 6) == "ss_xmm"
			movss %tok(%substr(%str(%1), 4)), [esp]
			add esp, 4
			%assign Frame_NumSavedRegs Frame_NumSavedRegs - 1
		%else
			pop %1
			%assign Frame_NumSavedRegs Frame_NumSavedRegs - 1
		%endif
	%endrep
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
	%ifdef LastPassParam
		%undef LastPassParam
	%endif
	%defstr LastPassParam
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

%macro strcontains 3
	%push
	%strlen %$len_str %2
	%strlen %$len_sub %3
	%assign %$i 1
	%assign %$found 0
	%if %$len_str >= %$len_sub
		%rep %$len_str - %$len_sub + 1
			%substr %$part %2 %$i, %$len_sub
			%ifidn %$part, %3
				%assign %$found 1
				%exitrep
			%endif
			%assign %$i %$i + 1
		%endrep
	%endif
	%assign %1 %$found
	%pop
%endmacro

%macro PrepParam 2
	%if %1 >= Frame_NumReservedParams
		%error Bad param index %1
		%exitmacro
	%endif
	%if %substr(%str(%2), 1, 1) == "&"
		%ifnidn %str(%2), LastPassParam
			RotatePassReg
			lea PassReg, %tok(%substr(%str(%2), 2))
		%endif
		mov CallParam(%1), PassReg
	%elif %substr(%str(%2), 1, 1) == "["
		%ifnidn %str(%2), LastPassParam
			RotatePassReg
			mov PassReg, %2
		%endif
		mov CallParam(%1), PassReg
	%else
		mov dword CallParam(%1), %2
	%endif
	%defstr LastPassParam %2
%endmacro

%macro PrepStdCallParam 2
	%ifdef esP
		%error 'esP' had been defined to esP.
	%endif
	%define esp (esP + (%1) * 4)
	%if %substr(%str(%2), 1, 1) == "&"
		RotatePassReg
		lea PassReg, %tok(%substr(%str(%2), 2))
		push PassReg
	%else
		push %2
	%endif
	%undef esp
%endmacro

%macro invoke_stdcall 1-*
	%if %0 == 1
		call %1
	%else
		ResetPassReg
		%rep %0 - 1
			%rotate -1
			%if IsPassReg(%1)
				AddRegAvoidForPass %1
			%else
				%undef pos_eax
				%undef pos_ecx
				%undef pos_edx
				strcontains pos_eax, %str(%1), "eax"
				strcontains pos_ecx, %str(%1), "ecx"
				strcontains pos_edx, %str(%1), "edx"
				%if pos_eax > 0
					AddRegAvoidForPass eax
				%elif pos_ecx > 0
					AddRegAvoidForPass ecx
				%elif pos_edx > 0
					AddRegAvoidForPass edx
				%endif
			%endif
		%endrep
		%rotate -1
		%assign StdCallParamIndex 0
		%rep %0 - 1
			%rotate -1
			PrepStdCallParam StdCallParamIndex, %1
			%assign StdCallParamIndex StdCallParamIndex + 1
		%endrep
		%rotate -1
		call %1
	%endif
%endmacro

%macro invoke_dll_stdcall 1-*
	%if %0 == 1
		invoke_dll_func %1
	%else
		ResetPassReg
		%rep %0 - 1
			%rotate -1
			%if IsPassReg(%1)
				AddRegAvoidForPass %1
			%else
				%undef pos_eax
				%undef pos_ecx
				%undef pos_edx
				strcontains pos_eax, %str(%1), "eax"
				strcontains pos_ecx, %str(%1), "ecx"
				strcontains pos_edx, %str(%1), "edx"
				%if pos_eax > 0
					AddRegAvoidForPass eax
				%elif pos_ecx > 0
					AddRegAvoidForPass ecx
				%elif pos_edx > 0
					AddRegAvoidForPass edx
				%endif
			%endif
		%endrep
		%rotate -1
		%assign StdCallParamIndex 0
		%rep %0 - 1
			%rotate -1
			PrepStdCallParam StdCallParamIndex, %1
			%assign StdCallParamIndex StdCallParamIndex + 1
		%endrep
		%rotate -1
		invoke_dll_func %1
	%endif
%endmacro

%macro invoke_cdecl 1-*
	%if %0 == 1
		call %1
	%else
		ResetPassReg
		%rep %0 - 1
			%rotate 1
			%if IsPassReg(%1)
				AddRegAvoidForPass %1
			%else
				%undef pos_eax
				%undef pos_ecx
				%undef pos_edx
				strcontains pos_eax, %str(%1), "eax"
				strcontains pos_ecx, %str(%1), "ecx"
				strcontains pos_edx, %str(%1), "edx"
				%if pos_eax > 0
					AddRegAvoidForPass eax
				%elif pos_ecx > 0
					AddRegAvoidForPass ecx
				%elif pos_edx > 0
					AddRegAvoidForPass edx
				%endif
			%endif
		%endrep
		%rotate 1
		%assign CDeclParamIndex 0
		%rep %0 - 1
			%rotate 1
			PrepParam CDeclParamIndex, %1
			%assign CDeclParamIndex CDeclParamIndex + 1
		%endrep
		%rotate 1
		call %1
	%endif
%endmacro

%macro invoke_dll_cdecl 1-*
	%if %0 == 1
		invoke_dll_func %1
	%else
		ResetPassReg
		%rep %0 - 1
			%rotate 1
			%if IsPassReg(%1)
				AddRegAvoidForPass %1
			%else
				%undef pos_eax
				%undef pos_ecx
				%undef pos_edx
				strcontains pos_eax, %str(%1), "eax"
				strcontains pos_ecx, %str(%1), "ecx"
				strcontains pos_edx, %str(%1), "edx"
				%if pos_eax > 0
					AddRegAvoidForPass eax
				%elif pos_ecx > 0
					AddRegAvoidForPass ecx
				%elif pos_edx > 0
					AddRegAvoidForPass edx
				%endif
			%endif
		%endrep
		%rotate 1
		%assign CDeclParamIndex 0
		%rep %0 - 1
			%rotate 1
			PrepParam CDeclParamIndex, %1
			%assign CDeclParamIndex CDeclParamIndex + 1
		%endrep
		%rotate 1
		invoke_dll_func %1
	%endif
%endmacro

%endif
