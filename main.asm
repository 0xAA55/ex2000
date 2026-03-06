%include "frame.inc"

global _start
extern _InitLoadLibrary

segment .text
_start:
	call _InitLoadLibrary



	ret
