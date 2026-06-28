%ifndef _LOADDLL_INC_
%define _LOADDLL_INC_ 1

%include "frame.inc"

%define NULL 0

%macro def_dll 2
	[segment .bss]
	extern _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	[segment .rdata]
	extern _name_of_ %+ %1
	_name_of_ %+ %1 db %2, 0

	__SECT__
%endmacro

%macro def_dll_func 1
	[segment .bss]
	extern _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	[segment .rdata]
	extern _name_of_ %+ %1
	_name_of_ %+ %1 db %str(%1), 0

	__SECT__
%endmacro

%macro def_dll_func_addr 1
	[segment .bss]
	extern _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	__SECT__
%endmacro

%macro def_dll_func_alias 2
	[segment .bss]
	extern _addr_of_ %+ %1
	_addr_of_ %+ %1 resd 1

	[segment .rdata]
	extern _name_of_ %+ %1
	_name_of_ %+ %1 db %2, 0

	__SECT__
%endmacro

%macro load_dll 1
	push _name_of_ %+ %1
	call [_addr_of_LoadLibraryA]
	mov [_addr_of_ %+ %1], eax
	%ifdef INVOKE_CHECK
		[segment .rdata]
		%%dllfail db %str(CurFuncName), ": On load dll `", %str(%1), "`: failed", 0

		__SECT__
		test eax, eax
		jnz %%success
		extern _addr_of_MessageBoxA
		push 0
		push 0
		push %%dllfail
		push 0
		call [_addr_of_MessageBoxA]
		int3
	%%success:
	%endif
%endmacro

%macro load_dll_func 2
	push _name_of_ %+ %2
	push [_addr_of_ %+ %1]
	call [_addr_of_GetProcAddress]
	mov [_addr_of_ %+ %2], eax
	%ifdef INVOKE_CHECK
		test eax, eax
		jnz %%success
		int3
	%%success:
	%endif
%endmacro

%macro invoke_dll_func 1
	%ifdef INVOKE_CHECK
		mov eax, [_addr_of_ %+ %1]
		test eax, eax
		jnz %%success
		[segment .rdata]
		%%func_name db %str(CurFuncName), ": On call `", %str(%1), "`: NULL function pointer", 0

		__SECT__
		extern _addr_of_MessageBoxA
		push 0
		push 0
		push %%func_name
		push 0
		call [_addr_of_MessageBoxA]
		jmp %%unsuccess
		%%success:
		call [_addr_of_ %+ %1]
		%%unsuccess:
	%else
		call [_addr_of_ %+ %1]
	%endif
%endmacro

%macro def_dll_and_load 2
	def_dll %1, %2
	load_dll %1
%endmacro

%macro def_dll_func_and_load 2
	def_dll_func %2
	load_dll_func %1, %2
%endmacro

%macro def_dll_func_and_load_alias 3
	def_dll_func_alias %2, %3
	load_dll_func %1, %2
%endmacro

%macro import_dll 1
	extern _addr_of_ %+ %1
%endmacro

%macro import_dll_func 1
	extern _addr_of_ %+ %1
%endmacro

%macro dll_func_group_start 1
	[segment .bss]
	extern _First %+ %1 %+ Addr
	_First %+ %1 %+ Addr:

	[segment .rdata]
	extern _First %+ %1 %+ Name
	_First %+ %1 %+ Name:
%endmacro

%macro dll_func_group_start_without_name 1
	[segment .bss]
	extern _First %+ %1 %+ Addr
	_First %+ %1 %+ Addr:
%endmacro

%macro dll_func_group_end 1
	segment .bss
	_Last %+ %1 %+ Addr:
%endmacro

%macro dll_func_group_load 2
	mov esi, _First %+ %2 %+ Name
	mov edi, _First %+ %2 %+ Addr
	mov ecx, (_Last %+ %2 %+ Addr - _First %+ %2 %+ Addr) / 4
	mov ebx, [_addr_of_ %+ %1]
	call _LoadFuncGroup
%endmacro

%macro dll_func_group_load_alter_name 3
	mov esi, %3
	mov edi, _First %+ %2 %+ Addr
	mov ecx, (_Last %+ %2 %+ Addr - _First %+ %2 %+ Addr) / 4
	mov ebx, [_addr_of_ %+ %1]
	call _LoadFuncGroup
