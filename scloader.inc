%ifndef _SCLOADER_INC_
%define _SCLOADER_INC_ 1

%include "shellcode.inc"

extern _LoadShellcode
extern _UnloadShellcode

extern _ShellcodeBase
extern _ShellcodeSize
extern _ShellcodeEAT

extern _CreateBitMap
extern _DestroyBitMap
extern _GetBitmapPixelAddress
extern _SampleFloatMap

%endif
