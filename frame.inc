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

%macro FrameBegin 1-2+
	%assign Frame_NumVariables %1
	%assign Frame_NumLocals Frame_NumVariables
	%assign Frame_NumSavedRegs 0
	%ifdef Frame_UseEBP
		push ebp
		mov ebp, esp
	%endif
	%if %0 > 1
		%xdefine Frame_SavedRegs %2
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
%define AddrOfVariable(x) (esp + (x) * 4)
%define AddrOfCallParam(x) %error There are no addresses for call params
%define Param(x) [AddrOfParam(x)]
%define Variable(x) [AddrOfVariable(x)]
%define CallParam(x) [AddrOfCallParam(x)]

%define GetNumRooms(x, r) (((x) - 1) / (r) + 1)
%define RoundUp(x, r) (GetNumRooms(x, r) * (r))
%define SizedVar(x) GetNumRooms(x, 4)

%macro AssignVars 1-*
	%rep %0
		%define %1 Variable(%[CurVarIndex])
		%assign CurVarIndex CurVarIndex + 1
		%rotate 1
	%endrep
%endmacro

%macro AssignSizedVar 2
	%define %1%[_Addr] AddrOfVariable(%[CurVarIndex])
	%define %1 Variable(%[CurVarIndex])
	%assign CurVarIndex CurVarIndex + RoundUp(%2, 4)
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

%macro __ReplaceSubStr 4
	%strlen %%old_len %2
	%strlen %%orig_len %1
	%assign %%pos 1
	%assign %%found 0

	%rep %%orig_len - %%old_len + 1
		%substr %%part %1 %%pos, %%old_len
		%ifidn %%part, %2
			%assign %%found 1
			%exitrep
		%endif
		%assign %%pos %%pos + 1
	%endrep

	%if %%found
		%if %%pos > 1
			%substr %%before %1 1, %%pos - 1
		%else
			%define %%before ""
		%endif
		%substr after %1 %%pos + %%old_len, %%orig_len - (%%pos + %%old_len - 1)
		%strcat %4, %%before, %3, after
	%else
		%define %4 %1
	%endif
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

%define __NUM_REG_USED_FOR_PASS (\
	__EAX_USED_FOR_PASS + \
	__ECX_USED_FOR_PASS + \
	__EDX_USED_FOR_PASS)

%macro __IsRegUsedForPass 2
	%assign %1 \
		(%isidn(%2, eax) && __EAX_USED_FOR_PASS) || \
		(%isidn(%2, ecx) && __ECX_USED_FOR_PASS) || \
		(%isidn(%2, edx) && __EDX_USED_FOR_PASS)
%endmacro

%macro __IsPassRegAllUsed 1
	%assign %1 (\
		__EAX_USED_FOR_PASS && \
		__ECX_USED_FOR_PASS && \
		__EDX_USED_FOR_PASS)
%endmacro

%macro __IsRegAvoidForPass 2
	%assign %1 \
		(%isidn(%2, eax) && __EAX_AVOID_FOR_PASS) || \
		(%isidn(%2, ecx) && __ECX_AVOID_FOR_PASS) || \
		(%isidn(%2, edx) && __EDX_AVOID_FOR_PASS)
%endmacro

%macro __AddRegUsedForPass 1
	%ifidn %1, eax
		%define __EAX_USED_FOR_PASS 1
	%elifidn %1, ecx
		%define __ECX_USED_FOR_PASS 1
	%elifidn %1, edx
		%define __EDX_USED_FOR_PASS 1
	%endif
%endmacro

%macro __AddRegAvoidForPass 1
	%ifidn %1, eax
		%define __EAX_AVOID_FOR_PASS 1
	%elifidn %1, ecx
		%define __ECX_AVOID_FOR_PASS 1
	%elifidn %1, edx
		%define __EDX_AVOID_FOR_PASS 1
	%endif
%endmacro

