%ifndef _ASSETS_INC_
%define _ASSETS_INC_ 1

%include "loaddll.inc"

%ifndef ASSETS_ASM
extern _AssetsInit ; int AssetsInit();
extern _AssetsQuery ; void *AssetsQuery(char *key, int *size);
%endif

%endif
