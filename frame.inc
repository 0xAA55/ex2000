%ifndef _FRAME_INC_
%define _FRAME_INC_ 1

; %define Frame_UseEBP
; %define INVOKE_CHECK

%macro DefFunc 1
	%xdefine CurFuncName %1
	segment .text
	extern %1:
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
		%xdefine Frame_SavedRegs %3
		FrameSaveRegs Frame_SavedRegs
	%else
		%undef Frame_SavedRegs
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
		push %1
		%assign Frame_NumSavedRegs Frame_NumSavedRegs + 1
		%rotate 1
	%endrep
%endmacro

%macro FrameStoreRegs 1-*
	%rep %0
		%rotate -1
		pop %1
		%assign Frame_NumSavedRegs Frame_NumSavedRegs - 1
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

%macro __StrContains 3
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

%macro IsFloatStr 2
	%xdefine %%src %2
	%strlen %%len %%src
	%assign %%i 0
	%define %1 1
	%rep %%len
		%assign %%i %%i + 1
		%xdefine %%c %substr(%%src, %%i, 1)
		%if %isidn(%%c, '"') || %isidn(%%c, "'")
			%define %1 0
			%exitmacro
		%endif
		%xdefine %%t %tok(%%c)
		%if !%isnum(%%t)
			%ifidni %%c, 'e'
				%ifndef %%exp
					%define %%exp
				%else
					%define %1 0
					%exitmacro
				%endif
			%elifidn %%c, '.'
				%ifdef %%exp
					%define %1 0
				%elifndef %%dot
					%define %%dot
				%else
					%define %1 0
					%exitmacro
				%endif
			%else
				%define %1 0
				%exitmacro
			%endif
		%else
			%ifdef %%exp
				%define %%dgt_after_exp
			%endif
		%endif
	%endrep
	%ifndef %%dot
		%define %1 0
	%endif
	%if %isdef(%%exp) && %isndef(%%dgt_after_exp)
		%define %1 0
	%endif
%endmacro

%macro IsFloatF 2
	%defstr %%src %2
	%strlen %%len %%src
	%ifidni %substr(%%src, %%len), 'f'
		IsFloatStr %1, %substr(%%src, 1, -2)
	%else
		%define %1 0
	%endif
%endmacro

%macro StripStringFromDot 2
	%xdefine %%src %2
	%strlen %%len %%src
	%assign %%i 0
	%defstr %1
	%rep %%len
		%assign %%i %%i + 1
		%xdefine %%c %substr(%%src, %%i, 1)
		%ifidn %%c, '.'
			%exitrep
		%endif
		%strcat %1 %1, %%c
	%endrep
%endmacro

%define __IsPassReg(reg) (%isidn(reg, eax) || %isidn(reg, ecx) || %isidn(reg, edx))

%macro __IsRegUsedForPass 2
	__StrContains %1, __PassRegUsed, %str(%2)
%endmacro

%macro __IsPassRegAllUsed 1
	%undef __EAX_USED
	%undef __ECX_USED
	%undef __EDX_USED
	%undef __EAX_AVOID
	%undef __ECX_AVOID
	%undef __EDX_AVOID
	__StrContains __EAX_USED, __PassRegUsed, "eax"
	__StrContains __ECX_USED, __PassRegUsed, "ecx"
	__StrContains __EDX_USED, __PassRegUsed, "edx"
	__StrContains __EAX_AVOID, __PassRegAvoid, "eax"
	__StrContains __ECX_AVOID, __PassRegAvoid, "ecx"
	__StrContains __EDX_AVOID, __PassRegAvoid, "edx"
	%if	(__EAX_AVOID == 0 && __EAX_USED == 0) || \
		(__ECX_AVOID == 0 && __ECX_USED == 0) || \
		(__EDX_AVOID == 0 && __EDX_USED == 0)
		%define %1 0
	%else
		%define %1 1
	%endif
%endmacro

%macro __IsRegAvoidForPass 2
	__StrContains %1, __PassRegAvoid, %str(%2)
%endmacro

%macro __AddRegUsedForPass 1
	%undef __RegSearchPos
	__IsRegUsedForPass __RegSearchPos, %str(%1)
	%if __RegSearchPos == 0
		%strcat __PassRegUsed __PassRegUsed, %str(%1)
	%endif
%endmacro

%macro __AddRegAvoidForPass 1
	%undef __RegSearchPos
	__IsRegAvoidForPass __RegSearchPos, %str(%1)
	%if __RegSearchPos == 0
		%strcat __PassRegAvoid __PassRegAvoid, %str(%1)
	%endif
%endmacro

