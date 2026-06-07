%ifndef _EXPRE_INC_
%define _EXPRE_INC_ 1

%define __IsNum(x) %eval(%strlen(x) == 1 && (x) >= '0' && (x) <= '9')
%define __IsOctal(x) %eval(%strlen(x) == 1 && (x) >= '0' && (x) <= '7')
%define __IsAlpha(x) %eval(%strlen(x) == 1 && (((x) >= 'a' && (x) <= 'z') || ((x) >= 'A' && (x) <= 'Z')))
%define __IsHex(x) %eval(__IsNum(x) || ((x) >= 'a' && (x) <= 'f') || ((x) >= 'A' && (x) <= 'F'))
%define __IsFirstIdent(x) %eval(__IsAlpha(x) || (x) == '_'  || (x) == '.' || (x) == '@' || (x) == '$' || (x) == '?' || (x) == '#' || (x) == ':' || (x) >= 0x80)
%define __IsIdent(x) %eval(__IsFirstIdent(x) || __IsNum(x))

; %define __DEBUG_EVALUATION

%define __IsPow2Number(x) (\
	(x) == 0x0000000000000001 || \
	(x) == 0x0000000000000002 || \
	(x) == 0x0000000000000004 || \
	(x) == 0x0000000000000008 || \
	(x) == 0x0000000000000010 || \
	(x) == 0x0000000000000020 || \
	(x) == 0x0000000000000040 || \
	(x) == 0x0000000000000080 || \
	(x) == 0x0000000000000100 || \
	(x) == 0x0000000000000200 || \
	(x) == 0x0000000000000400 || \
	(x) == 0x0000000000000800 || \
	(x) == 0x0000000000001000 || \
	(x) == 0x0000000000002000 || \
	(x) == 0x0000000000004000 || \
	(x) == 0x0000000000008000 || \
	(x) == 0x0000000000010000 || \
	(x) == 0x0000000000020000 || \
	(x) == 0x0000000000040000 || \
	(x) == 0x0000000000080000 || \
	(x) == 0x0000000000100000 || \
	(x) == 0x0000000000200000 || \
	(x) == 0x0000000000400000 || \
	(x) == 0x0000000000800000 || \
	(x) == 0x0000000001000000 || \
	(x) == 0x0000000002000000 || \
	(x) == 0x0000000004000000 || \
	(x) == 0x0000000008000000 || \
	(x) == 0x0000000010000000 || \
	(x) == 0x0000000020000000 || \
	(x) == 0x0000000040000000 || \
	(x) == 0x0000000080000000 || \
	(x) == 0x0000000100000000 || \
	(x) == 0x0000000200000000 || \
	(x) == 0x0000000400000000 || \
	(x) == 0x0000000800000000 || \
	(x) == 0x0000001000000000 || \
	(x) == 0x0000002000000000 || \
	(x) == 0x0000004000000000 || \
	(x) == 0x0000008000000000 || \
	(x) == 0x0000010000000000 || \
	(x) == 0x0000020000000000 || \
	(x) == 0x0000040000000000 || \
	(x) == 0x0000080000000000 || \
	(x) == 0x0000100000000000 || \
	(x) == 0x0000200000000000 || \
	(x) == 0x0000400000000000 || \
	(x) == 0x0000800000000000 || \
	(x) == 0x0001000000000000 || \
	(x) == 0x0002000000000000 || \
	(x) == 0x0004000000000000 || \
	(x) == 0x0008000000000000 || \
	(x) == 0x0010000000000000 || \
	(x) == 0x0020000000000000 || \
	(x) == 0x0040000000000000 || \
	(x) == 0x0080000000000000 || \
	(x) == 0x0100000000000000 || \
	(x) == 0x0200000000000000 || \
	(x) == 0x0400000000000000 || \
	(x) == 0x0800000000000000 || \
	(x) == 0x1000000000000000 || \
	(x) == 0x2000000000000000 || \
	(x) == 0x4000000000000000 || \
	(x) == 0x8000000000000000)

%macro __GetMaxBitsOfNumber 2 ;Result, Number
	%assign %%index 0
	%assign %1 0
	%rep 64
		%if (1 << %%index) & %2
			%assign %1 (%%index + 1)
		%endif
		%assign %%index %%index + 1
	%endrep
%endmacro

%macro __RemoveSpaces 2 ;Result, String
	%xdefine %%expre %2
	%strlen %%len %%expre
	%defstr %1
	%assign %%pos 0
	%rep %%len
		%assign %%pos %%pos + 1
		%define %%c %substr(%%expre, %%pos, 1)
		%if %%c != ' ' && %%c != `\t` && %%c != `\n`
			%strcat %1 %1, %%c
		%endif
	%endrep
%endmacro

