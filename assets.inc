%ifndef _ASSETS_INC_
%define _ASSETS_INC_ 1

extern _AssetsInit ; int AssetsInit();
extern _AssetsQuery ; void *AssetsQuery(char *key, int *size);
extern _AssetsDestroy ; void AssetsDestroy();

%endif