%macro __ResetPassReg 0
	%undef __PassReg
	%undef __PassRegUsed
	%undef __PassRegAvoid
	%undef __LastPassParam
	%define __PassReg
	%defstr __PassRegUsed
	%defstr __PassRegAvoid
	%define __LastPassParam
	%assign __StdCallEspBias 0
%endmacro

%macro __FlushPassArgs 0
	%ifdef __1_load
		__1_load
	%endif
	%ifdef __2_load
		__2_load
	%endif
	%ifdef __3_load
		__3_load
	%endif
	%ifdef __1_prep
		__1_prep
		%ifidn %substr(%str(__1_prep), 1, 4), 'push'
			%assign __StdCallEspBias (__StdCallEspBias + 4)
		%endif
	%endif
	%ifdef __2_prep
		__2_prep
		%ifidn %substr(%str(__2_prep), 1, 4), 'push'
			%assign __StdCallEspBias (__StdCallEspBias + 4)
		%endif
	%endif
	%ifdef __3_prep
		__3_prep
		%ifidn %substr(%str(__3_prep), 1, 4), 'push'
			%assign __StdCallEspBias (__StdCallEspBias + 4)
		%endif
	%endif
	%undef __1_load
	%undef __2_load
	%undef __3_load
	%undef __1_prep
	%undef __2_prep
	%undef __3_prep
%endmacro

%macro __RotatePassReg 4
	%rep 4
		%undef __UseLastReg
		%ifidn __LastPassParam, %4
			%define __UseLastReg 1
		%else
			%ifidn __PassReg, eax
				%define __PassReg ecx
			%elifidn __PassReg, ecx
				%define __PassReg edx
			%else
				%define __PassReg eax
			%endif
		%endif
		%undef __IsAvoid
		__IsRegAvoidForPass __IsAvoid, __PassReg
		%if __IsAvoid == 0
			__AddRegUsedForPass __PassReg
			%if %strlen(__PassRegUsed) <= 3
				%ifndef __UseLastReg
					%xdefine __1_load %1 __PassReg, %2
				%endif
				%ifidn %3, push
					%xdefine __1_prep push __PassReg
				%else
					%xdefine __1_prep mov %3, __PassReg
				%endif
			%elif %strlen(__PassRegUsed) <= 6
				%ifndef __UseLastReg
					%xdefine __2_load %1 __PassReg, %2
				%endif
				%ifidn %3, push
					%xdefine __2_prep push __PassReg
				%else
					%xdefine __2_prep mov %3, __PassReg
				%endif
			%else
				%ifndef __UseLastReg
					%xdefine __3_load %1 __PassReg, %2
				%endif
				%ifidn %3, push
					%xdefine __3_prep push __PassReg
				%else
					%xdefine __3_prep mov %3, __PassReg
				%endif
			%endif
			%undef __ALL_USED
			__IsPassRegAllUsed __ALL_USED
			%if __ALL_USED != 0
				__FlushPassArgs
				%defstr __PassRegUsed
			%endif
			%exitmacro
		%endif
	%endrep
	%error No registers available to store address reference parameters to pass
%endmacro

