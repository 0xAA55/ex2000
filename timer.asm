%include "loaddll.inc"
%include "timer.inc"
%include "hrsleep.inc"

import_dll_func QueryPerformanceFrequency
import_dll_func QueryPerformanceCounter

segment .bss
extern _PerfFreq
extern _SysTimerVal
_PerfFreq resq 1
_SysTimerVal resq 1

segment .rdata
extern _WThousand
_WThousand dw 1000

extern _Million
_Million dd 1000000

DefFunc _GetSysTimerVal
	FrameBegin 0
	invoke_dll_stdcall QueryPerformanceFrequency, _PerfFreq
	invoke_dll_stdcall QueryPerformanceCounter, _SysTimerVal

	fild qword [_SysTimerVal]
	fild qword [_PerfFreq]
	fdiv
	FrameEnd
	ret

DefFunc _GetTimerVal
	FrameBegin 0
	mov eax, Param(0)
	fld qword [eax + Timer.TimerVal]
	FrameEnd
	ret

DefFunc _InitTimer
	FrameBegin 0
	invoke_cdecl _GetSysTimerVal
	mov edx, Param(0)
	fst qword [edx + Timer.PausedTime]
	fstp qword [edx + Timer.StartTime]
	xor eax, eax
	mov [edx + Timer.IsPaused], eax
	FrameEnd
	ret

DefFunc _UpdateTimer
	FrameBegin 0, esi

	mov esi, Param(0)
	mov eax, [esi + Timer.IsPaused]
	test eax, eax
	jnz .paused

	invoke_cdecl _GetSysTimerVal
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
	FrameBegin 0
	mov eax, Param(0)
	mov eax, [eax + Timer.IsPaused]
	FrameEnd
	ret

DefFunc _PauseTimer
	FrameBegin 0, esi

	mov esi, Param(0)
	mov eax, [esi + Timer.IsPaused]
	test eax, eax
	jnz .end

	inc eax
	mov [esi + Timer.IsPaused], eax

	invoke_cdecl _GetSysTimerVal
	fstp qword [esi + Timer.PausedTime]

.end:
	FrameEnd
	ret

DefFunc _UnpauseTimer
	FrameBegin 0, esi

	mov esi, Param(0)
	mov eax, [esi + Timer.IsPaused]
	test eax, eax
	jz .end

	xor eax, eax
	mov [esi + Timer.IsPaused], eax

	invoke_cdecl _GetSysTimerVal
	fsub qword [esi + Timer.PausedTime]
	fadd qword [esi + Timer.StartTime]
	fstp qword [esi + Timer.StartTime]

.end:
	FrameEnd
	ret

; void HybridWaitUs(uint32_t us_l, uint32_t us_h);
DefFunc _HybridWaitUs
	FrameBegin 4
	AssignVars _TimeValL, _TimeValH, _WaitedUsL, _WaitedUsH

	invoke_cdecl _GetSysTimerVal
	fstp qword _TimeValL

.again:
	invoke_cdecl _GetSysTimerVal
	fsub qword _TimeValL
	fimul dword [_Million]
	fistp qword _WaitedUsL
	mov eax, Param(0)
	mov edx, Param(1)
	sub eax, _WaitedUsL
	sbb edx, _WaitedUsH
	jb .end
	test edx, edx
	jnz .sleep
	cmp eax, 1000
	jbe .again
.sleep:
	invoke_cdecl _HRSleep500us
	jmp .again

.end:
	FrameEnd
	ret
	%undef _TimeValL
	%undef _TimeValH
	%undef _WaitedUsL
	%undef _WaitedUsH
