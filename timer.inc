%ifndef _TIMER_INC_
%define _TIMER_INC_ 1

%macro InstTimer 0
	.Address:
	.StartTime resq 1
	.PausedTime resq 1
	.TimerVal resq 1
	.IsPaused resd 1
	.size equ $ - .Address
%endmacro

struc Timer
	InstTimer
endstruc

; double GetSysTimerVal();

; void InitTimer(Timer *t);
extern _InitTimer

; double GetTimerVal(const Timer *t);
extern _GetTimerVal

; double UpdateTimer(Timer *t);
extern _UpdateTimer

; int IsTimerPaused(const Timer *t);
extern _IsTimerPaused

; void PauseTimer(Timer *t);
extern _PauseTimer

; void PauseTimer(Timer *t);
extern _UnpauseTimer

%macro PerfStart 1
	[segment .bss]
	extern %1
	%1:
		InstTimer

	__SECT__
	invoke_cdecl _InitTimer, %1
%endmacro

%macro PerfStop 1
	invoke_cdecl _PauseTimer, %1
	invoke_cdecl _UpdateTimer, %1
%endmacro

%endif