%macro __PrepParam 2
	%if %1 >= Frame_NumReservedParams
		%error Bad param index %1
		%exitmacro
	%endif
	%xdefine %%Param %2
	%defstr %%ParamStr %%Param
	%strlen %%ParamStrLen %%ParamStr
	%assign __NumParamsPassed 1
	%undef __IsFloatF
	%undef __IsFloatD
	IsFloatF __IsFloatF, %%Param
	IsFloatStr __IsFloatD, %%ParamStr
	%if %substr(%%ParamStr, 1, 1) == "&"
		%xdefine %%Param %tok(%substr(%%ParamStr, 2))
		__RotatePassReg lea, %%Param, CallParam(%1), %tok(%%ParamStr)
	%elif %substr(%%ParamStr, 1, 1) == "["
		__RotatePassReg mov, %%Param, CallParam(%1), %%Param
	%elif %substr(%%ParamStr, 1, 3) == "xmm"
		%undef __XmmParamStr
		StripStringFromDot __XmmParamStr, %%ParamStr
		%xdefine __XmmParam %tok(__XmmParamStr)
		%if %substr(%%ParamStr, %%ParamStrLen -1) == ".x"
			movss CallParam(%1), __XmmParam
		%elif %substr(%%ParamStr, %%ParamStrLen -2) == ".xy"
			%assign __NumParamsPassed 2
			movq CallParam(%1), __XmmParam
		%elif %substr(%%ParamStr, %%ParamStrLen -4) == ".xyzw"
			%assign __NumParamsPassed 4
			movdqu CallParam(%1), __XmmParam
		%else
			%error Unknown param %%ParamStr
		%endif
	%elif %substr(%%ParamStr, 1, 3) == "qw "
		%xdefine %%Param %tok(%substr(%%ParamStr, 4))
		%defstr %%ParamStr %%Param
		%strlen %%ParamStrLen %%ParamStr
		%assign __NumParamsPassed 2
		%if %substr(%%ParamStr, 1, 1) == "["
			%xdefine %%InnerStr %substr(%%ParamStr, 2, -2)
			%xdefine %%Inner %tok(%%InnerStr)
			__RotatePassReg mov, [%%Inner + 0], CallParam(%1 + 0), [%%Inner + 0]
			__RotatePassReg mov, [%%Inner + 4], CallParam(%1 + 1), [%%Inner + 4]
		%elif %substr(%%ParamStr, 1, 2) == "&["
			%xdefine %%InnerStr %substr(%%ParamStr, 3, -2)
			%xdefine %%Inner %tok(%%InnerStr)
			__RotatePassReg lea, [%%Inner + 0], CallParam(%1 + 0), [%%Inner + 0]
			__RotatePassReg lea, [%%Inner + 4], CallParam(%1 + 1), [%%Inner + 4]
		%else
			__RotatePassReg mov, (%%Param) & 0xFFFFFFFF, CallParam(%1 + 0), (%%Param) & 0xFFFFFFFF
			__RotatePassReg mov, (%%Param) >> 32, CallParam(%1 + 1), (%%Param) >> 32
		%endif
	%elif %substr(%%ParamStr, 1, 4) == "f2d "
		%xdefine %%Param %tok(%substr(%%ParamStr, 5))
		%defstr %%ParamStr %%Param
		%strlen %%ParamStrLen %%ParamStr
		%assign __NumParamsPassed 2
		%if %substr(%%ParamStr, 1, 1) == "["
			%xdefine %%InnerStr %substr(%%ParamStr, 2, -2)
			%xdefine %%Inner %tok(%%InnerStr)
			fld dword [%%Inner]
			fstp qword CallParam(%1)
		%else
			%error `f2d` only supports convert float number from memory address.
		%endif
	%elif __IsFloatF
		mov dword CallParam(%1), __?float32?__(%tok(%substr(%%ParamStr, 1, -2)))
	%elif __IsFloatD
		%assign __NumParamsPassed 2
		mov dword CallParam(%1 + 0), (__?float64?__(%%Param) & 0xFFFFFFFF)
		mov dword CallParam(%1 + 1), (__?float64?__(%%Param) >> 32)
	%else
		mov dword CallParam(%1), %%Param
	%endif
	%xdefine __LastPassParam %2
%endmacro

