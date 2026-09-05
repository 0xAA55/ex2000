%ifndef _VBLANK_INC_
%define _VBLANK_INC_ 1

%include "loaddll.inc"
%include "timer.inc"

extern _VBlankInit
extern _VBlankDeInit
extern _VBlankReInit

extern _WaitForVBlank

%macro InstVBlankData 0
	.MonitorsData resd 1
	.VBlankTimer:
		InstTimer
	.VBlankFrameStartTime resq 1
	.VBlankTimeUsedMs resd 1
	.VBlankTimeUsedUs resq 1
	.LastFrameRenderTimeMs resd 1
	.LastFrameRenderTimeUs resq 1
	.FrameRenderDelayMs resd 1
	.FrameRenderDelayUs resq 1
	.VBlankWithDelayTimeUsedMs resd 1
	.VBlankWithDelayTimeUsedUs resq 1
	.size_of_vbdata equ $ - .MonitorsData
%endmacro

struc VBlankData
	InstVBlankData
endstruc

%endif

