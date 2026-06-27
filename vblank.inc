%ifndef _VBLANK_INC_
%define _VBLANK_INC_ 1

%include "loaddll.inc"

extern _VBlankInit
extern _VBlankDeInit
extern _FakeWaitForVBlank

import_dll_func WaitForVBlank

%endif