%macro __ResetPassReg 0
	%undef __PassReg
	%define __EAX_USED_FOR_PASS 0
	%define __ECX_USED_FOR_PASS 0
	%define __EDX_USED_FOR_PASS 0
	%define __EAX_AVOID_FOR_PASS 0
	%define __ECX_AVOID_FOR_PASS 0
	%define __EDX_AVOID_FOR_PASS 0
	%undef __LastPassParam
	%define __PassReg
	%define __LastPassParam
	%assign __StdCallEspBias 0
	%assign __1_prep_cnt 0
	%assign __2_prep_cnt 0
	%assign __3_prep_cnt 0
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
	%if __1_prep_cnt > 0
		%assign __prep_index 0
		%rep __1_prep_cnt
			__1_prep%[__prep_index]
			%ifidn %substr(%str(__1_prep%[__prep_index]), 1, 4), 'push'
				%assign __StdCallEspBias __StdCallEspBias + 4
			%endif
			%undef __1_prep%[__prep_index]
			%assign __prep_index __prep_index + 1
		%endrep
	%endif
	%if __2_prep_cnt > 0
		%assign __prep_index 0
		%rep __2_prep_cnt
			__2_prep%[__prep_index]
			%ifidn %substr(%str(__2_prep%[__prep_index]), 1, 4), 'push'
				%assign __StdCallEspBias __StdCallEspBias + 4
			%endif
			%undef __2_prep%[__prep_index]
			%assign __prep_index __prep_index + 1
		%endrep
	%endif
	%if __3_prep_cnt > 0
		%assign __prep_index 0
		%rep __3_prep_cnt
			__3_prep%[__prep_index]
			%ifidn %substr(%str(__3_prep%[__prep_index]), 1, 4), 'push'
				%assign __StdCallEspBias __StdCallEspBias + 4
			%endif
			%undef __3_prep%[__prep_index]
			%assign __prep_index __prep_index + 1
		%endrep
	%endif
	%undef __1_load
	%undef __2_load
	%undef __3_load
	%assign __1_prep_cnt 0
	%assign __2_prep_cnt 0
	%assign __3_prep_cnt 0
	%define __EAX_USED_FOR_PASS 0
	%define __ECX_USED_FOR_PASS 0
	%define __EDX_USED_FOR_PASS 0
%endmacro

%macro __RotatePassReg 0
	%rep 4
		%undef __UseLastReg
		%ifidn __PassReg, eax
			%define __PassReg ecx
		%elifidn __PassReg, ecx
			%define __PassReg edx
		%else
			%define __PassReg eax
		%endif
		%undef __IsAvoid
		__IsRegAvoidForPass __IsAvoid, __PassReg
		%if __IsAvoid == 0
			__AddRegUsedForPass __PassReg
			%exitmacro
		%endif
	%endrep
	%error No registers available to store address reference parameters to pass
%endmacro

%macro __PassParam 3 ;The opcode to load, the operand, the actual param
	%rep 4
		%undef __UseLastReg
		%ifidn __LastPassParam, %3
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
			%if __NUM_REG_USED_FOR_PASS == 1
				%ifndef __UseLastReg
					%xdefine __1_load %1 __PassReg, %2
				%endif
				%xdefine __1_prep%[__1_prep_cnt] push __PassReg
				%assign __1_prep_cnt __1_prep_cnt + 1
			%elif __NUM_REG_USED_FOR_PASS == 2
				%ifndef __UseLastReg
					%xdefine __2_load %1 __PassReg, %2
				%endif
				%xdefine __2_prep%[__2_prep_cnt] push __PassReg
				%assign __2_prep_cnt __2_prep_cnt + 1
			%else
				%ifndef __UseLastReg
					%xdefine __3_load %1 __PassReg, %2
				%endif
				%xdefine __3_prep%[__3_prep_cnt] push __PassReg
				%assign __3_prep_cnt __3_prep_cnt + 1
			%endif
			%undef __ALL_USED
			__IsPassRegAllUsed __ALL_USED
			%if __ALL_USED != 0
				__FlushPassArgs
			%endif
			%exitmacro
		%endif
	%endrep
	%error No registers available to store address reference parameters to pass
%endmacro

