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

%endif
