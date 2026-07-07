%include "loaddll.inc"
%include "vblank.inc"
%include "avlbst.inc"
%include "timer.inc"

extern _hWnd
extern _hDC

def_dll DXGI, "dxgi.dll"
def_dll_func CreateDXGIFactory
def_dll_func DXGIDisableVBlankVirtualization

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

struc MonitorData
	.IDXGIOutput resd 1
	.IDirectDraw resd 1
	.IsVRR resd 1
	.RefreshRate resd 1
	.RefreshIntervalMs resd 1
	.size equ $ - MonitorData
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
extern _MonitorsData
_MonitorsData resd 1

extern _VBlankTimer
_VBlankTimer:
	InstTimer

extern _VBlankTimeUsedMs
_VBlankTimeUsedMs resd 1

extern _LastFrameRenderTimeMs
_LastFrameRenderTimeMs resd 1

extern _FrameRenderDelayMs
_FrameRenderDelayMs resd 1

extern _VBlankFrameStartTime
_VBlankFrameStartTime resq 1

DefFunc _FreeMonitorData
	FrameBegin 0, ebx

	mov ebx, Param(0)
	invoke_cdecl _SafeRelease, &[ebx + MonitorData.IDXGIOutput]
	invoke_cdecl _SafeRelease, &[ebx + MonitorData.IDirectDraw]
	invoke_cdecl _free, ebx

	FrameEnd
	ret

DefFunc _VBlankInit
	FrameBegin 6 + SizedVar(DXGI_OUTPUT_DESC.size), ebx, esi, edi
	AssignVars DXGIFactory, D3D11Device, DXGIDevice, DXGIOutput, DXGIAdapter, DXGIOutputDesc

	invoke_cdecl _InitTimer, _VBlankTimer

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

	load_dll_func DXGI, DXGIDisableVBlankVirtualization
	test eax, eax
	jz .after_disable_virtvblank

	invoke_dll_stdcall DXGIDisableVBlankVirtualization

.after_disable_virtvblank:
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

	invoke_cdecl _calloc, 1, MonitorData.size
	mov ecx, DXGIOutput
	mov [eax + MonitorData.IDXGIOutput], ecx

	invoke_cdecl _AVLInsert, _MonitorsData, [ebx + DXGI_OUTPUT_DESC.HMonitor], eax, _FreeMonitorData, _AVLOps_Integer
	inc edi
	jmp .loop_enum_outputs_dxgi

.end_enum_outputs_dxgi:
	invoke_cdecl _SafeRelease, &DXGIAdapter
	inc esi
	jmp .loop_enum_monitors_by_dxgi

.end_enum_adapeters_dxgi:
	invoke_cdecl _SafeRelease, &DXGIFactory
	xor eax, eax
	inc eax
	jmp .finish

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

	xor eax, eax
	inc eax

.finish:
	invoke_cdecl _AVLIterate, [_MonitorsData], NULL, _SetupMonitorDataProc

.no_ddraw:

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

	invoke_cdecl _calloc, 1, MonitorData.size
	mov ecx, DDrawObj
	mov [eax + MonitorData.IDirectDraw], ecx

	invoke_cdecl _AVLInsert, _MonitorsData, Param(4), eax, _FreeMonitorData, _AVLOps_Integer
	xor eax, eax
	jmp .end

.fail:
	xor eax, eax

.end:
	inc eax
	FrameEnd
	ret 20

