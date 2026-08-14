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

%include "tls.imp"
%include "bitmap.imp"
binform _GetBitmapPixelAddress, "bmpaddr"
%include "bitmapdup.imp"
%include "samplefmap.imp"
binform _BatchAdd, "batchadd"
binform _BatchBias, "batchbias"
binform _BatchCurve, "batchcurve"
binform _BatchMax, "batchmax"
binform _BatchMin, "batchmin"
%include "fmnm.imp"
%include "conemap.imp"
%include "matmult.imp"
binform _MatrixProjection, "matproj"
%include "mateuler.imp"
%include "matteuler.imp"
%include "matveuler.imp"
binform _MatrixTranspose, "mattranspose"
binform _FloatMapApplyGain, "floatmapgain"
%include "floatmapmax.imp"
%include "floatmapmin.imp"
%include "floatmapcurve.imp"
%include "seedvec.imp"
%include "perlin.imp"
binform _VectorCross, "veccross"
binform _VectorDot, "vecdot"
binform _VectorLength, "veclength"
binform _VectorMultMatrix, "vecmultmat"
binform _VectorNormal, "vecnormal"
binform _UtfReadCharFromPtr, "utf8read"
binform _Utf32to16, "utf16enc"
%include "hrsleep.imp"
%include "timer.imp"
%include "shader.imp"
%include "buffer.imp"
%include "lfu.imp"
%include "fontgl.imp"
%include "raymarch.imp"

DefFunc _ShellcodeInit
	FrameBegin
	invoke_cdecl _TlsInit
	invoke_cdecl _LfuInit
	invoke_cdecl _HRSleepInit
	FrameEnd
	ret

DefFunc _ShellcodeDeInit
	FrameBegin
	invoke_cdecl _HRSleepDeInit
	invoke_cdecl _TlsDeInit
	FrameEnd
	ret

segment .text
align 4

segment .data
align 4

segment .rdata
align 4
