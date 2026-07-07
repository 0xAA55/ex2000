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
	.size equ $ - DXGI_OUTPUT_DESC
endstruc

struc DXGI_MODE_DESC
	.Width resd 1
	.Height resd 1
	.RefreshRate_Numerator resd 1
	.RefreshRate_Denominator resd 1
	.Format resd 1
	.ScanlineOrdering resd 1
	.Scaling resd 1
	.size equ $ - DXGI_MODE_DESC
endstruc

struc IDirectDrawVtbl
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
	.RefreshIntervalUs resd 1
	.size equ $ - MonitorData
endstruc

%define DXGI_FORMAT_UNKNOWN	                    0
%define DXGI_FORMAT_R32G32B32A32_TYPELESS       1
%define DXGI_FORMAT_R32G32B32A32_FLOAT          2
%define DXGI_FORMAT_R32G32B32A32_UINT           3
%define DXGI_FORMAT_R32G32B32A32_SINT           4
%define DXGI_FORMAT_R32G32B32_TYPELESS          5
%define DXGI_FORMAT_R32G32B32_FLOAT             6
%define DXGI_FORMAT_R32G32B32_UINT              7
%define DXGI_FORMAT_R32G32B32_SINT              8
%define DXGI_FORMAT_R16G16B16A16_TYPELESS       9
%define DXGI_FORMAT_R16G16B16A16_FLOAT          10
%define DXGI_FORMAT_R16G16B16A16_UNORM          11
%define DXGI_FORMAT_R16G16B16A16_UINT           12
%define DXGI_FORMAT_R16G16B16A16_SNORM          13
%define DXGI_FORMAT_R16G16B16A16_SINT           14
%define DXGI_FORMAT_R32G32_TYPELESS             15
%define DXGI_FORMAT_R32G32_FLOAT                16
%define DXGI_FORMAT_R32G32_UINT                 17
%define DXGI_FORMAT_R32G32_SINT                 18
%define DXGI_FORMAT_R32G8X24_TYPELESS           19
%define DXGI_FORMAT_D32_FLOAT_S8X24_UINT        20
%define DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS    21
%define DXGI_FORMAT_X32_TYPELESS_G8X24_UINT     22
%define DXGI_FORMAT_R10G10B10A2_TYPELESS        23
%define DXGI_FORMAT_R10G10B10A2_UNORM           24
%define DXGI_FORMAT_R10G10B10A2_UINT            25
%define DXGI_FORMAT_R11G11B10_FLOAT             26
%define DXGI_FORMAT_R8G8B8A8_TYPELESS           27
%define DXGI_FORMAT_R8G8B8A8_UNORM              28
%define DXGI_FORMAT_R8G8B8A8_UNORM_SRGB         29
%define DXGI_FORMAT_R8G8B8A8_UINT               30
%define DXGI_FORMAT_R8G8B8A8_SNORM              31
%define DXGI_FORMAT_R8G8B8A8_SINT               32
%define DXGI_FORMAT_R16G16_TYPELESS             33
%define DXGI_FORMAT_R16G16_FLOAT                34
%define DXGI_FORMAT_R16G16_UNORM                35
%define DXGI_FORMAT_R16G16_UINT                 36
%define DXGI_FORMAT_R16G16_SNORM                37
%define DXGI_FORMAT_R16G16_SINT                 38
%define DXGI_FORMAT_R32_TYPELESS                39
%define DXGI_FORMAT_D32_FLOAT                   40
%define DXGI_FORMAT_R32_FLOAT                   41
%define DXGI_FORMAT_R32_UINT                    42
%define DXGI_FORMAT_R32_SINT                    43
%define DXGI_FORMAT_R24G8_TYPELESS              44
%define DXGI_FORMAT_D24_UNORM_S8_UINT           45
%define DXGI_FORMAT_R24_UNORM_X8_TYPELESS       46
%define DXGI_FORMAT_X24_TYPELESS_G8_UINT        47
%define DXGI_FORMAT_R8G8_TYPELESS               48
%define DXGI_FORMAT_R8G8_UNORM                  49
%define DXGI_FORMAT_R8G8_UINT                   50
%define DXGI_FORMAT_R8G8_SNORM                  51
%define DXGI_FORMAT_R8G8_SINT                   52
%define DXGI_FORMAT_R16_TYPELESS                53
%define DXGI_FORMAT_R16_FLOAT                   54
%define DXGI_FORMAT_D16_UNORM                   55
%define DXGI_FORMAT_R16_UNORM                   56
%define DXGI_FORMAT_R16_UINT                    57
%define DXGI_FORMAT_R16_SNORM                   58
%define DXGI_FORMAT_R16_SINT                    59
%define DXGI_FORMAT_R8_TYPELESS                 60
%define DXGI_FORMAT_R8_UNORM                    61
%define DXGI_FORMAT_R8_UINT                     62
%define DXGI_FORMAT_R8_SNORM                    63
%define DXGI_FORMAT_R8_SINT                     64
%define DXGI_FORMAT_A8_UNORM                    65
%define DXGI_FORMAT_R1_UNORM                    66
%define DXGI_FORMAT_R9G9B9E5_SHAREDEXP          67
%define DXGI_FORMAT_R8G8_B8G8_UNORM             68
%define DXGI_FORMAT_G8R8_G8B8_UNORM             69
%define DXGI_FORMAT_BC1_TYPELESS                70
%define DXGI_FORMAT_BC1_UNORM                   71
%define DXGI_FORMAT_BC1_UNORM_SRGB              72
%define DXGI_FORMAT_BC2_TYPELESS                73
%define DXGI_FORMAT_BC2_UNORM                   74
%define DXGI_FORMAT_BC2_UNORM_SRGB              75
%define DXGI_FORMAT_BC3_TYPELESS                76
%define DXGI_FORMAT_BC3_UNORM                   77
%define DXGI_FORMAT_BC3_UNORM_SRGB              78
%define DXGI_FORMAT_BC4_TYPELESS                79
%define DXGI_FORMAT_BC4_UNORM                   80
%define DXGI_FORMAT_BC4_SNORM                   81
%define DXGI_FORMAT_BC5_TYPELESS                82
%define DXGI_FORMAT_BC5_UNORM                   83
%define DXGI_FORMAT_BC5_SNORM                   84
%define DXGI_FORMAT_B5G6R5_UNORM                85
%define DXGI_FORMAT_B5G5R5A1_UNORM              86
%define DXGI_FORMAT_B8G8R8A8_UNORM              87
%define DXGI_FORMAT_B8G8R8X8_UNORM              88
%define DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM  89
%define DXGI_FORMAT_B8G8R8A8_TYPELESS           90
%define DXGI_FORMAT_B8G8R8A8_UNORM_SRGB         91
%define DXGI_FORMAT_B8G8R8X8_TYPELESS           92
%define DXGI_FORMAT_B8G8R8X8_UNORM_SRGB         93
%define DXGI_FORMAT_BC6H_TYPELESS               94
%define DXGI_FORMAT_BC6H_UF16                   95
%define DXGI_FORMAT_BC6H_SF16                   96
%define DXGI_FORMAT_BC7_TYPELESS                97
%define DXGI_FORMAT_BC7_UNORM                   98
%define DXGI_FORMAT_BC7_UNORM_SRGB              99

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
extern _VBlankTimeUsedUs
_VBlankTimeUsedMs resd 1
_VBlankTimeUsedUs resd 1