%macro __PrepParam 2
	%define __Param %2
	%defstr __ParamStr __Param
	%strlen __ParamStrLen __ParamStr
	%assign __NumParamsPassed 1
	%undef __IsFloatF
	%undef __IsFloatD
	IsFloatF __IsFloatF, __Param
	IsFloatStr __IsFloatD, __ParamStr
	%if %substr(__ParamStr, 1, 1) == "&"
		%define __Param %tok(%substr(__ParamStr, 2))
		%define __ESP_PLACE_HOLDER__ (esP + __StdCallEspBias)
		__PassParam lea, __Param, %tok(__ParamStr)
		%undef __ESP_PLACE_HOLDER__
	%elif %substr(__ParamStr, 1, 3) == "xmm"
		%undef __XmmParamStr
		StripStringFromDot __XmmParamStr, __ParamStr
		%xdefine __XmmParam %tok(__XmmParamStr)
		%if %substr(__ParamStr, __ParamStrLen -1) == ".x"
			sub esP, 4
			%assign __StdCallEspBias __StdCallEspBias + 4
			movss [esP], __XmmParam
		%elif %substr(__ParamStr, __ParamStrLen -2) == ".xy"
			%assign __NumParamsPassed 2
			sub esP, 8
			%assign __StdCallEspBias __StdCallEspBias + 8
			movq [esP], __XmmParam
		%elif %substr(__ParamStr, __ParamStrLen -4) == ".xyzw"
			%assign __NumParamsPassed 4
			sub esP, 16
			%assign __StdCallEspBias __StdCallEspBias + 16
			movdqu [esP], __XmmParam
		%else
			%error Unknown param __ParamStr
		%endif
	%elif %substr(__ParamStr, 1, 3) == "qw "
		%define __Param %tok(%substr(__ParamStr, 4))
		%defstr __ParamStr __Param
		%strlen __ParamStrLen __ParamStr
		%assign __NumParamsPassed 2
		%if %substr(__ParamStr, 1, 1) == "["
			__FlushPassArgs
			%xdefine __InnerStr %substr(__ParamStr, 2, -2)
			%xdefine __Inner %tok(__InnerStr)
			%define __ESP_PLACE_HOLDER__ (esP + __StdCallEspBias)
			push [__Inner + 4]
			%undef __ESP_PLACE_HOLDER__
			%assign __StdCallEspBias __StdCallEspBias + 4
			%define __ESP_PLACE_HOLDER__ (esP + __StdCallEspBias)
			push [__Inner + 0]
			%undef __ESP_PLACE_HOLDER__
			%assign __StdCallEspBias __StdCallEspBias + 4
		%elif %substr(__ParamStr, 1, 2) == "&["
			%xdefine __InnerStr %substr(__ParamStr, 3, -2)
			%xdefine __Inner %tok(__InnerStr)
			__PassParam lea, [__Inner + 4], [__Inner + 4]
			__PassParam lea, [__Inner + 0], [__Inner + 0]
		%else
			__FlushPassArgs
			push (__Param) >> 32
			%assign __StdCallEspBias __StdCallEspBias + 4
			push (__Param) & 0xFFFFFFFF
			%assign __StdCallEspBias __StdCallEspBias + 4
		%endif
	%elif %substr(__ParamStr, 1, 4) == "f2d "
		%define __Param %tok(%substr(__ParamStr, 5))
		%defstr __ParamStr __Param
		%strlen __ParamStrLen __ParamStr
		%assign __NumParamsPassed 2
		%if %substr(__ParamStr, 1, 1) == "["
			%xdefine __InnerStr %substr(__ParamStr, 2, -2)
			%xdefine __Inner %tok(__InnerStr)
			sub esP, 8
			%assign __StdCallEspBias __StdCallEspBias + 8
			%define __ESP_PLACE_HOLDER__ (esP + __StdCallEspBias)
			fld dword [__Inner]
			%undef __ESP_PLACE_HOLDER__
			fstp qword [esP]
		%else
			%error `f2d` only supports convert float number from memory address.
		%endif
	%elif %substr(__ParamStr, 1, 4) == "f2i "
		%define __Param %tok(%substr(__ParamStr, 5))
		%defstr __ParamStr __Param
		%strlen __ParamStrLen __ParamStr
		%assign __NumParamsPassed 2
		%if %substr(__ParamStr, 1, 1) == "["
			%xdefine __InnerStr %substr(__ParamStr, 2, -2)
			%xdefine __Inner %tok(__InnerStr)
			sub esP, 4
			%assign __StdCallEspBias __StdCallEspBias + 8
			%define __ESP_PLACE_HOLDER__ (esP + __StdCallEspBias)
			fld dword [__Inner]
			%undef __ESP_PLACE_HOLDER__
			fistp dword [esP]
		%else
			%error `f2i` only supports convert float number from memory address.
		%endif
	%elif %substr(__ParamStr, 1, 4) == "i2f "
		%define __Param %tok(%substr(__ParamStr, 5))
		%defstr __ParamStr __Param
		%strlen __ParamStrLen __ParamStr
		%assign __NumParamsPassed 2
		%if %substr(__ParamStr, 1, 1) == "["
			%xdefine __InnerStr %substr(__ParamStr, 2, -2)
			%xdefine __Inner %tok(__InnerStr)
			sub esP, 4
			%assign __StdCallEspBias __StdCallEspBias + 8
			%define __ESP_PLACE_HOLDER__ (esP + __StdCallEspBias)
			fild dword [__Inner]
			%undef __ESP_PLACE_HOLDER__
			fstp dword [esP]
		%else
			%error `i2f` only supports convert float number from memory address.
		%endif
	%elifidn __ParamStr, 'st0'
		sub esP, 4
		%assign __StdCallEspBias __StdCallEspBias + 4
		fstp dword [esP]
	%elifidn __ParamStr, 'st0d'
		%assign __NumParamsPassed 2
		sub esP, 8
		%assign __StdCallEspBias __StdCallEspBias + 8
		fstp qword [esP]
	%elif __IsFloatF
		__FlushPassArgs
		push __?float32?__(%tok(%substr(__ParamStr, 1, -2)))
		%assign __StdCallEspBias __StdCallEspBias + 4
	%elif __IsFloatD
		__FlushPassArgs
		%assign __NumParamsPassed 2
		push (__?float64?__(__Param) >> 32)
		%assign __StdCallEspBias __StdCallEspBias + 4
		push (__?float64?__(__Param) & 0xFFFFFFFF)
		%assign __StdCallEspBias __StdCallEspBias + 4
	%else
		__FlushPassArgs
		%define __ESP_PLACE_HOLDER__ (esP + __StdCallEspBias)
		push __Param
		%undef __ESP_PLACE_HOLDER__
		%assign __StdCallEspBias __StdCallEspBias + 4
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
		%defstr %%Param %1
		__StrContains __pos_eax, %%Param, "eax"
		__StrContains __pos_ecx, %%Param, "ecx"
		__StrContains __pos_edx, %%Param, "edx"
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

