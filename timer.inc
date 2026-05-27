%ifndef _TIMER_INC_
%define _TIMER_INC_ 1

struc Timer
.StartTime resq 1
.PausedTime resq 1
.TimerVal resq 1
.IsPaused resd 1
.size equ $ - Timer
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

%endif
