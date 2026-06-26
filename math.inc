%ifndef _MATRIX_INC_
%define _MATRIX_INC_ 1

%include "loaddll.inc"

%define FLT_MAX 0x7F7FFFFF
%define FLT_MIN 0xFF7FFFFF

%define _MM_SHUFFLE(fp3,fp2,fp1,fp0) (((fp3) << 6) | ((fp2) << 4) | ((fp1) << 2) | ((fp0)))

%define _MM_CMP_EQ_    0x00
%define _MM_CMP_LT_    0x01
%define _MM_CMP_LE_    0x02
%define _MM_CMP_UNORD_ 0x03
%define _MM_CMP_NEQ_   0x04
%define _MM_CMP_GE_    0x05
%define _MM_CMP_GT_    0x06
%define _MM_CMP_ORD_   0x07

%define _MM_ROUND_NEAREST_ 0x00
%define _MM_ROUND_DOWN_    0x01
%define _MM_ROUND_UP_      0x02
%define _MM_ROUND_ZERO_    0x03

%macro InstVector 0
	.x resd 1
	.y resd 1
	.z resd 1
	.w resd 1
	.size equ $ - .x
%endmacro

%macro InstMatrix 0
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
	.size equ $ - .x
%endmacro

%macro InstDVector 0
	.x resq 1
	.y resq 1
	.z resq 1
	.w resq 1
	.size equ $ - .x
%endmacro

%macro InstDMatrix 0
.x:
	.xx resq 1
	.xy resq 1
	.xz resq 1
	.xw resq 1
.y:
	.yx resq 1
	.yy resq 1
	.yz resq 1
	.yw resq 1
.z:
	.zx resq 1
	.zy resq 1
	.zz resq 1
	.zw resq 1
.w:
	.wx resq 1
	.wy resq 1
	.wz resq 1
	.ww resq 1
	.size equ $ - .x
%endmacro

%macro InstBitMap 0
	.data resd 1
	.border_len resd 1
	.num_pixels resd 1
	.num_floats resd 1
	.num_bytes resd 1
	.bytes_per_pixel resd 1
	.dims resd 1
	.head_size equ $ - .data
	.row_ptr:
%endmacro

; Must be 16-byte aligned
struc Vector
	InstVector
endstruc

; Must be 16-byte aligned
struc Matrix
	InstMatrix
endstruc

struc DVector
	InstDVector
endstruc

struc DMatrix
	InstDMatrix
endstruc

struc BitMap
	InstBitMap
endstruc

extern _Pi_P
extern _Pi_N
extern _2Pi
extern _2.0f
extern _M1.0f
extern _M2.0f
extern _100.0f
extern _W6
extern _W10
extern _W15
extern _HaveSSE3
extern _HaveSSE41
extern _FMAX
extern _FMIN
extern _F1000
extern _F0100
extern _F0010
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

; void MathDeInit();
extern _MathDeInit

%ifdef _DEBUG
	; void FMatrix2DMatrix(DMatrix *out, Matrix *m);
	extern _FMatrix2DMatrix

	; void DebugMatrix(int x, int y, Matrix *m);
	extern _DebugMatrix
%endif

; void BatchAdd(float *dst, float *src, size_t num_floats);
extern _BatchAdd

; float BatchMax(float *data, size_t num_floats);
extern _BatchMax

struc CurvePoint
	.volume resd 1
	.weight resd 1
	.size equ $ - .volume
endstruc
; typedef struct CurvePoints_s
; {
; 	float volume;
; 	float weight;
; } CurvePoints_t, *CurvePoints_p;
; void BatchCurve(float *data, size_t num_data, CurvePoints_p curve, size_t num_curve_points);
extern _BatchCurve

; void CreateSeedVector(int128_t *)
extern _CreateSeedVector

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

; void MatrixEulerTranslated(Matrix *out, Vector *pos, float yaw, float pitch, float roll);
extern _MatrixEulerTranslated

; void MatrixViewEuler(Matrix *out, Vector *eye, float yaw, float pitch, float roll);
extern _MatrixViewEuler

