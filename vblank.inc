%ifndef _VBLANK_INC_
%define _VBLANK_INC_ 1

%include "loaddll.inc"

extern _VBlankInit
extern _VBlankDeInit
extern _VBlankReInit

extern _VBlankTimeUsedMs
extern _FrameRenderDelayMs
extern _LastFrameRenderTimeMs

extern _WaitForVBlank

%endif

