%include "loaddll.inc"
%include "hrsleep.inc"

segment .bss
extern _hWaitableTimer
_hWaitableTimer resd 1

DefFunc _HRSleepInit
	FrameBegin
	cmp dword[_addr_of_CreateWaitableTimerExW], 0
	jz .end
	cmp dword[_addr_of_SetWaitableTimer], 0
	jz .end
	invoke_dll_stdcall CreateWaitableTimerExW, NULL, NULL, 2, 0x000F0000|0x00100000|0x0001|0x0002
	mov [_hWaitableTimer], eax
.end:
	FrameEnd
	ret

DefFunc _HRSleepDeInit
	FrameBegin
	invoke_dll_stdcall CloseHandle, [_hWaitableTimer]
	mov dword[_hWaitableTimer], 0
	FrameEnd
	ret

DefFunc _HRSleep500us
	FrameBegin
	cmp dword[_hWaitableTimer], 0
	jz .fallback

	invoke_dll_stdcall SetWaitableTimer, [_hWaitableTimer], .wait_time, 0, NULL, NULL, 0
	test eax, eax
	jz .fallback
	invoke_dll_stdcall WaitForSingleObject, [_hWaitableTimer], 0xFFFFFFFF

	jmp .end
.fallback:
	invoke_dll_stdcall Sleep, 1
.end:
	FrameEnd
	ret
[segment .rdata]
	.wait_time dq -5000
