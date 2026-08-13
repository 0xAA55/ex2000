OUT_DIR:=../out
SRCS=$(filter-out shellcode.asm, $(wildcard *.asm))
INCS=$(wildcard *.inc)
BINS=$(patsubst %.asm, %.bin, $(SRCS))
DEFS:=
ASMFLAGS=-i..

%.inc:
	copy $@+ >nul 2>&1

%.asm: common.inc
	copy $@+ >nul 2>&1

%.bin: %.asm
	if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	nasm $(DEFS) $(ASMFLAGS) $^ -o $@

all: shellcode.bin
shellcode.asm: $(BINS) $(INCS) ../shellcode.inc
../shellcode.inc: ../scfuncs.tmp ../glfuncs.tmp
../loaddll.inc: ../frame.inc ../expfuncs.tmp
lfuimpl.inc: common.inc ../lfu.inc ../avlbst.inc
common.inc: ../frame.inc ../math.inc ../shellcode.inc

clean:
	del /f /q *.bin