%endmacro

%macro debug_msg 1-2+
	[segment .rdata]
	%%format db %1, 0

	__SECT__
	%if %0 >= 2
		invoke_stdcall _DebugMsg, %%format, %2
	%else
		invoke_stdcall _DebugMsg, %%format
	%endif
	add esp, __ParamIndex * 4
%endmacro

%macro debug_printf 1-2+
	[segment .rdata]
	%%format db %1, 0

	__SECT__
	%if %0 >= 2
		invoke_dll_stdcall printf, %%format, %2
	%else
		invoke_dll_stdcall printf, %%format
	%endif
	add esp, __ParamIndex * 4
%endmacro

%macro debug_show 3-4+
	%ifndef _DEBUG
		%error `_DEBUG` not defined.
		%exitmacro
	%endif
	[segment .rdata]
	%%format db %3, 0

	__SECT__
	%if %0 >= 4
		invoke_stdcall _DebugShow, %1, %2, %%format, %4
	%else
		invoke_stdcall _DebugShow, %1, %2, %%format
	%endif
	add esp, __ParamIndex * 4
%endmacro

%macro snprintf 3-4+
	[segment .rdata]
	%%format db %3, 0

	__SECT__
	%if %0 >= 4
		invoke_cdecl _snprintf, %1, %2, %%format, %4
	%else
		invoke_cdecl _snprintf, %1, %2, %%format
	%endif
%endmacro

import_dll Kernel32
import_dll_func GetProcAddress
import_dll_func LoadLibraryA

extern _hInstance

%ifdef _DEBUG
	extern _hDCDesktop
%endif

extern _LoadFuncGroup

;void LoadFuncsFromAssets(void *output, void *dll_base, const char *asset_path, size_t count)
extern _LoadFuncsFromAssets
%macro LoadFuncsFromAssets 4
	[segment .rdata]
	%%AssetName db %3, 0

	__SECT__
	invoke_cdecl _LoadFuncsFromAssets, %1, %2, %%AssetName, %4
%endmacro

extern _DebugMsg ;void DebugMsg(const char *format, ...);
%ifdef _DEBUG
	extern _DebugShow ;void DebugShow(int x, int y, const char *format, ...);
	extern _DebugShowV ;void DebugShowV(int x, int y, const char *format, void *ap);
%endif
extern _snprintf
extern _malloc
extern _calloc
extern _realloc
extern _free
extern _aligned_malloc
extern _aligned_free

extern _NLtoNUL
extern _DebugMsgBuffer
extern _InitDbg
extern _DeInitDbg

extern _ReleaseComObj
extern _SafeRelease

%define _DebugMsgBufferSize 4096

import_dll User32
import_dll GDI32
import_dll MSVCRT
import_dll OpenGL32

import_dll_func ExitProcess
import_dll_func QueryPerformanceFrequency
import_dll_func QueryPerformanceCounter
import_dll_func GetProcessHeap
import_dll_func HeapAlloc
import_dll_func HeapReAlloc
import_dll_func HeapFree
import_dll_func Sleep
import_dll_func GetTickCount
import_dll_func CreateThread
import_dll_func CloseHandle
import_dll_func WaitForMultipleObjects
import_dll_func VirtualProtect
import_dll_func TlsAlloc
import_dll_func TlsGetValue
import_dll_func TlsSetValue
import_dll_func TlsFree
import_dll_func InterlockedIncrement
import_dll_func InterlockedDecrement
import_dll_func InterlockedExchange

import_dll_func MessageBoxA
import_dll_func MessageBoxW
import_dll_func DrawTextA
import_dll_func LoadIconA
import_dll_func LoadCursorA
import_dll_func RegisterClassExA
import_dll_func CreateWindowExA
import_dll_func ShowWindow
import_dll_func UpdateWindow
import_dll_func PeekMessageA
import_dll_func TranslateMessage
import_dll_func DispatchMessageA
import_dll_func PostQuitMessage
import_dll_func DefWindowProcA
import_dll_func GetDC
import_dll_func ReleaseDC
import_dll_func GetWindowRect
import_dll_func GetClientRect
import_dll_func ClientToScreen
import_dll_func GetCursorPos
import_dll_func SetCursorPos
import_dll_func ShowCursor
import_dll_func GetAsyncKeyState
import_dll_func GetForegroundWindow
import_dll_func MonitorFromWindow

