%ifndef _VBLANK_INC_
%define _VBLANK_INC_ 1

%include "loaddll.inc"

extern _VBlankInit
extern _VBlankDeInit
extern _VBlankReInit

extern _VBlankTimeUsedMs
extern _VBlankTimeUsedUs
extern _FrameRenderDelayMs
extern _FrameRenderDelayUs
extern _LastFrameRenderTimeMs
extern _LastFrameRenderTimeUs
extern _VBlankWithDelayTimeUsedMs
extern _VBlankWithDelayTimeUsedUs

extern _WaitForVBlank

%endif

