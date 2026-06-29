%ifndef _LFU_INC_
%define _LFU_INC_ 1

struc LfuCache
	.data_tree resd 1
	.freq_tree resd 1
	.capacity resd 1
	.current_size resd 1
	.user_keyops resd 1
	.size equ $ - LfuCache
endstruc

; LfuCache *LfuCreate(int capacity, KeyCompareOps *user_ops);
extern _LfuCreate

; void* LfuGet(LfuCache *cache, void *key);
extern _LfuGet

; void LfuPut(LfuCache *cache, void *key, void *value, void(*on_free)(void *userdata));
extern _LfuPut

; void LfuDestroy(LfuCache *cache)
extern _LfuDestroy

%endif
