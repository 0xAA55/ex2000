bits 32

%macro DefImp 1
	segment .text
	%1: db 0xE9, 0xE9, 0xE9, 0xE9, 0xE9
%endmacro

%macro DefExp 1
	segment .text
	dd %1
%endmacro

%include "shellcode.inc"

InstImpFull
InstExp

%unmacro DefImp 1
%unmacro DefExp 1

%macro DefImp 1
.%1 resb 5
%endmacro

%macro DefExp 1
.%1 resd 1
%endmacro

struc SCHead
.imports:
	InstImpFull

.exports:
	InstExp

.last_ptr:
	.size equ $ - SCHead
endstruc

%macro binform 2
DefFunc %1
incbin %strcat(%2, ".bin")
%endmacro

%include "bitmap.inc"
%include "bitmapdup.inc"
%include "samplefmap.inc"
binform _BatchAdd, "batchadd"
binform _BatchBias, "batchbias"
binform _BatchCurve, "batchcurve"
binform _BatchMax, "batchmax"
binform _BatchMin, "batchmin"
%include "fmnm.inc"
%include "conemap.inc"
%include "matmult.inc"
binform _MatrixProjection, "matproj"
%include "mateuler.inc"
%include "matteuler.inc"
%include "matveuler.inc"
binform _MatrixTranspose, "mattranspose"
binform _FloatMapApplyGain, "floatmapgain"
%include "floatmapmax.inc"
%include "floatmapmin.inc"
%include "floatmapcurve.inc"
%include "seedvec.inc"
%include "perlin.inc"
binform _VectorCross, "veccross"
binform _VectorDot, "vecdot"
binform _VectorLength, "veclength"
binform _VectorMultMatrix, "vecmultmat"
binform _VectorNormal, "vecnormal"
binform _UtfReadCharFromPtr, "utf8read"
binform _Utf32to16, "utf16enc"
%include "lfuimpl.inc"
%include "raymarch.inc"

DefFunc _ShellcodeInit
	FrameBegin
	invoke_cdecl _LfuInit
	FrameEnd
	ret

times 16 - ($ - $$) % 16 int3