%macro __PrepStdCallParam 2
	%xdefine %%Param %2
	%defstr %%ParamStr %%Param
	%strlen %%ParamStrLen %%ParamStr
	%assign __NumParamsPassed 1
	%undef __IsFloatF
	%undef __IsFloatD
	IsFloatF __IsFloatF, %%Param
	IsFloatStr __IsFloatD, %%ParamStr
	%if %substr(%%ParamStr, 1, 1) == "&"
		%xdefine %%Param %tok(%substr(%%ParamStr, 2))
		__RotatePassReg lea, %%Param, push, %%%tok(%%ParamStr)
	%elif %substr(%%ParamStr, 1, 3) == "xmm"
		%undef __XmmParamStr
		StripStringFromDot __XmmParamStr, %%ParamStr
		%xdefine __XmmParam %tok(__XmmParamStr)
		%if %substr(%%ParamStr, %%ParamStrLen -1) == ".x"
			sub esp, 4
			movss [esp], __XmmParam
		%elif %substr(%%ParamStr, %%ParamStrLen -2) == ".xy"
			%assign __NumParamsPassed 2
			sub esp, 8
			movq [esp], __XmmParam
		%elif %substr(%%ParamStr, %%ParamStrLen -4) == ".xyzw"
			%assign __NumParamsPassed 4
			sub esp, 16
			movdqu [esp], __XmmParam
		%else
			%error Unknown param %%ParamStr
		%endif
	%elif %substr(%%ParamStr, 1, 3) == "qw "
		%xdefine %%Param %tok(%substr(%%ParamStr, 4))
		%defstr %%ParamStr %%Param
		%strlen %%ParamStrLen %%ParamStr
		%assign __NumParamsPassed 2
		%if %substr(%%ParamStr, 1, 1) == "["
			__FlushPassArgs
			%xdefine %%InnerStr %substr(%%ParamStr, 2, -2)
			%xdefine %%Inner %tok(%%InnerStr)
			push [%%Inner + 4]
			%assign __StdCallEspBias (__StdCallEspBias + 4)
			push [%%Inner + 0]
			%assign __StdCallEspBias (__StdCallEspBias + 4)
		%elif %substr(%%ParamStr, 1, 2) == "&["
			%xdefine %%InnerStr %substr(%%ParamStr, 3, -2)
			%xdefine %%Inner %tok(%%InnerStr)
			__RotatePassReg lea, [%%Inner + 4], push, [%%Inner + 4]
			__RotatePassReg lea, [%%Inner + 0], push, [%%Inner + 0]
		%else
			__FlushPassArgs
			push (%%Param) >> 32
			%assign __StdCallEspBias (__StdCallEspBias + 4)
			push (%%Param) & 0xFFFFFFFF
			%assign __StdCallEspBias (__StdCallEspBias + 4)
		%endif
	%elif %substr(%%ParamStr, 1, 4) == "f2d "
		%xdefine %%Param %tok(%substr(%%ParamStr, 5))
		%defstr %%ParamStr %%Param
		%strlen %%ParamStrLen %%ParamStr
		%assign __NumParamsPassed 2
		%if %substr(%%ParamStr, 1, 1) == "["
			%xdefine %%InnerStr %substr(%%ParamStr, 2, -2)
			%xdefine %%Inner %tok(%%InnerStr)
			sub esp, 8
			fld dword [%%Inner]
			fstp qword [esp]
		%else
			%error `f2d` only supports convert float number from memory address.
		%endif
	%elif __IsFloatF
		__FlushPassArgs
		push __?float32?__(%tok(%substr(%%ParamStr, 1, -2)))
		%assign __StdCallEspBias (__StdCallEspBias + 4)
	%elif __IsFloatD
		__FlushPassArgs
		%assign __NumParamsPassed 2
		push (__?float64?__(%%Param) >> 32)
		%assign __StdCallEspBias (__StdCallEspBias + 4)
		push (__?float64?__(%%Param) & 0xFFFFFFFF)
		%assign __StdCallEspBias (__StdCallEspBias + 4)
	%else
		__FlushPassArgs
		push %%Param
		%assign __StdCallEspBias (__StdCallEspBias + 4)
	%endif
	%xdefine __LastPassParam %2
%endmacro

%macro __PickOutRegToAvoid 1
	%if __IsPassReg(%1)
		__AddRegAvoidForPass %1
	%else
		%undef __pos_eax
		%undef __pos_ecx
		%undef __pos_edx
		__StrContains __pos_eax, %str(%1), "eax"
		__StrContains __pos_ecx, %str(%1), "ecx"
		__StrContains __pos_edx, %str(%1), "edx"
		%if __pos_eax > 0
			__AddRegAvoidForPass eax
		%endif
		%if __pos_ecx > 0
			__AddRegAvoidForPass ecx
		%endif
		%if __pos_edx > 0
			__AddRegAvoidForPass edx
		%endif
	%endif
%endmacro

%macro invoke_stdcall 1-*
	%if %0 == 1
		call %1
	%else
		%ifdef esP
			%undef esP
			%error Preserved keyword `esP` was defined to something.
		%endif
		__ResetPassReg
		%define esp (esP + __StdCallEspBias)
		%rep %0 - 1
			%rotate -1
			__PickOutRegToAvoid %1
		%endrep
		%rotate -1
		%assign __StdCallParamIndex 0
		%rep %0 - 1
			%rotate -1
			__PrepStdCallParam __StdCallParamIndex, %1
			%assign __StdCallParamIndex __StdCallParamIndex + __NumParamsPassed
		%endrep
		%rotate -1
		__FlushPassArgs
		call %1
		%undef esp
	%endif
%endmacro

%macro invoke_dll_stdcall 1-2+
	%if %0 == 1
		invoke_stdcall [_addr_of_ %+ %1]
	%else
		invoke_stdcall [_addr_of_ %+ %1], %2
	%endif
%endmacro

%macro invoke_cdecl 1-*
	%if %0 == 1
		call %1
	%else
		__ResetPassReg
		%rep %0 - 1
			%rotate 1
			__PickOutRegToAvoid %1
		%endrep
		%rotate 1
		%assign __CDeclParamIndex 0
		%rep %0 - 1
			%rotate 1
			%if !%isidn(%1, _)
				__PrepParam __CDeclParamIndex, %1
			%endif
			%assign __CDeclParamIndex __CDeclParamIndex + __NumParamsPassed
		%endrep
		%rotate 1
		__FlushPassArgs
		call %1
	%endif
%endmacro

%macro invoke_dll_cdecl 1-2+
	%if %0 == 1
		invoke_cdecl [_addr_of_ %+ %1]
	%else
		invoke_cdecl [_addr_of_ %+ %1], %2
	%endif
%endmacro

%endif
