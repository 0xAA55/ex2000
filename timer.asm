%include "loaddll.inc"
%include "timer.inc"

import_dll_func QueryPerformanceFrequency
import_dll_func QueryPerformanceCounter

segment .bss
extern _PerfFreq
extern _SysTimerVal
_PerfFreq resq 1
_SysTimerVal resq 1

DefFunc _GetSysTimerVal
	FrameBegin 0, 0
	invoke_dll_stdcall QueryPerformanceFrequency, _PerfFreq
	invoke_dll_stdcall QueryPerformanceCounter, _SysTimerVal

	fild qword [_SysTimerVal]
	fild qword [_PerfFreq]
	fdiv
	FrameEnd
	ret

DefFunc _GetTimerVal
	FrameBegin 0, 0
	mov eax, Param(0)
	fld qword [eax + Timer.TimerVal]
	FrameEnd
	ret

DefFunc _InitTimer
	FrameBegin 0, 0
	call _GetSysTimerVal
	mov edx, Param(0)
	fstp qword [edx + Timer.StartTime]
	xor eax, eax
	mov [edx + Timer.IsPaused], eax
	FrameEnd
	ret

DefFunc _UpdateTimer
	FrameBegin 0, 0, esi

	mov esi, Param(0)
	mov eax, [esi + Timer.IsPaused]
	test eax, eax
	jnz .paused

	call _GetSysTimerVal
	jmp .calc
.paused:
	fld qword [esi + Timer.PausedTime]
.calc:
	fsub qword [esi + Timer.StartTime]
	fst qword [esi + Timer.TimerVal]

.end:
	FrameEnd
	ret

DefFunc _IsTimerPaused
	FrameBegin 0, 0
	mov eax, Param(0)
	mov eax, [eax + Timer.IsPaused]
	FrameEnd
	ret

DefFunc _PauseTimer
	FrameBegin 0, 0, esi

	mov esi, Param(0)
	mov eax, [esi + Timer.IsPaused]
	test eax, eax
	jnz .end

	inc eax
	mov [esi + Timer.IsPaused], eax

	call _GetSysTimerVal
	fstp qword [esi + Timer.PausedTime]

.end:
	FrameEnd
	ret

DefFunc _UnpauseTimer
	FrameBegin 0, 0, esi

	mov esi, Param(0)
	mov eax, [esi + Timer.IsPaused]
	test eax, eax
	jz .end

	xor eax, eax
	mov [esi + Timer.IsPaused], eax

	call _GetSysTimerVal
	fsub qword [esi + Timer.PausedTime]
	fadd qword [esi + Timer.StartTime]
	fstp qword [esi + Timer.StartTime]

.end:
	FrameEnd
	ret
