%include "loaddll.inc"
%include "vblank.inc"
%include "avlbst.inc"

extern _hWnd
extern _hDC

def_dll DXGI, "dxgi.dll"
def_dll_func CreateDXGIFactory

def_dll D3D11, "d3d11.dll"
def_dll_func D3D11CreateDevice

%define D3D11_SDK_VERSION 7

%define D3D_DRIVER_TYPE_UNKNOWN 0
%define D3D_DRIVER_TYPE_HARDWARE 1
%define D3D_DRIVER_TYPE_REFERENCE 2
%define D3D_DRIVER_TYPE_NULL 3
%define D3D_DRIVER_TYPE_SOFTWARE 4
%define D3D_DRIVER_TYPE_WARP 5

%define MAX_OUTPUTS_PER_ADAPTER 32
%define MAX_ADAPTERS 32

struc ID3D11DeviceVtbl
	.QueryInterface resd 1
	.AddRef resd 1
	.Release resd 1
endstruc

struc IDXGIDeviceVtbl
	.QueryInterface resd 1
	.AddRef resd 1
	.Release resd 1
	.SetPrivateData resd 1
	.SetPrivateDataInterface resd 1
	.GetPrivateData resd 1
	.GetParent resd 1
	.GetAdapter resd 1
	.CreateSurface resd 1
	.QueryResourceResidency resd 1
	.SetGPUThreadPriority resd 1
	.GetGPUThreadPriority resd 1
endstruc

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
	.Dummy resd 1 ;This dummy must be initialized to zero, so `.HMonitor` could be used as a string key because a string key needs a NUL char.
	.size equ $ - .DeviceName
endstruc

segment .rdata
extern _IID_IDXGIDevice
_IID_IDXGIDevice:
	dd 0x54ec77fa
	dw 0x1377, 0x44e6
	db 0x8c, 0x32, 0x88, 0xfd, 0x5f, 0x44, 0xc8, 0x4c

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
	FrameBegin 5 + DXGI_OUTPUT_DESC.size / 4, ebx, esi, edi
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
	jz .enum_monitors_by_d3d11

	load_dll_func DXGI, CreateDXGIFactory
	test eax, eax
	jz .enum_monitors_by_d3d11

	invoke_dll_stdcall CreateDXGIFactory, _IID_IDXGIFactory, &DXGIFactory
	cmp eax, 0
	jl .enum_monitors_by_d3d11

.loop_enum_monitors_by_dxgi:
	invoke_com DXGIFactory, IDXGIFactoryVtbl.EnumAdapters, esi, &DXGIAdapter
	cmp eax, 0
	jl .enum_next_adapter_dxgi

	xor edi, edi
.loop_enum_outputs_dxgi:
	invoke_com DXGIAdapter, IDXGIAdapterVtbl.EnumOutputs, edi, &DXGIOutput
	cmp eax, 0
	jl .enum_next_output_dxgi
	invoke_com DXGIOutput, IDXGIOutputVtbl.GetDesc, ebx
	invoke_cdecl _AVLInsert, _DXGIOutputs, &[ebx + DXGI_OUTPUT_DESC.HMonitor], DXGIOutput, _ReleaseComObj

.enum_next_output_dxgi:
	inc edi
	cmp edi, MAX_OUTPUTS_PER_ADAPTER
	jb .loop_enum_outputs_dxgi

	invoke_cdecl _SafeRelease, &DXGIAdapter

.enum_next_adapter_dxgi
	inc esi
	cmp esi, MAX_ADAPTERS
	jb .loop_enum_monitors_by_dxgi

	invoke_cdecl _SafeRelease, &DXGIFactory

	jmp .end_enum_outputs
.enum_monitors_by_d3d11:
	load_dll D3D11
	test eax, eax
	jz .no_d3d11

	load_dll_func D3D11, D3D11CreateDevice
	test eax, eax
	jz .no_d3d11

	invoke_dll_stdcall D3D11CreateDevice, NULL, D3D_DRIVER_TYPE_HARDWARE, NULL, 0, NULL, 0, D3D11_SDK_VERSION, &D3D11Device, NULL, NULL
	cmp eax, 0
	jl .no_d3d11

	invoke_com D3D11Device, ID3D11DeviceVtbl.QueryInterface, _IID_IDXGIDevice, &DXGIDevice
	cmp eax, 0
	jl .d3d11_initfail
	invoke_cdecl _SafeRelease, &D3D11Device

	invoke_com DXGIDevice, IDXGIDeviceVtbl.GetAdapter, &DXGIAdapter
	cmp eax, 0
	jl .d3d11_initfail
	invoke_cdecl _SafeRelease, &DXGIDevice

.loop_enum_outputs_d3d11:
	invoke_com DXGIAdapter, IDXGIAdapterVtbl.EnumOutputs, edi, &DXGIOutput
	cmp eax, 0
	jl .enum_next_output_d3d11
	invoke_com DXGIOutput, IDXGIOutputVtbl.GetDesc, ebx
	invoke_cdecl _AVLInsert, _DXGIOutputs, &[ebx + DXGI_OUTPUT_DESC.HMonitor], DXGIOutput, _ReleaseComObj

.enum_next_output_d3d11:
	inc edi
	cmp edi, MAX_OUTPUTS_PER_ADAPTER
	jb .loop_enum_outputs_d3d11

	invoke_cdecl _SafeRelease, &DXGIAdapter

.end_enum_outputs:
	mov dword[_addr_of_WaitForVBlank], _WaitForVBlankD3D

	xor eax, eax
	inc eax
	jmp .end
.d3d11_initfail:
	invoke_cdecl _VBlankD3DDeInit

.no_d3d11:
	; Fallback to `_FakeWaitForVBlank`

.end:
	FrameEnd
	ret
	%undef DXGIFactory
	%undef D3D11Device
	%undef DXGIDevice
	%undef DXGIOutput
	%undef DXGIAdapter
	%undef DXGIOutputDesc

DefFunc _WaitForVBlankD3D
	FrameBegin 2
	AssignVars HMonitor, Dummy

	xor eax, eax
	lea edi, HMonitor
	stosd
	stosd

	invoke_dll_stdcall MonitorFromWindow, [_hWnd], MONITOR_DEFAULTTONEAREST
	mov HMonitor, eax
	invoke_cdecl _AVLSearch, [_DXGIOutputs], &HMonitor
	test eax, eax
	jz .not_found

	invoke_com [eax + AVLBST_Node.userdata], IDXGIOutputVtbl.WaitForVBlank
	jmp .end
.not_found:
	invoke_dll_stdcall Sleep, 1

.end:
	FrameEnd
	ret

DefFunc _VBlankD3DDeInit
	FrameBegin 0, ebx

	invoke_cdecl _AVLClear, _DXGIOutputs

	FrameEnd
	ret

DefFunc _VBlankDeInit
	FrameBegin 0
	invoke_cdecl _VBlankD3DDeInit
	FrameEnd
	ret

DefFunc _FakeWaitForVBlank
	FrameBegin 0
	invoke_dll_stdcall Sleep, 1
	FrameEnd
	ret
