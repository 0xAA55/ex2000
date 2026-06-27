%include "loaddll.inc"
%include "vblank.inc"
%include "avlbst.inc"

extern _hWnd
extern _hDC

def_dll DXGI, "dxgi.dll"
def_dll_func CreateDXGIFactory

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

segment .rdata
extern _IID_IDXGIFactory
_IID_IDXGIFactory:
	dd 0x7b7166ec
	dw 0x21c7, 0x44ae
	db 0xb2, 0x1a, 0xc9, 0xae, 0x32, 0x1a, 0xe3, 0x69

segment .data
extern _addr_of_WaitForVBlank
_addr_of_WaitForVBlank dd _FakeWaitForVBlank

segment .bss
extern _DXGIOutputs
_DXGIOutputs resd 1

DefFunc _VBlankInit
	FrameBegin 8 + DXGI_OUTPUT_DESC.size / 4, ebx, esi, edi
	AssignVars DXGIFactory, D3D11Device, DXGIDevice, DXGIOutput, DXGIAdapter, HMonitor, Dummy, DXGIOutputDesc

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
	mov eax, [ebx + DXGI_OUTPUT_DESC.HMonitor]
	mov HMonitor, eax ; Use `Dummy` as `NUL` for `strcmp()` inside `AVLInsert()`
	invoke_cdecl _AVLInsert, _DXGIOutputs, &HMonitor, DXGIOutput, _ReleaseComObj
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
	; Fallback to `_FakeWaitForVBlank`

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

DefFunc _WaitForVBlankD3D
	FrameBegin 2
	AssignVars HMonitor, Dummy

	xor eax, eax
	lea edi, HMonitor
	stosd
	stosd

	invoke_dll_stdcall MonitorFromWindow, [_hWnd], MONITOR_DEFAULTTONEAREST
	mov HMonitor, eax ; Use `Dummy` as `NUL` for `strcmp()` inside `AVLInsert()`
	invoke_cdecl _AVLSearch, [_DXGIOutputs], &HMonitor
	test eax, eax
	jz .not_found

	invoke_com [eax + AVLBST_Node.userdata], IDXGIOutputVtbl.WaitForVBlank
	jmp .end
.not_found:
	invoke_cdecl _FakeWaitForVBlank

.end:
	FrameEnd
	ret

DefFunc _VBlankDeInit
	FrameBegin 0
	invoke_cdecl _AVLClear, _DXGIOutputs
	FrameEnd
	ret

DefFunc _FakeWaitForVBlank
	FrameBegin 0
	invoke_dll_stdcall Sleep, 100 ; Debug, will change to 1
	FrameEnd
	ret
