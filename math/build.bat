@echo off

if not exist out mkdir out

nasm -I.. -f win32 math.asm -o out\math.obj
nasm -I.. -f win32 seedvec.asm -o out\seedvec.obj
nasm -I.. -f win32 dmap.asm -o out\dmap.obj
nasm -I.. -f win32 floatmap.asm -o out\floatmap.obj
nasm -I.. -f win32 floatmapgain.asm -o out\floatmapgain.obj
nasm -I.. -f win32 floatmapgaussianblur.asm -o out\floatmapgaussianblur.obj
nasm -I.. -f win32 floatmapmax.asm -o out\floatmapmax.obj
nasm -I.. -f win32 floatmappool.asm -o out\floatmappool.obj
nasm -I.. -f win32 kmap.asm -o out\kmap.obj
nasm -I.. -f win32 mateuler.asm -o out\mateuler.obj
nasm -I.. -f win32 math.asm -o out\math.obj
nasm -I.. -f win32 matmult.asm -o out\matmult.obj
nasm -I.. -f win32 matproj.asm -o out\matproj.obj
nasm -I.. -f win32 matteuler.asm -o out\matteuler.obj
nasm -I.. -f win32 mattranspose.asm -o out\mattranspose.obj
nasm -I.. -f win32 matveuler.asm -o out\matveuler.obj
nasm -I.. -f win32 multfloatmap.asm -o out\multfloatmap.obj
nasm -I.. -f win32 perlin.asm -o out\perlin.obj
nasm -I.. -f win32 rmap.asm -o out\rmap.obj
nasm -I.. -f win32 seedvec.asm -o out\seedvec.obj
nasm -I.. -f win32 sstep.asm -o out\sstep.obj
nasm -I.. -f win32 veccross.asm -o out\veccross.obj
nasm -I.. -f win32 veclength.asm -o out\veclength.obj
nasm -I.. -f win32 vecmultmat.asm -o out\vecmultmat.obj
nasm -I.. -f win32 vecnormal.asm -o out\vecnormal.obj
nasm -I.. -f win32 warpfmap.asm -o out\warpfmap.obj

lib /NOLOGO /NODEFAULTLIB /MACHINE:IX86 /OUT:out\math.lib out\dmap.obj out\floatmap.obj out\floatmapgain.obj out\floatmapgaussianblur.obj out\floatmapmax.obj out\floatmappool.obj out\kmap.obj out\mateuler.obj out\math.obj out\matmult.obj out\matproj.obj out\matteuler.obj out\mattranspose.obj out\matveuler.obj out\multfloatmap.obj out\perlin.obj out\rmap.obj out\seedvec.obj out\sstep.obj out\veccross.obj out\veclength.obj out\vecmultmat.obj out\vecnormal.obj out\warpfmap.obj 