; void MatrixProjection(Matrix *out, float fovy, float aspect, float zn, float zf);
extern _MatrixProjection

; void MatrixTranspose(Matrix *out, Matrix *m);
extern _MatrixTranspose

; void MatrixMultiply(Matrix *out, Matrix *l, Matrix *r);
extern _MatrixMultiply

; void MatrixMultiplyTo(Matrix *out_l, Matrix *r);
extern _MatrixMultiplyTo

; BitMap *CreateBitMap(int border_len, int dims);
extern _CreateBitMap

; BitMap *DuplicateBitMap(BitMap *src);
extern _DuplicateBitMap

; void DestroyBitMap(BitMap *map);
extern _DestroyBitMap

; void WarpBitMap(BitMap *dst, BitMap *src, int x, int y);
extern _WarpBitMap

; float SmootherStep(float x);
extern _SmootherStep

; BitMap *CreatePerlinMap2D(int border_len);
extern _CreatePerlinMap2D

; float *GetBitmapPixelAddress(int x, int y, BitMap *map);
extern _GetBitmapPixelAddress

; BitMap *ConvertPerlinMapToAltitude(int ratio, float amplitude, BitMap *src);
extern _ConvertPerlinMapToAltitude

; BitMap *GenPerlinAltitude(int perlin_border_len, int ratio, float amplitude);
extern _GenPerlinAltitude

; void AccumulateFloatMap(BitMap *accum_to, BitMap *src);
extern _AccumulateFloatMap

; void MultiplyFloatMap(BitMap *mult_to, BitMap *src);
extern _MultiplyFloatMap

; void FloatMapDivide(BitMap *dst, BitMap *src);
extern _FloatMapDivide

; void FloatMapApplyGain(BitMap *map, float gain);
extern _FloatMapApplyGain

; BitMap *GenMultiLayerPerlinAltitude(int size, float amplitude, int num_layers);
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

; BitMap *GenDistanceMap(int size);
extern _GenDistanceMap

%macro InstBMDataCmn 0
	.dst_map resd 1
	.src_map resd 1
	.userdata resd 1
	.size equ $ - .dst_map
%endmacro

struc BMDataCmn
	InstBMDataCmn
endstruc

; BitMap *BitMapMTPool(
; 	BitMap *src,
; 	int num_workers,
; 	void *userdata,
; 	int(*work_proc)(BMDataCmn *param, size_t index),
; 	size_t stack_size);
; // Each line of the bitmap were processed by `work_proc()`
; // The `index` param for `work_proc()` is the row number of the bitmap
extern _BitMapMTPool

; BitMap *FloatMapGaussianBlur(BitMap *src, int16_t blur_radius);
extern _FloatMapGaussianBlur

; float FloatMapGetMaxValue(BitMap *src);
extern _FloatMapGetMaxValue

; void FloatMapClamp(BitMap *map, float max, float min);
extern _FloatMapClamp

; void BitMapBlt(
; 	BitMap *dst,
; 	int dst_x, int dst_y,
; 	int dst_w, int dst_h,
; 	BitMap *src,
; 	int src_x, int src_y,
; 	void *userdata,
; 	void (*line_proc)(
; 		float *dst,
; 		const float *src,
; 		size_t num_pixels,
; 		void *userdata
; 	)
; );
extern _BitMapBlt

; void FloatMapCurve(BitMap *map, CurvePoints_p curve, size_t num_curve_points);
extern _FloatMapCurve

; BitMap *FloatMapDownScale(BitMap *map);
extern _FloatMapDownScale

; BitMap *GenKMapOfAltitudeMap(BitMap *map);
extern _GenKMapOfAltitudeMap

%macro InstSimpleVertex 0
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
%endmacro
struc SimpleVertex
	InstSimpleVertex
endstruc
struc SimpleMesh ; All data of a `SimpleMesh` must be `malloc()` once
	.vertices resd 1
	.indices resd 1
	.num_vertices resd 1
	.num_indices resd 1
	.size equ $ - SimpleMesh
endstruc
; SimpleMesh *AltitudeToTerrain(BitMap *src, float height_mod, float size_mod);
extern _AltitudeToTerrain

%endif