%macro __ExtractIdent 4 ;String, ExtractedIdentString, AfterIdentString, IdentBaseIfIsConstantNumber
	__RemoveSpaces %%expre, %1
	%strlen %%len %%expre
	%assign %%base 0
	%define %%start1 %substr(%%expre, 1, 1)
	%define %%start2 %substr(%%expre, 1, 2)
	%define %%start3 %substr(%%expre, 1, 3)
	%if %%start1 == '['
		%assign %%pos 1
		%rep %%len
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if %%c == '['
				%error Nested memory access is not supported.
				%define __ConditionError
			%elif %%c == ']'
				%define %2 %substr(%%expre, 1, %%pos)
				%define %3 %substr(%%expre, %%pos + 1)
				%define %4 %%base
				%exitmacro
			%endif
		%endrep
		%error No matching ']'
		%define __ConditionError
	%elif %isidni(%substr(%%expre, 1, 6), 'dword[')
		%assign %%pos 6
		%rep %%len
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if %%c == '['
				%error Nested memory access is not supported.
				%define __ConditionError
			%elif %%c == ']'
				%define %2 %substr(%%expre, 1, %%pos)
				%define %3 %substr(%%expre, %%pos + 1)
				%define %4 %%base
				%exitmacro
			%endif
		%endrep
		%error No matching ']'
		%define __ConditionError
	%elif %isidni(%substr(%%expre, 1, 5), 'word[') || %isidni(%substr(%%expre, 1, 5), 'byte[')
		%assign %%pos 5
		%rep %%len
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if %%c == '['
				%error Nested memory access is not supported.
				%define __ConditionError
			%elif %%c == ']'
				%define %2 %substr(%%expre, 1, %%pos)
				%define %3 %substr(%%expre, %%pos + 1)
				%define %4 %%base
				%exitmacro
			%endif
		%endrep
		%error No matching ']'
		%define __ConditionError
	%elif %isidni(%%start2, '0x') || %isidni(%%start2, '0h')
		%assign %%base 16
		%assign %%pos 2
		%rep %%len
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if !__IsHex(%%c) && %%c != '_'
				%if __IsFirstIdent(%%c)
					%error Syntax error: %%expre
					%define __ConditionError
				%endif
				%define %2 %substr(%%expre, 1, %%pos - 1)
				%define %3 %substr(%%expre, %%pos)
				%define %4 %%base
				%exitmacro
			%endif
		%endrep
	%elif %isidni(%%start2, '0d')
		%assign %%base 10
		%assign %%pos 2
		%rep %%len
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if !__IsNum(%%c) && %%c != '_'
				%if __IsFirstIdent(%%c)
					%error Syntax error: %%expre
					%define __ConditionError
				%endif
				%define %2 %substr(%%expre, 1, %%pos - 1)
				%define %3 %substr(%%expre, %%pos)
				%define %4 %%base
				%exitmacro
			%endif
		%endrep
	%elif %isidni(%%start2, '0o') || %isidni(%%start2, '0q')
		%assign %%base 8
		%assign %%pos 2
		%rep %%len
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if !__IsOctal(%%c) && %%c != '_'
				%if __IsFirstIdent(%%c)
					%error Syntax error: %%expre
					%define __ConditionError
				%endif
				%define %2 %substr(%%expre, 1, %%pos - 1)
				%define %3 %substr(%%expre, %%pos)
				%define %4 %%base
				%exitmacro
			%endif
		%endrep
	%elif %isidni(%%start2, '0b') || %isidni(%%start2, '0y')
		%assign %%base 2
		%assign %%pos 2
		%rep %%len
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if %%c != '0' && %%c != '1' && %%c != '_'
				%if __IsFirstIdent(%%c)
					%error Syntax error: %%expre
					%define __ConditionError
				%endif
				%define %2 %substr(%%expre, 1, %%pos - 1)
				%define %3 %substr(%%expre, %%pos)
				%define %4 %%base
				%exitmacro
			%endif
		%endrep
	%elif __IsNum(%substr(%%expre, 1, 1))
		%assign %%pos 0
		%assign %%base 2
		%assign %%have_b 0
		%assign %%have_d 0
		%assign %%have_bin 0
		%assign %%have_oct 0
		%assign %%have_dec 0
		%assign %%have_hex 0
		%rep %%len + 1
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if %%c == '_' || %%c == '0' || %%c == '1'
			%elif __IsOctal(%%c) && %%base <= 8
				%assign %%base 8
			%elif __IsNum(%%c) && %%base <= 10
				%assign %%base 10
			%elif %%c == 'b' || %%c == 'B'
				%assign %%have_b %%have_b + 1
			%elif %%c == 'd' || %%c == 'D'
				%assign %%have_d %%have_d + 1
			%elif __IsHex(%%c) && %%base <= 16
				%assign %%base 16
			%elif %%c == 'y' || %%c == 'Y'
				%assign %%have_bin %%have_bin + 1
			%elif %%c == 'q' || %%c == 'Q' || %%c == 'o' || %%c == 'O'
				%assign %%have_oct %%have_oct + 1
			%elif %%c == 'h' || %%c == 'H'
				%assign %%have_hex %%have_hex + 1
			%else
				%if __IsFirstIdent(%%c)
					%error Syntax error: %%expre
					%define __ConditionError
				%endif
				%assign %%have_base_suffix %%have_bin + %%have_oct + %%have_dec + %%have_hex
				%assign %%have_bin %%have_bin + %%have_b
				%assign %%have_dec %%have_dec + %%have_d
				%if %%have_base_suffix > 1
					%error Syntax error: %%expre
					%define __ConditionError
				%elif %%have_hex == 1
					%assign %%base 16
				%elif %%have_hex > 1
					%error Syntax error: %%expre
					%define __ConditionError
				%elif (%%have_bin == 1 && %%base > 2) || %%have_bin > 1
					%error Syntax error: %%expre
					%define __ConditionError
				%elif %%have_oct == 1
					%if %%base > 8
						%error Syntax error: %%expre
						%define __ConditionError
					%endif
					%assign %%base 8
				%elif %%have_dec == 1 || (%%have_base_suffix == 0 && !%%have_b && !%%have_d)
					%if %%base > 10
						%error Syntax error: %%expre
						%define __ConditionError
					%endif
					%assign %%base 10
				%else
					%error Syntax error: %%expre
					%define __ConditionError
				%endif
				%define %2 %substr(%%expre, 1, %%pos - 1)
				%define %3 %substr(%%expre, %%pos)
				%define %4 %%base
				%exitmacro
			%endif
		%endrep
	%elif __IsFirstIdent(%substr(%%expre, 1, 1))
		%assign %%pos 0
		%rep %%len + 1
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if !__IsIdent(%%c)
				%define %2 %substr(%%expre, 1, %%pos - 1)
				%define %3 %substr(%%expre, %%pos)
				%define %4 %%base
				%exitmacro
			%endif
		%endrep
	%elif %%start2 == '<<' || %%start2 == '>>' || %%start2 == '<=' || %%start2 == '>=' || %%start2 == '&&' || %%start2 == '||' || %%start2 == '==' || %%start2 == '!='
		%define %2 %%start2
		%define %3 %substr(%%expre, 3)
		%define %4 -1
	%elif %%start1 == '+' || %%start1 == '-' || %%start1 == '*' || %%start1 == '/' || %%start1 == '&' || %%start1 == '|' || %%start1 == '~' || %%start1 == '!' || %%start1 == '<' || %%start1 == '>' || %%start1 == '='
		%define %2 %%start1
		%define %3 %substr(%%expre, 2)
		%define %4 -1
	%else
		%error Syntax error: %%expre
		%define __ConditionError
	%endif
