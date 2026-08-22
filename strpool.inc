%ifndef _STRPOOL_INC_
%define _STRPOOL_INC_ 1

%ifndef __DEFSTR_COUNT__
%assign __DEFSTR_COUNT__ 0
%endif

%macro DefStr 2
	%if %strlen(%2) == 0
		%ifdef __DEFSTR_ZERO_ADDR
			%1 equ __DEFSTR_ZERO_ADDR
		%else
			[section .rdata]
			__DEFSTR_ZERO_INIT equ $
			db 0
			__SECT__

			%define __DEFSTR_ZERO_ADDR __DEFSTR_ZERO_INIT
			%1 equ __DEFSTR_ZERO_ADDR
		%endif
		%exitmacro
	%endif

	%assign %%idx 0
	%assign %%found 0
	%assign %%found_idx -1

	%rep __DEFSTR_COUNT__
		%xdefine %%old_raw __DEFSTR_%[%%idx]_raw
		%ifidn %2, %%old_raw
			%assign %%found 1
			%assign %%found_idx %%idx
			%exitrep
		%endif
		%assign %%idx %%idx + 1
	%endrep

	%if %%found
		%1 equ __DEFSTR_%[%%found_idx]_addr
	%else
		[section .rdata]
		__DEFSTR_%[__DEFSTR_COUNT__]_addr equ $
		db %2
		__DEFSTR_%[__DEFSTR_COUNT__]_zero equ $
		db 0
		__SECT__
		%define __DEFSTR_ZERO_ADDR __DEFSTR_%[__DEFSTR_COUNT__]_zero
		%define __DEFSTR_%[__DEFSTR_COUNT__]_raw %2
		%1 equ __DEFSTR_%[__DEFSTR_COUNT__]_addr
		%assign __DEFSTR_COUNT__ __DEFSTR_COUNT__ + 1
	%endif
%endmacro

%endif