import_dll_func SelectObject
import_dll_func DeleteObject
import_dll_func GetStockObject
import_dll_func ChoosePixelFormat
import_dll_func SetPixelFormat

import_dll_func strcpy
import_dll_func strcat
import_dll_func strlen
import_dll_func strcmp
import_dll_func printf
import_dll_func vsnprintf
import_dll_func memset
import_dll_func memcpy
import_dll_func memmove
import_dll_func rand
import_dll_func srand

%define PAGE_NOACCESS           0x01
%define PAGE_READONLY           0x02
%define PAGE_READWRITE          0x04

%define DT_TOP                      0x00000000
%define DT_LEFT                     0x00000000
%define DT_CENTER                   0x00000001
%define DT_RIGHT                    0x00000002
%define DT_VCENTER                  0x00000004
%define DT_BOTTOM                   0x00000008
%define DT_WORDBREAK                0x00000010
%define DT_SINGLELINE               0x00000020
%define DT_EXPANDTABS               0x00000040
%define DT_TABSTOP                  0x00000080
%define DT_NOCLIP                   0x00000100
%define DT_EXTERNALLEADING          0x00000200
%define DT_CALCRECT                 0x00000400
%define DT_NOPREFIX                 0x00000800
%define DT_INTERNAL                 0x00001000

%define WM_CREATE 0x0001
%define WM_DESTROY 0x0002
%define WM_QUIT 0x0012

%define WS_OVERLAPPEDWINDOW (0x00000000 | 0x00C00000 | 0x00080000 | 0x00040000 | 0x00020000 | 0x00010000)

%define CW_USEDEFAULT 0x80000000

%define PM_REMOVE 1

%define WHITE_BRUSH         0
%define LTGRAY_BRUSH        1
%define GRAY_BRUSH          2
%define DKGRAY_BRUSH        3
%define BLACK_BRUSH         4
%define NULL_BRUSH          5
%define HOLLOW_BRUSH        NULL_BRUSH
%define WHITE_PEN           6
%define BLACK_PEN           7
%define NULL_PEN            8
%define OEM_FIXED_FONT      10
%define ANSI_FIXED_FONT     11
%define ANSI_VAR_FONT       12
%define SYSTEM_FONT         13
%define DEVICE_DEFAULT_FONT 14
%define DEFAULT_PALETTE     15
%define SYSTEM_FIXED_FONT   16

%define MONITOR_DEFAULTTONULL 0
%define MONITOR_DEFAULTTOPRIMARY 1
%define MONITOR_DEFAULTTONEAREST 2

struc PIXELFORMATDESCRIPTOR
	.nSize: resw 1
	.nVersion: resw 1
	.dwFlags: resd 1
	.iPixelType: resb 1
	.cColorBits: resb 1
	.cRedBits: resb 1
	.cRedShift: resb 1
	.cGreenBits: resb 1
	.cGreenShift: resb 1
	.cBlueBits: resb 1
	.cBlueShift: resb 1
	.cAlphaBits: resb 1
	.cAlphaShift: resb 1
	.cAccumBits: resb 1
	.cAccumRedBits: resb 1
	.cAccumGreenBits: resb 1
	.cAccumBlueBits: resb 1
	.cAccumAlphaBits: resb 1
	.cDepthBits: resb 1
	.cStencilBits: resb 1
	.cAuxBuffers: resb 1
	.iLayerType: resb 1
	.bReserved: resb 1
	.dwLayerMask: resd 1
	.dwVisibleMask: resd 1
	.dwDamageMask: resd 1
	.size equ $ - .nSize
endstruc

%define PFD_DRAW_TO_WINDOW 0x00000004
%define PFD_SUPPORT_OPENGL 0x00000020
%define PFD_DOUBLEBUFFER 0x00000001
%define PFD_TYPE_RGBA 0
%define PFD_MAIN_PLANE 0

%define VK_LBUTTON        0x01
%define VK_RBUTTON        0x02
%define VK_CANCEL         0x03
%define VK_MBUTTON        0x04

%define VK_BACK           0x08
%define VK_TAB            0x09

