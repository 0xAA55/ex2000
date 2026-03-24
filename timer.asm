%include "loaddll.inc"

%define TIMER_ASM
%include "timer.inc"

import_dll_func QueryPerformanceFrequency
import_dll_func QueryPerformanceCounter

segment .bss
_PerfFreq resq 1
_SysTimerVal resq 1

segment .text
global _GetSysTimerVal
_GetSysTimerVal:
	push _PerfFreq
	invoke_dll_func QueryPerformanceFrequency

	push _SysTimerVal
	invoke_dll_func QueryPerformanceCounter

	fild qword [_SysTimerVal]
	fild qword [_PerfFreq]
	fdiv
	ret

global _GetTimerVal
_GetTimerVal:
	FrameBegin 0, 0
	LoadParam eax, 0
	fld qword [eax + Timer.TimerVal]
	FrameEnd
	ret

global _InitTimer
_InitTimer:
	FrameBegin 0, 0
	call _GetSysTimerVal
	LoadParam edx, 0
	fst qword [edx + Timer.StartTime]
	xor eax, eax
	mov [edx + Timer.IsPaused], eax
	FrameEnd
	ret

global _UpdateTimer
_UpdateTimer:
	FrameBegin 0, 0, esi

	LoadParam esi, 0
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

global _IsTimerPaused
_IsTimerPaused:
	FrameBegin 0, 0
	LoadParam eax, 0
	mov eax, [eax + Timer.IsPaused]
	FrameEnd
	ret

global _PauseTimer
_PauseTimer:
	FrameBegin 0, 0, esi

	LoadParam esi, 0
	mov eax, [esi + Timer.IsPaused]
	test eax, eax
	jnz .end

	inc eax
	mov [esi + Timer.IsPaused], eax

	call _GetSysTimerVal
	fst qword [esi + Timer.PausedTime]

.end:
	FrameEnd
	ret

global _UnpauseTimer
_UnpauseTimer:
	FrameBegin 0, 0, esi

	LoadParam esi, 0
	mov eax, [esi + Timer.IsPaused]
	test eax, eax
	jz .end

	xor eax, eax
	mov [esi + Timer.IsPaused], eax

	call _GetSysTimerVal
	fsub qword [esi + Timer.PausedTime]
	fadd qword [esi + Timer.StartTime]
	fst qword [esi + Timer.StartTime]

.end:
	FrameEnd
	ret
