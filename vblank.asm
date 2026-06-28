%include "loaddll.inc"
%include "vblank.inc"
%include "avlbst.inc"

extern _hWnd
extern _hDC

def_dll DXGI, "dxgi.dll"
def_dll_func CreateDXGIFactory

def_dll DDraw, "ddraw.dll"
def_dll_func DirectDrawEnumerateExA
def_dll_func DirectDrawCreate

%define D3D11_SDK_VERSION 7

struc IDXGIFactoryVtbl
	.QueryInterface resd 1
	.AddRef resd 1
	.Release resd 1
	.SetPrivateData resd 1
	.SetPrivateDataInterface resd 1
	.GetPrivateData resd 1
	.GetParent resd 1
	.EnumAdapters resd 1
	.MakeWindowAssociation resd 1
	.GetWindowAssociation resd 1
	.CreateSwapChain resd 1
	.CreateSoftwareAdapter resd 1
endstruc

struc IDXGIAdapterVtbl
	.QueryInterface resd 1
	.AddRef resd 1
	.Release resd 1
	.SetPrivateData resd 1
	.SetPrivateDataInterface resd 1
	.GetPrivateData resd 1
	.GetParent resd 1
	.EnumOutputs resd 1
	.GetDesc resd 1
	.CheckInterfaceSupport resd 1
endstruc

struc IDXGIOutputVtbl
	.QueryInterface resd 1
	.AddRef resd 1
	.Release resd 1
	.SetPrivateData resd 1
	.SetPrivateDataInterface resd 1
	.GetPrivateData resd 1
	.GetParent resd 1
	.GetDesc resd 1
	.GetDisplayModeList resd 1
	.FindClosestMatchingMode resd 1
	.WaitForVBlank resd 1
	.TakeOwnership resd 1
	.ReleaseOwnership resd 1
	.GetGammaControlCapabilities resd 1
	.SetGammaControl resd 1
	.GetGammaControl resd 1
	.SetDisplaySurface resd 1
	.GetDisplaySurfaceData resd 1
	.GetFrameStatistics resd 1
endstruc

struc DXGI_OUTPUT_DESC
	.DeviceName resw 32
	.DesktopCoordinates resd 4
	.AttachedToDesktop resd 1
	.Rotation resd 1
	.HMonitor resd 1
	.size equ $ - .DeviceName
endstruc

struc IDirectDraw
	.QueryInterface resd 1
	.AddRef resd 1
	.Release resd 1
	.Compact resd 1
	.CreateClipper resd 1
	.CreatePalette resd 1
	.CreateSurface resd 1
	.DuplicateSurface resd 1
	.EnumDisplayModes resd 1
	.EnumSurfaces resd 1
	.FlipToGDISurface resd 1
	.GetCaps resd 1
	.GetDisplayMode resd 1
	.GetFourCCCodes resd 1
	.GetGDISurface resd 1
	.GetMonitorFrequency resd 1
	.GetScanLine resd 1
	.GetVerticalBlankStatus resd 1
	.Initialize resd 1
	.RestoreDisplayMode resd 1
	.SetCooperativeLevel resd 1
	.SetDisplayMode resd 1
	.WaitForVerticalBlank resd 1
endstruc

%define DDENUM_ATTACHEDSECONDARYDEVICES 0x00000001
%define DDENUM_DETACHEDSECONDARYDEVICES 0x00000002
%define DDENUM_NONDISPLAYDEVICES        0x00000004

%define DDCREATE_HARDWAREONLY           0x00000001
%define DDCREATE_EMULATIONONLY          0x00000002

%define DDWAITVB_BLOCKBEGIN             0x00000001
%define DDWAITVB_BLOCKBEGINEVENT        0x00000002
%define DDWAITVB_BLOCKEND               0x00000004

segment .rdata
extern _IID_IDXGIFactory
_IID_IDXGIFactory:
	dd 0x7b7166ec
	dw 0x21c7, 0x44ae
	db 0xb2, 0x1a, 0xc9, 0xae, 0x32, 0x1a, 0xe3, 0x69

segment .bss
extern _addr_of_WaitForVBlank
_addr_of_WaitForVBlank resd 1

extern _DXGIOutputs
_DXGIOutputs resd 1

extern _DDrawObjects
_DDrawObjects resd 1

DefFunc _VBlankInit
	FrameBegin 6 + DXGI_OUTPUT_DESC.size / 4, ebx, esi, edi
	AssignVars DXGIFactory, D3D11Device, DXGIDevice, DXGIOutput, DXGIAdapter, DXGIOutputDesc

	xor eax, eax
	lea edi, DXGIFactory
	mov ecx, Frame_NumLocals
	rep stosd
	mov esi, eax
	mov edi, eax
	lea ebx, DXGIOutputDesc

	load_dll DXGI
	test eax, eax
	jz .no_dxgi

	load_dll_func DXGI, CreateDXGIFactory
	test eax, eax
	jz .no_dxgi

	invoke_dll_stdcall CreateDXGIFactory, _IID_IDXGIFactory, &DXGIFactory
	cmp eax, 0
	jl .no_dxgi

