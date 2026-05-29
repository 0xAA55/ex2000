OBJS=../out/math.obj ../out/seedvec.obj ../out/batchadd.obj ../out/batchmax.obj ../out/batchcurve.obj ../out/vecnormal.obj ../out/vecdot.obj ../out/veclength.obj ../out/veccross.obj ../out/vecmultmat.obj ../out/matmult.obj ../out/mateuler.obj ../out/matteuler.obj ../out/matveuler.obj ../out/mattranspose.obj ../out/matproj.obj ../out/floatmap.obj ../out/floatmapclamp.obj ../out/floatmapcurve.obj ../out/floatmapblt.obj ../out/floatmapdup.obj ../out/floatmapgain.obj ../out/floatmapmax.obj ../out/multfloatmap.obj ../out/warpfmap.obj ../out/floatmappool.obj ../out/rmap.obj ../out/dmap.obj ../out/floatmapgaussianblur.obj ../out/sstep.obj ../out/perlin.obj ../out/terrain.obj

%.inc:
	copy $@+

%.asm:
	copy $@+

all: ../out/math.lib
common.inc: ../math.inc ../pool.inc
dmap.asm: common.inc
batchadd.asm: common.inc
batchmax.asm: common.inc
batchcurve.asm: common.inc
floatmap.asm: common.inc
floatmapclamp.asm: common.inc
floatmapcurve.asm: common.inc
floatmapdup.asm: common.inc
floatmapblt.asm: common.inc
floatmapgain.asm: common.inc
floatmapgaussianblur.asm: common.inc
floatmapmax.asm: common.inc
floatmappool.asm: common.inc
makefile: common.inc
mateuler.asm: common.inc
math.asm: common.inc
matmult.asm: common.inc
matproj.asm: common.inc
matteuler.asm: common.inc
mattranspose.asm: common.inc
matveuler.asm: common.inc
multfloatmap.asm: common.inc
perlin.asm: common.inc
rmap.asm: common.inc
seedvec.asm: common.inc
sstep.asm: common.inc
terrain.asm: common.inc
veccross.asm: common.inc
vecdot.asm: common.inc
veclength.asm: common.inc
vecmultmat.asm: common.inc
vecnormal.asm: common.inc
warpfmap.asm: common.inc

../out/%.obj: %.asm
	nasm -I.. -f win32 -g $^ -o $@
../out/math.lib: $(OBJS)
	lib /NOLOGO /OUT:$@ /NODEFAULTLIB $^