%endmacro

%macro __IsIdentOperable 2 ;Result, String
	%define %%expre %2
	%strlen %%len %%expre
	%substr %%last %%expre %%len,1
	%define %1 0
	%if %isidni(%%expre, 'eax') || %isidni(%%expre, 'ecx') || %isidni(%%expre, 'edx') || %isidni(%%expre, 'ebx') || \
		  %isidni(%%expre, 'esp') || %isidni(%%expre, 'ebp') || %isidni(%%expre, 'esi') || %isidni(%%expre, 'edi')
		%define %1 32
	%elif %isidni(%%expre, 'ax') || %isidni(%%expre, 'cx') || %isidni(%%expre, 'dx') || %isidni(%%expre, 'bx') || \
		  %isidni(%%expre, 'sp') || %isidni(%%expre, 'bp') || %isidni(%%expre, 'si') || %isidni(%%expre, 'di')
		%define %1 16
	%elif %isidni(%%expre, 'al') || %isidni(%%expre, 'ah') || %isidni(%%expre, 'cl') || %isidni(%%expre, 'ch') || \
		  %isidni(%%expre, 'dl') || %isidni(%%expre, 'dh') || %isidni(%%expre, 'bl') || %isidni(%%expre, 'bh')
		%define %1 8
	%elif %%last == ']'
		%if %substr(%%expre, 1, 1) == '['
			%define %1 1
		%elif %isidni(%substr(%%expre, 1, 5), 'byte[')
			%define %1 8
		%elif %isidni(%substr(%%expre, 1, 5), 'word[')
			%define %1 16
		%elif %isidni(%substr(%%expre, 1, 6), 'dword[')
			%define %1 32
		%endif
	%endif
%endmacro

%macro __EvalCheckResult 1
	%ifidn %1, '#ERROR#'
		%error Unevaluable expression occurs near __EvalExtractedIdent
		%define __ConditionError
	%endif
%endmacro