DefFunc _SetupMonitorDataProc
	FrameBegin SizedVar(MONITORINFOEXW.size) + SizedVar(DEVMODEW.size), ebx, edi
	AssignSizedVar _MonitorInfoExW, MONITORINFOEXW.size
	AssignSizedVar _DevModeW, DEVMODEW.size

	xor eax, eax
	lea edi, _MonitorInfoExW
	mov ecx, Frame_NumLocals
	rep stosd

	mov ebx, Param(1)
	mov byte[_MonitorInfoExW_Addr + MONITORINFOEXW.cbSize], MONITORINFOEXW.size
	mov byte[_DevModeW_Addr + DEVMODEW.dmSize], DEVMODEW.size
	mov byte[ebx + MonitorData.RefreshRate], 60
	mov byte[ebx + MonitorData.RefreshIntervalMs], 16

	invoke_dll_stdcall GetMonitorInfoW, Param(0), &_MonitorInfoExW
	test eax, eax
	jz .end
	invoke_dll_stdcall EnumDisplaySettingsW, &[_MonitorInfoExW_Addr + MONITORINFOEXW.szDevice], ENUM_CURRENT_SETTINGS, &_DevModeW
	test eax, eax
	jz .end

	mov eax, 1000
	xor edx, edx
	mov ecx, [_DevModeW_Addr + DEVMODEW.dmDisplayFrequency]
	div ecx
	mov [ebx + MonitorData.RefreshRate], ecx
	mov [ebx + MonitorData.RefreshIntervalMs], eax

.end:
	FrameEnd
	ret
	%undef _MonitorInfoExW
	%undef _MonitorInfoExW_Addr
	%undef _DevModeW
	%undef _DevModeW_Addr

DefFunc _VBlankDeInit
	FrameBegin 0
	invoke_cdecl _AVLClear, _MonitorsData
	FrameEnd
	ret

DefFunc _VBlankReInit
	FrameBegin 0
	invoke_cdecl _VBlankInit
	invoke_cdecl _VBlankDeInit
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
	xor eax, eax
	FrameEnd
	ret

segment .bss
.prompted resd 1

DefFunc _WaitForVBlank
	FrameBegin 4, ebx
	AssignVars _VBlankStartTimeL, _VBlankStartTimeH, _NewFrameStartTimeL, _NewFrameStartTimeH

	invoke_dll_stdcall MonitorFromWindow, [_hWnd], MONITOR_DEFAULTTONEAREST
	invoke_cdecl _AVLSearch, [_MonitorsData], eax
	test eax, eax
	jz .not_found
	mov ebx, [eax + AVLBST_Node.userdata]

	invoke_cdecl _UpdateTimer, _VBlankTimer
	fst qword _VBlankStartTimeL
	fsub qword [_VBlankFrameStartTime]
	fimul word [_WThousand]
	fistp dword [_LastFrameRenderTimeMs]

	mov eax, [ebx + MonitorData.RefreshIntervalMs]
	cmp [_LastFrameRenderTimeMs], eax
	jae .overloaded

.w_dxgi:
	mov eax, [ebx + MonitorData.IDXGIOutput]
	test eax, eax
	jz .w_ddraw
	invoke_com eax, IDXGIOutputVtbl.WaitForVBlank
	jmp .w_after
.w_ddraw:
	mov eax, [ebx + MonitorData.IDirectDraw]
	test eax, eax
	jz .not_found
	invoke_com eax, IDirectDraw.WaitForVerticalBlank, DDWAITVB_BLOCKEND, NULL
.w_after:
	cmp eax, 0
	jl .not_found

	invoke_cdecl _UpdateTimer, _VBlankTimer
	fst qword _NewFrameStartTimeL
	fsub qword _VBlankStartTimeL
	fimul word [_WThousand]
	fistp dword [_VBlankTimeUsedMs]

	mov eax, [ebx + MonitorData.RefreshIntervalMs]
	sub eax, [_LastFrameRenderTimeMs]
	jbe .no_delay
	dec eax
	mov [_FrameRenderDelayMs], eax
	invoke_cdecl _HybridWaitMs, eax

	invoke_cdecl _UpdateTimer, _VBlankTimer
	fstp qword [_VBlankFrameStartTime]
	jmp .end
.no_delay:
	movq xmm0, _NewFrameStartTimeL
	movq [_VBlankFrameStartTime], xmm0
	jmp .end
.overloaded:
	movq xmm0, _VBlankStartTimeL
	movq [_VBlankFrameStartTime], xmm0
	xor eax, eax
	mov [_VBlankTimeUsedMs], eax
	mov [_FrameRenderDelayMs], eax

.not_found:
.end:
	FrameEnd
	ret
	%undef _VBlankStartTimeL
	%undef _VBlankStartTimeH
	%undef _NewFrameStartTimeL
	%undef _NewFrameStartTimeH
