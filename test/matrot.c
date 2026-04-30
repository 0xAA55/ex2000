#include <math.h>

typedef struct Vector_s
{
	float x, y, z, w;
}Vector_t, *Vector_p;

typedef struct Matrix_s
{
	Vector_t x, y, z, w;
}Matrix_t, *Matrix_p;

static void MatrixItentity(Matrix_p out)
{
	*out = (Matrix_t){
		{1, 0, 0, 0},
		{0, 1, 0, 0},
		{0, 0, 1, 0},
		{0, 0, 0, 1},
	};
}

static void MatrixRotationX(Matrix_p out, float angle)
{
	float ca = (float)cos(angle);
	float sa = (float)sin(angle);
	*out = (Matrix_t){
		{1, 0, 0, 0},
		{0, ca, sa, 0},
		{0, -sa, ca, 0},
		{0, 0, 0, 1},
	};
}

static void MatrixRotationY(Matrix_p out, float angle)
{
	float ca = (float)cos(angle);
	float sa = (float)sin(angle);
	*out = (Matrix_t){
		{ca, 0, -sa, 0},
		{0, 1, 0, 0},
		{sa, 0, ca, 0},
		{0, 0, 0, 1},
	};
}

static void MatrixRotationZ(Matrix_p out, float angle)
{
	float ca = (float)cos(angle);
	float sa = (float)sin(angle);
	*out = (Matrix_t){
		{ca, sa, 0, 0},
		{-sa, ca, 0, 0},
		{0, 0, 1, 0},
		{0, 0, 0, 1},
	};
}

static void VectorMultMatrix(Vector_p out, Vector_p v, Matrix_p m)
{
	*out = (Vector_t){
		v->x * m->x.x + v->y * m->y.x + v->z * m->z.x + v->w * m->w.x,
		v->x * m->x.y + v->y * m->y.y + v->z * m->z.y + v->w * m->w.y,
		v->x * m->x.z + v->y * m->y.z + v->z * m->z.z + v->w * m->w.z,
		v->x * m->x.w + v->y * m->y.w + v->z * m->z.w + v->w * m->w.w
	};
}

static void MatrixMultMatrix(Matrix_p out, Matrix_p l, Matrix_p r)
{
	Vector_t ox, oy, oz, ow;
	VectorMultMatrix(&ox, &l->x, r);
	VectorMultMatrix(&oy, &l->y, r);
	VectorMultMatrix(&oz, &l->z, r);
	VectorMultMatrix(&ow, &l->w, r);
	*out = (Matrix_t){ox, oy, oz, ow};
}

void MatrixRotationEuler(Matrix_p out, float yaw, float pitch, float roll)
{
	Matrix_t ym, pm, rm, rpm;
	MatrixRotationZ(&rm, roll);
	MatrixRotationX(&pm, pitch);
	MatrixRotationY(&ym, yaw);
	MatrixMultMatrix(&rpm, &rm, &pm);
	MatrixMultMatrix(out, &ym, &rpm);
}
