
struc Timer
.StartTime resq 1
.PausedTime resq 1
.TimerVal resq 1
.IsPaused resd 1
.size equ $ - Timer
endstruc