%macro __PickOutRegToAvoidFromArgs 1-*
	%rep %0 - 1
		%rotate 1
		__PickOutRegToAvoid %1
	%endrep
%endmacro

%macro invoke_stdcall 1-*
	%if %0 == 1
		call %1
	%else
		%ifdef esP
			%undef esP
			%error Preserved keyword `esP` was defined to something.
		%endif
		%ifndef __NoResetPassReg
			__ResetPassReg
		%endif
		%undef __NoResetPassReg
		%define esp __ESP_PLACE_HOLDER__
		%rep %0 - 1
			%rotate 1
			__PickOutRegToAvoid %1
		%endrep
		%rotate 1
		%assign __ParamIndex 0
		%assign __NumParamsToCheck %0 - 1
		%rep %0 - 1
			%rotate -1
			__PrepParam __ParamIndex, %1
			%assign __NumParamsChecking 0
			%assign __EaxUsed 0
			%assign __EcxUsed 0
			%assign __EdxUsed 0
			%rep %0
				%if __NumParamsChecking < __NumParamsToCheck
					%undef __EAX_USED
					%undef __ECX_USED
					%undef __EDX_USED
					%defstr __ParamsToCheck %1
					__StrContains __EAX_USED, __ParamsToCheck, "eax"
					__StrContains __ECX_USED, __ParamsToCheck, "ecx"
					__StrContains __EDX_USED, __ParamsToCheck, "edx"
					%assign __EaxUsed  __EaxUsed | __EAX_USED
					%assign __EcxUsed  __EcxUsed | __ECX_USED
					%assign __EdxUsed  __EdxUsed | __EDX_USED
				%endif
				%assign __NumParamsChecking __NumParamsChecking + 1
				%rotate -1
			%endrep
			%assign __ParamIndex __ParamIndex + __NumParamsPassed
			%assign __NumParamsToCheck __NumParamsToCheck - 1
			%if __EaxUsed == 0
				%define __EAX_AVOID_FOR_PASS 0
			%endif
			%if __EcxUsed == 0
				%define __ECX_AVOID_FOR_PASS 0
			%endif
			%if __EdxUsed == 0
				%define __EDX_AVOID_FOR_PASS 0
			%endif
		%endrep
		%rotate -1
		__FlushPassArgs
		%define __ESP_PLACE_HOLDER__ (esP + __StdCallEspBias)
		call %1
		%undef __ESP_PLACE_HOLDER__
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

%macro invoke_cdecl 1-2+
	%assign __ParamIndex 0
	%if %0 == 1
		invoke_stdcall %1
	%else
		invoke_stdcall %1, %2
	%endif
	%if __ParamIndex == 1
		pop ecx
	%elif __ParamIndex != 0
		add esp, __ParamIndex * 4
	%endif
%endmacro

%macro invoke_dll_cdecl 1-2+
	%if %0 == 1
		invoke_cdecl [_addr_of_ %+ %1]
	%else
		invoke_cdecl [_addr_of_ %+ %1], %2
	%endif
%endmacro

%macro invoke_com 2-3+
	__ResetPassReg
	%define __NoResetPassReg
	__PickOutRegToAvoid %1
	__PickOutRegToAvoid %2
	%if %0 != 2
		__PickOutRegToAvoidFromArgs %3
	%endif
	__RotatePassReg
	mov __PassReg, %1
	mov __PassReg, [__PassReg]
	%if %0 == 2
		invoke_stdcall [__PassReg + %2], %1
	%else
		invoke_stdcall [__PassReg + %2], %1, %3
	%endif
%endmacro

struc IUnknown
	.QueryInterface resd 1
	.AddRef resd 1
	.Release resd 1
endstruc

%endif
