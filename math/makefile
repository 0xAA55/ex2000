OBJ_DIR:=../out
SRCS=$(wildcard *.asm)
OBJS=$(patsubst %.asm, $(OBJ_DIR)/%.obj, $(SRCS))
DEFS:=
ASMFLAGS=

%.inc:
	copy $@+

%.asm:
	copy $@+

all: ../out/math.lib
../loaddll.inc: ../frame.inc
common.inc: ../math.inc ../pool.inc ../loaddll.inc
bitmapblt.asm: common.inc
bitmapdup.asm: common.inc
bitmappool.asm: common.inc
dmap.asm: common.inc
floatmapclamp.asm: common.inc
floatmapcurve.asm: common.inc
floatmapdiv.asm: common.inc
floatmapgain.asm: common.inc
floatmapmax.asm: common.inc
floatmapmin.asm: common.inc
mateuler.asm: common.inc
math.asm: common.inc
matmult.asm: common.inc
matproj.asm: common.inc
matteuler.asm: common.inc
mattranspose.asm: common.inc
matveuler.asm: common.inc
multfloatmap.asm: common.inc
perlin.asm: common.inc
raymarch.asm: common.inc
rmap.asm: common.inc
seedvec.asm: common.inc
sstep.asm: common.inc
terrain.asm: common.inc
veccross.asm: common.inc
vecdot.asm: common.inc
veclength.asm: common.inc
vecmultmat.asm: common.inc
vecnormal.asm: common.inc
vfmap: common.inc
warpbitmap.asm: common.inc

$(OBJ_DIR)/%.obj: %.asm
	if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
	nasm -I.. -f win32 -g $(DEFS) $(ASMFLAGS) $^ -o $@
$(OBJ_DIR)/math.lib: $(OBJS)
	lib /NOLOGO /OUT:$@ /NODEFAULTLIB $^