extern _LastFrameRenderTimeMs
extern _LastFrameRenderTimeUs
_LastFrameRenderTimeMs resd 1
_LastFrameRenderTimeUs resd 1

extern _FrameRenderDelayMs
extern _FrameRenderDelayUs
_FrameRenderDelayMs resd 1
_FrameRenderDelayUs resd 1

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
	FrameBegin SizedVar(MONITORINFOEXW.size) + SizedVar(DEVMODEW.size) + SizedVar(DXGI_MODE_DESC.size) + SizedVar(DXGI_MODE_DESC.size), ebx, esi, edi
	AssignSizedVar _MonitorInfoExW, MONITORINFOEXW.size
	AssignSizedVar _DevModeW, DEVMODEW.size
	AssignSizedVar _DesiredMode, DXGI_MODE_DESC.size
	AssignSizedVar _ClosestMode, DXGI_MODE_DESC.size

	xor eax, eax
	mov ecx, Frame_NumLocals
	lea edi, &_MonitorInfoExW
	rep stosd

	mov ebx, Param(1)
	mov byte[_MonitorInfoExW_Addr + MONITORINFOEXW.cbSize], MONITORINFOEXW.size
	mov byte[_DevModeW_Addr + DEVMODEW.dmSize], DEVMODEW.size
	mov byte[ebx + MonitorData.RefreshRate], 60
	mov byte[ebx + MonitorData.RefreshIntervalMs], 16
	mov word[ebx + MonitorData.RefreshIntervalUs], 16666

	invoke_dll_stdcall GetMonitorInfoW, Param(0), &_MonitorInfoExW
	test eax, eax
	jz .end
	invoke_dll_stdcall EnumDisplaySettingsW, &[_MonitorInfoExW_Addr + MONITORINFOEXW.szDevice], ENUM_CURRENT_SETTINGS, &_DevModeW
	test eax, eax
	jz .end

	mov eax, [_MonitorInfoExW_Addr + MONITORINFOEXW.rcMonitor_r]
	mov ecx, [_MonitorInfoExW_Addr + MONITORINFOEXW.rcMonitor_b]
	sub eax, [_MonitorInfoExW_Addr + MONITORINFOEXW.rcMonitor_x]
	sub ecx, [_MonitorInfoExW_Addr + MONITORINFOEXW.rcMonitor_y]
	mov [_DesiredMode_Addr + DXGI_MODE_DESC.Width], eax
	mov [_DesiredMode_Addr + DXGI_MODE_DESC.Height], ecx
	mov byte[_DesiredMode_Addr + DXGI_MODE_DESC.Format], DXGI_FORMAT_R8G8B8A8_UNORM

	mov eax, 1000
	xor edx, edx
	mov ecx, [_DevModeW_Addr + DEVMODEW.dmDisplayFrequency]
	div ecx
	mov [ebx + MonitorData.RefreshRate], ecx
	mov [ebx + MonitorData.RefreshIntervalMs], eax
	mov ecx, 1000
	mul ecx
	mov [ebx + MonitorData.RefreshIntervalUs], eax

	mov esi, [ebx + MonitorData.IDXGIOutput]
	test esi, esi
	jz .end

	invoke_com esi, IDXGIOutputVtbl.FindClosestMatchingMode, &_DesiredMode, &_ClosestMode, NULL
	cmp eax, 0
	jl .end

	mov eax, [_ClosestMode_Addr + DXGI_MODE_DESC.RefreshRate_Denominator]
	mov ecx, [_ClosestMode_Addr + DXGI_MODE_DESC.RefreshRate_Numerator]
	mov edx, 1000000
	mul edx
	div ecx
	mov [ebx + MonitorData.RefreshIntervalUs], eax

