%include "loaddll.inc"
%include "timer.inc"

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

DefFunc _BusyWaitMs
	FrameBegin 2
	AssignVars _TimeValL, _TimeValH

	invoke_cdecl _GetSysTimerVal
	fstp qword _TimeValL

.again:
	invoke_dll_stdcall Sleep, 0
	invoke_cdecl _GetSysTimerVal
	fsub qword _TimeValL
	fimul word [_WThousand]
	ficomp dword Param(0)
	fstsw ax
	sahf
	jb .again

.end:
	FrameEnd
	ret
	%undef _TimeValL
	%undef _TimeValH

DefFunc _HybridWaitMs
	FrameBegin 3
	AssignVars _TimeValL, _TimeValH, _WaitedMs

	invoke_cdecl _GetSysTimerVal
	fstp qword _TimeValL

.again:
	invoke_cdecl _GetSysTimerVal
	fsub qword _TimeValL
	fimul word [_WThousand]
	fistp dword _WaitedMs
	mov eax, _WaitedMs
	sub eax, Param(0)
	jae .end
	cmp eax, 1
	jle .again
	invoke_dll_stdcall Sleep, 1
	jmp .again

.end:
	FrameEnd
	ret
	%undef _TimeValL
	%undef _TimeValH
