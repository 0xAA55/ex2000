OUT_DIR:=../out
SRCS=$(wildcard *.asm)
OBJS=$(patsubst %.asm, $(OUT_DIR)/%.obj, $(SRCS))
DEFS:=
ASMFLAGS=-i..

../%.inc:
	copy /b ..\\$(notdir $@)+ >nul 2>&1
%.inc:
	copy /b $@+ >nul 2>&1
%.asm:
	copy /b $@+ >nul 2>&1

all: ../out/math.lib
../loaddll.inc: ../frame.inc ../expfuncs.tmp
common.inc: ../math.inc ../pool.inc ../loaddll.inc
bitmapblt.asm: common.inc
math.asm: common.inc
vfmap: common.inc

$(OUT_DIR)/%.obj: %.asm
	if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm -f win32 -g $(DEFS) $(ASMFLAGS) $^ -o $@
$(OUT_DIR)/math.lib: $(OBJS)
	lib /NOLOGO /OUT:$@ /NODEFAULTLIB $^
