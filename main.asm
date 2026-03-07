%include "frame.inc"
%include "loaddll.inc"

extern _InitLoadLibrary
extern _InitGL33

segment .rdata
_test_text db "test", 0

segment .text
global _start
_start:
	call _InitLoadLibrary

	load_dll User32
	load_dll_func User32, MessageBoxA

	call _InitGL33

	push dword 0
	push _test_text
	push _test_text
	push dword 0
	invoke_dll_func MessageBoxA

	ret

def_dll User32, "user32.dll"
def_dll_func MessageBoxA, "MessageBoxA"