.end:
	FrameEnd
	ret
	%undef _MonitorInfoExW
	%undef _MonitorInfoExW_Addr
	%undef _DevModeW
	%undef _DevModeW_Addr
	%undef _DesiredMode
	%undef _DesiredMode_Addr
	%undef _ClosestMode
	%undef _ClosestMode_Addr

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
	fist dword [_LastFrameRenderTimeMs]
	fimul word [_WThousand]
	fistp dword [_LastFrameRenderTimeUs]

	mov eax, [ebx + MonitorData.RefreshIntervalUs]
	cmp [_LastFrameRenderTimeUs], eax
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
	invoke_com eax, IDirectDrawVtbl.WaitForVerticalBlank, DDWAITVB_BLOCKEND, NULL
.w_after:
	cmp eax, 0
	jl .not_found

	invoke_cdecl _UpdateTimer, _VBlankTimer
	fst qword _NewFrameStartTimeL
	fsub qword _VBlankStartTimeL
	fimul word [_WThousand]
	fist dword [_VBlankTimeUsedMs]
	fimul word [_WThousand]
	fistp dword [_VBlankTimeUsedUs]

	mov eax, [ebx + MonitorData.RefreshIntervalUs]
	sub eax, [_LastFrameRenderTimeUs]
	jbe .no_delay
	sub eax, 1000
	jbe .no_delay
	mov [_FrameRenderDelayUs], eax
	invoke_cdecl _HybridWaitUs, eax, 0
	fild dword[_FrameRenderDelayUs]
	fidiv word[_WThousand]
	fist dword[_FrameRenderDelayMs]

	invoke_cdecl _UpdateTimer, _VBlankTimer
	fstp qword [_VBlankFrameStartTime]
	jmp .end
.no_delay:
	movq xmm0, _NewFrameStartTimeL
	movq [_VBlankFrameStartTime], xmm0
	jmp .no_delay_set_vars
.overloaded:
	movq xmm0, _VBlankStartTimeL
	movq [_VBlankFrameStartTime], xmm0
.no_delay_set_vars:
	xor eax, eax
	mov [_VBlankTimeUsedMs], eax
	mov [_VBlankTimeUsedUs], eax
	mov [_FrameRenderDelayMs], eax
	mov [_FrameRenderDelayUs], eax

.not_found:
.end:
	FrameEnd
	ret
	%undef _VBlankStartTimeL
	%undef _VBlankStartTimeH
	%undef _NewFrameStartTimeL
	%undef _NewFrameStartTimeH
