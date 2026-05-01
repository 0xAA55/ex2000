%ifndef _MATRIX_INC_
%define _MATRIX_INC_ 1

; Must be 16-byte aligned
struc Vector
	.x resd 1
	.y resd 1
	.z resd 1
	.w resd 1
	.size equ $ - .x
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
	.size equ $ - .x
endstruc



%ifndef MATRIX_ASM
extern _ZeroVector

; void VectorCross(Vector *out, Vector *v1, Vector *v2);
extern _VectorCross

; void VectorLength(float *out, Vector *v, int dim);
extern _VectorLength

; void VectorNormal(Vector *out, Vector *v, int dim);
extern _VectorNormal

; void VectorMultMatrix(Vector *out, Vector *v, Matrix *m);
extern _VectorMultMatrix

; void VectorMultMatrixTransposed(Vector *out, Vector *v, Matrix *m);
extern _VectorMultMatrixTransposed

; void MatrixIdentity(Matrix *out);
extern _MatrixIdentity

; void MatrixRotationEuler(Matrix *out, float yaw, float pitch, float roll);
extern _MatrixRotationEuler

; void MatrixLookAt(Matrix *out, Vector *eye, Vector *dir, Vector *up);
extern _MatrixLookAt

; void MatrixTranspose(Matrix *out, Matrix *m);
extern _MatrixTranspose

; void MatrixMultiply(Matrix *out, Matrix *l, Matrix *r);
extern _MatrixMultiply

; void MatrixMultiplyTransposed(Matrix *out, Matrix *l, Matrix *r);
extern _MatrixMultiplyTransposed

%endif


%endif
