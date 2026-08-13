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
../loaddll.inc: ../frame.inc ../expfuncs.tmp
common.inc: ../math.inc ../pool.inc ../loaddll.inc
bitmapblt.asm: common.inc
bitmapdup.asm: common.inc
bitmappool.asm: common.inc
math.asm: common.inc
raymarch.asm: common.inc
vfmap: common.inc

$(OBJ_DIR)/%.obj: %.asm
	if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
	nasm -I.. -f win32 -g $(DEFS) $(ASMFLAGS) $^ -o $@
$(OBJ_DIR)/math.lib: $(OBJS)
	lib /NOLOGO /OUT:$@ /NODEFAULTLIB $^
