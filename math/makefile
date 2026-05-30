OBJ_DIR=../out
SRCS=$(wildcard *.asm)
OBJS=$(patsubst %.asm, $(OBJ_DIR)/%.obj, $(SRCS))

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

$(OBJ_DIR)/%.obj: %.asm
	if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
	nasm -I.. -f win32 -g $^ -o $@
$(OBJ_DIR)/math.lib: $(OBJS)
	lib /NOLOGO /OUT:$@ /NODEFAULTLIB $^