%define VK_CLEAR          0x0C
%define VK_RETURN         0x0D

%define VK_SHIFT          0x10
%define VK_CONTROL        0x11
%define VK_MENU           0x12
%define VK_PAUSE          0x13
%define VK_CAPITAL        0x14

%define VK_KANA           0x15
%define VK_HANGEUL        0x15
%define VK_HANGUL         0x15
%define VK_IME_ON         0x16
%define VK_JUNJA          0x17
%define VK_FINAL          0x18
%define VK_HANJA          0x19
%define VK_KANJI          0x19
%define VK_IME_OFF        0x1A

%define VK_ESCAPE         0x1B

%define VK_CONVERT        0x1C
%define VK_NONCONVERT     0x1D
%define VK_ACCEPT         0x1E
%define VK_MODECHANGE     0x1F

%define VK_SPACE          0x20
%define VK_PRIOR          0x21
%define VK_NEXT           0x22
%define VK_END            0x23
%define VK_HOME           0x24
%define VK_LEFT           0x25
%define VK_UP             0x26
%define VK_RIGHT          0x27
%define VK_DOWN           0x28
%define VK_SELECT         0x29
%define VK_PRINT          0x2A
%define VK_EXECUTE        0x2B
%define VK_SNAPSHOT       0x2C
%define VK_INSERT         0x2D
%define VK_DELETE         0x2E
%define VK_HELP           0x2F

%define VK_LWIN           0x5B
%define VK_RWIN           0x5C
%define VK_APPS           0x5D

%define VK_NUMPAD0        0x60
%define VK_NUMPAD1        0x61
%define VK_NUMPAD2        0x62
%define VK_NUMPAD3        0x63
%define VK_NUMPAD4        0x64
%define VK_NUMPAD5        0x65
%define VK_NUMPAD6        0x66
%define VK_NUMPAD7        0x67
%define VK_NUMPAD8        0x68
%define VK_NUMPAD9        0x69
%define VK_MULTIPLY       0x6A
%define VK_ADD            0x6B
%define VK_SEPARATOR      0x6C
%define VK_SUBTRACT       0x6D
%define VK_DECIMAL        0x6E
%define VK_DIVIDE         0x6F
%define VK_F1             0x70
%define VK_F2             0x71
%define VK_F3             0x72
%define VK_F4             0x73
%define VK_F5             0x74
%define VK_F6             0x75
%define VK_F7             0x76
%define VK_F8             0x77
%define VK_F9             0x78
%define VK_F10            0x79
%define VK_F11            0x7A
%define VK_F12            0x7B
%define VK_F13            0x7C
%define VK_F14            0x7D
%define VK_F15            0x7E
%define VK_F16            0x7F
%define VK_F17            0x80
%define VK_F18            0x81
%define VK_F19            0x82
%define VK_F20            0x83
%define VK_F21            0x84
%define VK_F22            0x85
%define VK_F23            0x86
%define VK_F24            0x87

%define VK_NUMLOCK        0x90
%define VK_SCROLL         0x91

%define VK_LSHIFT         0xA0
%define VK_RSHIFT         0xA1
%define VK_LCONTROL       0xA2
%define VK_RCONTROL       0xA3
%define VK_LMENU          0xA4
%define VK_RMENU          0xA5

%define VK_BROWSER_BACK        0xA6
%define VK_BROWSER_FORWARD     0xA7
%define VK_BROWSER_REFRESH     0xA8
%define VK_BROWSER_STOP        0xA9
%define VK_BROWSER_SEARCH      0xAA
%define VK_BROWSER_FAVORITES   0xAB
%define VK_BROWSER_HOME        0xAC

%define VK_VOLUME_MUTE         0xAD
%define VK_VOLUME_DOWN         0xAE
%define VK_VOLUME_UP           0xAF
%define VK_MEDIA_NEXT_TRACK    0xB0
%define VK_MEDIA_PREV_TRACK    0xB1
%define VK_MEDIA_STOP          0xB2
%define VK_MEDIA_PLAY_PAUSE    0xB3
%define VK_LAUNCH_MAIL         0xB4
%define VK_LAUNCH_MEDIA_SELECT 0xB5
%define VK_LAUNCH_APP1         0xB6
%define VK_LAUNCH_APP2         0xB7

%endif
