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

%macro InstDrawTerrainProgramLocations 0
	.CameraMatrix resd 1
	.CameraPosition resd 1
	.ProjMatrix resd 1
	.RenderDistance resd 1
	.TerrainAltitudeMap resd 1
	.TerrainConeMap resd 1
	.TerrainHeight resd 1
	.TerrainScaling resd 1
	.TextureQuality resd 1
.first_output:
	.OutNormalDist resd 1
	.OutDiffuse resd 1
	.OutSpecular resd 1
	.OutEmissive resd 1
	.OutScatter resd 1
%endmacro

struc DrawTerrainProgramLocations
	InstDrawTerrainProgramLocations
endstruc

%macro InstDrawWaterProgramLocations 0
	.CameraMatrix resd 1
	.CameraPosition resd 1
	.ProjMatrix resd 1
	.Time resd 1
	.RenderDistance resd 1
	.TerrainAltitudeMap resd 1
	.TerrainConeMap resd 1
	.TerrainHeight resd 1
	.TerrainScaling resd 1
	.TextureQuality resd 1
	.SeaLevel resd 1
	.SeaWaveHeight resd 1
	.SeaWaveSize resd 1
	.SSTerrainNormalDepth resd 1
.first_output:
	.OutNormalDist resd 1
	.OutDiffuse resd 1
	.OutSpecular resd 1
	.OutEmissive resd 1
	.OutScatter resd 1
%endmacro

struc DrawWaterProgramLocations
	InstDrawWaterProgramLocations
endstruc

%macro InstDrawCompositeProgramLocations 0
	.CameraMatrix resd 1
	.CameraPosition resd 1
	.ProjMatrix resd 1
	.SunPosition resd 1
	.RenderDistance resd 1
	.TexSSNormalDist resd 1
	.TexSSDiffuse resd 1
	.TexSSSpecular resd 1
	.TexSSEmissive resd 1
	.TexSSScatter resd 1
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

%endif
