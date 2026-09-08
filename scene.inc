%ifndef _SCENE_INC_
%define _SCENE_INC_

%macro InstSSTextures 0
	.NormalDist resd 1
	.Diffuse resd 1
	.Specular resd 1
	.Emissive resd 1
	.Scatter resd 1
	.size equ $ - .NormalDist
	.NumTextures equ .size / 4
%endmacro

struc SSTextures
	InstSSTextures
endstruc

%macro InstDrawProgressProgramLocations 0
	.Progress resd 1
%endmacro

struc DrawProgressProgramLocations
	InstDrawProgressProgramLocations
endstruc

%macro InstSSOutputLocations 0
	.OutNormalDist resd 1
	.OutDiffuse resd 1
	.OutSpecular resd 1
	.OutEmissive resd 1
	.OutScatter resd 1
%endmacro

struc SSOutputLocations
	InstSSOutputLocations
endstruc

%macro InstRayUniformLocations 0
	.CameraMatrix resd 1
	.ProjMatrix resd 1
	.CameraPosition resd 1
	.RenderDistance resd 1
%endmacro

struc RayUniformLocations
	InstRayUniformLocations
endstruc

%macro InstSkyUniformLocations 0
	.SunPosition resd 1
	.Time resd 1
	.CloudTex resd 1
	.CloudHeight resd 1
	.CloudSize resd 1
	.SunGlowExponent resd 1
	.SunCenterBrightness resd 1
	.SunColor resd 1
	.FogColor resd 1
	.SkyColor resd 1
	.AmbColor resd 1
%endmacro

struc SkyUniformLocations
	InstSkyUniformLocations
endstruc

%macro InstTerrainUniformLocations 0
	.TerrainAltitudeMap resd 1
	.TerrainConeMap resd 1
	.TerrainHeight resd 1
	.TerrainScaling resd 1
%endmacro

struc TerrainUniformLocations
	InstTerrainUniformLocations
endstruc

%macro InstDrawTerrainProgramLocations 0
	.TextureQuality resd 1
.first_ray:
	InstRayUniformLocations
.first_terrain:
	InstTerrainUniformLocations
.first_sky:
	InstSkyUniformLocations
.first_output:
	InstSSOutputLocations
%endmacro

struc DrawTerrainProgramLocations
	InstDrawTerrainProgramLocations
endstruc

%macro InstDrawWaterProgramLocations 0
	.TextureQuality resd 1
	.SeaLevel resd 1
	.SeaWaveHeight resd 1
	.SeaWaveSize resd 1
	.SSTerrainNormalDepth resd 1
.first_ray:
	InstRayUniformLocations
.first_terrain:
	InstTerrainUniformLocations
.first_sky:
	InstSkyUniformLocations
.first_output:
	InstSSOutputLocations
%endmacro

struc DrawWaterProgramLocations
	InstDrawWaterProgramLocations
endstruc

%macro InstDrawCompositeProgramLocations 0
	.TextureQuality resd 1
	.TexSSNormalDist resd 1
	.TexSSDiffuse resd 1
	.TexSSSpecular resd 1
	.TexSSEmissive resd 1
	.TexSSScatter resd 1
.first_ray:
	InstRayUniformLocations
.first_sky:
	InstSkyUniformLocations
	.OutColor resd 1
%endmacro

struc DrawCompositeProgramLocations
	InstDrawCompositeProgramLocations
endstruc

%macro InstDrawBlurProgramLocations 0
	.HDRTexture resd 1
	.OutColor resd 1
%endmacro

struc DrawBlurProgramLocations
	InstDrawBlurProgramLocations
endstruc

%macro InstDrawHDR2LDRProgramLocations 0
	.BlurTexture resd 1
	.HDRTexture resd 1
	.OutColor resd 1
%endmacro

struc DrawHDR2LDRProgramLocations
	InstDrawHDR2LDRProgramLocations
endstruc

%macro InstSceneStatus 0
.scene_status_start:
	.CameraMatrix resd 16
	.CameraViewMatrix resd 16
	.ViewProjMatrix resd 16
	.ProjectionMatrix resd 16
	.SunPosition resd 4
	.VPWidthHalf resd 1 ;integer
	.VPHeightHalf resd 1 ;integer
	.VPWidthLow resd 1 ;integer
	.VPHeightLow resd 1 ;integer
	.FovY resd 1 ;float
	.Aspect resd 1 ;float
	.hWnd resd 1 ;HWND
	._pad1: alignb 16
.scene_status_base:
	.VPWidth resd 1 ;integer
	.VPHeight resd 1 ;integer
	.ZNear resd 1 ;float
	.ZFar resd 1 ;float
	.FovDegree resd 1 ;float
	.RenderDistance resd 1 ;float
	.TerrainMapHeight resd 1 ;float
	.TerrainMapScaling resd 1 ;float
	.CloudHeight resd 1
	.CloudSize resd 1
	.SunGlowExponent resd 1
	.SunCenterBrightness resd 1
	.CameraPos resd 4
	.SunColor resd 4
	.FogColor resd 4
	.SkyColor resd 4
	.AmbColor resd 4
	.SeaLevel resd 1
	.DayTime resd 1 ;float
	.CurTextureQuality resd 1
	.CameraYaw resd 1 ;float
	.CameraPitch resd 1 ;float
	.CameraRoll resd 1 ;float
	.TimeValueF resq 1 ;float
	.TimeValueD resd 1 ;double
	.DeltaTimeF resd 1 ;float
	.DeltaTimeD resq 1 ;double
	.RefTerrainTexture resd 1
	.RefTerrainConeTexture resd 1
	.RefNoiseTexture resd 1
	._pad2: alignb 16
%endmacro

struc SceneStatus
	InstSceneStatus
	.size equ $ - SceneStatus
endstruc

%endif
