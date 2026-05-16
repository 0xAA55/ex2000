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

%ifndef MATRIX_ASM
extern _Pi_P
extern _Pi_N
extern _2Pi
extern _2.0f
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
extern _ZeroVector
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

; void DestroyFloatMap(FloatMap *map);
extern _DestroyFloatMap

; float SmootherStep(float x);
extern _SmootherStep

; FloatMap *CreatePerlinMap2D(int border_len);
extern _CreatePerlinMap2D

; float *GetXYFloatMap(int x, int y, FloatMap *map);
extern _GetXYFloatMap

; FloatMap *ConvertPerlinMapToAltitude(int ratio, float amplitude, FloatMap *map);
extern _ConvertPerlinMapToAltitude

; FloatMap *GenPerlinAltitude(int perlin_border_len, int ratio, float amplitude);
extern _GenPerlinAltitude

; void AccumulateAltitude(FloatMap *accum_to, FloatMap *src);
extern _AccumulateAltitude

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

; FloatMap *FloatMapKMapGen(FloatMap *src);
extern _FloatMapKMapGen
%endif


%endif
