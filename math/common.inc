%ifndef _MATH_COMMON_INC_
%define _MATH_COMMON_INC_ 1

%include "loaddll.inc"
%include "math.inc"
%include "pool.inc"

%define _MM_SHUFFLE(fp3,fp2,fp1,fp0) (((fp3) << 6) | ((fp2) << 4) | ((fp1) << 2) | ((fp0)))

extern _Rand4MulVal
extern _Rand4AddVal
extern _Rand4AndVal

%define _MM_EQ_    0x00
%define _MM_LT_    0x01
%define _MM_LE_    0x02
%define _MM_UNORD_ 0x03
%define _MM_NEQ_   0x04
%define _MM_GE_    0x05
%define _MM_GT_    0x06
%define _MM_ORD_   0x07

%endif
