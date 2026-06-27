%include "loaddll.inc"
%include "vblank.inc"
%include "avlbst.inc"

extern _hWnd
extern _hDC

def_dll D3D11, "d3d11.dll"
def_dll_func D3D11CreateDevice

%define D3D11_SDK_VERSION 7

%define D3D_DRIVER_TYPE_UNKNOWN 0
%define D3D_DRIVER_TYPE_HARDWARE 1
%define D3D_DRIVER_TYPE_REFERENCE 2
%define D3D_DRIVER_TYPE_NULL 3
%define D3D_DRIVER_TYPE_SOFTWARE 4
%define D3D_DRIVER_TYPE_WARP 5

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
extern _IID_IDXGIDevice
_IID_IDXGIDevice:
	dd 0x54ec77fa
	dw 0x1377, 0x44e6
	db 0x8c, 0x32, 0x88, 0xfd, 0x5f, 0x44, 0xc8, 0x4c

segment .data
extern _addr_of_WaitForVBlank
_addr_of_WaitForVBlank dd _FakeWaitForVBlank

segment .bss
extern _D3D11Device
_D3D11Device resd 1

extern _DXGIDevice
_DXGIDevice resd 1

extern _DXGIAdapter
_DXGIAdapter resd 1

extern _DXGIOutputs
_DXGIOutputs resd 1

DefFunc _VBlankInit
	FrameBegin 1 + DXGI_OUTPUT_DESC.size / 4, ebx, esi, edi

	load_dll D3D11
	test eax, eax
	jz .no_d3d11

	load_dll_func D3D11, D3D11CreateDevice
	test eax, eax
	jz .no_d3d11

	invoke_dll_stdcall D3D11CreateDevice, NULL, D3D_DRIVER_TYPE_HARDWARE, NULL, 0, NULL, 0, D3D11_SDK_VERSION, _D3D11Device, NULL, NULL
	cmp eax, 0
	jl .no_d3d11

	invoke_com [_D3D11Device], ID3D11DeviceVtbl.QueryInterface, _IID_IDXGIDevice, _DXGIDevice
	cmp eax, 0
	jl .d3d11_initfail

	invoke_com [_DXGIDevice], IDXGIDeviceVtbl.GetAdapter, _DXGIAdapter
	cmp eax, 0
	jl .d3d11_initfail

	xor edi, edi
	lea esi, Variable(0)
	lea ebx, Variable(1)
.loop_enum_outputs:
	invoke_com [_DXGIAdapter], IDXGIAdapterVtbl.EnumOutputs, edi, esi
	cmp eax, 0
	jl .enum_next
	invoke_com [esi], IDXGIOutputVtbl.GetDesc, ebx
	invoke_cdecl _AVLInsert, _DXGIOutputs, [ebx + DXGI_OUTPUT_DESC.HMonitor], [esi], _ReleaseComObj

.enum_next:
	inc edi
	cmp edi, 64
	jae .end_enum_outputs
	jmp .loop_enum_outputs
.end_enum_outputs:
	mov dword[_addr_of_WaitForVBlank], _WaitForVBlankD3D

	xor eax, eax
	inc eax
	jmp .end
.d3d11_initfail:
	invoke_cdecl _VBlankD3DDeInit

.no_d3d11:
	


.end:
	FrameEnd
	ret

DefFunc _WaitForVBlankD3D
	FrameBegin 0

	invoke_dll_stdcall MonitorFromWindow, [_hWnd], MONITOR_DEFAULTTONEAREST
	invoke_cdecl _AVLSearch, [_DXGIOutputs], eax
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
	invoke_cdecl _SafeRelease, _DXGIAdapter
	invoke_cdecl _SafeRelease, _DXGIDevice
	invoke_cdecl _SafeRelease, _D3D11Device

	FrameEnd
	ret

DefFunc _VBlankDeInit
	FrameBegin 0
	invoke_cdecl _VBlankD3DDeInit
	FrameEnd
	ret

DefFunc _FakeWaitForVBlank
	FrameBegin 0
	FrameEnd
	ret
