%ifndef _MATH_COMMON_INC_
%define _MATH_COMMON_INC_ 1

%include "math.inc"
%include "pool.inc"

%define _MM_SHUFFLE(fp3,fp2,fp1,fp0) (((fp3) << 6) | ((fp2) << 4) | ((fp1) << 2) | ((fp0)))

extern _malloc
extern _calloc
extern _free
extern _aligned_malloc
extern _aligned_free

import_dll_func memcpy
import_dll_func memset
import_dll_func rand
import_dll_func srand
import_dll_func ExitProcess

extern _Pi_P
extern _Pi_N
extern _2Pi
extern _counter
extern _HaveSSE3
extern _HaveSSE41
extern _ZeroVector
extern _Rand4MulVal
extern _Rand4AddVal
extern _Rand4AndVal
extern _F1111
extern _F2222
extern _F3333
extern _F4444
extern _F8888
extern _FCCCC
extern _FHHHH
extern _I0123
extern _F0123
extern _UF0F0
extern _FP5P5P5P5
extern _IdentityMatrix
extern _B0123
extern _2.0f
extern _M1.0f
extern _W6
extern _W10
extern _W15
extern _FMAX
extern _FMIN

%endif
