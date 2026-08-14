%include "common.inc"
%include "hrsleep.inc"

segment .data
align 4
_hWaitableTimer dd 0

DefFunc _HRSleepInit
	FrameBegin ebx
	GetAbsAddr ebx, _hWaitableTimer
	invoke_stdcall CreateWaitableTimerExW, NULL, NULL, 2, 0x000F0000|0x00100000|0x0001|0x0002
	mov [ebx], eax
.end:
	FrameEnd
	ret

DefFunc _HRSleepDeInit
	FrameBegin ebx
	GetAbsAddr ebx, _hWaitableTimer
	cmp dword[ebx], 0
	jz .end
	invoke_stdcall CloseHandle, eax
	mov dword[ebx], 0
.end:
	FrameEnd
	ret

DefFunc _HRSleep500us
	FrameBegin ebx
	GetAbsAddr ebx, _hWaitableTimer
	cmp dword[ebx], 0
	jz .fallback

	GetAbsAddr eax, .wait_time
	invoke_stdcall SetWaitableTimer, [ebx], eax, 0, NULL, NULL, 0
	test eax, eax
	jz .fallback
	invoke_stdcall WaitForSingleObject, [ebx], 0xFFFFFFFF

	jmp .end
.fallback:
	invoke_stdcall Sleep, 1
.end:
	FrameEnd
	ret
[segment .rdata]
	align 4
	.wait_time dq -5000
