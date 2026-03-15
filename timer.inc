%ifndef _TIMER_INC_
%define _TIMER_INC_ 1

struc Timer
.StartTime resq 1
.PausedTime resq 1
.TimerVal resq 1
.IsPaused resd 1
.size equ $ - Timer
endstruc

%ifndef TIMER_ASM
extern _GetTimerVal
extern _InitTimer
extern _UpdateTimer
extern _IsTimerPaused
extern _PauseTimer
extern _UnpauseTimer
%endif

%endif
