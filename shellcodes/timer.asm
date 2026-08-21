%include "common.inc"
%include "timer.inc"
%include "hrsleep.inc"

struc TimerData
	.PerfFreq resq 1
	.SysTimerVal resq 1
endstruc

segment .data
align 4
_TimerData:
istruc TimerData
	at .PerfFreq, dq 0
	at .SysTimerVal, dq 0
iend

DefFunc _GetSysTimerVal
	FrameBegin ebx
	GetAbsAddr ebx, _TimerData

	invoke_stdcall QueryPerformanceFrequency, &[ebx + TimerData.PerfFreq]
	invoke_stdcall QueryPerformanceCounter, &[ebx + TimerData.SysTimerVal]

	fild qword [ebx + TimerData.SysTimerVal]
	fild qword [ebx + TimerData.PerfFreq]
	fdiv
	FrameEnd
	ret

DefFunc _GetTimerVal
	FrameBegin
	NameParams %$Timer
	mov eax, %$Timer
	fld qword [eax + Timer.TimerVal]
	FrameEnd
	ret

DefFunc _InitTimer
	FrameBegin
	NameParams %$Timer
	invoke_cdecl _GetSysTimerVal
	mov edx, %$Timer
	fst qword [edx + Timer.PausedTime]
	fstp qword [edx + Timer.StartTime]
	xor eax, eax
	mov [edx + Timer.IsPaused], eax
	FrameEnd
	ret

DefFunc _UpdateTimer
	FrameBegin esi
	NameParams %$Timer

	mov esi, %$Timer
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
	FrameBegin
	NameParams %$Timer
	mov eax, %$Timer
	mov eax, [eax + Timer.IsPaused]
	FrameEnd
	ret

DefFunc _PauseTimer
	FrameBegin esi
	NameParams %$Timer

	mov esi, %$Timer
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
	FrameBegin esi
	NameParams %$Timer

	mov esi, %$Timer
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
	FrameBegin
	NameParams %$US_L, %$US_H
	DefVars %$TimeValL, %$TimeValH, %$WaitedL, %$WaitedH, %$ToWaitL, %$ToWaitH, %$ThousandL, %$ThousandH, %$Million

	mov dword %$ThousandL, __float64__(1000.0) & 0xFFFFFFFF
	mov dword %$ThousandH, (__float64__(1000.0) >> 32) & 0xFFFFFFFF
	mov dword %$Million, __float32__(1000000.0)

	fild qword %$US_L
	fdiv dword %$Million
	fstp qword %$ToWaitL

	invoke_cdecl _GetSysTimerVal
	fstp qword %$TimeValL

.again:
	invoke_cdecl _GetSysTimerVal
	fsub qword %$TimeValL
	fstp qword %$WaitedL

	movq xmm0, %$ToWaitL
	movq xmm1, %$WaitedL
	movq xmm2, %$ThousandL
	ucomisd xmm0, xmm1
	jb .end
	ucomisd xmm0, xmm2
	jb .again
.sleep:
	invoke_cdecl _HRSleep500us
	jmp .again

.end:
	FrameEnd
	ret
