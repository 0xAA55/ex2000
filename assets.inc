%ifndef _ASSETS_INC_
%define _ASSETS_INC_ 1

extern _AssetsInit ; int AssetsInit();
extern _AssetsQuery ; void *AssetsQuery(char *key, int *size);
extern _AssetsDestroy ; void AssetsDestroy();

%macro AssetsQuery 2
	[segment .rdata]
	%%AssetName db %1, 0

	__SECT__
	invoke_cdecl _AssetsQuery, %%AssetName, %2
%endmacro

%endif
