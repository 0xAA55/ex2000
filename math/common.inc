%ifndef _MATH_COMMON_INC_
%define _MATH_COMMON_INC_ 1

%include "loaddll.inc"
%include "math.inc"
%include "pool.inc"

%define _MM_SHUFFLE(fp3,fp2,fp1,fp0) (((fp3) << 6) | ((fp2) << 4) | ((fp1) << 2) | ((fp0)))

extern _Rand4MulVal
extern _Rand4AddVal
extern _Rand4AndVal

%endif