.loop_enum_monitors_by_dxgi:
	invoke_com DXGIFactory, IDXGIFactoryVtbl.EnumAdapters, esi, &DXGIAdapter
	cmp eax, 0
	jl .end_enum_adapeters_dxgi

	xor edi, edi
.loop_enum_outputs_dxgi:
	invoke_com DXGIAdapter, IDXGIAdapterVtbl.EnumOutputs, edi, &DXGIOutput
	cmp eax, 0
	jl .end_enum_outputs_dxgi
	invoke_com DXGIOutput, IDXGIOutputVtbl.GetDesc, ebx
	invoke_cdecl _AVLInsert, _DXGIOutputs, [ebx + DXGI_OUTPUT_DESC.HMonitor], DXGIOutput, _ReleaseComObj, _AVLOps_Integer
	inc edi
	jmp .loop_enum_outputs_dxgi

.end_enum_outputs_dxgi:
	invoke_cdecl _SafeRelease, &DXGIAdapter
	inc esi
	jmp .loop_enum_monitors_by_dxgi

.end_enum_adapeters_dxgi:
	invoke_cdecl _SafeRelease, &DXGIFactory
	mov dword[_addr_of_WaitForVBlank], _WaitForVBlankD3D
	xor eax, eax
	inc eax
	jmp .end

.no_dxgi:
	load_dll DDraw
	test eax, eax
	jz .no_ddraw

	load_dll_func DDraw, DirectDrawEnumerateExA
	test eax, eax
	jz .no_ddraw

	load_dll_func DDraw, DirectDrawCreate
	test eax, eax
	jz .no_ddraw

	invoke_dll_stdcall DirectDrawEnumerateExA, _DDEnumCallbackExA@20, NULL, DDENUM_ATTACHEDSECONDARYDEVICES
	cmp eax, 0
	jl .no_ddraw

	mov dword[_addr_of_WaitForVBlank], _WaitForVBlankDDraw
	xor eax, eax
	inc eax
	jmp .end

.no_ddraw:
	; Fallback to `_FakeWaitForVBlank`
	mov dword[_addr_of_WaitForVBlank], _FakeWaitForVBlank

.end:
	FrameEnd
	ret
	%undef DXGIFactory
	%undef D3D11Device
	%undef DXGIDevice
	%undef DXGIOutput
	%undef DXGIAdapter
	%undef HMonitor
	%undef Dummy
	%undef DXGIOutputDesc

DefFunc _DDEnumCallbackExA@20
	FrameBegin 1, edi
	AssignVars DDrawObj

	mov eax, Param(0)
	test eax, eax
	jz .end

	xor eax, eax
	lea edi, DDrawObj
	mov ecx, Frame_NumVariables
	rep stosd

	invoke_dll_stdcall DirectDrawCreate, Param(0), &DDrawObj, NULL
	cmp eax, 0
	jl .fail

	invoke_cdecl _AVLInsert, _DDrawObjects, Param(4), DDrawObj, _ReleaseComObj, _AVLOps_Integer
	xor eax, eax
	jmp .end

.fail:
	xor eax, eax

.end:
	inc eax
	FrameEnd
	ret 20

DefFunc _WaitForVBlankD3D
	FrameBegin 0

	invoke_dll_stdcall MonitorFromWindow, [_hWnd], MONITOR_DEFAULTTONEAREST
	invoke_cdecl _AVLSearch, [_DXGIOutputs], eax
	test eax, eax
	jz .not_found

	invoke_com [eax + AVLBST_Node.userdata], IDXGIOutputVtbl.WaitForVBlank
	jmp .end
.not_found:
	invoke_cdecl _FakeWaitForVBlank

.end:
	FrameEnd
	ret

DefFunc _WaitForVBlankDDraw
	FrameBegin 0

	invoke_dll_stdcall MonitorFromWindow, [_hWnd], MONITOR_DEFAULTTONEAREST
	invoke_cdecl _AVLSearch, [_DDrawObjects], eax
	test eax, eax
	jz .not_found

	invoke_com [eax + AVLBST_Node.userdata], IDirectDraw.WaitForVerticalBlank, DDWAITVB_BLOCKBEGIN, NULL
	jmp .end
.not_found:
	invoke_cdecl _FakeWaitForVBlank

.end:
	FrameEnd
	ret

DefFunc _VBlankDeInit
	FrameBegin 0
	invoke_cdecl _AVLClear, _DXGIOutputs
	invoke_cdecl _AVLClear, _DDrawObjects
	FrameEnd
	ret

DefFunc _FakeWaitForVBlank
	FrameBegin 0

	cmp dword[.prompted], 0
	jnz .end

	debug_msg `Cannot provide accurate vertical synchronization for the current screen.`

	inc [.prompted]
.end:
	invoke_dll_stdcall Sleep, 1
	FrameEnd
	ret

segment .bss
.prompted resd 1