%macro __EvaluateSimple 1
	__RemoveSpaces %%expre, %str(%1)
	%define %%changed_to '#ERROR#'
	%rep 10000 ;Process unary ~ !
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos %%len + 1
		%rep %%len
			%assign %%pos %%pos - 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if %%c == '~' || %%c == '!'
				%undef __EvalExtractedIdent
				%undef __EvalAfterIdent
				%undef __EvalIdentBase
				__ExtractIdent %substr(%%expre, %%pos + 1), __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
				%if __EvalIdentBase > 0
					%assign %%found 1
					%defstr %%changed_to %eval(%tok(%%c)%tok(__EvalExtractedIdent))
				%else
					%undef __IsIdentOperableResult
					__IsIdentOperable __IsIdentOperableResult, __EvalExtractedIdent
					%if __IsIdentOperableResult
						%assign %%found 1
						%if %%c == '~'
							not %tok(__EvalExtractedIdent)
						%elif %%c == '!'
							test %tok(__EvalExtractedIdent), -1
							jz %%z
							mov %tok(__EvalExtractedIdent), 0
							jmp %%nz
						%%z:
							inc %tok(__EvalExtractedIdent)
						%%nz:
						%else
							%error Unknown operator %%c
							%define __ConditionError
						%endif
						%xdefine %%changed_to __EvalExtractedIdent
					%elif __EvalExtractedIdent == '='
						%xdefine %%changed_to '!='
					%else
						%error __EvalExtractedIdent is not operable
						%define __ConditionError
					%endif
				%endif
				__EvalCheckResult %%changed_to
				%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
				%strcat %%expre %%expre, %%changed_to
				%strcat %%expre %%expre, __EvalAfterIdent
				%define %%changed_to '#ERROR#'
				%exitrep
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary * / %
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 1)
				%if %%o == '*' || %%o == '/' || %%o == '%'
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 2), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
						%if __EvalExtractedIdent2 == '+' || __EvalExtractedIdent2 == '-'
							%assign %%found 1
							%xdefine __NextOpr %substr(__EvalExtractedIdent2, 1, 1)
							%xdefine __EvalExtractedIdent2 %substr(__EvalExtractedIdent2, 2)
							%if __NextOpr == '+'
								%xdefine %%changed_to %strcat(__EvalExtractedIdent, %%o)
							%else
								%xdefine %%changed_to %strcat('-', %strcat(__EvalExtractedIdent, %%o))
							%endif
						%else
							%error Syntax error: %%expre
							%define __ConditionError
						%endif
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%if %%o == '*'
							%undef __IsIdentOperableResult1
							%undef __IsIdentOperableResult2
							__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
							__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
							%if %isidni(__EvalExtractedIdent, 'eax') || %isidni(__EvalExtractedIdent2, 'eax')
								%assign %%found 1
								%if %isidni(__EvalExtractedIdent, 'eax')
									%xdefine __RightIdent __EvalExtractedIdent2
									%xdefine __RightBase __EvalIdentBase2
									%xdefine __RightOperable __IsIdentOperableResult2
								%else
									%xdefine __RightIdent __EvalExtractedIdent
									%xdefine __RightBase __EvalIdentBase
									%xdefine __RightOperable __IsIdentOperableResult1
								%endif
								%if __RightBase > 0
									%if __IsPow2Number(%tok(__RightIdent))
										%undef __BitsOfNumber
										__GetMaxBitsOfNumber __BitsOfNumber, %tok(__RightIdent)
										shl eax, %eval(__BitsOfNumber - 1)
									%else
										[segment .rdata]
										%%const32 dd %tok(__RightIdent)
										__SECT__
										mul dword[%%const32]
									%endif
								%elif __RightOperable == 32
									mul %tok(__RightIdent)
								%elif __RightOperable == 1
									mul dword %tok(__RightIdent)
								%else
									%error eax can only multiply to 32-bit data
									%define __ConditionError
								%endif
								%define %%changed_to 'eax'
							%elif %isidni(__EvalExtractedIdent, 'ax') || %isidni(__EvalExtractedIdent2, 'ax')
								%assign %%found 1
								%if %isidni(__EvalExtractedIdent, 'ax')
									%xdefine __RightIdent __EvalExtractedIdent2
									%xdefine __RightBase __EvalIdentBase2
									%xdefine __RightOperable __IsIdentOperableResult2
								%else
									%xdefine __RightIdent __EvalExtractedIdent
									%xdefine __RightBase __EvalIdentBase
									%xdefine __RightOperable __IsIdentOperableResult1
								%endif
								%if __RightBase > 0
									%if __IsPow2Number(%tok(__RightIdent))
										%undef __BitsOfNumber
										__GetMaxBitsOfNumber __BitsOfNumber, %tok(__RightIdent)
										shl ax, %eval(__BitsOfNumber - 1)
									%else
										[segment .rdata]
										%%const16 dw %tok(__RightIdent)
										__SECT__
										mul word[%%const16]
									%endif
								%elif __RightOperable == 16
									mul %tok(__RightIdent)
								%elif __RightOperable == 1
									mul word %tok(__RightIdent)
								%else
									%error ax can only multiply to 16-bit data
									%define __ConditionError
								%endif
								%define %%changed_to 'ax'
							%elif %isidni(__EvalExtractedIdent, 'al') || %isidni(__EvalExtractedIdent2, 'al')
								%assign %%found 1
								%if %isidni(__EvalExtractedIdent, 'al')
									%xdefine __RightIdent __EvalExtractedIdent2
									%xdefine __RightBase __EvalIdentBase2
									%xdefine __RightOperable __IsIdentOperableResult2
								%else
									%xdefine __RightIdent __EvalExtractedIdent
									%xdefine __RightBase __EvalIdentBase
									%xdefine __RightOperable __IsIdentOperableResult1
								%endif
								%if __RightBase > 0
									%if __IsPow2Number(%tok(__RightIdent))
										%undef __BitsOfNumber
										__GetMaxBitsOfNumber __BitsOfNumber, %tok(__RightIdent)
										mov ah, 0
										shl ax, %eval(__BitsOfNumber - 1)
									%else
										[segment .rdata]
										%%const8 db %tok(__RightIdent)
										__SECT__
										mul byte[%%const8]
									%endif
								%elif __RightOperable == 8
									mul %tok(__RightIdent)
								%elif __RightOperable == 1
									mul byte %tok(__RightIdent)
								%else
									%error al can only multiply to 8-bit data
									%define __ConditionError
								%endif
								%define %%changed_to 'ax'
							%elif __EvalIdentBase2 > 0 && __IsPow2Number(%tok(__EvalExtractedIdent2))
								%assign %%found 1
								%undef __BitsOfNumber
								__GetMaxBitsOfNumber __BitsOfNumber, %tok(__RightIdent)
								shl %tok(__EvalExtractedIdent), %eval(__BitsOfNumber - 1)
								%define %%changed_to __EvalExtractedIdent
							%else
								%error Cannot perform multiply without 'eax' or 'ax' or 'al'
								%define __ConditionError
							%endif
						%elif %%o == '/' || %%o == '%'
							%undef __IsIdentOperableResult1
							%undef __IsIdentOperableResult2
							__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
							__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
							%xdefine __RightIdent __EvalExtractedIdent2
							%xdefine __RightBase __EvalIdentBase2
							%xdefine __RightOperable __IsIdentOperableResult2
							%if %isidni(__EvalExtractedIdent, 'eax')
								%assign %%found 1
								%if __RightBase > 0
									%if __IsPow2Number(%tok(__RightIdent))
										%undef __BitsOfNumber
										__GetMaxBitsOfNumber __BitsOfNumber, %tok(__RightIdent)
										%if %%o == '/'
											shr eax, %eval(__BitsOfNumber - 1)
										%else
											and eax, %eval((1 << (__BitsOfNumber - 1)) - 1)
										%endif
									%else
										[segment .rdata]
										%%const32 dd %tok(__RightIdent)
										__SECT__
										xor edx, edx
										div dword[%%const32]
									%endif
								%elif __RightOperable == 32
									xor edx, edx
									div %tok(__RightIdent)
								%elif __RightOperable == 1
									xor edx, edx
									div dword %tok(__RightIdent)
								%elif __RightOperable != 0
									%error Cannot divide by a __RightOperable bit integer
									%define __ConditionError
								%else
									%error Cannot divide by __RightIdent
									%define __ConditionError
								%endif
								%if __RightBase > 0
									%define %%changed_to 'eax'
								%else
									%if %%o == '/'
										%define %%changed_to 'eax'
									%else
										%define %%changed_to 'edx'
									%endif
								%endif
							%elif %isidni(__EvalExtractedIdent, 'ax')
								%assign %%found 1
								%if __RightBase > 0
									%if __IsPow2Number(%tok(__RightIdent))
										%undef __BitsOfNumber
										__GetMaxBitsOfNumber __BitsOfNumber, %tok(__RightIdent)
										%if %%o == '/'
											shr ax, %eval(__BitsOfNumber - 1)
										%else
											and ax, %eval((1 << (__BitsOfNumber - 1)) - 1)
										%endif
									%else
										[segment .rdata]
										%%const16 dw %tok(__RightIdent)
										__SECT__
										xor dx, dx
										div word[%%const16]
									%endif
									%assign %%divbits 16
								%elif __RightOperable == 16
									xor dx, dx
									div %tok(__RightIdent)
									%assign %%divbits 16
								%elif __RightOperable == 8
									div %tok(__RightIdent)
									%assign %%divbits 8
								%elif __RightOperable == 1
									%assign %%divbits 16
									div word %tok(__RightIdent)
								%elif __RightOperable != 0
									%error Cannot divide by a __RightOperable bit integer
									%define __ConditionError
								%else
									%error Cannot divide by __RightIdent
									%define __ConditionError
								%endif
								%if __RightBase > 0
									%define %%changed_to 'ax'
								%elif %%o == '/'
									%if %%divbits == 16
										%define %%changed_to 'ax'
									%else
										%define %%changed_to 'al'
									%endif
								%else
									%if %%divbits == 16
										%define %%changed_to 'dx'
									%else
										%define %%changed_to 'ah'
									%endif
								%endif
							%elif __EvalIdentBase2 > 0 && __IsPow2Number(%tok(__EvalExtractedIdent2))
								%assign %%found 1
								%undef __BitsOfNumber
								__GetMaxBitsOfNumber __BitsOfNumber, %tok(__RightIdent)
								%if %%o == '/'
									shr %tok(__EvalExtractedIdent), %eval(__BitsOfNumber - 1)
								%else
									and %tok(__EvalExtractedIdent), %eval((1 << (__BitsOfNumber - 1)) - 1)
								%endif
								%define %%changed_to __EvalExtractedIdent
							%else
								%error Can only perform divide from 'eax' or 'ax' or 'al'
								%define __ConditionError
							%endif
						%else
							%error Unknown operator %%o
							%define __ConditionError
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process unary + -
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 2)
			%assign %%found 1
			%if %%c == '++' || %%c == '--'
				%xdefine %%expre %strcat(%strcat(%substr(%%expre, 1, %%pos - 1), '+', %substr(%%expre, %%pos + 2)))
				%exitrep
			%elif %%c == '+-' || %%c == '-+'
				%xdefine %%expre %strcat(%strcat(%substr(%%expre, 1, %%pos - 1), '-', %substr(%%expre, %%pos + 2)))
				%exitrep
			%else
				%assign %%found 0
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary + -
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%if %substr(%%expre, 1, 1) == '-'
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent %substr(%%expre, 2), __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%undef __IsIdentOperableResult
			__IsIdentOperable __IsIdentOperableResult, __EvalExtractedIdent
			%if __IsIdentOperableResult
				%assign %%found 1
				neg %tok(__EvalExtractedIdent)
				%xdefine %%expre %substr(%%expre, 2)
			%endif
		%endif
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 1)
				%if %%o == '+' || %%o == '-'
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 2), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
						%error Syntax error: %%expre
						%define __ConditionError
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%undef __IsIdentOperableResult1
						%undef __IsIdentOperableResult2
						__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
						__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
						%if __IsIdentOperableResult1
							%assign %%found 1
							%if __EvalExtractedIdent2 != '0'
								%if %%o == '-'
									sub %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
								%else
									add %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
								%endif
							%endif
							%xdefine %%changed_to __EvalExtractedIdent
						%elif __IsIdentOperableResult2
							%assign %%found 1
							%if %%o == '-'
								neg %tok(__EvalExtractedIdent2)
							%endif
							%if __EvalExtractedIdent != '0'
								add %tok(__EvalExtractedIdent2), %tok(__EvalExtractedIdent)
							%endif
							%xdefine %%changed_to __EvalExtractedIdent2
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary << >>
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 2)
				%if %%o == '<<' || %%o == '>>'
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 3), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
						%error Syntax error: %%expre
						%define __ConditionError
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%undef __IsIdentOperableResult1
						%undef __IsIdentOperableResult2
						__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
						__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
						%if __IsIdentOperableResult1
							%if __EvalExtractedIdent != '0'
								%assign %%found 1
								%if %%o == '<<'
									shl %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
								%else
									shr %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
								%endif
							%endif
							%xdefine %%changed_to __EvalExtractedIdent
						%else
							%error __EvalExtractedIdent is not operable, cannot perform %%o on it
							%define __ConditionError
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary < > <= >=
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 2)
				%if %%o == '<=' || %%o == '>='
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 3), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
						%error Syntax error: %%expre
						%define __ConditionError
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%undef __IsIdentOperableResult1
						%undef __IsIdentOperableResult2
						__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
						__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
						%if __IsIdentOperableResult1
							%assign %%found 1
							cmp %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
							mov %tok(__EvalExtractedIdent), 0
							%if %%o == '<='
								jg %%gt
								inc %tok(__EvalExtractedIdent)
							%%gt:
							%else
								jl %%lt
								inc %tok(__EvalExtractedIdent)
							%%lt:
							%endif
							%xdefine %%changed_to __EvalExtractedIdent
						%elif __IsIdentOperableResult2
							%assign %%found 1
							cmp %tok(__EvalExtractedIdent2), %tok(__EvalExtractedIdent)
							mov %tok(__EvalExtractedIdent2), 0
							%if %%o == '>='
								jl %%lt
								inc %tok(__EvalExtractedIdent2)
							%%lt:
							%else
								jg %%gt
								inc %tok(__EvalExtractedIdent2)
							%%gt:
							%endif
							%xdefine %%changed_to __EvalExtractedIdent2
						%else
							%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%else
					%define %%o %substr(__EvalAfterIdent, 1, 1)
					%if %%o == '<' || %%o == '>'
						%undef __EvalExtractedIdent2
						%undef __EvalAfterIdent2
						%undef __EvalIdentBase2
						__ExtractIdent %substr(__EvalAfterIdent, 2), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
						%if __EvalIdentBase2 < 0
							%error Syntax error: %%expre
							%define __ConditionError
						%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
							%assign %%found 1
							%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
						%else
							%undef __IsIdentOperableResult1
							%undef __IsIdentOperableResult2
							__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
							__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
							%if __IsIdentOperableResult1
								%assign %%found 1
								cmp %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
								mov %tok(__EvalExtractedIdent), 0
								%if %%o == '<'
									jge %%ge
									inc %tok(__EvalExtractedIdent)
								%%ge:
								%else
									jle %%le
									inc %tok(__EvalExtractedIdent)
								%%le:
								%endif
								%xdefine %%changed_to __EvalExtractedIdent
							%elif __IsIdentOperableResult2
								%assign %%found 1
								cmp %tok(__EvalExtractedIdent2), %tok(__EvalExtractedIdent)
								mov %tok(__EvalExtractedIdent2), 0
								%if %%o == '>'
									jle %%le
									inc %tok(__EvalExtractedIdent2)
								%%le:
								%else
									jge %%ge
									inc %tok(__EvalExtractedIdent2)
								%%ge:
								%endif
								%xdefine %%changed_to __EvalExtractedIdent2
							%else
								%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
							%endif
						%endif
						__EvalCheckResult %%changed_to
						%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
						%strcat %%expre %%expre, %%changed_to
						%strcat %%expre %%expre, __EvalAfterIdent2
						%define %%changed_to '#ERROR#'
						%exitrep
					%else
						%define %%o %substr(__EvalAfterIdent, 1, 1)
					%endif
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary ==
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 2)
				%if %%o == '==' || %%o == '!='
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 3), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
						%error Syntax error: %%expre
						%define __ConditionError
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%undef __IsIdentOperableResult1
						%undef __IsIdentOperableResult2
						__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
						__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
						%if __IsIdentOperableResult1
							%assign %%found 1
							cmp %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
							mov %tok(__EvalExtractedIdent), 0
							%if %%o == '=='
								jnz %%nz
								inc %tok(__EvalExtractedIdent)
								%%nz:
							%else
								jz %%z
								inc %tok(__EvalExtractedIdent)
								%%z:
							%endif
							%xdefine %%changed_to __EvalExtractedIdent
						%elif __IsIdentOperableResult2
							%assign %%found 1
							cmp %tok(__EvalExtractedIdent2), %tok(__EvalExtractedIdent)
							mov %tok(__EvalExtractedIdent2), 0
							%if %%o == '=='
								jnz %%nz
								inc %tok(__EvalExtractedIdent2)
								%%nz:
							%else
								jz %%z
								inc %tok(__EvalExtractedIdent2)
								%%z:
							%endif
							%xdefine %%changed_to __EvalExtractedIdent2
						%else
							%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary &
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 1)
				%if %%o == '&'
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 2), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
					 	%if __EvalExtractedIdent2 != '&'
							%error Syntax error: %%expre
							%define __ConditionError
						%else
							%define %%changed_to %strcat(%strcat(__EvalExtractedIdent, '&'), __EvalExtractedIdent2)
						%endif
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%undef __IsIdentOperableResult1
						%undef __IsIdentOperableResult2
						__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
						__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
						%if __IsIdentOperableResult1
							%assign %%found 1
							and %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
							%xdefine %%changed_to __EvalExtractedIdent
						%elif __IsIdentOperableResult2
							%assign %%found 1
							and %tok(__EvalExtractedIdent2), %tok(__EvalExtractedIdent)
							%xdefine %%changed_to __EvalExtractedIdent2
						%else
							%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary ^
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 1)
				%if %%o == '^'
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 2), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
						%error Syntax error: %%expre
						%define __ConditionError
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%undef __IsIdentOperableResult1
						%undef __IsIdentOperableResult2
						__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
						__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
						%if __IsIdentOperableResult1
							%assign %%found 1
							xor %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
							%xdefine %%changed_to __EvalExtractedIdent
						%elif __IsIdentOperableResult2
							%assign %%found 1
							xor %tok(__EvalExtractedIdent2), %tok(__EvalExtractedIdent)
							%xdefine %%changed_to __EvalExtractedIdent2
						%else
							%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary |
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 1)
				%if %%o == '|'
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 2), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
						%if __EvalExtractedIdent2 != '|'
							%error Syntax error: %%expre
							%define __ConditionError
						%else
							%define %%changed_to %strcat(%strcat(__EvalExtractedIdent, '|'), __EvalExtractedIdent2)
						%endif
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%undef __IsIdentOperableResult1
						%undef __IsIdentOperableResult2
						__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
						__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
						%if __IsIdentOperableResult1
							%assign %%found 1
							or %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
							%xdefine %%changed_to __EvalExtractedIdent
						%elif __IsIdentOperableResult2
							%assign %%found 1
							or %tok(__EvalExtractedIdent2), %tok(__EvalExtractedIdent)
							%xdefine %%changed_to __EvalExtractedIdent2
						%else
							%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary &&
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 2)
				%if %%o == '&&'
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 3), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
						%error Syntax error: %%expre
						%define __ConditionError
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%undef __IsIdentOperableResult1
						%undef __IsIdentOperableResult2
						__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
						__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
						%if __IsIdentOperableResult1
							%assign %%found 1
							cmp %tok(__EvalExtractedIdent), 0
							jz %%no
							mov %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
							%%no:
							%xdefine %%changed_to __EvalExtractedIdent
						%elif __IsIdentOperableResult2
							%assign %%found 1
							cmp %tok(__EvalExtractedIdent2), 0
							jz %%no
							mov %tok(__EvalExtractedIdent2), %tok(__EvalExtractedIdent)
							%%no:
							%xdefine %%changed_to __EvalExtractedIdent2
						%else
							%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary ||
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 2)
				%if %%o == '||'
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 3), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
						%error Syntax error: %%expre
						%define __ConditionError
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%undef __IsIdentOperableResult1
						%undef __IsIdentOperableResult2
						__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
						__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
						%if __IsIdentOperableResult1
							%assign %%found 1
							or %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
							cmp %tok(__EvalExtractedIdent), 0
							jz %%z
								mov %tok(__EvalExtractedIdent), 1
							%%z:
							%xdefine %%changed_to __EvalExtractedIdent
						%elif __IsIdentOperableResult2
							%assign %%found 1
							or %tok(__EvalExtractedIdent2), %tok(__EvalExtractedIdent)
							cmp %tok(__EvalExtractedIdent2), 0
							jz %%z
								mov %tok(__EvalExtractedIdent2), 1
							%%z:
							%xdefine %%changed_to __EvalExtractedIdent2
						%else
							%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%rep 10000 ;Process binary =
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%found 0
		%strlen %%len %%expre
		%assign %%pos 0
		%rep %%len
			%assign %%pos %%pos + 1
			%define __ToExtract %substr(%%expre, %%pos)
			%if %strlen(__ToExtract) == 0
				%exitrep
			%endif
			%undef __EvalExtractedIdent
			%undef __EvalAfterIdent
			%undef __EvalIdentBase
			__ExtractIdent __ToExtract, __EvalExtractedIdent, __EvalAfterIdent, __EvalIdentBase
			%if __EvalIdentBase >= 0
				%define %%o %substr(__EvalAfterIdent, 1, 1)
				%if %%o == '='
					%undef __EvalExtractedIdent2
					%undef __EvalAfterIdent2
					%undef __EvalIdentBase2
					__ExtractIdent %substr(__EvalAfterIdent, 2), __EvalExtractedIdent2, __EvalAfterIdent2, __EvalIdentBase2
					%if __EvalIdentBase2 < 0
						%error Syntax error: %%expre
						%define __ConditionError
					%elif __EvalIdentBase > 0 && __EvalIdentBase2 > 0
						%assign %%found 1
						%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
					%else
						%undef __IsIdentOperableResult1
						%undef __IsIdentOperableResult2
						__IsIdentOperable __IsIdentOperableResult1, __EvalExtractedIdent
						__IsIdentOperable __IsIdentOperableResult2, __EvalExtractedIdent2
						%if __IsIdentOperableResult1
							%assign %%found 1
							mov %tok(__EvalExtractedIdent), %tok(__EvalExtractedIdent2)
							%xdefine %%changed_to __EvalExtractedIdent
						%elif __IsIdentOperableResult2
							%assign %%found 1
							mov %tok(__EvalExtractedIdent2), %tok(__EvalExtractedIdent)
							%xdefine %%changed_to __EvalExtractedIdent2
						%else
							%defstr %%changed_to %eval(%tok(__EvalExtractedIdent)%tok(%%o)%tok(__EvalExtractedIdent2))
						%endif
					%endif
					__EvalCheckResult %%changed_to
					%xdefine %%expre %substr(%%expre, 1, %%pos - 1)
					%strcat %%expre %%expre, %%changed_to
					%strcat %%expre %%expre, __EvalAfterIdent2
					%define %%changed_to '#ERROR#'
					%exitrep
				%endif
			%endif
		%endrep
		%if %%found == 0
			%exitrep
		%endif
	%endrep
	%ifdef __DEBUG_EVALUATION
		%warning %%expre
	%endif
	%define __EvaluateResult %%expre
