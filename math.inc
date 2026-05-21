%ifndef _MATRIX_INC_
%define _MATRIX_INC_ 1

%include "loaddll.inc"

; Must be 16-byte aligned
struc Vector
	.x resd 1
	.y resd 1
	.z resd 1
	.w resd 1
	.size equ $ - Vector
endstruc

; Must be 16-byte aligned
struc Matrix
.x:
	.xx resd 1
	.xy resd 1
	.xz resd 1
	.xw resd 1
.y:
	.yx resd 1
	.yy resd 1
	.yz resd 1
	.yw resd 1
.z:
	.zx resd 1
	.zy resd 1
	.zz resd 1
	.zw resd 1
.w:
	.wx resd 1
	.wy resd 1
	.wz resd 1
	.ww resd 1
	.size equ $ - Matrix
endstruc

struc FloatMap
.data resd 1
.border_len resd 1
.num_pixels resd 1
.dims resd 1
.head_size equ $ - FloatMap
.row_ptr:
endstruc

struc FMDataCmn
.dst_map resd 1
.src_map resd 1
.userdata resd 1
.size equ $ - FMDataCmn
endstruc

extern _Pi_P
extern _Pi_N
extern _2Pi
extern _2.0f
extern _M1.0f
extern _W6
extern _W10
extern _W15
extern _HaveSSE3
extern _HaveSSE41
extern _FMAX
extern _FMIN
extern _F0001
extern _FPMPM
extern _FMMMM
extern _FMPMP
extern _F1111
extern _F2222
extern _F3333
extern _F4444
extern _F8888
extern _FCCCC
extern _FHHHH
extern _B0123
extern _I0123
extern _F0123
extern _UF0F0
extern _UF000
extern _UFF00
extern _UFFF0
extern _UFFFF
extern _U0FFF
extern _U00FF
extern _U000F
extern _ZeroVector
extern _FP5P5P5P5
extern _point_001_vector
extern _IdentityMatrix

; void MathInit();
extern _MathInit

; int128_t *CreateSeedVector()
extern _CreateSeedVector

; void DestroySeedVector(int128_t *sv)
extern _DestroySeedVector

; void VectorCross(Vector *out, Vector *v1, Vector *v2);
extern _VectorCross

; void VectorLength(float *out, Vector *v, int dim);
extern _VectorLength

; void _VectorDot(float *out, Vector *v1, Vector *v2, int dim);
extern _VectorDot

; void VectorNormal(Vector *out, Vector *v, int dim);
extern _VectorNormal

; void VectorMultMatrix(Vector *out, Vector *v, Matrix *m);
extern _VectorMultMatrix

; void MatrixRotationEuler(Matrix *out, float yaw, float pitch, float roll);
extern _MatrixRotationEuler

; void MatrixTransformPositionEuler(Matrix *out, Vector *pos, float yaw, float pitch, float roll);
extern _MatrixTransformPositionEuler

; void MatrixViewEuler(Matrix *out, Vector *eye, float yaw, float pitch, float roll);
extern _MatrixViewEuler

; void MatrixProjection(Matrix *out, float fovy, float aspect, float zn, float zf);
extern _MatrixProjection

; void MatrixTranspose(Matrix *out, Matrix *m);
extern _MatrixTranspose

; void MatrixMultiply(Matrix *out, Matrix *l, Matrix *r);
extern _MatrixMultiply

; FloatMap *CreateFloatMap(int border_len, int dims);
extern _CreateFloatMap

; FloatMap *DuplicateFloatMap(FloatMap *src);
extern _DuplicateFloatMap

; void DestroyFloatMap(FloatMap *map);
extern _DestroyFloatMap

; FloatMap *WarpFloatMap(FloatMap *src, int x, int y);
extern _WarpFloatMap

; float SmootherStep(float x);
extern _SmootherStep

; FloatMap *CreatePerlinMap2D(int border_len);
extern _CreatePerlinMap2D

; float *GetXYFloatMap(int x, int y, FloatMap *map);
extern _GetXYFloatMap

; FloatMap *ConvertPerlinMapToAltitude(int ratio, float amplitude, FloatMap *src);
extern _ConvertPerlinMapToAltitude

; FloatMap *GenPerlinAltitude(int perlin_border_len, int ratio, float amplitude);
extern _GenPerlinAltitude

; void AccumulateFloatMap(FloatMap *accum_to, FloatMap *src);
extern _AccumulateFloatMap

; void MultiplyFloatMap(FloatMap *mult_to, FloatMap *src);
extern _MultiplyFloatMap

; void FloatMapApplyGain(FloatMap *map, float gain);
extern _FloatMapApplyGain

; FloatMap *GenMultiLayerPerlinAltitude(int size, float amplitude, int num_layers);
extern _GenMultiLayerPerlinAltitude

; typedef struct radmap_s
; {
; 	size_t items;
; 	struct item
; 	{
;  		int16_t x, y;
;  	}[0];
; } radmap_t, *radmap_p;
; radmap_p GenRadiusMap(int16_t radius);
; // The returned pointer should be `free()`d.
extern _GenRadiusMap

; FloatMap *GenDistanceMap(int size);
extern _GenDistanceMap

; FloatMap *FloatMapMTPool(FloatMap *src, int num_workers, void *userdata, int(*work_proc)(FM1DDataCmn *param, size_t index), size_t stack_size);
extern _FloatMapMTPool

; FloatMap *FloatMapGaussianBlur(FloatMap *src, int16_t blur_radius);
extern _FloatMapGaussianBlur

; float FloatMapGetMaxValue(FloatMap *src);
extern _FloatMapGetMaxValue

; FloatMap *FloatMapKMapGen(FloatMap *src);
extern _FloatMapKMapGen

struc SimpleVertex
.position:
	.x resd 1
	.y resd 1
	.z resd 1
.normal:
	.nx resd 1
	.ny resd 1
	.nz resd 1
.uv:
	.u resd 1
	.v resd 1
.size equ $ - SimpleVertex
endstruc
struc SimpleMesh ; All data of a `SimpleMesh` must be `malloc()` once
	.vertices resd 1
	.indices resd 1
	.num_vertices resd 1
	.num_indices resd 1
	.size equ $ - SimpleMesh
endstruc
; SimpleMesh *AltitudeToTerrain(FloatMap *src, float height_mod, float size_mod);
extern _AltitudeToTerrain

%endif