%endmacro

%macro Evaluate 1
	__RemoveSpaces %%expre, %str(%1)
	%rep 10000
		%ifdef __ConditionError
			%exitmacro
		%endif
		%assign %%pos 0
		%assign %%last_lparenthesis 0
		%assign %%rparenthesis 0
		%strlen %%len %%expre
		%rep %%len
			%assign %%pos %%pos + 1
			%define %%c %substr(%%expre, %%pos, 1)
			%if %%c == '('
				%assign %%last_lparenthesis %%pos
			%elif %%c == ')'
				%assign %%rparenthesis %%pos
				%if %%last_lparenthesis == 0
					%error No matching '('
					%define __ConditionError
				%endif
				__EvaluateSimple %tok(%substr(%%expre, %%last_lparenthesis + 1, %%rparenthesis - %%last_lparenthesis - 1))
				%define %%Left %substr(%%expre, 1, %%last_lparenthesis - 1)
				%define %%Right %substr(%%expre, %%rparenthesis + 1)
				%xdefine %%expre %strcat(%strcat(%%Left, __EvaluateResult), %%Right)
				%exitrep
			%endif
		%endrep
		%if %%rparenthesis == 0
			%if %%last_lparenthesis != 0
				%error No matching ')'
				%define __ConditionError
			%else
				%exitrep
			%endif
		%endif
	%endrep
	__EvaluateSimple %tok(%%expre)
%endmacro

; Evaluate (2 * (-2 + 4 + 6 * ~eax - ecx + 8 / 3)) * 4 << 1 >= 1 > 0 == ecx != edx && 1 || ecx % 16
; __EvaluateResult

%endif
